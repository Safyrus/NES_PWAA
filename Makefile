
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
	-rm -f $(C)/a
	-rm -f $(C)/CHR.chr
	-rm -f "$(ANIM_0)"
	-rm -f "$(ANIM_1)"
	-rm -f "$(ANIM_2)"
	-rm -f "$(ANIM_3)"
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
	$(PYTHON) $(PY)/txtEncode/fusionFiles.py data/text/pwaa $(TEXT)
	mkdir -p "$(ASM)/data"
	cd $(ASM)/data && $(PYTHON) ../../$(PY)/txtEncode/txt_2_bin.py ../../$(TEXT) ./text.bin 1
	cd $(ASM)/data && $(PYTHON) ../../$(PY)/txtEncode/lz_encode_block.py ./text.bin ./text.bin


#--------------------------------

img:
# make images and anims
	$(PYTHON) $(PY)/img/all2nes.py -if $(DATA)/img -sf $(DATA)/snif -of $(ASM)/data/img
# merge FONT and images tiles
	$(PYTHON) $(PY)/chr/merge_chr.py $(DATA)/FONT.chr $(ASM)/data/img/all.chr -o PWAA.chr
# make photo
# 	cd $(PY)/imgEncoder && $(PYTHON) encode_photo.py \
# 	-i ../../$(EVIDENCE) \
# 	-o ../../$(ASM)/data/evidences.bin \
# 	-c ../../$(DATA)/EVI.chr \
# 	-b 2


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
