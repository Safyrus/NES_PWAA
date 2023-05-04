; case NAM
@NAM:
    ; name = next_char()
    JSR read_next_char
    STA txt_name
    ;
    ora_adr box_flags, #BOX_FLAG_NAME
    ; update_name()
    JMP update_name

