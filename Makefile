
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


# create the nes file from assembler sources
$(GAME_NAME).nes:
# create folder if it does not exist
ifeq ($(OS), Windows_NT)
	@-if not exist "$(BIN)" ( mkdir "$(BIN)" )
else
	mkdir -p "$(BIN)"
endif
# assemble main file
	$(CA65) asm/crt0.asm -o $(BIN)/$(GAME_NAME).o --debug-info -DFAMISTUDIO=$(FAMISTUDIO) -DMMC5=1
# link files
	$(LD65) $(BIN)/$(GAME_NAME).o -C link.cfg -o $(GAME_NAME).nes --dbgfile $(GAME_NAME).dbg


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
	del $(GAME_NAME).nes
	del $(GAME_NAME).DBG
	del dump_$(GAME_NAME).txt
else
	rm -f $(GAME_NAME).nes
	rm -f $(GAME_NAME).DBG
	rm -f dump_$(GAME_NAME).txt
endif


# run the nes game generated with assembler sources
run:
	$(EMULATOR) $(GAME_NAME).nes


# dump the nes files binary into hexa text
hex:
	$(HEXDUMP) $(GAME_NAME).nes > dump_$(GAME_NAME).txt