nasm -fbin loader.asm -o loader.bin
nasm -fbin kernel.asm -o kernel.bin
cat loader.bin kernel.bin > res.bin
qemu-system-i386 res.bin
