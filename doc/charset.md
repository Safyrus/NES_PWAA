# Char set

- 00:1F = control char
- 20:7F = display char

## Control chars

| TODO |  Code  | Mne | Description                                                  | argument                                      |
|:----:|:------:|:---:|:-------------------------------------------------------------|:----------------------------------------------|
|      | **00** | END | END of dialog                                                |                                               |
|      | **01** | LB  | Line Break                                                   |                                               |
|      | **02** | DB  | Dialog Break                                                 |                                               |
|      | **03** | FDB | Force Dialog Break                                           |                                               |
|      | **04** | TD  | Toggle Dialog Box display                                    |                                               |
|      | **05** | SET | Set flag                                                     | 1: index                                      |
|      | **06** | CLR | Clear flag                                                   | 1: index                                      |
|      | **07** | SAK | ShAKe                                                        |                                               |
|      | **08** | SPD | SPeeD                                                        | 1: speed                                      |
|      | **09** | DL  | DeLay                                                        | 1: delay                                      |
|      | **0A** | NAM | change NAMe of dialog box                                    | 1: name (0=remove)                            |
|      | **0B** | FLH | FLasH                                                        |                                               |
|      | **0C** | FAD | FADe in/out                                                  |                                               |
|      | **0D** | SAV | Save the current text location                               |                                               |
|      | **0E** | COL | change text COLor                                            | 1: color                                      |
|      | **0F** | RET | Return to the previous saved location                        |                                               |
|      | **10** | BIP | change dialog BIP effect                                     | 1: bip (0=remove)                             |
|      | **11** | MUS | MUSic                                                        | 1: music (0=remove)                           |
|      | **12** | SND | SouND effect                                                 | 1: sfx                                        |
|  /   | **13** | PHT | show PHoto                                                   | 1: photo (0=remove)                           |
|      | **14** | CHR | CHaRacter to show                                            | 1: character (0=remove)                       |
|      | **15** | ANI | character ANImation                                          | 1: animation                                  |
|      | **16** | BKG | change BacKGround                                            | 1: background                                 |
|      | **17** | FNT | Change FoNT to use                                           | 1: font                                       |
|      | **18** | JMP | JuMP to another dialog                                       | jmp_adr, \[condition\]                        |
|      | **19** | ACT | jump to the selected choice (depending on the player ACTion) | (jmp_adr, \[condition\], text line)*nb_choice |
|  X   | **1A** | BP  | Background Palette                                           | 4: palettes (pal 0 first)                     |
|  X   | **1B** | SP  | Sprite Palette                                               | 4: palettes (pal 0 first)                     |
|      | **1C** | RES | Reserved                                                     |                                               |
|      | **1D** | RES | Reserved                                                     |                                               |
|      | **1E** | EVT | EVenT. Use to add control characters specific to the game    | 1: function                                   |
|      | **1F** | EXT | EXTension. Reserved to add more ctrl char to the dialog box  | 1: ext command                                |

### Events

Note: each name is precead by `evt-`.

|  Name  | code | args | description                           |
|:------:|:----:|:----:|:--------------------------------------|
| cr     | $00  |  /   | Toggle court record                   |
| cr-obj | $01  |  /   | Toggle present evidence               |
| cr-set | $02  | flag | Set evidence flag                     |
| cr-clr | $03  | flag | Clear evidence flag                   |
| cr-idx | $04  | idx  | Index of correct evidence to present  |
| swoosh | $??  |  /   | Scroll to the other side of the scene |
| scroll | $??  |  /   | Scroll to the other background        |
| hp-bar | $??  |  /   | Toggle life-bar display               |
| hp-hit | $??  |  /   | Life-bar hit effect                   |
| ce-txt | $??  |  /   | Cross-examination top text            |
| t-txt  | $??  |  /   | Testimony top text                    |
| t-SCR  | $??  |  /   | Testimony scroll text effect          |
| clue   | $??  |  /   | New evidence scroll effect            |

### Jump addresses format

```
Format:
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
```

## Display char

### Occidental

#### ASCII (0)

|    | 0  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C  | D | E | F |
|:---|:--:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:--:|:-:|:-:|:-:|
| 2x | SP | ! | " | # | $ | % | & | ' | ( | ) | * | + | ,  | - | . | / |
| 3x | 0  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | : | ; | <  | = | > | ? |
| 4x | @  | A | B | C | D | E | F | G | H | I | J | K | L  | M | N | O |
| 5x | P  | Q | R | S | T | U | V | W | X | Y | Z | [ | \  | ] | ^ | _ |
| 6x | `  | a | b | c | d | e | f | g | h | i | j | k | l  | m | n | o |
| 7x | p  | q | r | s | t | u | v | w | x | y | z | { | \| | } | ~ |   |

### Japanese (日本語)

#### Hiragana (平仮名) (2)

|    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |
|:---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 2x |   | 。 | 「 | 」 | 、 | ・ | を | ぁ | ぃ | ぅ | ぇ | ぉ | ゃ | ゅ | ょ | っ |
| 3x | ー | あ | い | う | え | お | か | き | く | け | こ | さ | し | す | せ | そ |
| 4x | た | ち | つ | て | と | な | に | ぬ | ね | の | は | ひ | ふ | へ | ほ | ま |
| 5x | み | む | め | も | や | ゆ | よ | ら | り | る | れ | ろ | わ | ん | ゛ | ゜ |
| 6x | ￥ |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
| 7x |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |

#### Katakana (片仮名) (3)

|    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |
|:---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 2x |   | 。 | 「 | 」 | 、 | ・ | ヲ | ァ | ィ | ゥ | ェ | ォ | ャ | ュ | ョ | ッ |
| 3x | ー | ア | イ | ウ | エ | オ | カ | キ | ク | ケ | コ | サ | シ | ス | セ | ソ |
| 4x | タ | チ | ツ | テ | ト | ナ | ニ | ヌ | ネ | ノ | ハ | ヒ | フ | ヘ | ホ | マ |
| 5x | ミ | ム | メ | モ | ヤ | ユ | ヨ | ラ | リ | ル | レ | ロ | ワ | ン | ゛ | ゜ |
| 6x | ￥ |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
| 7x |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |

