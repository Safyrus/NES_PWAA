;################
; File: Constants
;################
; List all constants
.include "data/img/anim_names.asm"
.include "data/img/img_names.asm"


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
    PPU_CTRL_X        = %00000001
    PPU_CTRL_Y        = %00000010

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

    ; input modes
    IM_NORMAL = 0
    IM_ACT = 1
    IM_CR = 2
    IM_NONE = $FF

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

    ZP_BACKGROUND_SIZE = 77

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
; Group: Banks
;================

    ; Constants: Game ROM Banks
    ;
    ; CODE_BNK - _$80_ Bank containing game code
    ; SFX_BNK  - _$81_ Bank containing SFX sound data
    ; MUS_BNK  - _$82_ Starting bank containing music data
    ; DPCM_BNK - _$88_ Bank containing DPCM sound data
    ; ANI_BNK  - _$8B_ Bank containing animation table
    ; IMG_BNK  - _$8E_ Starting bank containing image data
    ; TXT_BNK  - _$CF_ Starting bank containing text data
    CODE_BNK     = $80
    SFX_BNK      = $81
    MUS_BNK      = $82
    DPCM_BNK     = $88
    ANI_BNK      = $8E
    IMG_BNK      = $91
    TXT_BNK      = $CF
    SPE_BNK      = $00

    ; Constants: Game RAM Banks
    ;
    ; TEXT_BUF_BNK - _$00_ Contain decoded text data
    ; IMG_BUF_BNK  - _$01_ Contain decoded image data
    ; GENERAL_BNK  - _$02_ Contain other data
    TEXT_BUF_BNK = $00
    IMG_BUF_BNK  = $01
    GENERAL_BNK = $02

;================
; Group: Game
;================

    ; Constants: Effect flags
    ; See: <effect_flags>
    ;
    ; EFFECT_FLAG_PAL_SPLIT - _%10000000_
    EFFECT_FLAG_PAL_SPLIT = %10000000
    EFFECT_FLAG_MIDBOX    = %01000000
    EFFECT_FLAG_IMAGE     = %00000001
    EFFECT_FLAG_DIALOG    = %00000010
    EFFECT_FLAG_DB_ANIM   = %00000100

    ; Constants: Nametable mapping
    ; See: <MMC5 Nametable mapping>
    ;
    ; NT_MAPPING_EMPTY   - _%11111111_
    ; NT_MAPPING_NT12     - _%11110100_
    ; DEFAULT_NT_MAPPING - _NT_MAPPING_EMPTY_
    NT_MAPPING_EMPTY   = %11111111
    NT_MAPPING_NT12    = %00010100
    NT_MAPPING_ALL     = %11100100
    DEFAULT_NT_MAPPING = NT_MAPPING_EMPTY

    ; Constants: HITBOX buffers addresses
    ;
    ; HITBOX_ADR  - _MMC5_RAM+$F00_  Text pointer array to jump to if the correct hitbox was selected
    ; HITBOX_MAP  - _MMC5_RAM+$1000_ Hitbox map use to detect where the player is clicking on
    HITBOX_ADR = MMC5_RAM + $F00
    HITBOX_MAP = MMC5_RAM + $1000

    ; Constants: Investigation constants
    ;
    ; CLICK_ENA      - _%00000001_ Flag for enabling investigation
    ; CLICK_INIT     - _%00000010_ Flag set when investigation has been initialized
    ; CLICK_SPR_BNK  - _0_ CHR Banks of the cursor sprite
    ; CLICK_SPR_IDX  - _$FC_ tile index of the cursor sprite
    CLICK_ENA     = %00000001
    CLICK_INIT    = %00000010
    CLICK_SPR_BNK = 0
    CLICK_SPR_IDX = $FC

    ; Constants: Others constants
    ;
    ; RAM_MAX_BNK             - _2_     Maximum number of RAM banks
    ; BTN_TIMER               - _15_    Time before another player input is process
    ; MAX_EVIDENCE_IDX        - _9_     Maximum number of evidences
    RAM_MAX_BNK             = 2
    BTN_TIMER               = 15
    MAX_EVIDENCE_IDX        = 9

    ; MMC5 PRG bank to be in during rleinc decoding
    RLEINC_BANK_IDX = 0


;================
; Group: Scanline
;================

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
    ; SCANLINE_NAME       - _%01000100_
    ; SCANLINE_DIALOG     - _%01000101_
    ; SCANLINE_BOT_IMG    - _%00000110_
    SCANLINE_TOP        = %01000000
    SCANLINE_TOP_IMG    = %01000001
    SCANLINE_TOP_MIDBOX = %01000010
    SCANLINE_BOT_MIDBOX = %01000011
    SCANLINE_NAME       = %01000100
    SCANLINE_DIALOG     = %01000101
    SCANLINE_BOT_IMG    = %00000110


