			area lab2code, code, readonly
byteData 	dcb 0x23, 0xAB, 48, 0x9F, 0xFF ; data can be declared in 'code' area 
byteDataLen equ 5
wordDataLen equ 5

			export __main
__main 		proc

; TASKS 1&2
; moving (dealing) one-byte (8-bit) data
			ldr r0, =0x20002000
			ldr r1, =byteData
			mov r12, #0
moreBytes	ldrb r3, [r1]
			strb r3, [r0]
			add r12, #1
			add r0, #1
			add r1, #1
			cmp r12, #byteDataLen 
			bne moreBytes
			
; TASK 3
; moving (dealing) with 4-byte data
			ldr r0, =0x20004000
			ldr r1, =wordData
			mov r12, #0
moreWords	ldr r3, [r1]
			str r3, [r0]
			add r12, #1
			add r0, #4
			add r1, #4
			cmp r12, #wordDataLen
			bne moreWords

; TASK 4
; Find the largest value from the word data array
			mov r8, #0

			ldr r1, = wordData 
			mov r12, #0
moreToGo 	ldr r3, [r1] 
			cmp r3, r8 
			blt skip

			mov r8, r3
skip 		add r12, #1
			add r0, #4
			add r1, #4
			cmp r12, #wordDataLen
			bne moreToGo
			
			endp
			
			
			area lab2data, data, readonly
wordData	dcd 0x12345678, 0x2BCD1234, 0x1234ABCD, 0x4FAABBCC, 8

			end