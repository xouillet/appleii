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
CRCL        equ     $EC
CRCH        equ     $ED
COUT1       equ     $FDF0


            org     $280
INIT
            ldy     STARTH      ; init CUR with START
            sty     CURH
            ldy     #$FF
            sty     CRCL
            sty     CRCH
            iny                 ; Y = 0
            sty     CURL
            ldy     STARTL
LOOP1
            lda     (CURL),y
            jsr     CALC
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
            lda     CRCH
            jsr     COUTBYTE    ; and print
            lda     CRCL
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

CALC                            ; add byte to XMODEM CRC
            eor     CRCH        ; A contained the data
            sta     CRCH        ; XOR it into high byte
            lsr                 ; right shift A 4 bits
            lsr                 ; to make top of x^12 term
            lsr                 ; ($1...)
            lsr
            tax                 ; save it
            asl                 ; then make top of x^5 term
            eor     CRCL        ; and XOR that with low byte
            sta     CRCL        ; and save
            txa                 ; restore partial term
            eor     CRCH        ; and update high byte
            sta     CRCH        ; and save
            asl                 ; left shift three
            asl                 ; the rest of the terms
            asl                 ; have feedback from x^12
            tax                 ; save bottom of x^12
            asl                 ; left shift two more
            asl                 ; watch the carry flag
            eor     CRCH        ; bottom of x^5 ($..2.)
            sta     CRCH        ; save high byte
            txa                 ; fetch temp value
            rol                 ; bottom of x^12, middle of x^5!
            eor     CRCL        ; finally update low byte
            ldx     CRCH        ; then swap high and low bytes
            sta     CRCH
            stx     CRCL
            rts                 ; 40 bytes, 72 cycles, AXP undefined
