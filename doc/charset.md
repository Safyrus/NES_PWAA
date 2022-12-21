# Char set

- 00:1F = control char
- 20:7F = display char

## Control chars

|  Code  | Mne | Description                                                        | argument
|:------:|:---:|:-------------------------------------------------------------------|:--------
| **00** | END | END of dialog                                                      |
| **01** | LB  | Line Break                                                         |
| **02** | DB  | Dialog Break                                                       |
| **03** | FDB | Force Dialog Break                                                 |
| **04** | TGB | ToGgle dialog Box display                                          |
| **05** | SCR | SCRoll to the other side of the scene                              |
| **06** |     |                                                                    |
| **07** |     |                                                                    |
| **08** | SPD | SPeeD                                                              | arg_1: speed
| **09** | DLY | DeLaY                                                              | arg_1: delay
| **0A** | NAM | change NAMe of dialog box                                          | arg_1: idx
| **0B** | FLH | FLasH                                                              | arg_1: color
| **0C** | FDI | FaDe In ()                                                         | arg_1: color
| **0D** | FDO | De Out                                                             | arg_1: color
| **0E** | COL | change text COLor                                                  | arg_1: color
| **0F** | BKD | change BacKground color of the Dialog box                          | arg_1: color
| **10** | BIP | change dialog BIP effect                                           | arg_1: color
| **11** | MUS | MUSic                                                              | arg_1: color
| **12** | SND | SouND effect                                                        | arg_1: color
| **13** | PHT | show PHoto                                                         | arg_1: idx (0=remove)
| **14** | CSH | Character SHow                                                     | arg_1: idx (0=remove)
| **15** | CAN | Character ANimation                                                | arg_1: color
| **16** | BKG | change BacKGround                                                  | arg_1: color
| **17** | FNT | Change FoNT to use                                                 | arg_1: color
| **18** | JMP | JuMP to another dialog                                             | arg_1: idx_hi, arg_2: idx_lo
| **19** | CHC | CHoiCe, jump to the dialog + offset depending on the player choice | arg_1: idx_hi, arg_2: idx_lo, arg_3: nb_choice
| **1A** | BPL | Background PaLette                                                 | arg_1 to 4: palette
| **1B** | SPL | Sprite PaLette                                                     | arg_1 to 4: palette
| **1C** | RES | Reserved                                                           |
| **1D** | RES | Reserved                                                           |
| **1E** | EVT | EVenT                                                              | arg_1: fct_idx
| **1F** | EXT | EXTension command                                                  | arg_1: ext command

## Display char

### Occidental (0)

|   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |
|:--|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|2x | SP| ! | " | # | $ | % | & | ' | ( | ) | * | + | , | - | . | / |
|3x | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | : | ; | < | = | > | ? |
|4x | @ | A | B | C | D | E | F | G | H | I | J | K | L | M | N | O |
|5x | P | Q | R | S | T | U | V | W | X | Y | Z | [ | \ | ] | ^ | _ |
|6x | ` | a | b | c | d | e | f | g | h | i | j | k | l | m | n | o |
|7x | p | q | r | s | t | u | v | w | x | y | z | { | | | } | ~ |   |

### Japanese (日本語)

#### Hiragana (平仮名) (1)

|   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |
|:--|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|2x |   | 。 | 「 | 」 | 、 | ・  | を | ぁ | ぃ | ぅ | ぇ | ぉ | ゃ | ゅ | ょ | っ |
|3x | ー | あ | い | う | え  | お | か | き | く | け | こ | さ | し | す | せ  | そ |
|4x | た | ち | つ | て | と  | な | に | ぬ | ね | の | は | ひ | ふ | へ | ほ  | ま |
|5x | み | む | め | も | や  | ゆ | よ | ら | り | る | れ | ろ | わ | ン | ゛ | ゜ |
|6x | ￥ |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
|7x |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |

#### Katakana (片仮名) (2)

|   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |
|:--|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|2x |   | 。 | 「 | 」 | 、 | ・  | ヲ | ァ | ィ | ゥ | ェ | ォ | ャ | ュ | ョ | ッ |
|3x | ー | ア | イ | ウ | エ  | オ | カ | キ | ク | ケ | コ | サ | シ | ス | セ  | ソ |
|4x | タ | チ | ツ | テ | ト  | ナ | ニ | ヌ | ネ | ノ | ハ | ヒ | フ | ヘ | ホ  | マ |
|5x | ミ | ム | メ | モ | ヤ  | ユ | ヨ | ラ | リ | ル | レ | ロ | ワ | ン | ゛ | ゜ |
|6x | ￥ |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
|7x |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |

