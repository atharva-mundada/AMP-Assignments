;real mode
bits 16

;jumping to the boot sector position
org 0x7c00

boot:	
	;video ram position in ex using ax
	mov ax, 0xB800
	mov es, ax

	;interrupt for pressing a key
	mov ah, 0x00
	int 0x16

	;background color
	mov ax, 0x1e00	
	
	;clear the screen
	;clearing the Di register
	xor di,di

	;the default console size
	mov cx, 80*24

	repnz stosw

	
	;setting the color of the message
	mov ah, 0x1f
	;getting to the start location of the message for the real mode
	mov si, msg_r
	
	;clearing the DI register
	xor di, di

	.loop:	;loads byte from SI into AL and increment SI for the next character
		lodsb

		;test condition for end of string
		test al, al
		jz .end
		
		;Storing AX (char + color)
		stosw
		;printing the next character
		jmp .loop

	.end: 	

	;at the end of the real mode message moving to the protected mode message by a keypress
	mov ah, 0x00
	int 0x16
		
	;Color of the background
	mov ax, 0x0000
	
	;Clearing the Screen
	;Clearing DI register
	xor di,di

	;the default size of the console
	mov cx, 80*24

        repnz stosw
	
	
	;for the protected mode we load the gdt table with the required descriptors
	;loading the gdt table
	lgdt [gdt_pointer]
	
	;set the protected mode bit on special CPU reg cr0 to go in the protected mode
	mov eax, cr0 
	or eax, 0x1
	mov cr0, eax

	;long jump to the code segment
	jmp CODE_SEG: boot2


;The data and information of the gdt table
;the null descriptor at the beginning of the table
gdt_start:
    	dq 0x0

;the code segment descriptor
gdt_code:
	dw 0xFFFF	;the size field
	dw 0x0
	db 0x0
	db 10011010b	;the access right byte
	db 11001111b
	db 0x0

;the data segment descriptor
gdt_data:
	dw 0xFFFF	;the size field
    	dw 0x0
    	db 0x0
    	db 10010010b	;the access right byte
    	db 11001111b
    	db 0x0

gdt_end:

;setting the gdt pointer
gdt_pointer:
    	dw gdt_end - gdt_start
    	dd gdt_start

;Getting the code segment and the data segment start point
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start


;the protected mode
bits 32
boot2:
	;initializing all the segments
	mov ax, DATA_SEG
    	mov ds, ax
    	mov es, ax
   	mov fs, ax
    	mov gs, ax
    	mov ss, ax
	
	;getting the protected mode message into the esi register
    	mov ah, 0x1f
    	mov esi, msg_p

	;the video ram
    	mov ebx, 0xb8000


.loop:
	;loading the message byte
    	lodsb

	;ending the code
    	or al,al
    	jz halt

    	or eax, 0x0100
    	mov word [ebx], ax
    	add ebx,2
    	jmp .loop


;halting the code
halt:  	;returning back to the real mode
	mov eax, cr0
	and eax,0xfffffffe
    	mov cr0, eax

       	cli
       	hlt


;Displaying the message	
display:
	;clearing the DI register
	xor   di, di

	.loop:	;loading byte from SI into AL and increamenting SI
		lodsb

		;testing the end of string
		test  al, al
		jz .end
		
		;Storing AX (char + color)
		stosw
		;printing the next character
		jmp .loop

	.end:	ret


;the two messages for the real and the protected mode
msg_p db "Protected Mode", 0
msg_r db "Real Mode", 0

;Making it a disk sector with scaling
times 510-($-$$) db 0


;MBR Signature
db 0x55 ;byte 511 = 0x55
db 0xAA ;byte 512 = 0xAA
