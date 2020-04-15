SYSROOT=/build/rootfs
CC=/build/tools/cross-pi-gcc-6.3.0-2/bin/arm-linux-gnueabihf-gcc
#CC = gcc
CFLAGS += --sysroot=$(SYSROOT) \
          -I$(SYSROOT)/usr/include/arm-linux-gnueabihf
LDFLAGS += -B$(SYSROOT)/usr/lib/arm-linux-gnueabihf \
           -Wl,-rpath-link,$(SYSROOT)/lib/arm-linux-gnueabihf \
           -Wl,-rpath-link,$(SYSROOT)/usr/lib/arm-linux-gnueabihf

all: capturer_mmap capturer_read viewer

capturer_mmap: capturer_mmap.c
	$(CC) -O2 -o capturer_mmap capturer_mmap.c

capturer_read: capturer_read.c
	$(CC) -O2 $(CFLAGS) $(LDFLAGS) -o capturer_read capturer_read.c

viewer: viewer.c
	$(CC) -O2 $(CFLAGS) $(LDFLAGS) -lX11 -lXext -o viewer viewer.c

clean:
	rm -f capturer_mmap
	rm -f capturer_read
	rm -f viewer
