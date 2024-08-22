
In short: The link.cfg is responsible for indicating where in the cartridge data must be put.

You shouldn't need to edit this file in normal cases.
But if you get a message like for example:
`Warning: link.cfg:20: Segment 'TXT_BNK' overflows memory area 'BNK_TXT' by 1024 bytes`

That's mean that your data are too big to fit inside the designated segment.
In this case, you have 1 KB of text that does not fit.

There are 2 solutions to this problem:
1. Remove some of your data (not that good of a solution)
2. Edit the link.cfg file to tell it that you have enough space

In the case you choose option 2, this is you how to do it:

First, go to the line indicated (20 in this case)
Then, change the number after the `size =` to a bigger number.
Note that the number must be written in hexadecimal and should be a multiple of $2000.
Lets supposed it was $62000, and that we add 8 KB ($2000 in hex) that will give us $64000.

But you are not done yet! Because now the size of all segments add up to more of the cartridge space.
You must now remove the same amount of space you added from other segment.
Let's suppose than you do not have many images and there is still space in the BNK_IMG segment.
Then we can replace the old value of $84000 by $82000 (a difference of 8 KB).

Of course, if all your data does not fit in 1 MB
(not counting the CHR space of 1 MB that is filled for you)
Then you just out of space and must remove something.
