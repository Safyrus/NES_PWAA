# Tags

## Syntax

- tag: `<`, name, (`:`, arguments), `>`
- arguments: argument, (`,` arguments)

comment tag syntax is: `<!--`, anything `-->`

## List

| name        | description                                                  | argument             |
| :---------- | :----------------------------------------------------------- | :------------------- |
| b           | line break, match the LB char                                | /                    |
| p           | wait for press, match the DB char                            | /                    |
| fp          | force press, match the FDB char                              | /                    |
| speed       | dialog speed, match the SPD char                             | speed_arg            |
| wait        | wait a certain time, match the DL char                       | time (in frame)      |
| name        | change displayed name, match the NAM char                    | name_arg             |
| color       | change text/palette color, match the COL char                | color_arg            |
| hidetextbox | toggle the dialog box display, match the TD char             | /                    |
| shake       | Shake the screen, match the SAK char                         | force_arg            |
| flash       | Make the screen flash, match the FLH char                    | force_arg            |
| fade        | Make the screen fade to/from black, match the FAD char       | force_arg            |
| photo       | show, change, or remove a photo, match the PHT char          | index_arg            |
| background  | change the background, match the BKG char                    | index_arg            |
| character   | change the character, match the CHR char                     | char_arg             |
| music       | change the music, match the MUS char                         | music_arg            |
| sound       | play a sound effect, match the SND char                      | sfx index            |
| bip         | change the bip effect of the text, match the BIP char        | index_arg            |
| set         | set a flag, match the SET char                               | flag index           |
| clear       | clear a flag, match the CLR char                             | flag index           |
| font        | change the text font, match the FNT char                     | font index           |
| label       | create a label to reference the current address              | label name           |
| const       | create a constant equal to a number to use in the script     | constant name, value |
| jump        | jump to an address, match the JMP char                       | jump_arg             |
| act         | create a choice/action for the player, match the ACT char    | act_arg              |
| event       | call event that are specific to the game, match the EVT char | event_arg            |
| save        | save the current address, match the SAV char                 | /                    |
| return      | return to the saved address, match the RET char              | /                    |
| box         | create a collision box for the examination mode              | box_arg              |

## Arguments

### speed_arg

The value/argument is a integer that indicate the text speed.

The speed is compute as "value / 32"
and correspond to the number of character to display per frame.

### name_arg

value = name to use

0 = remove displayed name.

### color_arg

if 1 argument:
value = text color (0=white, 1=red, 2=blue, 3=green)

if 3 arguments:
first value = NES color,
second value = palette index (0-3 = background, 4-7 = sprites, 8-11 = text)
third value = color index (0-3)

### force_arg

2 arguments:
first value = force (0-7)
second value = time in frame

force argument:
for shake, force is maximum scroll in pixel * 2.
for flash, force is color change from white to current (0=no change, 4=complete white).
for fade, force is color change from current toward black (0=no change, 4=complete black).

Note:

- Color change set by using fade persist.
- for fade and shake, the time that will be used
  is the closest multiple of 8 round down.

### index_arg

value = index (0-127).

if index = last index then remove the index usage.
(e.g. for character is to remove the character)

### char_arg

same as index_arg but value can range from 0 to 16383.

### music_arg

value = music index

if value = 0, stop music.

if value = last value = pause music.

### jump_arg

arguments:

1. label or address value
2. (optional) include JMP char (either 0 or 1)
3. (optional) include next flag (either 0 or 1)
4. (optional) include condition (value = flag index)

### act_arg

not for the tag itself,
but next tags should be a series of `jump`
with no JMP char and next flag set (apart for the last one).

### event_arg

first argument should be the event to use.
other arguments depends on the event used.

### box_arg

arguments:

1. x position in tile (0-31)
2. y position in tile (0-31)
3. width in tile (0-31)
4. height in tile (0-31)
5. next flag (0-1)
