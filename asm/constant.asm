;################
; File: Constants
;################
; List all constants

;================
; Group: PPU
;================

    ; Constants: PPU registers
    ;
    ; PPU_CTRL   - _$2000_ PPU Control register address
    ; PPU_MASK   - _$2001_ PPU Mask register address
    ; PPU_STATUS - _$2002_ PPU Status register address
    ; PPU_SCROLL - _$2005_ PPU Scroll register address
    ; PPU_ADDR   - _$2006_ PPU Addr register address
    ; PPU_DATA   - _$2007_ PPU Data register address
    ; OAMDMA     - _$4014_ OAM DMA register address
    PPU_CTRL   := $2000
    PPU_MASK   := $2001
    PPU_STATUS := $2002
    PPU_SCROLL := $2005
    PPU_ADDR   := $2006
    PPU_DATA   := $2007
    OAMDMA := $4014

    ; Constants: PPU Mask register flags
    ;
    ; PPU_MASK_GREY - _%00000001_ Render as grayscale
    ; PPU_MASK_BKG8 - _%00000010_ Display background in leftmost 8 pixels
    ; PPU_MASK_SPR8 - _%00000100_ Display sprites in leftmost 8 pixels
    ; PPU_MASK_BKG  - _%00001000_ Display background
    ; PPU_MASK_SPR  - _%00010000_ Display sprites
    ; PPU_MASK_R    - _%00100000_ Emphasize red
    ; PPU_MASK_G    - _%01000000_ Emphasize green
    ; PPU_MASK_B    - _%10000000_ Emphasize blue
    PPU_MASK_GREY = %00000001
    PPU_MASK_BKG8 = %00000010
    PPU_MASK_SPR8 = %00000100
    PPU_MASK_BKG  = %00001000
    PPU_MASK_SPR  = %00010000
    PPU_MASK_R    = %00100000
    PPU_MASK_G    = %01000000
    PPU_MASK_B    = %10000000

    ; Constants: PPU Control register flags
    ;
    ; PPU_CTRL_NM_0     - _%00000000_ PPU nametable 0 (top left)
    ; PPU_CTRL_NM_1     - _%00000001_ PPU nametable 1 (top right)
    ; PPU_CTRL_NM_2     - _%00000010_ PPU nametable 2 (bottom left)
    ; PPU_CTRL_NM_3     - _%00000011_ PPU nametable 3 (bottom right)
    ; PPU_CTRL_INC      - _%00000100_ Increment VRAM address by 32
    ; PPU_CTRL_SPR      - _%00001000_ Sprite pattern table address
    ; PPU_CTRL_BKG      - _%00010000_ Background pattern table address
    ; PPU_CTRL_SPR_SIZE - _%00100000_ 8*16 Sprite size
    ; PPU_CTRL_SEL      - _%01000000_ PPU Master/Slave select
    ; PPU_CTRL_NMI      - _%10000000_ Generate an NMI at the start of the Vblank
    PPU_CTRL_NM_0     = %00000000
    PPU_CTRL_NM_1     = %00000001
    PPU_CTRL_NM_2     = %00000010
    PPU_CTRL_NM_3     = %00000011
    PPU_CTRL_INC      = %00000100
    PPU_CTRL_SPR      = %00001000
    PPU_CTRL_BKG      = %00010000
    PPU_CTRL_SPR_SIZE = %00100000
    PPU_CTRL_SEL      = %01000000
    PPU_CTRL_NMI      = %10000000

    ; Constants: PPU Nametable addresses
    ;
    ; PPU_NAMETABLE_0 - _$2000_
    ; PPU_NAMETABLE_1 - _$2400_
    ; PPU_NAMETABLE_2 - _$2800_
    ; PPU_NAMETABLE_3 - _$2C00_
    PPU_NAMETABLE_0 := $2000
    PPU_NAMETABLE_1 := $2400
    PPU_NAMETABLE_2 := $2800
    PPU_NAMETABLE_3 := $2C00



;================
; Group: APU
;================

    ; Constant: APU start address
    ; _$4000_
    APU := $4000

    ; Constants: APU square 1 channel registers
    ;
    ; APU_SQ1_VOL   - _$4000_
    ; APU_SQ1_SWEEP - _$4001_
    ; APU_SQ1_LO    - _$4002_
    ; APU_SQ1_HI    - _$4003_
    APU_SQ1_VOL   := $4000
    APU_SQ1_SWEEP := $4001
    APU_SQ1_LO    := $4002
    APU_SQ1_HI    := $4003

    ; Constants: APU square 2 channel registers
    ;
    ; APU_SQ2_VOL   - _$4004_
    ; APU_SQ2_SWEEP - _$4005_
    ; APU_SQ2_LO    - _$4006_
    ; APU_SQ2_HI    - _$4007_
    APU_SQ2_VOL   := $4004
    APU_SQ2_SWEEP := $4005
    APU_SQ2_LO    := $4006
    APU_SQ2_HI    := $4007

    ; Constants: APU triangle channel registers
    ;
    ; APU_TRI_LINEAR - _$4008_
    ; APU_TRI_LO     - _$400A_
    ; APU_TRI_HI     - _$400B_
    APU_TRI_LINEAR := $4008
    APU_TRI_LO     := $400A
    APU_TRI_HI     := $400B

    ; Constants: APU noise channel registers
    ;
    APU_NOISE_VOL := $400C
    APU_NOISE_LO  := $400E
    APU_NOISE_HI  := $400F

    ; Constants: APU DPCM channel registers
    ;
    APU_DMC_FREQ  := $4010
    APU_DMC_RAW   := $4011
    APU_DMC_START := $4012
    APU_DMC_LEN   := $4013

    ; Constants: APU other registers
    ;
    ; APU_SND_CHN - _$4015_
    ; APU_CTRL    - _$4015_
    ; APU_STATUS  - _$4015_
    ; APU_FRAME   - _$4017_
    APU_SND_CHN := $4015
    APU_CTRL    := $4015
    APU_STATUS  := $4015
    APU_FRAME   := $4017


;================
; Group: IO
;================

    ; Constants: Joypad registers
    ;
    ; IO_JOY1 - _$4016_ Joypad 1 address
    ; IO_JOY2 - _$4017_ Joypad 2 address
    IO_JOY1 := $4016
    IO_JOY2 := $4017

    ; Constants: Button masks
    ; See <buttons_1> variable
    ;
    ; BTN_A      - _%10000000_
    ; BTN_B      - _%01000000_
    ; BTN_SELECT - _%00100000_
    ; BTN_START  - _%00010000_
    ; BTN_UP     - _%00001000_
    ; BTN_DOWN   - _%00000100_
    ; BTN_LEFT   - _%00000010_
    ; BTN_RIGHT  - _%00000001_
    BTN_A      = %10000000
    BTN_B      = %01000000
    BTN_SELECT = %00100000
    BTN_START  = %00010000
    BTN_UP     = %00001000
    BTN_DOWN   = %00000100
    BTN_LEFT   = %00000010
    BTN_RIGHT  = %00000001


;================
; Group: NMI
;================

    ; Constants: NMI vector control flags
    ;
    ; NMI_DONE  - _%10000000_ Signal that NMI has finish. Flag must be clear before another frame is process
    ; NMI_FORCE - _%01000000_ Force NMI acknowledge
    ; NMI_SCRL  - _%00010000_ Send scroll data
    ; NMI_PLT   - _%00001000_ Send palette data
    ; NMI_ATR   - _%00000100_ Send Nametables attributes data
    ; NMI_SPR   - _%00000010_ Send sprites data
    ; NMI_BKG   - _%00000001_ Send background data
    NMI_DONE  = %10000000
    NMI_FORCE = %01000000
    NMI_SCRL  = %00010000
    NMI_PLT   = %00001000
    NMI_ATR   = %00000100
    NMI_SPR   = %00000010
    NMI_BKG   = %00000001