;================
; Group: Images
;================
    PACKET_BUFFER_ADR = $6000
    IMG_BKG_LO_ADR    = $6400
    IMG_BKG_HI_ADR    = $6700
    IMG_CHANGE_ADR    = $6A00
    IMG_CHR_LO_ADR    = $6A00
    IMG_CHR_HI_ADR    = $6D00
    IMG_BUF_LO_ADR    = $7000
    IMG_BUF_HI_ADR    = $7300
    IMG_BUF2_LO_ADR   = $7600
    IMG_BUF2_HI_ADR   = $7900
    IMG_CHR_SPR       = $7C00
    ANIM_BUF_ADR      = $7D00

    IMG_FLAG_FORCE     = $80
    IMG_FLAG_EVISPR    = $08
    IMG_FLAG_REGION    = $03
    IMG_FLAG_OTHERNT   = $04
    IMG_FLAG_UNSPRITE  = $10
    IMG_FLAG_DO_REGION = $20

;================
; Group: Dialog Box
;================
    DB_ADR_LO = $7E00
    DB_ADR_HI = $7F00

    ; Constants: Dialog box tiles addresses
    ;
    ; DB_TILE_TL - _$0011_ Top left tile
    ; DB_TILE_T  - _$0012_ Top tile
    ; DB_TILE_TR - _$0013_ Top right tile
    ; DB_TILE_L  - _$0014_ Left tile
    ; DB_TILE_M  - _$0015_ Middle tile
    ; DB_TILE_R  - _$0016_ Right tile
    ; DB_TILE_BL - _$0017_ Bottom left tile
    ; DB_TILE_B  - _$0018_ Bottom tile
    ; DB_TILE_BR - _$0019_ Bottom right tile
    ; DB_TILE    - _$0001_ Fill tile
    DB_TILE_TL = $0011
    DB_TILE_T  = $0012
    DB_TILE_TR = $0013
    DB_TILE_L  = $0014
    DB_TILE_M  = $0015
    DB_TILE_R  = $0016
    DB_TILE_BL = $0017
    DB_TILE_B  = $0018
    DB_TILE_BR = $0019
    DB_TILE    = $0001

    SPLIT_PAL0_0 = $00
    SPLIT_PAL0_1 = $10
    SPLIT_PAL0_2 = $30
    SPLIT_PAL1_0 = $06
    SPLIT_PAL1_1 = $16
    SPLIT_PAL1_2 = $26
    SPLIT_PAL2_0 = $02
    SPLIT_PAL2_1 = $12
    SPLIT_PAL2_2 = $22
    SPLIT_PAL3_0 = $0A
    SPLIT_PAL3_1 = $1A
    SPLIT_PAL3_2 = $2A

;================
; Group: Text
;================
    ; MAX_TXT_SPD is 15 char per frames.
    ; More than that and text_speed_timer may overflow
    MAX_TXT_SPD = $F0

    TXT_FLAG_BUSY   = %10000000
    TXT_FLAG_MIDBOX = %01000000

    DEFAULT_TEXT_SPEED = $10
    DEFAULT_TEXT_FONT = $00
    DEFAULT_TEXT_COLOR = $00

    TXTARG_FORCE = $70
    TXTARG_TIME = $0F

    ONE_LINE_OFFSET_2_SPACE = $22 ; (1 line + 2 char)
    ONE_LINE_OFFSET_7_SPACE = $27 ; (1 line + 7 char)
    TWO_LINE_OFFSET_2_SPACE = $42 ; (2 line + 2 char)
    DEFAULT_PRINT_OFFSET = $22 ; (1 line + 2 char)
    CR_PRINT_OFFSET = $27 ; (1 line + 7 char)

;================
; Group: Light filter
;================
    LF_LIGHT = $F0

;================
; Group: Name
;================
    NAME_ATR = $03
    NAME_X_POS = $08
    NAME_Y_POS = $8F

    NAME_COL_1 = $01
    NAME_COL_2 = $21
    NAME_COL_3 = $20

;================
; Group: Famistudio
;================
    ; Constants: Famistudio bank mapping
    ; during NMI. Value are index in <mmc5_banks> variable
    ;
    ; SFX_BNK_OFF  - _1_ Corrspond to $8000
    ; MUS_BNK_OFF  - _2_ Corrspond to $A000
    ; DPCM_BNK_OFF - _3_ Corrspond to $C000
    SFX_BNK_OFF  = 1 ; $8000
    MUS_BNK_OFF  = 2 ; $A000
    DPCM_BNK_OFF = 3 ; $C000

