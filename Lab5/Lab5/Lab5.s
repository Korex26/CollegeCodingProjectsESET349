        AREA lab5, CODE, READONLY
        EXPORT _main

_main   PROC
        ; Enable GPIOC clock
        LDR R0, =0x40023830      ; RCC_AHB1ENR address
        LDR R1, [R0]             ; Load current value of RCC_AHB1ENR
        ORR R1, R1, #0x00000004  ; Enable GPIOC clock (set bit 2)
        STR R1, [R0]             ; Write back to RCC_AHB1ENR

        ; Configure GPIOC pins
        LDR R0, =0x40020800      ; GPIOC base address
        LDR R1, [R0, #0x00]      ; Load GPIOC_MODER register

        ; Configure PC0 - PC3 as inputs (00)
        BIC R1, R1, #0x000000FF  ; Clear MODER bits for PC0-PC3

        ; Configure PC4 - PC7 as outputs (01)
        ORR R1, R1, #0x00005500  ; Set MODER bits for PC4-PC7 (01)
        STR R1, [R0, #0x00]      ; Write back to GPIOC_MODER

        ; Configure pull-up resistors for PC0 to PC3
        MOV R1, #0x00000055      ; Pull-up (01) for PC0 - PC3
        STR R1, [R0, #0x0C]      ; Write to GPIOC_PUPDR

repeat
        MOV R5, #0x00            ; Clear output byte
        LDRB R3, [R0, #0x10]     ; Read GPIOC_IDR

check0
        AND R4, R3, #0x01
        CMP R4, #0x01
        BNE check1
        ORR R5, R5, #0x10

check1
        AND R4, R3, #0x02
        CMP R4, #0x02
        BNE check2
        ORR R5, R5, #0x20

check2
        AND R4, R3, #0x04
        CMP R4, #0x04
        BNE check3
        ORR R5, R5, #0x40

check3
        AND R4, R3, #0x08
        CMP R4, #0x00
        BEQ headlight_on

        B no_headlight

headlight_on
        ORR R5, R5, #0x80

no_headlight
        STRB R5, [R0, #0x14]     ; Write to GPIOC_ODR
        B repeat

        ENDP
        END
