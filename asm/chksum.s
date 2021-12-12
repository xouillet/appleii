; Will do an EOR on a memory range
; Usage: to do between 2A0 and 2DE
; FA: A0 02 DE 02
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
            lda     #0
            sta     CURL
            sta     RES
            ldx     STARTH
            stx     CURH
            ldy     STARTL
LOOP1
            ldx     CURH
            cpx     ENDH
            bcs     LASTLOOP    ; branch for lastloop

            eor     (CURL),y

            iny                 ; next byte
            bne     LOOP1       ;
            inc     CURH        ; next page
            jmp     LOOP1
LASTLOOP    
            eor     (CURL),y

            iny                 ; next byte
            cpy     ENDL
            bcc     LASTLOOP
FINISH
            sta     RES
            jsr     COUTBYTE
            rts
COUT4
            and     #$0F
            ora     #$B0        ; convert to ASCII for number
            cmp     #$BA        ; > BA (3A|80) -> not number but [A-F], need to add 6
            bcc     COUTN
            adc     #$06
COUTN
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
