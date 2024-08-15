ASM = nasm
SRC_DIR = ./src
BUILD_DIR = ./build
BOOTSTRAP_FILE = $(SRC_DIR)/bootstrap.asm
BOOTSTRAP_OBJ = $(BUILD_DIR)/bootstrap.o
KERNEL_FILE = $(SRC_DIR)/simple_kernel.asm
KERNEL_OBJ = $(BUILD_DIR)/kernel.o
KERNEL_IMG = $(BUILD_DIR)/kernel.img


build_kernel:  $(BOOTSTRAP_FILE) $(KERNEL_FILE)
	$(ASM) -f bin $(BOOTSTRAP_FILE) -o $(BOOTSTRAP_OBJ)
	$(ASM) -f bin $(KERNEL_FILE) -o $(KERNEL_OBJ)
	dd if=$(BOOTSTRAP_OBJ) of=$(KERNEL_IMG)
	dd seek=1 conv=sync if=$(KERNEL_OBJ) of=$(KERNEL_IMG) bs=512
	qemu-system-x86_64 -s $(KERNEL_IMG)

clean:
	rm -f $(BUILD_DIR)/*.o $(KERNEL_IMG)
