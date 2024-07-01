# Event tag

This tag is used to call an event.
It is typically specific to a game.

You can use it to add your own event / special characters.
But this requires to modify this tag code.

It takes 1 or more arguments.
The first argument is the event you want to call.
Other arguments may be necessary depending on the event trigger.

## NES-PWAA event char

This is all the event that you can trigger in the NES-PWAA project

### EVT_CR

Toggle access to the court record

### EVT_CR_OBJ

Toggle the 'objection!' and 'hold it!' button of the court record

### EVT_CR_SET

Set a court record flag

Argument: flag index

### EVT_CR_CLR

Clear a court record flag

Argument: flag index

### EVT_CR_IDX

Set the correct evidence index of the court record

Argument: flag index