;================
; Group: Jump address
;================
    JMPADR_POS_NEXT  = 0
    JMPADR_MASK_NEXT = $40

;================
; Group: Act
;================
    ACT_ONE_CHOICE_SIZE = $20
    ACT_SPR_ATR = $00

    ACT_SPR_TILE = $1A

    ACT_SPR_PAL_0 = $00
    ACT_SPR_PAL_1 = $10
    ACT_SPR_PAL_2 = $20

    ACT_BKG_PAL_0 = $00
    ACT_BKG_PAL_1 = $10
    ACT_BKG_PAL_2 = $30
    ACT_BKG_PAL_3 = $06
    ACT_BKG_PAL_4 = $16
    ACT_BKG_PAL_5 = $26

;================
; Group: Court Record
;================
    ; Constants: Court record flags
    ; See: <cr_flag>
    ;
    ; CR_FLAG_OPEN   - _%00000001_ Is the court recod displayed ?
    ; CR_FLAG_ACCESS - _%00000010_ Can the court record be accessed ?
    ; CR_FLAG_OBJ    - _%00000100_ Can we present evidences ?
    ; CR_FLAG_HOLD   - _%00001000_ Can we "Hold it" ?
    CR_FLAG_OPEN   = %00000001
    CR_FLAG_ACCESS = %00000010
    CR_FLAG_OBJ    = %00000100
    CR_FLAG_HOLD   = %00001000

    EVI_FLAG_OBJ = 0
    EVI_FLAG_OKOBJ = 1

    DIALOG_STACK_SIZE = 8

;================
; Group: HP
;================
    ;
    MAX_HP = 8
    HP_SPR_ATR = $03
    HP_BAR_SIZE_PX = (8 + PX_BETWEEN_HP) * MAX_HP
    ;
    HP_START_TILE = $08
    HP_POS_Y = 8*3
    PX_BETWEEN_HP = 6
    HP_TIMER_STEP = 3

    ;
    HP_SPR_NORMAL = $08
    HP_SPR_DANGER = $0A
    HP_SPR_DAMAGE = $0C
    HP_SPR_EMPTY  = $0E

    ;
    HP_TYPE_NORMAL = $00
    HP_TYPE_DANGER = $02
    HP_TYPE_DAMAGE = $04
    HP_TYPE_EMPTY  = $06

    ;
    HP_STATE_HIDE = %00
    HP_STATE_ENTER = %01
    HP_STATE_SHOW = %10
    HP_STATE_EXIT = %11

    ;
    HP_PAL_0 = $16
    HP_PAL_1 = $21
    HP_PAL_2 = $30

;================
; Group: Scroll Effect
;================
    SCROLL_DIR_LEFT  = $00
    SCROLL_DIR_RIGHT = $01
    SCROLL_DIR_UP    = $02
    SCROLL_DIR_DOWN  = $03

    SCROLL_STATE_NONE  = 0
    SCROLL_STATE_LOAD  = 1
    SCROLL_STATE_LOAD1 = 2
    SCROLL_STATE_LOAD2 = 3
    SCROLL_STATE_START = 4
    SCROLL_STATE_STEP  = 5
    SCROLL_STATE_END   = 6

    SCROLL_IMG_BUFFERS_LO = $6200
    SCROLL_IMG_BUFFERS_HI = $6800
    SCROLL_IMG_PALS_BUF   = $6180

;================
; Group: Special Characters
;================

    .enum SPE_CHR
        END ; END of dialog
        LB  ; Line Break
        DB  ; Dialog Break
        FDB ; Force Dialog Break
        TD  ; Toggle Dialog Box display
        SET ; Set flag
        CLR ; Clear flag
        SAK ; ShAKe
        SPD ; SPeeD
        DL  ; DeLay
        NAM ; change NAMe of dialog box
        FLH ; FLasH
        FAD ; FADe in/out
        SAV ; Save the current text location
        COL ; change text COLor
        RET ; Return to the previous saved location
        BIP ; change dialog BIP effect
        MUS ; MUSic
        SND ; SouND effect
        PHT ; show PHoto
        CHR ; change CHaRacter
        R15 ; Reserved
        BKG ; change BacKGround
        FNT ; Change FoNT to use
        JMP ; JuMP to another dialog
        ACT ; jump to the selected choice (depending on the player ACTion
        R1A ; Reserved
        R1B ; Reserved
        R1C ; Reserved
        R1D ; Reserved
        EVT ; EVenT. Use to add control characters specific to the game
        EXT ; EXTension. Reserved to add more ctrl char to the dialog box
    .endenum
