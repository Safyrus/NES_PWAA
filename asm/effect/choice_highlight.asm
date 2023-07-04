choice_highlight:
    ; choice highlight
    LDA max_choice
    bze @choice_highlight_end
        ; if we need to init the choice display
        BPL :+
            AND #$7F
            STA max_choice
            JSR act_display
        :

        ; 
        @wait:
            LDX background_index
            BNE @wait
        LDA max_choice
        ORA #$80
        STA background, X
        INX
        LDA #(>PPU_NAMETABLE_0)+1
        STA background, X
        INX
        LDA #$02
        STA background, X
        INX

        LDY #$00
        @choice_highlight_loop:
            CPY choice
            BEQ @choice_highlight_yes
            @choice_highlight_no:
                LDA #BOX_TILE_M
                BNE @choice_highlight_next
            @choice_highlight_yes:
                LDA #ACT_SPR_TILE
            @choice_highlight_next:
            STA background, X
            INX
            INY
            CPY max_choice
            BNE @choice_highlight_loop

        STX background_index
        LDA #$00
        STA background, X

    @choice_highlight_end:
