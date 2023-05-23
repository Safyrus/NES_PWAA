; use: A
wait_next_frame:
    ; wait for next frame to start
    @wait_vblank:
        BIT nmi_flags
        BPL @wait_vblank

    ; acknowledge nmi
    and_adr nmi_flags, #($FF-NMI_DONE)

    RTS

update_screen_scroll:
    PHA
    ; update high scroll
    and_adr ppu_ctrl_val, #$FE
    LDA effect_flags
    AND #EFFECT_FLAG_NT
    LSR
    LSR
    ORA ppu_ctrl_val
    STA ppu_ctrl_val
    STA PPU_CTRL
    ; update mmmc5 high upper chr bits
    LDA img_header
    AND #$03
    STA mmc5_upper_chr
    ; return
    PLA
    RTS


; X = input page
; Y = output page
cp_page:
    push_ay
    push tmp+0
    push tmp+1
    push tmp+2
    push tmp+3

    @in = tmp+0
    @out = tmp+2

    STX @in+1
    STY @out+1
    LDY #$00
    STY @in+0
    STY @out+0
    @loop:
        LDA (@in), Y
        STA (@out), Y
    to_y_inc @loop, #0

    pull tmp+3
    pull tmp+2
    pull tmp+1
    pull tmp+0
    pull_ay
    RTS


; A / tmp
; X = result
; A = remainder
div:
    LDX #$FF
    @loop:
        sub tmp
        INX
        BCS @loop
    BNE @end
        INX
    @end:
    ADC tmp
    RTS
