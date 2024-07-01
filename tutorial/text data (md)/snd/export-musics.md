# Exporting sounds

TODO: make a script to export musics automatically. (famistudio.exe -help)

## Musics

TODO

- choose export with FamiStudio
- export musics in multiple bank of 8KB max
- edit data.asm list to match music index
- edit link.cfg and data.asm to add more banks

## SFX

TODO

Famistudio ->
export ->
FamiStudio SFX Code ->
Format:CA65, Mode:NTSC, choose sfx to export ->
export to `asm/audio/sfx.s` ->
make sure it does not go over 8KB

order of SFX in FamiStudio = order of SFX in code
(SFX 0 = first SFX, SFX 1 = second SFX, ...)
