@echo off

:start
CLS
echo Choose what to make:
echo - [D]ata    : all game resources
echo - [N]es     : the NES files
echo - [A]ll     : the two above
echo - [R]un     : run the game
echo - [T]ext    : text data
echo - [F]ont    : font data
echo - [I]mage   : images data
echo - [C] code  : execute c code for image data
echo - [M]usic   : music and sfx data
echo - d[O]c     : code documentation
echo - [V]isual  : convert the NES file into a PNG
echo - [H]exdump : dump the NES file into a txt
echo - c[L]ean   : clean generated files
echo - [E]xit    : do nothing

choice /c dnartficmovhle /n /m ">"
if %errorlevel% EQU 1 goto data
if %errorlevel% EQU 2 goto nes
if %errorlevel% EQU 3 goto all
if %errorlevel% EQU 4 goto run
if %errorlevel% EQU 5 goto text
if %errorlevel% EQU 6 goto font
if %errorlevel% EQU 7 goto image
if %errorlevel% EQU 8 goto img_c
if %errorlevel% EQU 9 goto music
if %errorlevel% EQU 10 goto doc
if %errorlevel% EQU 11 goto visual
if %errorlevel% EQU 12 goto hexdump
if %errorlevel% EQU 13 goto clean
if %errorlevel% EQU 14 goto exit


:data
echo data
start /WAIT /B make -s resource
goto continue
:nes
start /WAIT /B make -s nes
goto continue
:all
start /WAIT /B make -s all
goto continue
:run
start /WAIT /B make -s run
goto continue
:text
start /WAIT /B make -s text
goto continue
:font
start /WAIT /B make -s font
goto continue
:image
start /WAIT /B make -s img
goto continue
:img_c
start /WAIT /B make -s img_c
goto continue
:music
start /WAIT /B make -s music
goto continue
:doc
start /WAIT /B make -s gendoc
goto continue
:visual
start /WAIT /B make -s visual
goto continue
:hexdump
start /WAIT /B make -s hex
goto continue
:clean
start /WAIT /B make -s clean
goto continue
:exit
exit

:continue
echo Done. Continue ?
choice /m ">"
if %errorlevel% EQU 1 goto start
exit