;================
; Group: MMC5
;================

    ; Constant: MMC5 PRG banking mode
    ; address: _$5100_
    MMC5_PRG_MODE  := $5100

    ; Constant: MMC5 CHR banking mode
    ; address: _$5101_
    MMC5_CHR_MODE  := $5101

    ; Constants: MMC5 RAM protection registers
    ;
    ; MMC5_RAM_PRO1 - _$5102_
    ; MMC5_RAM_PRO2 - _$5103_
    MMC5_RAM_PRO1  := $5102
    MMC5_RAM_PRO2  := $5103

    ; Constant: MMC5 Extended RAM mode
    ; address: _$5104_
    MMC5_EXT_RAM   := $5104

    ; Constant: MMC5 Nametable mapping
    ; address: _$5105_
    ;
    ;--- Text
    ; 7  bit  0
    ; ---- ----
    ; DDCC BBAA
    ; |||| ||||
    ; |||| ||++- Select nametable at PPU $2000-$23FF
    ; |||| ++--- Select nametable at PPU $2400-$27FF
    ; ||++------ Select nametable at PPU $2800-$2BFF
    ; ++-------- Select nametable at PPU $2C00-$2FFF
    ;---
    MMC5_NAMETABLE := $5105

    ; Constants: MMC5 Fill nametable registers
    ;
    ; MMC5_FILL_TILE - _$5106_
    ; MMC5_FILL_COL  - _$5107_
    MMC5_FILL_TILE := $5106
    MMC5_FILL_COL  := $5107

    ; Constant: MMC5 RAM Bank
    ; address: _$5113_
    MMC5_RAM_BNK   := $5113

    ; Constants: MMC5 PRG banks control registers
    ;
    ; MMC5_PRG_BNK0  - _$5114_
    ; MMC5_PRG_BNK1  - _$5115_
    ; MMC5_PRG_BNK2  - _$5116_
    ; MMC5_PRG_BNK3  - _$5117_
    MMC5_PRG_BNK0  := $5114
    MMC5_PRG_BNK1  := $5115
    MMC5_PRG_BNK2  := $5116
    MMC5_PRG_BNK3  := $5117

    ; Constants: MMC5 CHR banks control registers
    ;
    ; MMC5_CHR_BNK0  - _$5120_
    ; MMC5_CHR_BNK1  - _$5121_
    ; MMC5_CHR_BNK2  - _$5122_
    ; MMC5_CHR_BNK3  - _$5123_
    ; MMC5_CHR_BNK4  - _$5124_
    ; MMC5_CHR_BNK5  - _$5125_
    ; MMC5_CHR_BNK6  - _$5126_
    ; MMC5_CHR_BNK7  - _$5127_
    ; MMC5_CHR_BNK8  - _$5128_
    ; MMC5_CHR_BNK9  - _$5129_
    ; MMC5_CHR_BNKA  - _$512A_
    ; MMC5_CHR_BNKB  - _$512B_
    ; MMC5_CHR_UPPER - _$5130_
    MMC5_CHR_BNK0  := $5120
    MMC5_CHR_BNK1  := $5121
    MMC5_CHR_BNK2  := $5122
    MMC5_CHR_BNK3  := $5123
    MMC5_CHR_BNK4  := $5124
    MMC5_CHR_BNK5  := $5125
    MMC5_CHR_BNK6  := $5126
    MMC5_CHR_BNK7  := $5127
    MMC5_CHR_BNK8  := $5128
    MMC5_CHR_BNK9  := $5129
    MMC5_CHR_BNKA  := $512A
    MMC5_CHR_BNKB  := $512B
    MMC5_CHR_UPPER := $5130

    ; Constants: MMC5 Vertical Split registers
    ;
    ; MMC5_SPLT_MODE - _$5200_
    ; MMC5_SPLT_SCRL - _$5201_
    ; MMC5_SPLT_BNK  - _$5202_
    MMC5_SPLT_MODE := $5200
    MMC5_SPLT_SCRL := $5201
    MMC5_SPLT_BNK  := $5202

    ; Constants: MMC5 IRQ Scanline counter
    ;
    ; MMC5_SCNL_VAL  - _$5203_
    ; MMC5_SCNL_STAT - _$5204_
    MMC5_SCNL_VAL  := $5203
    MMC5_SCNL_STAT := $5204

    ; Constants: MMC5 multiplier registers
    ;
    ; MMC5_MUL_A - _$5205_
    ; MMC5_MUL_B - _$5206_
    MMC5_MUL_A     := $5205
    MMC5_MUL_B     := $5206

    ; Constant: MMC5 Expansion RAM
    ; address: _$5C00_
    MMC5_EXP_RAM   := $5C00

    ; Constant: MMC5 RAM
    ; address: _$6000_
    MMC5_RAM       := $6000


;================
; Group: Game
;================

    ; Constants: Game ROM Banks
    ;
    ; CODE_BNK - _$80_ Bank containing game code
    ; SFX_BNK  - _$81_ Bank containing SFX sound data
    ; MUS_BNK  - _$82_ Starting bank containing music data
    ; DPCM_BNK - _$84_ Bank containing DPCM sound data
    ; EVI_BNK  - _$85_ Bank containing evidence image data
    ; ANI_BNK  - _$86_ Bank containing animation table
    ; IMG_BNK  - _$89_ Starting bank containing image data
    ; TXT_BNK  - _$C0_ Starting bank containing text data
    CODE_BNK     = $80
    SFX_BNK      = $81
    MUS_BNK      = $82
    DPCM_BNK     = $84
    EVI_BNK      = $85
    ANI_BNK      = $86
    IMG_BNK      = $89
    TXT_BNK      = $BC

    ; Constants: Game RAM Banks
    ;
    ; TEXT_BUF_BNK - _$01_ Bank containg decoded text data
    ; IMG_BUF_BNK  - _$00_ Bank containg decoded image data
    TEXT_BUF_BNK = $01
    IMG_BUF_BNK  = $00

    ; Constants: Dialog box text flags
    ; See: <txt_flags>
    ;
    ; TXT_FLAG_WAIT  - _%00000001_ Wait for an user input
    ; TXT_FLAG_INPUT - _%00000010_ Set if a player input has occured
    ; TXT_FLAG_FORCE - _%00000100_ Force input
    ; TXT_FLAG_BOX   - _%00001000_ Wait for dialog box to be draw
    ; TXT_FLAG_LZ    - _%00010000_ Wait for LZ decoding to finish
    ; TXT_FLAG_PRINT - _%00100000_ Wait for text to be print
    ; TXT_FLAG_SKIP  - _%01000000_ Try to read & display text as fast as possible, skipping animation
    ; TXT_FLAG_READY - _%10000000_ Set when the dialog box is ready
    TXT_FLAG_WAIT  = %00000001
    TXT_FLAG_INPUT = %00000010
    TXT_FLAG_FORCE = %00000100
    TXT_FLAG_BOX   = %00001000
    TXT_FLAG_LZ    = %00010000
    TXT_FLAG_PRINT = %00100000
    TXT_FLAG_SKIP  = %01000000
    TXT_FLAG_READY = %10000000

    ; Constants: Effect flags
    ; See: <effect_flags>
    ;
    ; EFFECT_FLAG_FADE      - _%00000001_
    ; EFFECT_FLAG_NT        - _%00000100_
    ; EFFECT_FLAG_BKG       - _%00001000_
    ; EFFECT_FLAG_DRAW      - _%00010000_
    ; EFFECT_FLAG_BKG_MMC5  - _%00100000_
    ; EFFECT_FLAG_PAL_SPLIT - _%10000000_
    EFFECT_FLAG_FADE      = %00000001
    EFFECT_FLAG_NT        = %00000100
    EFFECT_FLAG_BKG       = %00001000
    EFFECT_FLAG_DRAW      = %00010000
    EFFECT_FLAG_BKG_MMC5  = %00100000
    EFFECT_FLAG_PAL_SPLIT = %10000000

    ; Constants: Dialog box display flags
    ; See: <box_flags>
    ;
    ; BOX_FLAG_HIDE    - _%10000000_
    ; BOX_FLAG_NAME    - _%00000010_
    ; BOX_FLAG_REFRESH - _%00000001_
    BOX_FLAG_HIDE    = %10000000
    BOX_FLAG_NAME    = %00000010
    BOX_FLAG_REFRESH = %00000001

    ; Constants: Dialog box tiles addresses
    ;
    ; BOX_TILE_TL - _$00F1_ Top left tile
    ; BOX_TILE_T  - _$00F2_ Top tile
    ; BOX_TILE_TR - _$00F3_ Top right tile
    ; BOX_TILE_L  - _$00F4_ Left tile
    ; BOX_TILE_M  - _$00F5_ Middle tile
    ; BOX_TILE_R  - _$00F6_ Right tile
    ; BOX_TILE_BL - _$00F7_ Bottom left tile
    ; BOX_TILE_B  - _$00F8_ Bottom tile
    ; BOX_TILE_BR - _$00F9_ Bottom right tile
    ; BOX_UPPER_TILE - _$C0_ MMC5 upper CHR bits
    BOX_TILE_TL = $00F1
    BOX_TILE_T  = $00F2
    BOX_TILE_TR = $00F3
    BOX_TILE_L  = $00F4
    BOX_TILE_M  = $00F5
    BOX_TILE_R  = $00F6
    BOX_TILE_BL = $00F7
    BOX_TILE_B  = $00F8
    BOX_TILE_BR = $00F9
    BOX_UPPER_TILE = $C0

    ; Constants: Scanline flags
    ; See: <scanline>
    ;
    ; SCANLINE_FLAG_WAIT  - _%10000000_ Waiting for scanline
    ; SCANLINE_FLAG_FRAME - _%01000000_ In-frame
    SCANLINE_FLAG_WAIT  = %10000000
    SCANLINE_FLAG_FRAME = %01000000

    ; Constants: Scanline states
    ; See: <scanline>
    ;
    ; SCANLINE_TOP        - _%01000000_
    ; SCANLINE_TOP_IMG    - _%01000001_
    ; SCANLINE_TOP_MIDBOX - _%01000010_
    ; SCANLINE_BOT_MIDBOX - _%01000011_
    ; SCANLINE_DIALOG     - _%01000100_
    ; SCANLINE_BOT_IMG    - _%00000101_
    ; SCANLINE_BOT        - _%00000110_
    SCANLINE_TOP        = %01000000
    SCANLINE_TOP_IMG    = %01000001
    SCANLINE_TOP_MIDBOX = %01000010
    SCANLINE_BOT_MIDBOX = %01000011
    SCANLINE_DIALOG     = %01000100
    SCANLINE_BOT_IMG    = %00000101
    SCANLINE_BOT        = %00000110

    ; Constants: Image header byte flags
    ; See: <img_header>
    ;
    ; IMG_HEADER_CHR  - %00000011 MMC5 CHR upper bits
    ; IMG_HEADER_SPR  - %00010000 Image contain sprite data
    ; IMG_HEADER_BKG  - %00100000 Image contain background data
    ; IMG_HEADER_PAL  - %01000000 Image contain palette data
    ; IMG_HEADER_FULL - %10000000 Image is a full frame
    IMG_HEADER_CHR   = %00000011
    IMG_HEADER_SPR   = %00010000
    IMG_HEADER_BKG   = %00100000
    IMG_HEADER_PAL   = %01000000
    IMG_HEADER_FULL  = %10000000

    ; Constants: Nametable mapping
    ; See: <MMC5 Nametable mapping>
    ;
    ; NT_MAPPING_EMPTY   - _%11111111_
    ; NT_MAPPING_NT1     - _%11110100_
    ; DEFAULT_NT_MAPPING - _NT_MAPPING_EMPTY_
    NT_MAPPING_EMPTY   = %11111111
    NT_MAPPING_NT1     = %11110100
    DEFAULT_NT_MAPPING = NT_MAPPING_EMPTY

    ; Constants: Image buffers addresses
    ;
    ; IMG_CHR_BUF_LO  - _MMC5_RAM+$000_ Buffer for the character low bytes
    ; IMG_CHR_BUF_HI  - _MMC5_RAM+$300_ Buffer for the character high bytes
    ; IMG_CHR_BUF_SPR - _MMC5_RAM+$600_ Buffer for the character sprites
    ; IMG_BKG_BUF_LO  - _MMC5_RAM+$900_ Buffer for the background low bytes
    ; IMG_BKG_BUF_HI  - _MMC5_RAM+$C00_ Buffer for the background high bytes
    IMG_CHR_BUF_LO  = MMC5_RAM + $000
    IMG_CHR_BUF_HI  = MMC5_RAM + $300
    IMG_CHR_BUF_SPR = MMC5_RAM + $600
    IMG_BKG_BUF_LO  = MMC5_RAM + $900
    IMG_BKG_BUF_HI  = MMC5_RAM + $C00

    ; Constants: Names tiles addresses
    ;
    ; NAME_CHR_BANK - _$C0_
    ; NAME_PPU_ADR  - _$2342_
    NAME_CHR_BANK = $C0
    NAME_PPU_ADR  = $2342

    ; Constants: Famistudio bank mapping
    ; during NMI. Value are index in <mmc5_banks> variable
    ;
    ; SFX_BNK_OFF  - _1_ Corrspond to $8000
    ; MUS_BNK_OFF  - _2_ Corrspond to $A000
    ; DPCM_BNK_OFF - _3_ Corrspond to $C000
    SFX_BNK_OFF  = 1 ; $8000
    MUS_BNK_OFF  = 2 ; $A000
    DPCM_BNK_OFF = 3 ; $C000

    ; Constants: Court record flags
    ; See: <cr_flag>
    ;
    ; CR_FLAG_SHOW   - _%00000001_ Is the court recod displayed ?
    ; CR_FLAG_ACCESS - _%00000010_ Can the court record be accessed ?
    ; CR_FLAG_OBJ    - _%00000100_ Can we present evidences ?
    CR_FLAG_SHOW   = %00000001
    CR_FLAG_ACCESS = %00000010
    CR_FLAG_OBJ    = %00000100

    ; Constants: Speciel dialog flags
    ;
    ; TXT_FLG_HOLDIT - _0_
    ; TXT_FLG_OBJ    - _1_
    ; TXT_FLG_OBJ_OK - _2_
    TXT_FLG_HOLDIT = 0
    TXT_FLG_OBJ    = 1
    TXT_FLG_OBJ_OK = 2

    ; Constants: Others constants
    ;
    ; FADE_TIME               - _$3F_   Time for the fade effect
    ; FLASH_TIME              - _$04_   Time for the flash effect
    ; RAM_MAX_BNK             - _1_     Maximum number of RAM banks
    ; BTN_TIMER               - _15_    Time before another player input is process
    ; RES_SPR                 - _1_     Number of sprites reserved (for high priority)
    ; IMG_PARTIAL_MAX_BUF_LEN - _$40_   Size of the <img_partial_buf> array
    ; SEGMENT_IMGS_START_ADR  - _$A000_ Use for image data pointer table
    ; MAX_EVIDENCE_IDX        - _9_     Maximum number of evidences
    ; MAX_EVENT               - _5_     Maximum number of event chr
    FADE_TIME               = $3F
    FLASH_TIME              = $04
    RAM_MAX_BNK             = 1
    BTN_TIMER               = 15
    RES_SPR                 = 1
    IMG_PARTIAL_MAX_BUF_LEN = $40
    SEGMENT_IMGS_START_ADR  = $A000
    MAX_EVIDENCE_IDX        = 9
    MAX_EVENT               = 5
