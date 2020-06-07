;setting the location counter to the boot loader location
org 0x7c00

;real mode
bits 16
	
boot: 	;position of the video memory in RAM
	push 0xb800

	;Set ES to the Video Memory
	pop es

	;Clear screen
	mov ax, 0x0100
	call cls

	;Print the message
	call print

	;freezing the system for testing
	jmp $

	;making the real system halt
	hlt

	;making qemu halt
	ret


cls:
	;setting the DI register to 0
	xor di,di

	;Default console size (80 rows and 25 columns)
	mov cx, 80*25

	repnz stosw
	ret


print:
	;setting the Di register to 0
	xor di, di

	;setting position of the text on the screen
	add di, 800


.loop:	;interrupt for reading the key from keyboard into al
	mov ah, 0x00
	int 16H

	mov ah, 0x2f

	; Storing AX (color in ah and character in al)
        stosw

	;printing next character
	jmp .loop

.end:	ret


;Making it a disk sector with scaling
times 512-($-$$) db 0


;MBR Signature
db 0x55 ;byte 511 = 0x55
db 0xAA ;byte 512 = 0xAA
