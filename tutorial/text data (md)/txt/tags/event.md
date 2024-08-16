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

### EVT_CR (0)

Toggle access to the court record

### EVT_CR_OBJ (1)

Toggle the 'objection!' and 'hold it!' button of the court record

### EVT_CR_SET (2)

Set a court record flag

Argument: flag index

### EVT_CR_CLR (3)

Clear a court record flag

Argument: flag index

### EVT_CR_IDX (4)

Set the correct evidence index of the court record

Argument: flag index

### EVT_CLICK (5)

Enable investigation/cursor mode.

<!-- <event:EVT_ACT_RET><event:EVT_CLICK>
<box:15,11,6,5,1><jump:label_2_53,0,1>
<box:4,0,7,9,1><jump:label_2_54,0,1>
<box:7,18,6,2,1><jump:label_2_55,0,1>
<box:27,9,5,6,1><jump:label_2_66,0,1>
<box:6,10,8,8,0><jump:label_2_57,0,1> -->

### EVT_ACT_RET (6)

Enable return from a choice/investigation.
