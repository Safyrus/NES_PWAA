# General text information

## == Write text data ==

Writing text data for your game is not difficult, but to explain it...
Well I think an example will better teach you how to do it.

Let's say you want to write this simple dialog between 2 characters:

```
A:
Hey!
B:
Ho, hi!
How you'r doing?
A:
Great and you?
B:
Great too!
A:
Do you still have it?
B:
The... Oh this, yeah.
Here you go.
Just be careful with it.
A:
Nice, I won't bother
you any longer.
Good luck!
B:
Good luck to you too.
```

You may start by writing this into a plain text file and indicate the path to the folder containing it to the project ('data/text' by default).
If you feed the project with this text data, it will not complain and correctly compile the game.
But, as soon as the game start all this plain text will be displayed one line of the dialog box.
(and very likely cause bug and crash the game because the dialog go out of the screen).
It will look something like this:

```
A: Hey!B: Ho, hi! How you'r doing?A: Great and you?B: Great too!A: Do you still have it?B: The... Oh this, yeah. Here you go.Just be careful with it.A: Nice, I won't bother you any longer.Good luck!B: Good luck to you too.
```

The project does not know anything about our text apart from "this is text".
To indicate that we want new lines, multiple dialog box, etc. We need "tags".

## == Tags ==

Tag are written by using angle bracket like this:`<tag>`
Each tag have a specific name and purpose. Each of them is explained in the tag section.

But for now, let's start by adding `<b>` tags to the text. (b like "break line")
this tag act as a new line character. Each time it is encounter the text will jump to the start of the next line.

```
A:
Hey!
B:
Ho, hi!<b>
How you'r doing?
A:
Great and you?
B:
Great too!
A:
Do you still have it?
B:
The... Oh this, yeah.<b>
Here you go.<b>
Just be careful with it.
A:
Nice, I won't bother<b>
you any longer.<b>
Good luck!
B:
Good luck to you too.
```

We still need multiple dialog box and not just one with all our text.
For that, we will use the `<p>` tag (p like page?/press?).
This tag indicates that we have reached the end of the dialog box
and that the user need to press continue to go to the next one.

Putting them where we want to separate our text, this look like this:

```
A:
Hey!<p>
B:
Ho, hi!<b>
How you'r doing?<p>
A:
Great and you?<p>
B:
Great too!<p>
A:
Do you still have it?<p>
B:
The... Oh this, yeah.<b>
Here you go.<b>
Just be careful with it.<p>
A:
Nice, I won't bother<b>
you any longer.<b>
Good luck!<p>
B:
Good luck to you too.<p>
```

Now the game will correctly display the first dialog box and wait for an input.
After pressing continue, the second dialog box will appear and so one.

Of course this is only the basics. Other tags exist to do more complicated stuff.
Also, you need to add this at the end of our text data: "`<label:end><jump:end>`".
If you want details, go to the label tag and jump tag section, but for short, it soft lock the game and make it not crash.

## == Tag arguments ==

Tags can also take arguments.
For example, if we want to add names to our characters,
we can use the `<name>` tag.

```
<name:NAM_A>
Hey!<p>
<name:NAM_B>
Ho, hi!<b>
How you'r doing?<p>
<name:NAM_A>
Great and you?<p>
<name:NAM_B>
Great too!<p>
<name:NAM_A>
Do you still have it?<p>
<name:NAM_B>
The... Oh this, yeah.<b>
Here you go.<b>
Just be careful with it.<p>
<name:NAM_A>
Nice, I won't bother<b>
you any longer.<b>
Good luck!<p>
<name:NAM_B>
Good luck to you too.<p>
```

This will display a name at the bottom left of the dialog box.
The constant/number specified the name to use from a list. See the `<name>` tag section to learn how to edit them.

## == Comments ==

New lines are ignored, so don't hesitate to use them to add space between dialogs and make it more readable for you and others.

There is also a special tag called a comment.
It starts with `<!--` and end with `-->`.
Everything in between is ignored by the game.
It's very useful to annotate your text and to tell you or other info about your text.
For example: "What is this section about?", "Why is this chain of tag use for?" or "Things to add there in the future".
