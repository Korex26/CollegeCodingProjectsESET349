			AREA Lab6, CODE, READONLY
			EXPORT __main

RS			equ 0x20	; RS connects to PA5 (bit 5)
RW			equ 0x40	; RW connects to PA6 (bit 6)
EN			equ 0x80	; EN connects to PA7 (bit 7)

__main		PROC	

			BL LCDInit

			; Send "SUCCESS" to the LCD
			MOV R3, #'S'		; Character 'S'	
			BL LCDData
			MOV R3, #'U'		; Character 'U'
			BL LCDData
			MOV R3, #'C'		; Character 'C'
			BL LCDData
			MOV R3, #'C'		; Character 'C'
			BL LCDData
			MOV R3, #'E'		; Character 'E'
			BL LCDData
			MOV R3, #'S'		; Character 'S'
			BL LCDData
			MOV R3, #'S'		; Character 'S'
			BL LCDData

			; Move to the next line and send "FAILURE"
			MOV R2, #0xC8		; Command to set cursor to the beginning of the 2nd line
			BL LCDCommand

			MOV R3, #'F'		; Character 'F'
			BL LCDData
			MOV R3, #'A'		; Character 'A'
			BL LCDData
			MOV R3, #'I'		; Character 'I'
			BL LCDData
			MOV R3, #'L'		; Character 'L'
			BL LCDData
			MOV R3, #'U'		; Character 'U'
			BL LCDData
			MOV R3, #'R'		; Character 'R'
			BL LCDData
			MOV R3, #'E'		; Character 'E'
			BL LCDData

stay		B stay				; Remain here after completion
			ENDP

LCDInit		FUNCTION
			; Enable GPIOA and GPIOC clocks
			LDR R0, =0x40023830      ; RCC_AHB1ENR address
			MOV R1, #0x00000005      ; Enable GPIOA (bit 0) and GPIOC (bit 2) clocks
			STR R1, [R0]             ; Write the value to RCC_AHB1ENR

			; Configure GPIOA and GPIOC
			LDR R0, =0x40020000		; GPIOA base address for control pins
			LDR R1, =0x40020800		; GPIOC base address for data pins 		
			LDR R2, =0x28005400     ; Set PA5, PA6, PA7 as General Purpose Output Mode 0010 1000 0000 0000 0101 0100 0000 0000 (keep PA13 & PA14 in alternative function mode)
			STR R2, [R0, #0x00]		; Configure PA5, PA6, PA7 as output pins
			
			LDR R2, =0x00015555		; Set PC0-PC7 as outputs (data pins)
			STR R2, [R1, #0x00]		; Configure PC0-PC7 as output pins

			PUSH {LR}		
			MOV R2, #0x38			; 2 lines, 5x8 characters, 8-bit mode		 
			BL LCDCommand			; Send command in R2 to LCD

			; Turn on display and cursor
			MOV R2, #0x0E			; Turn ON Display and Cursor
			BL LCDCommand

			; Clear display
			MOV R2, #0x01			; Clear the display screen
			BL LCDCommand

			; Move cursor right
			MOV R2, #0x06			; Increment Cursor
			BL LCDCommand

			POP {LR}			
			BX LR
			ENDP

LCDCommand	FUNCTION				; R2 brings in the command byte
			STRB R2, [R1, #0x14]	; Send command to data pins (PC0-PC7)
			MOV R2, #0x00			; RS = 0, RW = 0, EN = 1
			ORR R2, EN
			STRB R2, [R0, #0x14]	; Set EN = 1 (enable pulse)
			PUSH {LR}
			BL delay

			MOV R2, #0x00
			STRB R2, [R0, #0x14]	; EN = 0, RS = 0, RW = 0
			POP {LR}
			BX LR
			ENDP

LCDData		FUNCTION				; R3 brings in the character byte
			STRB R3, [R1, #0x14]	; Send character to data pins (PC0-PC7)
			MOV R2, #0x20			; RS = 1, RW = 0, EN = 1 (RS=1 for data)
			ORR R2, EN
			STRB R2, [R0, #0x14]	; Set EN = 1 (enable pulse)
			PUSH {LR}
			BL delay

			MOV R2, #0x00			; RS = 0, RW = 0, EN = 0
			STRB R2, [R0, #0x14]	; Set EN = 0
			POP {LR}
			BX LR
			ENDP
			
delay		FUNCTION
			MOV R5, #50
loop1		MOV R4, #0xFF
loop2		SUBS R4, #1
			BNE loop2
			SUBS R5, #1
			BNE loop1
			BX LR
			ENDP

			END