# General text information

## == Write text data ==

Writing text data for your game is not difficult, but to explain it...
Well I think an example will better teach how to do it.

Let's say you want to write this simple dialog between 2 characters:
(TODO show img with plain text)
You will start by writing this into a plain text file and indicate the path to this file to the project (see struct/data/txt).
If you feed the project with this text data, it will not complain and correctly compile the game.
But, as soon as the game start all this plain text will be displayed one line of the dialog box.
(and possibly cause bug because the dialog go out of the screen).
It will look something like this: (TODO: show img)

The project does not know anything about our text apart from "this is text".
To indicate that we want new lines and multiple dialog box, we need to use "tags".

## == Tags ==

Tag are written by using angle bracket like this:`<tag>`
Each tag have a specific name and purpose. Each of them is explained in the tag section.

But for now, let's start by adding `<b>` tags to your text. (b like "break" I supposed)
this tag act as a new line character. Each time it is encounter the text will jump to the start of the next line.
(show img text with tag b)

Now the text displayed look like this: (TODO: show img)
Better, but we still need multiple dialog box and not just one with all our text.
For that, we will use the `<p>` tag (p like page?/press?).
This tag indicates that we have reached the end of the dialog box
and that the user need to press continue to go to the next one.

Putting them where we want to separate our text, this look like this: (TODO: show img)
and now the game is now displaying our first dialog box with proper lines and wait for an input.
After we press continue, we see our second dialog box! Hooray!

Of course this is only the basics. Other tags exist to do more complicated stuff.
But for now, we will add this at the end of our text data: "`<label:end><jump:end>`".
If you want details, go to the label tag and jump tag section, but for short, it soft lock the game and make it not crash.

## == Tag arguments ==

Tags can also take arguments.
For example, if we want to add names to our characters,
we can use the `<name>` tag.
(show text with name tag)
This will display a name at the bottom left of the dialog box.
The number specified the name to use from a list. See the `<name>` tag section to learn how to edit them.

## == Comments ==

There is a special tag called a comment.
It starts with `<!--` and end with `-->`.
Everything in between is ignored by the game.
It is very useful to annotate your text and to tell you or other peoples what is it about.
For example: "What is this section about ?", "Why is this chain of tag use for ?" or "Things to add there in the future".

(TODO: example)
