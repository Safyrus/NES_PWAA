;**********
; Memory
;**********

; - - - - - - - -
; Layout
; - - - - - - - -
; 
; - NES Memory:
;   Page | Description
;   $00 | Zero page (NMI, tmp & other variables)
;   $01 | Stack
;   $02 | OAM (sprites)
;   $03 | Famistudio
;   $04 | Famistudio
;   $05 | Game
;   $06 | Game
;   $07 | unused
; 
; - MMC5 Memory Bank (TEXT_BUF_BNK):
;   $0000-$1FFF = 8K decoded text buffer
; 
; - MMC5 Memory Bank (IMG_BUF_BNK):
;   $0000-$02FF = decoded character image (low)
;   $0300-$05FF = decoded character image (high)
;   $0600-$08FF = decoded character sprites
;   $0900-$0BFF = decoded background image (low)
;   $0C00-$0EFF = decoded background image (high)
;   $0F00-$1FFF = unused


;****************
; ZEROPAGE SEGMENT
;****************
.segment "ZEROPAGE"
    ; NMI Flags to activate graphical update
    ; Note: You cannot activate all updates.
    ;       You need to have a execution time
    ;       < ~2273 cycles (2000 to be sure)
    ; 7  bit  0
    ; ---- ----
    ; EFJR PASB
    ; |||| ||||
    ; |||| |||+- Background tiles update
    ; |||| |||   Execution time depend on data
    ; |||| |||   (cycles ~= 16 + 38*p + for i:p do (14*p[i].n))
    ; |||| |||   (p=packet number, p[i].n = packet data size)
    ; |||| ||+-- Sprites update (513+ cycles)
    ; |||| |+--- Nametables attributes update (821 cycles)
    ; |||| +---- Palettes update (356 cycles)
    ; |||+------ Scroll update (31 cycles)
    ; ||+------- Jump to specific subroutine
    ; |+-------- Force NMI acknowledge
    ; +--------- 1 when NMI has ended, should be set to 0 after reading.
    ;            If let to 1, it means the NMI is disable
    nmi_flags: .res 1

    ; Scroll X position
    scroll_x: .res 1

    ; Scroll Y position
    scroll_y: .res 1

    ; Nametable high adress to update attributes for
    ; $23 = Nametable 1
    ; $27 = Nametable 2
    ; $2B = Nametable 3
    ; $2F = Nametable 4
    atr_nametable: .res 1
    
    ; value of the PPUCTRL register (need to be refresh manually)
    ppu_ctrl_val: .res 1

    ; pointer to current text to read
    txt_rd_ptr: .res 2

    ; Palettes data to send to PPU during VBLANK
    ;   byte 0   = transparente color
    ;   byte 1-3 = background palette 1
    ;   byte 4-6 = background palette 2
    ;   ...
    ;   byte 13-16 = sprite palette 1
    ;   ...
    palettes: .res 25

    ; Attributes data to send to PPU during VBLANK
    ; attributes: .res 0

    ; Index for the background data
    ; FIII IIII
    ; |+++-++++-- Index
    ; +---------- A flag to tell that you are currently writing to the background buffer.
    ;             If it is already set, you must wait for it to be cleared.
    background_index: .res 1

    ; Background data to send to PPU during VBLANK
    ; Packet structure:
    ; byte 0   = vsssssss (v= vertical draw, s= size)
    ; byte 1-2 = ppu adress (most significant byte, least significant byte)
    ; byte 3-s = tile data
    ; packet of size 0 means there is no more data to draw
    background: .res $60-1

    ; temporary variables
    tmp: .res 12

;****************
; OAM SEGMENT
;****************
.segment "OAM"
OAM:


;****************
; BSS SEGMENT
;****************
.segment "BSS"

    ; - - - - - - - -
    ; Player input variables
    ; - - - - - - - -
        ; player 1 inputs
        buttons_1: .res 1
        ; timer before processing any input of player 1
        buttons_1_timer: .res 1

    ; - - - - - - - -
    ; Scanline state
    ; - - - - - - - -
        ; WFSS SSSS
        ; ||++-++++-- scanline IRQ state
        ; |+--------- 1 = in frame, 0 = in vblank
        ; +---------- wait for scanline, cleare when scanline IRQ occured
        scanline: .res 1

    ; - - - - - - - -
    ; Music and sound variables
    ; - - - - - - - -
        ; music to play
        music: .res 1
        ; sound effect to play
        sound: .res 1
        ; bip sound to play when text is draw
        bip: .res 1

    ; - - - - - - - -
    ; Visual effect variables
    ; - - - - - - - -
        ; P.UD BN.F
        ; | || || +-- Fade in (1) or out (0)
        ; | || |+---- current Nametable (0=left, 1=right)
        ; | || +----- redraw Background
        ; | |+------- currently Drawing the background
        ; | +-------- update background Upper tiles when drawing a partial frame
        ; +---------- mid frame Pallette switch for the dialog box (1=active)
        effect_flags: .res 1
        ; time remaining before the end of the fade effect
        fade_timer: .res 1
        ; time remaining before the end of the flash effect
        flash_timer: .res 1
        ; time remaining before the end of the shake effect
        shake_timer: .res 1
        ; D... ..NR
        ; |      |+-- Refresh box (1=refresh, 0=redraw)
        ; |      +--- refresh box Name
        ; +---------- Display box (0=show, 1=hidden)
        box_flags: .res 1

    ; - - - - - - - -
    ; Variables for LZ decoding
    ; - - - - - - - -
        ; pointer to input data
        lz_in: .res 2
        ; bank to use for input data
        lz_in_bnk: .res 1
        ; index to use for fetching data in lz tables
        lz_idx: .res 1

    ; - - - - - - - -
    ; Variables for text reading
    ; - - - - - - - -
        ; first byte of flags
        ; RSPZ BFIW
        ; |||| |||+-- Wait for user input to continue
        ; |||| ||+--- Player input
        ; |||| |+---- Force action (ignore player inputs)
        ; |||| +----- Wait for dialog box drawing
        ; |||+------- Wait for LZ decoding
        ; ||+-------- Wait for print
        ; |+--------- Skip to end of dialog
        ; +---------- Ready (set to 1 to enable read subroutines)
        txt_flags: .res 1
        ; speed of text
        txt_speed: .res 1
        ; speed counter
        txt_speed_count: .res 1
        ; delay to wait
        txt_delay: .res 1
        ; index of the current font
        txt_font: .res 1
        ;
        txt_bck_color: .res 1
        ;
        txt_jump_buf: .res 3
        ;
        txt_jump_flag_buf: .res 1
        ; pointer to the last dialog (0=lo, 1=hi, 2=bnk)
        txt_last_dialog_adr: .res 3
        ; saved pointer to jump back to when using a RET char
        txt_save_adr: .res 3

    ; - - - - - - - -
    ; Variables for name displaying
    ; - - - - - - - -
        ; index of the name of the current dialog
        name_idx: .res 1
        ; low address for name CHR data
        name_adr: .res 1
        ; size in CHR tiles of the name
        name_size: .res 1


    ; - - - - - - - -
    ; Court Record Variables
    ; - - - - - - - -
        ; .... .PAS
        ;       |||
        ;       ||+-- is Show
        ;       |+--- can Access
        ;       +---- can Present
        cr_flag: .res 1
        ; current evidence selected
        cr_idx: .res 1
        ; current evidence selected
        cr_correct_idx: .res 1
        ; array of flag to determine which evidences is obtained
        evidence_flags: .res 16

    ; - - - - - - - -
    ; Variables for text printing
    ; - - - - - - - -
        ; Value to send to MMC5 expansion RAM when printing text
        print_ext_val: .res 1
        ; pointer to current printed text in ext ram
        print_ext_ptr: .res 2
        ; pointer to current printed text in ppu
        print_ppu_ptr: .res 2
        ; number of character to print
        print_counter: .res 1
        ; offset to add to the text position (ppu+ext) when drawing a new line to the screen
        print_nl_offset: .res 1
        ; buffer containing text to print to ppu
        print_ppu_buf: .res 32
        ; buffer containing text to print to ext ram
        print_ext_buf: .res 32

    ; - - - - - - - -
    ; Image Variables
    ; - - - - - - - -
        ; photo/evidence to show
        img_photo: .res 1
        ; background image to display
        img_background: .res 1
        ; character animation index
        img_anim:
            ; character image to display
            img_character: .res 1
            ; character animation image to display
            img_animation: .res 1
        ; length of img_partial_buf
        img_partial_buf_len: .res 1
        ; data buffer of the partial image to send to PPU
        img_partial_buf: .res IMG_PARTIAL_MAX_BUF_LEN

    ; - - - - - - - -
    ; Animation Variables
    ; - - - - - - - -
        ; pointer to the base of the current animation data
        anim_base_adr: .res 2
        ; pointer to the current animation data
        anim_adr: .res 2
        ; current animation frame index
        anim_img_counter: .res 1
        ; remaining game frame before the next animation frame
        anim_frame_counter: .res 1

    ; - - - - - - - -
    ; Sprites Variables
    ; - - - - - - - -
        ; img_spr_header:
        ; FPTS ..BB
        ; ||||   ++-- CHR bits for the MMC5 upper CHR Bank bits
        ; |||+------- is Sprite map present ?
        ; ||+-------- is Tile map present ?
        ; |+--------- is Palette present ?
        ; +---------- 1 = Full frame
        ;             0 = partial frame
        img_header: .res 1
        ; width in tiles of the mega sprite
        img_spr_w: .res 1
        ; bank index of the mega sprite
        img_spr_b: .res 1
        ; image mega sprite position offset x
        img_spr_x: .res 1
        ; image mega sprite position offset y
        img_spr_y: .res 1
        ; image number of sprites
        img_spr_count: .res 1

    ; - - - - - - - -
    ; Palette Variables
    ; - - - - - - - -
        ; palettes to use for the background and character
        img_palettes:
            ; background color
            img_palette_bkg: .res 1
            ; background palette
            img_palette_0: .res 3
            ; character primary/background palette
            img_palette_1: .res 3
            ; character contour palette
            img_palette_2: .res 3
            ; character secondary/sprites palette
            img_palette_3: .res 3

    ; - - - - - - - -
    ; Player choice variables
    ; - - - - - - - -
        ; the current choice selected
        choice: .res 1
        ; the maximum number of choice for this dialog
        max_choice: .res 1
        ; pointers to jump to for each choice
        choice_jmp_table: .res 3*4

    ; - - - - - - - -
    ; Other variables
    ; - - - - - - - -
        ; the upper bits of the MMC5 CHR register
        mmc5_upper_chr: .res 1
        ; mmc5 banks to restore (ram,bnk0,bnk1,bnk2)
        mmc5_banks: .res 4
        ; array of flags use to make conditionnal jump in dialogs
        dialog_flags: .res 16
        ; buffer for the X position of sprites
        spr_x_buf: .res 64
