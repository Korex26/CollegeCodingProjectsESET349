		AREA Part2LEDControl, CODE, READONLY
        EXPORT __main

		; Hardware Setup
		; Motion Sensor1 OUT pin to PC8 STM pin
		; Motion Sensor1 VCC pin to 5V STM pin
		; Motion Sensor1 GND pin to GND STM pin
		; Motion Sensor2 OUT pin to PC9 STM pin
		; Motion Sensor2 VCC pin to 5V STM pin
		; Motion Sensor2 GND pin to GND STM pin
		; Motion Sensor3 OUT pin to PC10 STM pin
		; Motion Sensor3 VCC pin to 5V STM pin
		; Motion Sensor3 GND pin to GND STM pin
		; Motion Sensor4 OUT pin to PC11 STM pin
		; Motion Sensor4 VCC pin to 5V STM pin
		; Motion Sensor4 GND pin to GND STM pin
		; Red LED Anode pin to PC12 STM pin
		; Red LED Cathode pin to 220 Ohm Resistor to GND STM pin
		; Green LED Anode pin to PC13 STM pin
		; Green LED Cathode pin to 220 Ohm Resistor to GND STM pin

__main   PROC

        ; Enable GPIOC clock
        LDR R0, =0x40023830      ; RCC_AHB1ENR address
        LDR R1, [R0]             ; Load current value of RCC_AHB1ENR
        ORR R1, R1, #0x00000004  ; Enable GPIOC clock (set bit 2)
        STR R1, [R0]             ; Write back to RCC_AHB1ENR

        ; Configure GPIOC pins
        LDR R0, =0x40020800      ; GPIOC base address
        LDR R1, [R0, #0x00]      ; Load GPIOC_MODER register

        ; Configure PC8 - PC11 as inputs (00)
        BIC R1, R1, #0x0000FF00  ; Clear MODER bits for PC8-PC11 (4 pins * 2 bits = 8 bits)

        ; Configure PC12 and PC13 as outputs (01)
        ORR R1, R1, #0x01000000  ; Set MODER bits for PC12 (01)
        ORR R1, R1, #0x04000000  ; Set MODER bits for PC13 (01)
        STR R1, [R0, #0x00]      ; Write back to GPIOC_MODER

        ; Configure pull-up resistors for PC8 to PC11 (01 in PUPDR)
        MOV R1, #0x00005500      ; Pull-up (01) for PC8 - PC11
        STR R1, [R0, #0x0C]      ; Write to GPIOC_PUPDR

repeat  ; Main loop to read inputs and control LEDs

        MOV R5, #0x00            ; Clear output byte (R5)
        LDR R3, [R0, #0x10]      ; Read GPIOC_IDR (input data register)

check0  ; Check PC8 (1st Motion Sensor)
        AND R4, R3, #0x0100      ; Mask for PC8 (bit 8)
        CMP R4, #0x0100          ; Check if PC8 is high (no obstacle)
        BNE check1               ; If not high, skip to check1
        ORR R5, R5, #0x1000      ; Set PC12 (red LED) in R5

check1  ; Check PC9 (2nd Motion Sensor)
        AND R4, R3, #0x0200      ; Mask for PC9 (bit 9)
        CMP R4, #0x0200          ; Check if PC9 is high
        BNE check2               ; If not, skip to check2
        ORR R5, R5, #0x2000      ; Set PC13 (green LED) in R5

check2  ; Check PC10 (3rd Motion Sensor)
        AND R4, R3, #0x0400      ; Mask for PC10 (bit 10)
        CMP R4, #0x0400          ; Check if PC10 is high
        BNE check3               ; If not, skip to check3
        ORR R5, R5, #0x1000      ; Set PC12 (red LED) in R5 (same as PC8)

check3  ; Check PC11 (4th Motion Sensor)
        AND R4, R3, #0x0800      ; Mask for PC11 (bit 11)
        CMP R4, #0x0800          ; Check if PC11 is high
        BNE updateLED            ; If not high, skip to no_headlight
        ORR R5, R5, #0x1000      ; Set PC12 (red LED) in R5

updateLED
        ; Write to GPIOC_ODR (output data register)
        STRH R5, [R0, #0x14]     ; Update LEDs based on sensor input

        B repeat                 ; Repeat the loop

        ENDP
        END
