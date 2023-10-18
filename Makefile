TARGET_NAME ?= app
TARGET_ELF  ?= $(TARGET_NAME).elf
TARGET_HEX  ?= $(TARGET_NAME).hex
TARGET_BIN  ?= $(TARGET_NAME).bin

OPENOCD := /home/pawel/ch32v/toolchain/openocd-riscv/

# Toolchain local (12.3.0-1): https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases
# PREFIX := /home/pawel/ch32v/toolchain/12.3.0-1/bin/
# PREFIX := /home/pawel/Pobrane/xpack-riscv-none-elf-gcc-13.2.0-2/bin/
# AS := $(PREFIX)riscv-none-elf-gcc
# CC := $(PREFIX)riscv-none-elf-gcc
# CXX := $(PREFIX)riscv-none-elf-g++
# OBJCOPY := $(PREFIX)riscv-none-elf-objcopy
# SIZE := $(PREFIX)riscv-none-elf-size

PREFIX := /home/pawel/ch32v/toolchain/8.2.0/bin/
AS := $(PREFIX)riscv-none-embed-gcc
CC := $(PREFIX)riscv-none-embed-gcc
CXX := $(PREFIX)riscv-none-embed-lf-g++
OBJCOPY := $(PREFIX)riscv-none-embed-objcopy
SIZE := $(PREFIX)riscv-none-embed-size


BUILD_DIR ?= ./build
SRC_DIRS ?= ./src ./inc ./vendor/Core ./vendor/Debug ./vendor/Peripheral ./vendor/Startup ./vendor/User

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c -or -name *.S)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

FLAGS = -march=rv32imac -mabi=ilp32 -g -Og -static-libgcc -msmall-data-limit=8 -mno-save-restore -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wunused -Wuninitialized
ASFLAGS = -march=rv32imac $(FLAGS) -x assembler $(INC_FLAGS) -MMD -MP
CFLAGS = -march=rv32imac $(FLAGS) -std=gnu99
CPPFLAGS = $(FLAGS) $(INC_FLAGS) -std=gnu99 -MMD -MP
LDFLAGS = -march=rv32imac $(FLAGS) -T ./vendor/Ld/Link.ld -nostartfiles -Xlinker --gc-sections -Wl,-Map,"$(BUILD_DIR)/CH32V203.map" --specs=nano.specs --specs=nosys.specs


$(BUILD_DIR)/$(TARGET_ELF): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)
	$(OBJCOPY) -Oihex   $@ $(BUILD_DIR)/$(TARGET_HEX)
	$(OBJCOPY) -Obinary $@ $(BUILD_DIR)/$(TARGET_BIN)
#	sz $(BUILD_DIR)/$(TARGET_BIN)

# assembly
$(BUILD_DIR)/%.S.o: %.S
	$(MKDIR_P) $(dir $@)
	$(CC) $(ASFLAGS) -c $< -o $@

# c source
$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# c++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@


.PHONY: clean

clean:
	$(RM) -r $(BUILD_DIR)

size:
	$(SIZE) $(BUILD_DIR)/$(TARGET_ELF)

flash:
	$(OPENOCD)openocd -f $(OPENOCD)wch-riscv.cfg -c init -c halt -c "program $(BUILD_DIR)/$(TARGET_ELF)" -c exit

reset:
	$(OPENOCD)openocd -f $(OPENOCD)wch-riscv.cfg -c init -c halt -c wlink_reset_resume -c exit

erase:
	$(OPENOCD)openocd -f $(OPENOCD)wch-riscv.cfg -c init -c halt -c "flash erase_sector wch_riscv 0 last" -c exit

upload: flash reset

-include $(DEPS)

MKDIR_P ?= mkdir -p
