# Dialog scripting language

_In short: crapy HTML with custom tags._

## Description

This scripting language is very simple, it consists of 2 things: dialogs and tags.

Dialogs are the actual text to display and read and
tags are special characters that describe an action to perform.

Any text between angled bracket `<>` is considered as a tag.

Example:

```html
A dialog
<a_tag>
another dialog

<multiple><tag> with text between <tags>

<!-- Comment tag -->
```

Newline characters are ignored in the file (but can still be used to make the script more easy to read). If you want to display a newline character, you should use `<b>`.

Tags can have one or multiple arguments.
There are separated of the name by a colon `:`.
Each argument is separated by a comma `,`.

Example:
```html
<a_normal_tag>

<a_tag_with_one_argument: the_argument>

<a_tag_with_3_argument: arg1, arg2, arg3>
```

----

## Tag list

- [comments](#-comments)
- [b](#-b-(break))
- [p](#-p-(page))
- [fp](#-fp-(force-page))
- [speed](#-speed)
- [wait](#-wait)
- [const](#-const)
- [name](#-name)
- [color](#-color)
- [hidetextbox](#-hidetextbox)
- [shake](#-shake)
- [flash](#-flash)
- [background](#-background)
- [character](#-character)
- [animation](#-animation)
- [fade_out](#-fade_out)
- [fade_in](#-fade_in)
- [music](#-music)
- [sound](#-sound)
- [bip](#-bip)
- [set](#-set)
- [clear](#-clear)
- [label](#-label)
- [jump](#-jump)
- [act](#-act)
- [font](#-font)
- [photo](#-photo)
- [event](#-event)

### **comments** / `<!-- -->`

Everything inside a comment tag is ignored.
They can be multiple lines long.
Use it to make part of your script more clear.

```html
<!-- This is a comment -->

An actual dialog.

<!--
a comment with
multiple lines
-->
```

### **b** (break)

Used to display a newline character.

Example:

```html
This is a dialog<b>
with multiple lines<b>
of text.
```

### **p** (page)

Used to mark the end of the dialog. Wait for a user input to go to the next dialog.

Example:

```html
Find the 'next dialog button'<p>

Congrats! You found it!<p>
```

### **fp** (force page)

Function the same as `p` but does not wait for a user input.

Example:

```html
Read this quick!<fp>

Too slow!<p>
```

### **speed**

Change the speed of how fast the text is displaying.
The text will remain at this speed until another `speed` tag is encounter.

The argument is the number of frame to wait between each character displayed.
So the smaller the value, the faster the text.

Example:

```markdown
<speed:8>Slow text<b>
<speed:4>Normal text<b>
<speed:2>Fast text<b>
```

### **wait**

Wait for a certain number of frames to pass.

The argument is the number of frame to wait.
So the greater the value, the longer the wait.

Example:

```html
Wait i'm thinking...<wait:40><b>
OK I'm done<b>
<wait:10>Wait!<wait:100>Nothing :)<p>
```

### **const**

This tag can declare a constant value that you can use anywhere in the script.

It has 2 arguments:
the first is the constant name
and the second the value.

To use the new constant, just write it somewhere a value is needed, and it will be replaced when you will compile the script.

It is useful if you want to put a name on your value.

Another case: You have a value that you use multiple time to represent the same thing.
Now if you want to change the value, you will need to change all other values too.
But you can replace all values by a constant and only change its value to apply it to all others.

Example:

```html
<const:MAX_VALUE,127>
<const:NORMAL_SPEED,2>

<speed:NORMAL_SPEED>What a good day!
<wait:MAX_VALUE>...
<wait:MAX_VALUE>and now it's raining.
```

### **name**

Change the name of the dialog box.
The name will remain the same until another `name` tag is encounter.

The argument is the index of the name to use.
A value of 0 mean the name will not be displayed.

Example:

```html
<const:random_npc_1,1>
<const:random_npc_2,2>

<name:0>
In a small town:<p>

<name:random_npc_1>
Did you hear the new rumor ?<p>

<name:random_npc_2>
No, what is it ?<p>
```

### **color**

Change the text color.
The color will remain the same until another `color` tag is encounter.

The argument is the color to use. It can only take the value:
- 0: white (default)
- 1: red
- 2: blue
- 3: green

Example:

```html
Colors!<wait:8>We have<b>
<color:1>RED<color:0>,
<color:2>BLUE<color:0>,
and <color:3>GREEN<color:0>
!<p>
```

### **hidetextbox**

Toggle the dialog box display.

If the dialog box is currently displayed, it will be hidden.
And inversely, if the dialog box is currently hidden, it will be displayed.

Example:

```html
You can normally read this text.<p>
<hidetextbox>
But not this one.<p>
<hidetextbox>
What did I miss ?<p>
```

### **shake**

Make the screen shake during a certain amount of time.

Example:

```html
Watch out below!<p>

<shake>*bam*<p>
```

### **flash**

Turn the all screen white during a few frames, making a flash effect.

Example:

```html
Smile for the camera !<flash><p>
```

### **background**

Change the current background image to be displayed.
The background will remain the same until another `background` tag is encounter.

The argument correspond to the index of the background to use.

Example:

```html
<const:BKG_EMPTY,0>
<const:BKG_CASTLE_OUTSIDE,10>
<const:BKG_CASTLE_INSIDE,11>

<background:BKG_CASTLE_OUTSIDE>
You now have the castle in view.<p>

<background:BKG_EMPTY>
You decide to enter through the main gate...<p>

<background:BKG_CASTLE_INSIDE>
And find yourself in a vast hall.<p>
```

### **character**

Change the current character to be displayed.
The character will remain the same until another `character` tag is encounter.

The argument correspond to the index of the character to use. (See [animation index](#-animation-index))

If a value of 0 is used and a previous `animation` tag was used with also a 0 value,
then the character will not be displayed.

Example:

```html
<const:CHR_STRANGE_MAN,22>
<const:CHR_NONE,0>

<character:CHR_STRANGE_MAN>
You see the silhouette of a strange man.

<character:CHR_NONE>
But it disappears as soon as it sees you.
```

### **animation**

Change the current animation to be displayed.
The animation will remain the same until another `animation` tag is encounter. (See [animation index](#-animation-index))

If a value of 0 is used and a previous `character` tag was used with also a 0 value,
then the character (and so the animation) will not be displayed.

Example:

```html
<const:CHR_MAIN,6>
<const:ANI_TALK,4>
<const:ANI_STAND,2>

<character:CHR_MAIN>
<const:ANI_TALK>
Ho, hello you!
<const:ANI_STAND><p>
```

### **fade_out**

Fade the screen to black.
The screen will stay black until a `fade_in` tag is encounter.

Example:

```html
<const:BKG_FINAL_SCENE>

<background:BKG_FINAL_SCENE>
And so the hero defeated the bad guy<p>
<fade_out>
```

### **fade_in**

Fade the screen back from black.

Example:

```html
<const:BKG_TRUE_FINAL_SCENE>

<background:BKG_TRUE_FINAL_SCENE>
<fade_in>
Or not ?<p>
```

### **music**

Play a music.
The music will play until a `music` tag is encounter.

The argument is the index of the music to play.
An index of 0 stop the music.

Example:

```html
<const:MUS_TV,3>

That's when I decided to turn on the TV<p>
<music:MUS_TV>
My favorite show was on it !
```

### **sound**

Play a sound effect.

The argument is the index of the sound effect to play.

Example:

```html
<const:SND_TV_BROKE,49>

But then, the tv <sound:SND_TV_BROKE>broke!
```

### **bip**

Change the 'bip' effect play during display of the text.
The 'bip' will be used until another `bip` tag is encounter.

The argument is the index of the 'bip' to use.
An index of 0 stops the 'bip'.

Example:

```html
<const:BIP_LOW,3>
<const:BIP_HIGH,2>

<bip:BIP_LOW>
I can make a low pitch voice<p>
<bip:BIP_HIGH>
Or a high pitch if you prefer.<p>
```

### **set**

Set a flag.
Flags are part of the save of the game.
It can be used with a `jump` tag to take action.

The argument is the index of the flag to set.

Example:

```html
You pick-up the MacGuffin<set:5><p>
```

### **clear**

Clear a flag.
Flags are part of the save of the game.
It can be used with a `jump` tag to take action.

The argument is the index of the flag to clear.

Example:

```html
You drop the MacGuffin<clear:5><p>
```

### **label**

Can be used to declare a label.
A label represents the address of its location (the number of character from the start of the script to here).
It is generally used with a `jump` tag.

The argument is the name of the label.

Example:

```html
<!-- Declare a label to use for later -->
<label:chapter_1>
```

### **jump**

This tag makes a jump to another part of the script, progressing from there.

It takes multiples arguments:
1. address: Required. The address to jump to. Can be a number (don't) or a label (do).
2. JMP char: Optional. Use '0' If you just want the address without the JMP char.
2. 'next' flag: Optional. 1 = flag set, 0 otherwise.
2. 'condition' flag: Optional. The number correspond to the index of the flag (see [set](#-set) & [clear](#-clear)) to use.

In most cases, you just want the address to jump to.
The 'next' and 'condition' flags are use with the `act` tag.

Example:

```html
<label:loop>
You're in a loop
<jump:loop>
```

### **act**

This tag can be used to present a choice/action to the player.

When used, the way text is read is slightly different:
1. The dialog box is cleared
2. The text speed become instantaneous only for this dialog.
3. Each line will be conspired as a choice.
4. After the last choice, the player must choose something and the script will jump at the address linked with the choice.
5. After that the script return to a normal state and the action end. Note that the dialog box is not cleared after the choice but can be cleared with a `fp` tag.

Each choice is composed of:
1. The address to jump (without the JMP char) to if the choice is taken.
   If the 'next' flag is set, it tells the script that there is at least one choice after this one.
   If the 'condition' flag is set, the choice will not be selectable if the corresponding flag (see [set](#-set) & [clear](#-clear)) is cleared.
2. The text to represent the choice.
3. A `b` tag to mark the end of the choice.

Example 1:

```html
Make a choice<p>

<act>
<jump:choice_1,0,1>Choice 1<b>
<jump:choice_2,0,1,42>Choice 2<b> <!-- the flag 42 must be set to select this -->
<jump:secret,0,0>Secret Choice<b> <!-- the next flag is cleared, meaning it is the last choice -->

<label:choice_1><fp>You choose choice 1<p><jump:choice_end>

<label:choice_2><fp>You choose choice 2<p><jump:choice_end>

<label:secret><fp>You found the secret choose !<p><jump:choice_end>

<label:choice_end>
```

### **font**

This tag change the current font to another one.
Any character following this tag will be of that font until another `font` tag is encounter.

The argument is the index of the font to use.

Example:

```html
This is ASCII.<b><font:2>
これ　は　ひらがな　です。<b><font:3>
コレ　ハ　カタカナ　デス。<p><font:0>
```

### **photo**

TODO

Example:

```html
TODO
```

### **event**

TODO

Example:

```html
TODO
```

### **ext**

TODO

Example:

```html
TODO
```
