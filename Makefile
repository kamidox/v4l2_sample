#CC = /pitools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-gcc
CC = gcc
INCLUDE += -I/build/rootfs/usr/include
LDFLAGS += -L/build/rootfs/lib -L/build/rootfs/usr/lib

all: capturer_mmap capturer_read viewer

capturer_mmap: capturer_mmap.c
	$(CC) -O2 -o capturer_mmap capturer_mmap.c

capturer_read: capturer_read.c
	$(CC) -O2 $(INCLUDE) $(LDFLAGS) -o capturer_read capturer_read.c

viewer: viewer.c
	$(CC) -O2 $(INCLUDE) $(LDFLAGS) -lX11 -lXext -o viewer viewer.c

clean:
	rm -f capturer_mmap
	rm -f capturer_read
	rm -f viewer
