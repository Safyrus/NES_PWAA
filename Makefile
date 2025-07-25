
# All configuration vairables are located in the config file

CONFIG = cfg/make_default.cfg

# ! - - - - - - - - - - - - - - - - ! #
#  DO NOT CHANGE ANYTHING AFTER THIS  #
# ! - - - - - - - - - - - - - - - - ! #
include ${CONFIG}


#--------------------------------

# make the nes game from assembler files
all:
	make clean_bin
	make $(GAME_NAME).nes
	make $(GAME_NAME)_ines1.nes

resource:
	make clean_data
	make clean_tmp
	make text
	make img
	make clean_tmp

#--------------------------------

# create the nes file from assembler sources
$(GAME_NAME).nes:
# create folder if it does not exist
	mkdir -p "$(BIN)"
# assemble main file
	$(CA65) $(ASM)/crt0.asm -o $(BIN)/$(GAME_NAME).o --debug-info
# link files
	$(LD65) $(BIN)/$(GAME_NAME).o -C link.cfg -o $(GAME_NAME).nes --dbgfile $(GAME_NAME).dbg


# create the nes file from assembler sources (Ines 1.0 version)
$(GAME_NAME)_ines1.nes:
# create folder if it does not exist
	mkdir -p "$(BIN)"
# assemble main file
	$(CA65) $(ASM)/crt0.asm -o $(BIN)/$(GAME_NAME)_ines1.o --debug-info -DINES1
# link files
	$(LD65) $(BIN)/$(GAME_NAME)_ines1.o -C link.cfg -o $(GAME_NAME)_ines1.nes --dbgfile $(GAME_NAME)_ines1.dbg


#--------------------------------

# clean all generated files
clean:
	make clean_bin
	make clean_data
	make clean_tmp


# clean object and binary files
clean_bin:
	-rm -rf "$(BIN)"
	-rm -f $(GAME_NAME)*.nes
	-rm -f $(GAME_NAME)*.DBG
	-rm -f dump_$(GAME_NAME)*.txt

# clean/remove data folder
clean_data:
	-rm -f -r "$(ASM)/data"

# clean temporary files
clean_tmp:
	-rm -f $(DATA)/EVI.chr
	-rm -f $(DATA)/tmp.chr
	-rm -f $(DATA)/FONT.chr
	-rm -f $(C)/a
	-rm -f $(C)/CHR.chr
	-rm -f "$(ASM)/data/img/all.chr"
	-rm -f "$(ASM)/data/img/r0.snif"
	-rm -f "$(ASM)/data/img/r1.snif"
	-rm -f "$(ASM)/data/img/r2.snif"
	-rm -f "$(ASM)/data/img/r3.snif"
	-rm -f "tmp.png"


#--------------------------------

# run the nes game generated with assembler sources
run:
	$(EMULATOR) $(GAME_NAME).nes


#--------------------------------

text:
	mkdir -p "$(ASM)/data"
	$(PYTHON) $(PY)/txtEncode/txt_2_bin.py -i $(TEXT_MAIN) -o $(ASM)/data/text.bin
	cd $(ASM)/data && $(PYTHON) ../../$(PY)/txtEncode/lz_encode_block.py ./text.bin ./text.bin


#--------------------------------

font:
# make FONT chr
	$(PYTHON) $(PY)/img/build_font.py -if $(DATA)/font -in $(DATA)/name -oc $(DATA)/FONT.chr -on $(ASM)/data/name.asm -of $(ASM)/data/font.asm -ot $(TEXT)/name.txt -or $(DATA)/BASE.chr

img:
	make font
# convert images, anims and photos to snif files
	$(PYTHON) $(PY)/img/all2snif.py -if $(DATA)/img -sf $(DATA)/snif
	make img_c

img_c:
# merge all snif files & CHR into binary files
	cd $(C) && make && ./merge_snif ../$(DATA)/snif ../$(DATA)/FONT.chr ../$(DATA)/BASE.chr 33 ../PWAA.chr ../$(ASM)/data/img
#
	$(PYTHON) $(PY)/img/img_name.py -i $(ASM)/data/img -o $(TEXT)


#--------------------------------

music:
	$(PYTHON) $(PY)/snd/all.py -fs $(FAMISTUDIO) -i $(DATA)/$(MUSIC) -o $(ASM)/data/mus -mt $(TEXT)/music.txt -st $(TEXT)/sfx.txt

#--------------------------------

# dump the nes files binary into hex text
hex:
	$(HEXDUMP) $(GAME_NAME).nes > dump_$(GAME_NAME).txt

# generate an image of the nes file
visual:
	$(PYTHON) $(PY)/bin2img.py $(GAME_NAME).nes visual.png NES 2048

# generate the documentation
gendoc:
	mkdir -p "doc/html"
	$(NATURALDOC) "cfg/nd"
