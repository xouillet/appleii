; Will do an EOR on a memory range
; Usage: to do between 2A0 and 2E5
; FA: A0 02 E5 02
;

STARTL      equ     $FA
STARTH      equ     $FB
ENDL        equ     $FC
ENDH        equ     $FD
CURL        equ     $FE
CURH        equ     $FF
RES         equ     $EC
COUT1       equ     $FDF0

            org     $2A0
INIT
            ldy     STARTH
            sty     CURH
            ldy     STARTL
            sty     CURL
            ldy     #0
LOOP1
            eor     (CURL),y
            ldx     CURH
            cpx     ENDH
            bcs     LASTPAGE
            inc     CURL
            bne     LOOP1
            inc     CURH
            jmp     LOOP1
LASTPAGE
            inc     CURL
            ldx     CURL
            cpx     ENDL
            bcc     LOOP1
            beq     LOOP1
            sta     RES
            jsr     COUTBYTE
            rts
COUT4
            and     #$0F
            ora     #$B0        ; convert to ASCII for number
            cmp     #$BA        ; > BA (3A|80) -> not number but [A-F], need to add 6
            bcc     .L1
            adc     #$06
.L1
            jsr     COUT1
            rts
COUTBYTE
            pha
            pha
            lsr
            lsr
            lsr
            lsr
            jsr     COUT4
            pla
            jsr     COUT4
            pla
            rts
