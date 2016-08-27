all:
	nasm -o boot.bin boot.asm

run:
	qemu-system-x86_64 -drive file=boot.bin,format=raw

clean:
	rm -f boot.bin
