; X = number of pixels singed on the X axis
; Y = number of pixels singed on the Y axis
scroll_add:
    ; if X != 0
    TXA
    CLC
    BEQ :+
        ; if X < 0
        BPL :+
            ; scroll_x += X
            ADC scroll_x
            STA scroll_x
            BCS :++
            ; if scroll_x overflow
                ; flip high x scroll
                LDA ppu_ctrl_val
                EOR #PPU_CTRL_X
                STA ppu_ctrl_val
                JMP :++
        ; else
        :
            ; scroll_x += X
            ADC scroll_x
            STA scroll_x
            BCC :+
            ; if scroll_x overflow
                ; flip high x scroll
                LDA ppu_ctrl_val
                EOR #PPU_CTRL_X
                STA ppu_ctrl_val
    :
    ; if Y != 0
    TYA
    CLC
    BEQ :+
        ; if Y < 0
        BPL :+
            ; scroll_y += Y
            ADC scroll_y
            STA scroll_y
            BCS :++
            ; if scroll_y overflow
                ; flip high y scroll
                LDA ppu_ctrl_val
                EOR #PPU_CTRL_Y
                STA ppu_ctrl_val
                JMP :++
        ; else
        :
            ; scroll_y += Y
            ADC scroll_y
            STA scroll_y
            BCC :+
            ; if scroll_y overflow
                ; flip high y scroll
                LDA ppu_ctrl_val
                EOR #PPU_CTRL_Y
                STA ppu_ctrl_val
    :
    ; return
    RTS
