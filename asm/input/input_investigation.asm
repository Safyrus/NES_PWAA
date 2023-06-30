    ; if investigation scene
    LDA click_flag
    AND #CLICK_ENA
    BEQ @invest_end
    @invest:
        ;ABTSUDLR
        LDA buttons_1
        BEQ @invest_end
        ROL
        BCS @invest_A
        ROL
        ; BCS @invest_B
        ROL
        ; BCS @invest_SELECT
        ROL
        ; BCS @invest_START
        ROL
        BCS @invest_UP
        @invest_UP_end:
        ROL
        BCS @invest_DOWN
        @invest_DOWN_end:
        ROL
        BCS @invest_LEFT
        @invest_LEFT_end:
        ROL
        BCS @invest_RIGHT
        JMP @invest_end_input

        @invest_A:
            JSR investigation_click
            JMP @invest_end
        @invest_UP:
            PHA
            DEC cursor_y
            LDA #$17
            CMP cursor_y
            BNE :+
                INC cursor_y
            :
            PLA
            JMP @invest_UP_end
        @invest_DOWN:
            PHA
            INC cursor_y
            LDA #$D8
            CMP cursor_y
            BNE :+
                DEC cursor_y
            :
            PLA
            JMP @invest_DOWN_end
        @invest_LEFT:
            PHA
            DEC cursor_x
            LDA #$FF
            CMP cursor_x
            BNE :+
                INC cursor_x
            :
            PLA
            JMP @invest_LEFT_end
        @invest_RIGHT:
            INC cursor_x
            BNE :+
                DEC cursor_x
            :
            JMP @invest_end_input

    @invest_end_input:
    mov buttons_1_timer, #$00
    @invest_end:
