; case TD
@TD:
    ; flip display dialog box flag
    LDA box_flags
    EOR #BOX_FLAG_HIDE
    ; tell to redraw the dialog box entierly
    AND #($FF-BOX_FLAG_REFRESH)
    STA box_flags
    ; async redraw_dialog_box()
    ora_adr txt_flags, #TXT_FLAG_BOX
    ;
    RTS
