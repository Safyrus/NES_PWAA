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
        BCS @invest_B
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
        @invest_B:
            ; if ACT RET flag is set
            LDA input_flags
            AND #ACT_RET_FLAG
            BEQ @invest_end
                ; clear ACT_RET_FLAG flag
                and_adr input_flags, #($FF-ACT_RET_FLAG)
                ; return to last act
                JSR dec_act_ptr
                JSR act_return
                ; disable investigation
                JSR investigation_disable
                JMP @invest_end
        @invest_UP:
            PHA
            LDA #$18
            CMP cursor_y
            BEQ :+
                DEC cursor_y
            :
            PLA
            JMP @invest_UP_end
        @invest_DOWN:
            PHA
            LDA #$D2
            CMP cursor_y
            BEQ :+
                INC cursor_y
            :
            PLA
            JMP @invest_DOWN_end
        @invest_LEFT:
            PHA
            LDA cursor_x
            BEQ :+
                DEC cursor_x
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
