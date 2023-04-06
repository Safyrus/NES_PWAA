; param : tmp = input buffer
cp_2_mmc5_exp:
    ; - - - - - - - -
    ; copy exp buffer to expansion ram
    ; - - - - - - - -
    ; init pointers
    sta_ptr tmp+2, (MMC5_EXP_RAM+$60)
    ; find how many loop we need to do
    LDX #3
    BIT box_flags
    BMI @exp_dialog_box_off
        ; X = 2
        DEX
    @exp_dialog_box_off:
        ; X = 3
    ; start the loop
    @loop_exp:
        ; no need to check if we are still in frame
        ; because we now that we are at the top of the frame
        for_y @loop_exp_page, #0
            ; load and store the next byte
            LDA (tmp), Y
            STA (tmp+2), Y
        to_y_inc @loop_exp_page, #0
        ; update pointers
        INC tmp+1
        INC tmp+3
    to_x_dec @loop_exp, #0

    RTS

; param : tmp = input buffer
cp_non0_2_mmc5_exp:
    ; - - - - - - - -
    ; copy exp buffer to expansion ram
    ; - - - - - - - -
    ; init pointers
    sta_ptr tmp+2, (MMC5_EXP_RAM+$60)
    ; find how many loop we need to do
    LDX #3
    BIT box_flags
    BMI @exp_dialog_box_off
        ; X = 2
        DEX
    @exp_dialog_box_off:
        ; X = 3
    ; start the loop
    @loop_exp:
        ; no need to check if we are still in frame
        ; because we now that we are at the top of the frame
        for_y @loop_exp_page, #0
            ; load and store the next byte if it is not 0
            LDA (tmp), Y
            BEQ @next
                STA (tmp+2), Y
            @next:
        to_y_inc @loop_exp_page, #0
        ; update pointers
        INC tmp+1
        INC tmp+3
    to_x_dec @loop_exp, #0

    RTS


cp_bkgchr_2_mmc5_exp:
    ; - - - - - - - -
    ; copy exp buffer to expansion ram
    ; - - - - - - - -
    ; init pointers
    sta_ptr tmp, IMG_CHR_BUF_HI
    sta_ptr tmp+2, (MMC5_EXP_RAM+$60)
    sta_ptr tmp+4, IMG_BKG_BUF_HI
    ; find how many loop we need to do
    LDX #3
    BIT box_flags
    BMI @exp_dialog_box_off
        ; X = 2
        DEX
    @exp_dialog_box_off:
        ; X = 3
    ; start the loop
    @loop_exp:
        ; no need to check if we are still in frame
        ; because we now that we are at the top of the frame
        for_y @loop_exp_page, #0
            ; load and store the next byte
            LDA (tmp), Y
            BNE @chr
            @bkg:
                LDA (tmp+4), Y
            @chr:
                STA (tmp+2), Y
            @next:
        to_y_inc @loop_exp_page, #0
        ; update pointers
        INC tmp+1
        INC tmp+3
        INC tmp+5
    to_x_dec @loop_exp, #0

    RTS
    