    ; update player inputs
    JSR update_input

    .include "input_choice.asm"
    .include "input_cr.asm"
    .include "input_normal.asm"

    @input_end:
