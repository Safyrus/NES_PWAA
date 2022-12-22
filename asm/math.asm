.macro inc_16 adr
    .local @end
    INC adr+0
    BNE @end
        INC adr+1
    @end:
.endmacro
