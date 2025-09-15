        AREA Lab3, CODE, READONLY
        EXPORT __main

__main  PROC
        ; Enable GPIOA clock
        LDR R0, =0x40023830        ; RCC_AHB1ENR address
        MOV R1, #1                 ; Enable GPIOA clock
        STR R1, [R0]

        ; Configure PA5, PA6, PA7 as output (direct write)
        LDR R0, =0x40020000        ; GPIOA base address
        LDR R1, =0x28005400        ; Set PA5, PA6, PA7 as General Purpose Output Mode
        STR R1, [R0]               ; Write to GPIOA_MODER

repeat
        ; Turn on PA5
        LDR R1, =0x20              ; Set bit 5
        STR R1, [R0, #0x14]        ; Write to GPIOA_ODR to turn PA5 on
        BL delay                   ; Call delay

        ; Turn off PA5
        LDR R1, =0x00              ; Clear PA5
        STR R1, [R0, #0x14]        ; Write to GPIOA_ODR to turn PA5 off
        BL delay                   ; Call delay

        ; Turn on PA6
        LDR R1, =0x40              ; Set bit 6
        STR R1, [R0, #0x14]        ; Write to GPIOA_ODR to turn PA6 on
        BL delay                   ; Call delay

        ; Turn off PA6
        LDR R1, =0x00              ; Clear PA6
        STR R1, [R0, #0x14]        ; Write to GPIOA_ODR to turn PA6 off
        BL delay                   ; Call delay

        ; Turn on PA7
        LDR R1, =0x80              ; Set bit 7
        STR R1, [R0, #0x14]        ; Write to GPIOA_ODR to turn PA7 on
        BL delay                   ; Call delay

        ; Turn off PA7
        LDR R1, =0x00              ; Clear PA7
        STR R1, [R0, #0x14]        ; Write to GPIOA_ODR to turn PA7 off
        
		BL delay                   ; Call delay
        B repeat                   ; Repeat the sequence
        ENDP

delay   PROC
        MOV R12, #0x100              ; Outer loop constant (adjust for longer delay)
outer_loop
        MOV R11, #0x1000          ; Inner loop constant (adjust for shorter delay)
inner_loop
        SUBS R11, R11, #0x01       ; Subtract 1 from R12
        CMP R11, #0x00             ; Compare R12 with 0
        BNE inner_loop             ; Branch to continue if R12 is not zero

        SUBS R12, R12, #0x01         ; Subtract 1 from R2
        CMP R12, #0x00              ; Compare R2 with 0
        BNE outer_loop             ; Branch to continue if R2 is not zero

        BX LR                      ; Return to address in LR
        ENDP

        END
