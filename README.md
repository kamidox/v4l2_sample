### 功能

在 Raspberry PI 上，通过 Video 4 Linux 2 采集视频，并通过 xwindows 显示出来实时视频。示例来源: https://web.archive.org/web/20110707012738/http://alumnos.elo.utfsm.cl/~yanez/video-for-linux-2-sample-programs/

版权属于原作者。

## 使用 Docker 交叉编译

确保安装了 Docker 环境，运行如下命令：

```
docker run -it -v /Users/kamidox/work/raspberry:/build --name pi-cc mitchallen/pi-cross-compile /bin/bash
```

如果没有下载过 `mitchallen/pi-cross-compile`，则需要一定的时间下载 raspberry pi 交叉编译需要的 docker image，大概有 1.5GB。如果已经下载过，则会直接运行这个 image，并且命名为 `pi-cc`。同时，还会把本地目录 `/Users/kamidox/work/raspberry` 映射到 container 的 `/build` 目录下。

之后，就可以在 container shell 下通过 make 进行交叉编译了。如果已经运行过上面的命令，则直接通过下面的命令启动名字为 `pi-cc` 的 container，然后进入这个 container 的 shell 环境进行编译就可以了。

```
$ docker start pi-cc
pi-cc

$ docker exec -it pi-cc /bin/bash
root@6b7ac5b17190:/build#
```

### 编译

在 MacOS 上使用 Docker 交叉编译。如果要在 Raspberry PI 上编译，修改 Makefile 即可。

```
make
```

### 配置交叉编译的 rootfs

交叉编译时，需要依赖第三方库和头文件。这些头文件可以从 Raspberry Pi 板子上拷贝过来。

```
#!/bin/sh

mkdir -p ~/work/raspberrypi/rootfs
rsync -avz --delete-after --safe-links pi@192.168.31.100:/lib ~/work/raspberry/rootfs
rsync -avz --delete-after --safe-links pi@192.168.31.100:/usr/include ~/work/raspberry/rootfs/usr
rsync -avz --delete-after --safe-links pi@192.168.31.100:/usr/lib ~/work/raspberry/rootfs/usr
rsync -avz --delete-after --safe-links pi@192.168.31.100:/usr/local/include ~/work/raspberry/rootfs/usr/local
rsync -avz --delete-after --safe-links pi@192.168.31.100:/usr/local/lib ~/work/raspberry/rootfs/usr/local
```

交叉编译时，可以通过配置编译命令，让编译系统从 `~/work/raspberry/rootfs` 目录下查找头文件及需要链接的库。

### 配置交叉编译工具链

从 https://github.com/abhiTronix/raspberry-pi-cross-compilers#d-toolchain-binaries-downloads 下载工具链，根据当前 raspberry pi 操作系统选择版本，比如当前选择的是 Stretch/6.3.0 的版本。

不要使用官方的交叉编译工具 https://github.com/raspberrypi/tools ，这个版本的 gcc 太旧了，会有编译错误。

通过 -I, -B, -Wl,-rpath-link 配置交叉编译工具链，其中：

* -I 指定额外的头文件查找目录
* -B 指定额外的库查找目录
* -Wl,-rpath-link 给链接器 ld 传递库查找目录

可以运行 `/build/tools/cross-pi-gcc-6.3.0-2/bin/arm-linux-gnueabihf-gcc --sysroot=/build/rootfs -print-search-dirs` 来查看 gcc 的查找目录。


如果在 MacOS 上交叉编译，可以使用 Docker 运行任何一个 ubuntu 镜像，然后安装交叉编译工具和 rootfs 就可以。但实际上，实测下来，使用 Docker 交叉编译比使用 Raspberry PI 硬件编译还慢。

```
root@6b7ac5b17190:/build/v4l2/v4l2_sample# time make
/build/tools/cross-pi-gcc-6.3.0-2/bin/arm-linux-gnueabihf-gcc -O2 -o capturer_mmap capturer_mmap.c
/build/tools/cross-pi-gcc-6.3.0-2/bin/arm-linux-gnueabihf-gcc -O2 --sysroot=/build/rootfs -I/build/rootfs/usr/include/arm-linux-gnueabihf -B/build/rootfs/usr/lib/arm-linux-gnueabihf -Wl,-rpath-link,/build/rootfs/lib/arm-linux-gnueabihf -Wl,-rpath-link,/build/rootfs/usr/lib/arm-linux-gnueabihf -o capturer_read capturer_read.c
/build/tools/cross-pi-gcc-6.3.0-2/bin/arm-linux-gnueabihf-gcc -O2 --sysroot=/build/rootfs -I/build/rootfs/usr/include/arm-linux-gnueabihf -B/build/rootfs/usr/lib/arm-linux-gnueabihf -Wl,-rpath-link,/build/rootfs/lib/arm-linux-gnueabihf -Wl,-rpath-link,/build/rootfs/usr/lib/arm-linux-gnueabihf -lX11 -lXext -o viewer viewer.c

real	0m5.079s
user	0m0.410s
sys	    0m0.610s
```

```
pi@raspberrypi:~/work/V4l2_samples-0.4.1 $ time make
gcc -O2 -o capturer_mmap capturer_mmap.c
gcc -O2 -I/build/rootfs/usr/include -L/build/rootfs/lib -L/build/rootfs/usr/lib -o capturer_read capturer_read.c
gcc -O2 -I/build/rootfs/usr/include -L/build/rootfs/lib -L/build/rootfs/usr/lib -lX11 -lXext -o viewer viewer.c

real	0m2.584s
user	0m2.408s
sys	0m0.157s
```

由此可见，交叉编译只在 ubuntu 真机上有效，通过 docker 意义不大。
