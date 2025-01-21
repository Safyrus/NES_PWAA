call_update_img:
    ; if dialog box displayed
    BIT effect_flags
    BPL :+
        ; update all except dialog box space
        JMP update_img_no_db
    ; else
    :
        ; update all
        JMP update_all
