# Const tag

This tag can declare a constant value that you can use after in the script.

It has 2 arguments:
the first is the constant name
and the second the value.

To use the new constant, just write its name somewhere,
and it will be replaced by its value when you compile the script.

It is useful if you want to put a name on your value.
Especially, if you're using this value multiple times
Because if you want to change this value,
you will need to change all other places where this value it used too.
But you can replace all values by a constant
and only change its value to apply it to all others.

## Example

<const:MAX_VALUE,127>
<const:NORMAL_SPEED,2>

<speed:NORMAL_SPEED>What a good day!
<wait:MAX_VALUE>...
<wait:MAX_VALUE>and now it's raining.

## Tips

Don't hesitate to use it.
It improves readability and make change easier.
(`<name:MAIN_CHAR_NAME>` is more readable than `<name:45>`)
