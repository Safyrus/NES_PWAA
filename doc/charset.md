# Char set

- [Char set](#char-set)
  - [Info](#info)
  - [Control chars](#control-chars)
    - [Events](#events)
    - [Box format](#box-format)
    - [Jump addresses format](#jump-addresses-format)
  - [HP format](#hp-format)
  - [Fonts / Display char](#fonts--display-char)
    - [Occidental](#occidental)
      - [ASCII (0)](#ascii-0)
    - [Japanese (日本語)](#japanese-日本語)
      - [Hiragana (平仮名) (2)](#hiragana-平仮名-2)
      - [Katakana (片仮名) (3)](#katakana-片仮名-3)

## Info

- 00:1F = control char
- 20:7F = display char

## Control chars

| Code  |  Mne  | Description                                                  | arguments                                                                                          |
| :---: | :---: | :----------------------------------------------------------- | :------------------------------------------------------------------------------------------------- |
|  $00  |  END  | END of dialog                                                |                                                                                                    |
|  $01  |  LB   | Line Break                                                   |                                                                                                    |
|  $02  |  DB   | Dialog Break                                                 |                                                                                                    |
|  $03  |  FDB  | Force Dialog Break                                           |                                                                                                    |
|  $04  |  TD   | Toggle Dialog Box display                                    |                                                                                                    |
|  $05  |  SET  | Set flag                                                     | 1: index                                                                                           |
|  $06  |  CLR  | Clear flag                                                   | 1: index                                                                                           |
|  $07  |  SAK  | ShAKe                                                        | 1: `ffftttt` (f=force, t=time)                                                                     |
|  $08  |  SPD  | SPeeD                                                        | 1: speed                                                                                           |
|  $09  |  DL   | DeLay                                                        | 1: delay                                                                                           |
|  $0A  |  NAM  | change NAMe of dialog box                                    | 1: name (same as last = remove)                                                                    |
|  $0B  |  FLH  | FLasH                                                        | 1: `ffftttt` (f=force, t=time)                                                                     |
|  $0C  |  FAD  | FADe                                                         | 1: `ffftttt` (f=force, t=time)                                                                     |
|  $0D  |  SAV  | Save the current text location                               |                                                                                                    |
|  $0E  |  COL  | change text COLor                                            | 1: `pcccccc` (c=color,p=on palette), 2:`.ttppii` (t= palette type, p=palette index, i=color index) |
|  $0F  |  RET  | Return to the previous saved location                        |                                                                                                    |
|  $10  |  BIP  | change dialog BIP effect                                     | 1: bip (same as last = remove)                                                                     |
|  $11  |  MUS  | MUSic                                                        | 1: music (same as last = pause)                                                                    |
|  $12  |  SND  | SouND effect                                                 | 1: snd (0-63=sfx, 64-127=dpcm)                                                                     |
|  $13  |  PHT  | show PHoto                                                   | 1: photo (same as last = remove)                                                                   |
|  $14  |  CHR  | CHaRacter to show                                            | 1: character (low), 2:character (high), (same as last = remove)                                    |
|  $15  |  RES  | Reserved                                                     |                                                                                                    |
|  $16  |  BKG  | change BacKGround                                            | 1: background (same as last = remove)                                                              |
|  $17  |  FNT  | Change FoNT to use                                           | 1: font                                                                                            |
|  $18  |  JMP  | JuMP to another dialog                                       | jmp_adr, \[condition\]                                                                             |
|  $19  |  ACT  | jump to the selected choice (depending on the player ACTion) | (jmp_adr, \[condition\], text line)*nb_choice                                                      |
|  $1A  |  RES  | Reserved                                                     |                                                                                                    |
|  $1B  |  RES  | Reserved                                                     |                                                                                                    |
|  $1C  |  RES  | Reserved                                                     |                                                                                                    |
|  $1D  |  RES  | Reserved                                                     |                                                                                                    |
|  $1E  |  EVT  | EVenT. Use to add control characters specific to the game    | 1: function                                                                                        |
|  $1F  |  EXT  | EXTension. Reserved to add more ctrl char to the dialog box  | 1: ext command                                                                                     |

### Events

|  Mne  | code  |          args          | description                                                                                                                                      |
| :---: | :---: | :--------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------- |
|  CR   |  $00  |           /            | toggle access to Court Record                                                                                                                    |
|  CRF  |  $01  |           /            | Court Record : Force the court record to open                                                                                                    |
|  CRO  |  $02  |           /            | Court Record : toggle Objection (present evidence)                                                                                               |
|  CRH  |  $03  |        jmp_adr         | Court Record : toggle "Hold it" mode for this dialog. Jump to jmp_adr when pressing 'hold it'. Set next flag in jmp_adr to block previous dialog |
|  CRS  |  $04  |          flag          | Court Record : Set evidence flag / adding evidence to court record                                                                               |
|  CRC  |  $05  |          flag          | Court Record : Clear evidence flag / removing evidence from court record                                                                         |
|  CRI  |  $06  |          flag          | Court Record : Index/flag of correct evidence to present                                                                                         |
|  CRN  |  $07  |     flag, jmp_adr      | Court Record : add/replace the evidence with index/flag by a New evidence. jmp_adr point to what to display in the court record                  |
|  HPT  |  $08  |           /            | HP Toggle: Toggle HP bar display                                                                                                                 |
|  HPE  |  $09  |     hp_val,jmp_adr     | HP Event: Register an event when hp hp_val.type reach hp_val.num. When trigger, jump to jmp_adr                                                  |
|  HPS  |  $0A  |         hp_val         | HP Set: set hp hp_val.type to hp_val.num                                                                                                         |
|  HPA  |  $0B  |         hp_val         | HP Add: add hp_val.num to hp hp_val.type                                                                                                         |
|  SL1  |  $0C  |       background       | Scroll: Load 1 background image                                                                                                                  |
|  SL2  |  $0D  | background, background | Scroll: Load 2 background images                                                                                                                 |
|  SA   |  $0E  |    direction&speed     | Scroll: Activate scroll with direction (bit 0-1) and speed (bit 2-6)                                                                             |
|  EXA  |  $0F  | list of (box, jmp_adr) | configure and switch to EXAmination mode                                                                                                         |

### Box format

```text
Char:   0         1         2
Bits:   6543210   6543210   6543210
Name:   nXxxxxY   yyyyWww   wwHhhhh
        |||||||   |||||||   ||+++++-- height of the hitbox (W=MSB)
        |||||||   ||||+++---++------- width of the hitbox (W=MSB)
        ||||||+---++++--------------- y position of the hitbox (Y=MSB)
        |+++++----------------------- x position of the hitbox (X=MSB)
        +---------------------------- Next flag (1=another data block after this one
                                                 0=last data block)
```

```text
When evt:exa is read.

1. read a box
2. read a jump
3. go back to 1 if next box
4. wait for a box to be selected
5. use the jump of the selected box
```

### Jump addresses format

```text
<JUMP_ADR> [CONDITION] [other_data] [<LB> <JUMP_ADR> (if next flag set)]

JUMP_ADR:
20    14   13    7    6     0
cbbbbbb    ppppppp    nPPPPPP
|||||||    |||||||    |++++++-- High part of pointer (12:7)
|||||||    |||||||    +-------- Next flag (only used with the ACT control char)
|||||||    +++++++------------- Low part of pointer (6:0)
|++++++------------------------ Bank index
+------------------------------ Condition flag

CONDITION:
27    21
ccccccc
+++++++-- Index of flag to check if condition flag is set

other_data:
can be a line of text when using ACT
```

## HP format

```text
n.ttvvv
| ||+++-- Value
| ++----- Type (0= normal, 1=danger, 2=damage, 3=empty (dot not use))
+-------- Negate value
```

## Fonts / Display char

### Occidental

#### ASCII (0)

|      |   0   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |   8   |   9   |   A   |   B   |   C   |   D   |   E   |   F   |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 2x   |  SP   |   !   |   "   |   #   |   $   |   %   |   &   |   '   |   (   |   )   |   *   |   +   |   ,   |   -   |   .   |   /   |
| 3x   |   0   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |   8   |   9   |   :   |   ;   |   <   |   =   |   >   |   ?   |
| 4x   |   @   |   A   |   B   |   C   |   D   |   E   |   F   |   G   |   H   |   I   |   J   |   K   |   L   |   M   |   N   |   O   |
| 5x   |   P   |   Q   |   R   |   S   |   T   |   U   |   V   |   W   |   X   |   Y   |   Z   |   [   |   \   |   ]   |   ^   |   _   |
| 6x   |   `   |   a   |   b   |   c   |   d   |   e   |   f   |   g   |   h   |   i   |   j   |   k   |   l   |   m   |   n   |   o   |
| 7x   |   p   |   q   |   r   |   s   |   t   |   u   |   v   |   w   |   x   |   y   |   z   |   {   |  \|   |   }   |   ~   |       |

### Japanese (日本語)

#### Hiragana (平仮名) (2)

|      |   0   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |   8   |   9   |   A   |   B   |   C   |   D   |   E   |   F   |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 2x   |       |  。   |  「   |  」   |  、   |  ・   |  を   |  ぁ   |  ぃ   |  ぅ   |  ぇ   |  ぉ   |  ゃ   |  ゅ   |  ょ   |  っ   |
| 3x   |  ー   |  あ   |  い   |  う   |  え   |  お   |  か   |  き   |  く   |  け   |  こ   |  さ   |  し   |  す   |  せ   |  そ   |
| 4x   |  た   |  ち   |  つ   |  て   |  と   |  な   |  に   |  ぬ   |  ね   |  の   |  は   |  ひ   |  ふ   |  へ   |  ほ   |  ま   |
| 5x   |  み   |  む   |  め   |  も   |  や   |  ゆ   |  よ   |  ら   |  り   |  る   |  れ   |  ろ   |  わ   |  ん   |  ゛   |  ゜   |
| 6x   |   ￥   |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |
| 7x   |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |

#### Katakana (片仮名) (3)

|      |   0   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |   8   |   9   |   A   |   B   |   C   |   D   |   E   |   F   |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 2x   |       |       |       |       |       |       |  ヲ   |  ァ   |  ィ   |  ゥ   |  ェ   |  ォ   |  ャ   |  ュ   |  ョ   |  ッ   |
| 3x   |       |  ア   |  イ   |  ウ   |  エ   |  オ   |  カ   |  キ   |  ク   |  ケ   |  コ   |  サ   |  シ   |  ス   |  セ   |  ソ   |
| 4x   |  タ   |  チ   |  ツ   |  テ   |  ト   |  ナ   |  ニ   |  ヌ   |  ネ   |  ノ   |  ハ   |  ヒ   |  フ   |  ヘ   |  ホ   |  マ   |
| 5x   |  ミ   |  ム   |  メ   |  モ   |  ヤ   |  ユ   |  ヨ   |  ラ   |  リ   |  ル   |  レ   |  ロ   |  ワ   |  ン   |       |       |
| 6x   |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |
| 7x   |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |
