CRC         equ     $EB
STARTL      equ     $FA
STARTH      equ     $FB
ENDL        equ     $FC
ENDH        equ     $FD
CURL        equ     $FE
CURH        equ     $FF
COUT1       equ     $FDF0
TBLCRCL     equ     $2000       ; Two 256-byte tables for quick lookup
TBLCRCH     equ     $2100       ; (should be page-aligned for speed)

            org     $280
INIT
            jsr     MAKECRCTABLE
            ldy     STARTH      ; init CUR with START
            sty     CURH
            ldy     #$ff
            sty     CRC
            sty     CRC+1
            iny                 ; Y = 0
            sty     CURL
            ldy     STARTL
LOOP1
            lda     (CURL),y
            jsr     UPDCRC
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
            lda     CRC+1
            jsr     COUTBYTE    ; and print
            lda     CRC
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

UPDCRC
            eor     CRC+1       ; Quick CRC computation with lookup tables
            tax
            lda     CRC
            eor     TBLCRCH,X
            sta     CRC+1
            lda     TBLCRCL,X
            sta     CRC
            rts

MAKECRCTABLE
            ldx     #0          ; X counts from 0 to 255
BYTELOOP    lda     #0          ; A contains the low 8 bits of the CRC-16
            stx     CRC         ; and CRC contains the high 8 bits
            ldy     #8          ; Y counts bits in a byte
BITLOOP     asl
            rol     CRC         ; Shift CRC left
            bcc     NOADD       ; Do nothing if no overflow
            eor     #$21        ; else add CRC-16 polynomial $1021
            pha                 ; Save low byte
            lda     CRC         ; Do high byte
            eor     #$10
            sta     CRC
            pla                 ; Restore low byte
NOADD       dey
            bne     BITLOOP     ; Do next bit
            sta     TBLCRCL,X     ; Save CRC into table, low byte
            lda     CRC         ; then high byte
            sta     TBLCRCH,X
            inx
            bne     BYTELOOP    ; Do next byte
            rts

