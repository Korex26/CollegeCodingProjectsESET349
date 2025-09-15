        AREA Lab4, CODE, READONLY
        EXPORT __main

__main  PROC

        ; Enable GPIOC clock
        LDR R0, =0x40023830      ; RCC_AHB1ENR address
        MOV R1, #0x00000004      ; Enable GPIOC (bit 2) 
        STR R1, [R0]             ; Write to RCC_AHB1ENR

        ; Configure PC0 as input and PC1, PC2 as outputs
        LDR R0, =0x40020800      ; GPIOC base address
        LDR R1, [R0, #0x00]      ; Load GPIOC_MODER register
        BIC R1, R1, #0x00000003  ; Clear bits 1:0 for PC0 (input)
        ORR R1, R1, #(0x01 << 2) ; Set PC1 as output (01)
        ORR R1, R1, #(0x01 << 4) ; Set PC2 as output (01)
        STR R1, [R0, #0x00]      ; Write back to GPIOC_MODER

        ; Configure pull-up for PC0 (input pin)
        LDR R1, [R0, #0x0C]      ; Load GPIOC_PUPDR register
        BIC R1, R1, #0x00000003  ; Clear bits 1:0 for PC0 (no pull)
        ORR R1, R1, #0x00000001  ; Set pull-up for PC0 (01)
        STR R1, [R0, #0x0C]      ; Write back to GPIOC_PUPDR

repeat  ; Loop to read input and toggle LEDs
        LDR R2, [R0, #0x10]      ; Load GPIOC_IDR (input data register)
        AND R2, R2, #0x01        ; Mask PC0 (bit 0) to isolate its value
        CMP R2, #0x01            ; Compare masked value with 0x01 (PC0 high?)
        BEQ led1_on              ; If PC0 is high, jump to LED1_ON

        ; If PC0 is low (button pressed)
        MOV R3, #0x00000004      ; Set PC2 high (LED2 on), PC1 low (LED1 off)
        STR R3, [R0, #0x14]      ; Write to GPIOC_ODR
        B repeat                 ; Repeat the loop

led1_on ; If PC0 is high (button not pressed)
        MOV R3, #0x00000002      ; Set PC1 high (LED1 on), PC2 low (LED2 off)
        STR R3, [R0, #0x14]      ; Write to GPIOC_ODR
        B repeat                 ; Repeat the loop

        ENDP
        END
