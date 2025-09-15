		AREA Lab6_Game, CODE, READONLY
		EXPORT __main

RS      equ 0x20    ; RS connects to PA5 (bit 5)
RW      equ 0x40    ; RW connects to PA6 (bit 6)
EN      equ 0x80    ; EN connects to PA7 (bit 7)

__main  PROC
        BL LCDInit

        ; Display the game prompt
        MOV R3, #'G'
        BL LCDData
        MOV R3, #'U'
        BL LCDData
        MOV R3, #'E'
        BL LCDData
        MOV R3, #'S'
        BL LCDData
        MOV R3, #'S'
        BL LCDData
        MOV R3, #' '
        BL LCDData
        MOV R3, #'T'
        BL LCDData
        MOV R3, #'H'
        BL LCDData
        MOV R3, #'E'
        BL LCDData
        MOV R3, #' '
        BL LCDData
        MOV R3, #'N'
        BL LCDData
        MOV R3, #'U'
        BL LCDData
        MOV R3, #'M'
        BL LCDData
        MOV R3, #'B'
        BL LCDData
        MOV R3, #'E'
        BL LCDData
        MOV R3, #'R'
        BL LCDData

        ; Move to second line for user input
        MOV R2, #0xC0     ; Command to move to 2nd line
        BL LCDCommand

        ; Display the "enter 1, 2, 3, 4" prompt
        MOV R3, #'E'
        BL LCDData
        MOV R3, #'N'
        BL LCDData
        MOV R3, #'T'
        BL LCDData
        MOV R3, #'E'
        BL LCDData
        MOV R3, #'R'
        BL LCDData
        MOV R3, #' '
        BL LCDData
        MOV R3, #'1'
        BL LCDData
        MOV R3, #','
        BL LCDData
        MOV R3, #' '
        BL LCDData
        MOV R3, #'2'
        BL LCDData
        MOV R3, #','
        BL LCDData
        MOV R3, #' '
        BL LCDData
        MOV R3, #'3'
        BL LCDData
        MOV R3, #','
        BL LCDData
        MOV R3, #' '
        BL LCDData
        MOV R3, #'4'
        BL LCDData

        ; End the program here
        B stay             ; Stop here

stay    B stay             ; Infinite loop to keep display on

        ENDP

LCDInit FUNCTION
        ; Enable GPIOA and GPIOC clocks
        LDR R0, =0x40023830     ; RCC_AHB1ENR address
        MOV R1, #0x00000005     ; Enable GPIOA (bit 0) and GPIOC (bit 2) clocks
        STR R1, [R0]            ; Write the value to RCC_AHB1ENR

        ; Configure GPIOA and GPIOC
        LDR R0, =0x40020000     ; GPIOA base address for control pins
        LDR R1, =0x40020800     ; GPIOC base address for data pins
        LDR R2, =0x28005400     ; Set PA5, PA6, PA7 as General Purpose Output Mode
        STR R2, [R0, #0x00]     ; Configure PA5, PA6, PA7 as output pins
        
        LDR R2, =0x00015555     ; Set PC0-PC7 as outputs (data pins)
        STR R2, [R1, #0x00]     ; Configure PC0-PC7 as output pins

        ; Initialize LCD in 8-bit mode, 2-line, 5x8 characters
        PUSH {LR}
        MOV R2, #0x38          ; 2 lines, 5x8 characters, 8-bit mode
        BL LCDCommand

        ; Turn on display and cursor
        MOV R2, #0x0E          ; Turn ON Display and Cursor
        BL LCDCommand

        ; Clear display
        MOV R2, #0x01          ; Clear the display screen
        BL LCDCommand

        ; Move cursor right
        MOV R2, #0x06          ; Increment Cursor
        BL LCDCommand

        POP {LR}
        BX LR
        ENDP

LCDCommand FUNCTION          ; R2 brings in the command byte
        STRB R2, [R1, #0x14]   ; Send command to data pins (PC0-PC7)
        MOV R2, #0x00          ; RS = 0, RW = 0, EN = 1
        ORR R2, EN
        STRB R2, [R0, #0x14]   ; Set EN = 1 (enable pulse)
        PUSH {LR}
        BL delay

        MOV R2, #0x00
        STRB R2, [R0, #0x14]   ; EN = 0, RS = 0, RW = 0
        POP {LR}
        BX LR
        ENDP

LCDData FUNCTION             ; R3 brings in the character byte
        STRB R3, [R1, #0x14]   ; Send character to data pins (PC0-PC7)
        MOV R2, #0x20          ; RS = 1, RW = 0, EN = 1 (RS=1 for data)
        ORR R2, EN
        STRB R2, [R0, #0x14]   ; Set EN = 1 (enable pulse)
        PUSH {LR}
        BL delay

        MOV R2, #0x00          ; RS = 0, RW = 0, EN = 0
        STRB R2, [R0, #0x14]   ; Set EN = 0
        POP {LR}
        BX LR
        ENDP

delay FUNCTION
        MOV R5, #50
loop1   MOV R4, #0xFF
loop2   SUBS R4, #1
        BNE loop2
        SUBS R5, #1
        BNE loop1
        BX LR
        ENDP

        END
