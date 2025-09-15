        AREA lab5, CODE, READONLY
        EXPORT __main

        ; Hardware setup
        ; PC0, PC1, PC2, PC3: obstacle sensors (inputs)
        ; PC4, PC5, PC6: obstacle LEDs (outputs)
        ; PC7: headlight (output)

__main   PROC

        ; Enable GPIOC clock
        LDR R0, =0x40023830      ; RCC_AHB1ENR address
        LDR R1, [R0]             ; Load current value of RCC_AHB1ENR
        ORR R1, R1, #0x00000004  ; Enable GPIOC clock (set bit 2)
        STR R1, [R0]             ; Write back to RCC_AHB1ENR

        ; Configure GPIOC pins
        LDR R0, =0x40020800      ; GPIOC base address
        LDR R1, [R0, #0x00]      ; Load GPIOC_MODER register

        ; Configure PC0 - PC3 as inputs (00)
        BIC R1, R1, #0x000000FF  ; Clear MODER bits for PC0-PC3 (4 pins * 2 bits = 8 bits)

        ; Configure PC4 - PC7 as outputs (01)
        ORR R1, R1, #0x00005500  ; Set MODER bits for PC4-PC7 (01 in pairs of 2 bits)
        STR R1, [R0, #0x00]      ; Write back to GPIOC_MODER

        ; Configure pull-up resistors for PC0 to PC3 (01 in PUPDR)
        MOV R1, #0x00000055      ; Pull-up (01) for PC0 - PC3
        STR R1, [R0, #0x0C]      ; Write to GPIOC_PUPDR

repeat  ; Main loop to read inputs and control LEDs

        MOV R5, #0x00            ; Clear output byte (R5)
        LDRB R3, [R0, #0x10]     ; Read GPIOC_IDR (input data register)

check0  ; Check PC0 (Rear sensor)
        AND R4, R3, #0x01        ; Mask for PC0 (bit 0)
        CMP R4, #0x01            ; Check if PC0 is high (no obstacle)
        BNE check1               ; If not high, skip to check1
        ORR R5, R5, #0x10        ; Set PC4 (rear LED) in R5

check1  ; Check PC1 (Left sensor)
        AND R4, R3, #0x02        ; Mask for PC1 (bit 1)
        CMP R4, #0x02            ; Check if PC1 is high
        BNE check2               ; If not, skip to check2
        ORR R5, R5, #0x20        ; Set PC5 (left LED) in R5

check2  ; Check PC2 (Right sensor)
        AND R4, R3, #0x04        ; Mask for PC2 (bit 2)
        CMP R4, #0x04            ; Check if PC2 is high
        BNE check3               ; If not, skip to check3
        ORR R5, R5, #0x40        ; Set PC6 (right LED) in R5

check3  ; Check PC3 (Photoresistor for headlight)
        AND R4, R3, #0x08        ; Mask for PC3 (bit 3)
        CMP R4, #0x00            ; Check if PC3 is low (dark)
        BEQ headlight_on         ; If low, turn on headlight

        B no_headlight           ; Otherwise, skip

headlight_on
        ORR R5, R5, #0x80        ; Set PC7 (headlight LED) in R5

no_headlight
        ; Write to GPIOC_ODR (output data register)
        STRB R5, [R0, #0x14]     ; Update LEDs based on sensor input

        B repeat                 ; Repeat the loop

        ENDP
        END
