CRC         equ     $EB
STARTL      equ     $FA
STARTH      equ     $FB
ENDL        equ     $FC
ENDH        equ     $FD
CURL        equ     $FE
CURH        equ     $FF
COUT1       equ     $FDF0
CRCT0       equ     $2000       ; Four 256-byte tables
CRCT1       equ     $2100       ; (should be page-aligned for speed)
CRCT2       equ     $2200
CRCT3       equ     $2300

            org     $280
INIT
            jsr     MAKECRCTABLE
            ldy     STARTH      ; init CUR with START
            sty     CURH
            ldy     #$ff
            sty     CRC
            sty     CRC+1
            sty     CRC+2
            sty     CRC+3
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
            ldy     #3          ; eor $FFFFFFFF at the end
COMPL       lda     CRC,Y
            eor     #$FF
            sta     CRC,Y
            jsr     COUTBYTE    ; and print
            dey
            bpl     COMPL
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

MAKECRCTABLE:
            ldx     #0          ; X counts from 0 to 255
BYTELOOP    lda     #0          ; A contains the high byte of the CRC-32
            sta     CRC+2       ; The other three bytes are in memory
            sta     CRC+1
            stx     CRC
            ldy     #8          ; Y counts bits in a byte
BITLOOP     lsr                 ; The CRC-32 algorithm is similar to CRC-16
            ror     CRC+2       ; except that it is reversed (originally for
            ror     CRC+1       ; hardware reasons). This is why we shift
            ror     CRC         ; right instead of left here.
            bcc     NOADD       ; Do nothing if no overflow
            eor     #$ED        ; else add CRC-32 polynomial $EDB88320
            pha                 ; Save high byte while we do others
            lda     CRC+2
            eor     #$B8        ; Most reference books give the CRC-32 poly
            sta     CRC+2       ; as $04C11DB7. This is actually the same if
            lda     CRC+1       ; you write it in binary and read it right-
            eor     #$83        ; to-left instead of left-to-right. Doing it
            sta     CRC+1       ; this way means we won't have to explicitly
            lda     CRC         ; reverse things afterwards.
            eor     #$20
            sta     CRC
            pla                 ; Restore high byte
NOADD       dey
            bne     BITLOOP     ; Do next bit
            sta     CRCT3,X     ; Save CRC into table, high to low bytes
            lda     CRC+2
            sta     CRCT2,X
            lda     CRC+1
            sta     CRCT1,X
            lda     CRC
            sta     CRCT0,X
            inx
            bne     BYTELOOP    ; Do next byte
            rts

UPDCRC:
            eor     CRC         ; Quick CRC computation with lookup tables
            tax
            lda     CRC+1
            eor     CRCT0,X
            sta     CRC
            lda     CRC+2
            eor     CRCT1,X
            sta     CRC+1
            lda     CRC+3
            eor     CRCT2,X
            sta     CRC+2
            lda     CRCT3,X
            sta     CRC+3
            rts
