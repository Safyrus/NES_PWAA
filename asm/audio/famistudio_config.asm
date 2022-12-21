;----------------------------------------
; FamiStudio Sound Engine configuration
;----------------------------------------

    ;----------------------------------------
    ; You don't need to edit this
    ;----------------------------------------
    FAMISTUDIO_CFG_EXTERNAL=1
    .ifdef C_CODE
    FAMISTUDIO_CFG_C_BINDINGS = 1
    .endif

    ;----------------------------------------
    ; Segments Configuration (You don't need to edit this too)
    ;----------------------------------------
    .define FAMISTUDIO_CA65_ZP_SEGMENT   ZEROPAGE
    .define FAMISTUDIO_CA65_RAM_SEGMENT  BSS
    .define FAMISTUDIO_CA65_CODE_SEGMENT CODE
    ;----------------------------------------


    ; Audio Expansions (ONLY 0 OR 1 MUST BE ENABLE)
    ;----------------------------------------
    ; Konami VRC6 (2 extra square + saw)
    FAMISTUDIO_EXP_VRC6          = 0
    ; Konami VRC7 (6 FM channels)
    FAMISTUDIO_EXP_VRC7          = 0
    ; Nintendo MMC5 (2 extra squares, extra DPCM not supported)
    FAMISTUDIO_EXP_MMC5          = MMC5
    ; Sunsoft S5B (2 extra squares, advanced features not supported.)
    FAMISTUDIO_EXP_S5B           = 0
    ; Famicom Disk System (extra wavetable channel)
    FAMISTUDIO_EXP_FDS           = 0
    ; Namco 163 (between 1 and 8 extra wavetable channels) + number of channels.
    FAMISTUDIO_EXP_N163          = 0
    FAMISTUDIO_EXP_N163_CHN_CNT  = 4
    ;----------------------------------------


    ; Global Engine Configuration
    ;----------------------------------------
    ; One of these MUST be defined (PAL or NTSC playback). 
    ; Note that only NTSC support is supported when using any of the audio expansions.
    FAMISTUDIO_CFG_PAL_SUPPORT   = 0
    FAMISTUDIO_CFG_NTSC_SUPPORT  = 1

    ; Support for sound effects playback + number of SFX that can play at once.
    FAMISTUDIO_CFG_SFX_SUPPORT   = 1
    FAMISTUDIO_CFG_SFX_STREAMS   = 2

    ; Blaarg's smooth vibrato technique. Eliminates phase resets ("pops") on
    ; square channels. 
    FAMISTUDIO_CFG_SMOOTH_VIBRATO = 0

    ; Enables DPCM playback support.
    FAMISTUDIO_CFG_DPCM_SUPPORT   = 1

    ; Must be enabled if you are calling sound effects from a different 
    ; thread than the sound engine update.
    FAMISTUDIO_CFG_THREAD         = 1
    ;----------------------------------------


    ; Supported Features Configuration
    ;----------------------------------------
    ; Must be enabled if the songs you will be importing have been created using FamiTracker tempo mode. 
    ; If you are using FamiStudio tempo mode, this must be undefined. You cannot mix and match tempo modes, 
    ; the engine can only run in one mode or the other. 
    ; More information at: https://famistudio.org/doc/song/#tempo-modes
    ; FAMISTUDIO_USE_FAMITRACKER_TEMPO = 1

    ; Must be enabled if the songs uses delayed notes or delayed cuts. This is obviously only available when using
    ; FamiTracker tempo mode as FamiStudio tempo mode does not need this.
    ; FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS = 1

    ; Must be enabled if any song uses the volume track. The volume track allows manipulating the volume at the track
    ; level independently from instruments.
    ; More information at: https://famistudio.org/doc/pianoroll/#editing-volume-tracks-effects
    FAMISTUDIO_USE_VOLUME_TRACK      = 0

    ; Must be enabled if any song uses slides on the volume track. Volume track must be enabled too.
    ; More information at: https://famistudio.org/doc/pianoroll/#editing-volume-tracks-effects
    FAMISTUDIO_USE_VOLUME_SLIDES     = 0

    ; Must be enabled if any song uses the pitch track. The pitch track allows manipulating the pitch at the track
    ; level independently from instruments.
    ; More information at: https://famistudio.org/doc/pianoroll/#pitch
    FAMISTUDIO_USE_PITCH_TRACK       = 0

    ; Must be enabled if any song uses slide notes. Slide notes allows portamento and slide effects.
    ; More information at: https://famistudio.org/doc/pianoroll/#slide-notes
    FAMISTUDIO_USE_SLIDE_NOTES       = 0

    ; Must be enabled if any song uses slide notes on the noise channel too. 
    ; More information at: https://famistudio.org/doc/pianoroll/#slide-notes
    FAMISTUDIO_USE_NOISE_SLIDE_NOTES = 0

    ; Must be enabled if any song uses the vibrato speed/depth effect track. 
    ; More information at: https://famistudio.org/doc/pianoroll/#vibrato-depth-speed
    FAMISTUDIO_USE_VIBRATO           = 0

    ; Must be enabled if any song uses arpeggios (not to be confused with instrument arpeggio envelopes, those 
    ; are always supported).
    ; More information at: (TODO)
    FAMISTUDIO_USE_ARPEGGIO          = 0

    ; Must be enabled if any song uses the "Duty Cycle" effect (equivalent of FamiTracker Vxx, also called "Timbre").  
    FAMISTUDIO_USE_DUTYCYCLE_EFFECT  = 0
    ;----------------------------------------
