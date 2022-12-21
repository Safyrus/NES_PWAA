
# All configuration vairables are located in the config file

CONFIG = cfg/make_default.cfg

# ! - - - - - - - - - - - - - - - - ! #
#  DO NOT CHANGE ANYTHING AFTER THIS  #
# ! - - - - - - - - - - - - - - - - ! #
include ${CONFIG}


# make the nes game from assembler files
all: $(GAME_NAME).nes
	make clean


# create the nes file from assembler sources
$(GAME_NAME).nes:
# create folder if it does not exist
	@-if not exist "$(BIN)" ( mkdir "$(BIN)" )
# assemble main file
	$(CA65) asm/crt0.asm -o $(BIN)/$(GAME_NAME).o --debug-info -DFAMISTUDIO=$(FAMISTUDIO) -DMMC5=1
# link files
	$(LD65) $(BIN)/$(GAME_NAME).o -C link.cfg -o $(GAME_NAME).nes --dbgfile $(GAME_NAME).DBG


# clean object files
clean:
	@-if exist "$(BIN)" ( rmdir /Q /S "$(BIN)" )


# clean all generated files
clean_all:
	make clean
	del $(GAME_NAME).nes
	del $(GAME_NAME).DBG
	del dump_$(GAME_NAME).txt


# run the nes game generated with assembler sources
run:
	$(EMULATOR) $(GAME_NAME).nes


# dump the nes files binary into hexa text
hex:
	$(HEXDUMP) $(GAME_NAME).nes > dump_$(GAME_NAME).txt