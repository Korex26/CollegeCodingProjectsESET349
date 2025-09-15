; Lab 1
	area Lab1, code, readonly
	export __main
		
__main proc
	ldr r0, = 0x20000008
	ldr r1, = 0xABCD1234
	
	str r1, [r0]
	
	ldr r0, = 0x20002007
	add r1, #0x1F
	str r1, [r0]
	
	add r1, #0x2F
	add r10, r0, #23
	str r1, [r10]
	
	ldr r5, [r10]
	
	endp
	end