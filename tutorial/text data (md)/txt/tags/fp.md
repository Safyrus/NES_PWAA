# FP tag

The `<fp>` tag is one of the most basic tag.
When encountered, it indicates the end a dialog box, like `<p>`.
But it does not wait for user input to go to the next dialog box.
If you want to wait for an input, see the `<p>` tag.

Why call it `<fp>` ? I don't remember ?
For "force page/press" maybe ?

## Example

This is the dialog before you press--<fp>
Nop! No time for that!<p>

## Tips

You can use it to create an element of surprise,
having a dialog that is really fast and skip itself,
or force the dialog to be time with something else like music.

Be careful thought,
if you want your player to read a text before this tag,
make sure to give them enough time to do so (maybe with `<speed>` or `<wait>`)
