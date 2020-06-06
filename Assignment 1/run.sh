nasm -fbin loader.asm -o loader.bin
nasm -fbin printmessage.asm -o printmessage.bin
cat loader.bin printmessage.bin > res.bin
qemu-system-i386 res.bin
