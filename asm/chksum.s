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
            ldy     STARTH      ; init CUR with START
            sty     CURH
            ldy     #0
            sty     CURL
            ldy     STARTL
LOOP1
            eor     (CURL),y    ; EOR
            ldx     CURH        ; is last page ?
            cpx     ENDH
            bcs     LASTPAGE    ; yes -> LASTPAGE
            iny
            bne     LOOP1
            inc     CURH
            jmp     LOOP1
LASTPAGE
            iny
            beq     EXIT        ; last iter when CURL==$FF gives 0 -> EXIT
            cpy     ENDL
            bcc     LOOP1       ; <
            beq     LOOP1       ; =
EXIT
            sta     RES         ; store result
            jsr     COUTBYTE    ; and print
            rts
COUT4
            ora     #$B0        ; convert to ASCII for number
            cmp     #$BA        ; > BA (3A|80) -> not number but [A-F], need to add 6
            bcc     .L1
            adc     #$06
.L1
            jsr     COUT1
            rts
COUTBYTE
            pha                 ; push A for low nibble
            lsr                 ; >> 4
            lsr
            lsr
            lsr
            jsr     COUT4       ; display high nibble
            pla
            and     #$0F
            jsr     COUT4       ; display low nibble
            rts
