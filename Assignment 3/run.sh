nasm -fbin loader.asm -o loader.bin
nasm -fbin matrix_transpose.asm -o matrix_transpose.bin
cat loader.bin matrix_transpose.bin > res.bin
qemu-system-i386 res.bin
