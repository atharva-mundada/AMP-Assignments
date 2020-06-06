;setting the location counter to the boot sector location
org 0x7C00


;Reset disk system
mov ah, 0
int 0x13


;Reading from the disk and writing to the RAM
;moving the address into bx register to write the kernel code to
mov bx, 0x8500

;the amount of sectors to read is moved in the accumulator
mov al, 1

;The cylinder number and the head number are both 0
;The cylinder number is stored in ch register
mov ch, 0

;The head number is stored in the dh register
mov dh, 0

;The sector number (i.e, 2) is stored in the cl register
mov cl, 2

;Reading from the disk
mov ah, 2
int 0x13


;jumping to the kernel code and making it fit in a sector of 512 bytes
jmp 0x8500
times 510-($-$$) db 0


;Master Boot Record Signature
;byte 511 = 0x55
db 0x55
;byte 512 = 0xAA
db 0xAA
