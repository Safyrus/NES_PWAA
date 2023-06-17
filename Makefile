
# All configuration vairables are located in the config file

CONFIG = cfg/make_default.cfg

# ! - - - - - - - - - - - - - - - - ! #
#  DO NOT CHANGE ANYTHING AFTER THIS  #
# ! - - - - - - - - - - - - - - - - ! #
include ${CONFIG}


# make the nes game from assembler files
all:
	make clean_all
	make $(GAME_NAME).nes
	make $(GAME_NAME)_ines1.nes


# create the nes file from assembler sources
$(GAME_NAME).nes:
# create folder if it does not exist
ifeq ($(OS), Windows_NT)
	@-if not exist "$(BIN)" ( mkdir "$(BIN)" )
else
	mkdir -p "$(BIN)"
endif
# assemble main file
	$(CA65) $(ASM)/crt0.asm -o $(BIN)/$(GAME_NAME).o --debug-info
# link files
	$(LD65) $(BIN)/$(GAME_NAME).o -C link.cfg -o $(GAME_NAME).nes --dbgfile $(GAME_NAME).dbg


# create the nes file from assembler sources (Ines 1.0 version)
$(GAME_NAME)_ines1.nes:
# create folder if it does not exist
ifeq ($(OS), Windows_NT)
	@-if not exist "$(BIN)" ( mkdir "$(BIN)" )
else
	mkdir -p "$(BIN)"
endif
# assemble main file
	$(CA65) $(ASM)/crt0.asm -o $(BIN)/$(GAME_NAME)_ines1.o --debug-info -DINES1
# link files
	$(LD65) $(BIN)/$(GAME_NAME)_ines1.o -C link.cfg -o $(GAME_NAME)_ines1.nes --dbgfile $(GAME_NAME)_ines1.dbg


# clean object files
clean:
ifeq ($(OS), Windows_NT)
	@-if exist "$(BIN)" ( rmdir /Q /S "$(BIN)" )
else
	rm -rf "$(BIN)"
endif


# clean all generated files
clean_all:
	make clean
ifeq ($(OS), Windows_NT)
	del "$(GAME_NAME).nes"
	del "$(GAME_NAME)_ines1.nes"
	del "$(GAME_NAME).DBG"
	del "dump_$(GAME_NAME).txt"
else
	rm -f $(GAME_NAME).nes
	rm -f $(GAME_NAME).DBG
	rm -f dump_$(GAME_NAME).txt
endif

clean_data:
ifeq ($(OS), Windows_NT)
	del "$(DATA)\EVI.chr"
	del "$(DATA)\tmp.chr"
	del "$(C)\a.exe"
	del "$(C)\CHR.chr"
	del "$(ASM)\data" /s /q
else
	rm -f $(DATA)/EVI.chr
	rm -f $(DATA)/tmp.chr
	rm -f $(C)/a
	rm -f $(C)/CHR.chr
	rm -f -r "$(ASM)/data"
endif


# run the nes game generated with assembler sources
run:
	$(EMULATOR) $(GAME_NAME).nes


# dump the nes files binary into hex text
hex:
	$(HEXDUMP) $(GAME_NAME).nes > dump_$(GAME_NAME).txt


text:
ifeq ($(OS), Windows_NT)
	@-if not exist "$(ASM)/data" ( mkdir "$(ASM)/data" )
else
	mkdir -p "$(ASM)/data"
endif
	cd $(ASM)/data && $(PYTHON) ../../$(PY)/txtEncode/txt_2_bin.py ../../$(TEXT) ./text.bin
	cd $(ASM)/data && $(PYTHON) ../../$(PY)/txtEncode/lz_encode_block.py ./text.bin ./text.bin

img:
	make photo
	$(PYTHON) $(PY)/merge_chr.py $(DATA)/FONT.chr $(DATA)/EVI.chr -o $(DATA)/tmp.chr
ifeq ($(OS), Windows_NT)
	@-if not exist "$(ASM)/data" ( mkdir "$(ASM)/data" )
else
	mkdir -p "$(ASM)/data"
endif
	cd c && make
	cd $(ASM)/data && $(PYTHON) ../../$(PY)/imgEncoder/encode_region.py \
	-i ../../$(ANIM_0) ../../$(ANIM_1) ../../$(ANIM_2) ../../$(ANIM_3) \
	-bc ../../$(DATA)/tmp.chr -cp ../../c/ -oc ../../PWAA.chr

photo:
	cd $(PY)/imgEncoder && $(PYTHON) encode_photo.py \
	-i ../../$(EVIDENCE) \
	-o ../../$(ASM)/data/evidences.bin \
	-c ../../$(DATA)/EVI.chr \
	-b 2

visual:
	$(PYTHON) $(PY)/bin2img.py $(GAME_NAME).nes visual.png NES 2048

gendoc:
ifeq ($(OS), Windows_NT)
	@-if not exist "doc/html" ( mkdir "doc/html" )
else
	mkdir -p "doc/html"
endif
	$(NATURALDOC) "cfg/nd"
