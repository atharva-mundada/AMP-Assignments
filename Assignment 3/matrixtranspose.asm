;The code section
SECTION .text

GLOBAL _start 
_start:

;setting the location counter to the boot loader position
org 0x7C00

;real mode
bits 16

boot:   ;position of the video memory in RAM
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
	xor di, di
	mov si, mgiven
	mov cl, 8
	mov ah, 0x1e

	;printing the given matrix
	.loop:
		lodsb
		test al, al
		jz .ext
		stosw
		dec cl
		jnz .nxt
		mov cl, 8
		add di, 144
	.nxt:	jmp .loop


	;creating the transpose matrix from the original matrix / given matrix	
	.ext:
		mov si, mtranspose
		mov ax, di
		mov di, mgiven
		movq mm1, [di]
		movq mm2, [di + 8]
		movq mm3, [di + 16]
		movq mm4, [di + 24]
		punpcklbw mm1, mm2
		punpcklbw mm3, mm4
		movq mm0, mm1
		punpcklwd mm1, mm3
		punpckhwd mm0, mm3
		movq [si], mm1
		movq [si + 8], mm0
		
				
		movq mm1, [di]
		movq mm2, [di + 8]
		movq mm3, [di + 16]
		movq mm4, [di + 24]
		punpckhbw mm1, mm2
		punpckhbw mm3, mm4
		movq mm0, mm1
		punpcklwd mm1, mm3
		punpckhwd mm0, mm3
		movq [si + 24], mm0
		movq [si + 16], mm1
		
		;printing the transpose matrix
		mov di, ax
		mov ah, 0x1e
		mov si, mtranspose
		mov cl, 4
		add di, 160
		.loop2:
			lodsb
			test al, al
			jz .ext1
			stosw
			dec cl
			jnz .nxt1
			mov cl, 4
			add di,	 152
		.nxt1:	jmp .loop2

	.ext1:	ret

;Making it a disk sector with scaling
times 510-($-$$) db 0

		
;MBR Signature
db 0x55 ;byte 511 = 0x55
db 0xAA ;byte 512 = 0xAA

;Data section of the code
SECTION .DATA
	
;the given and the transpose matrix
mgiven: db "18734582749174829374829472587823", 0
mtranspose: times 32 db (0)
