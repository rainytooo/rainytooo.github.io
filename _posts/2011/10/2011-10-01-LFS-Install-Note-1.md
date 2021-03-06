---
layout: post
title: LFS安装笔记一
date: 2011-10-01
category: [devops, server]
tags: [linux, lfs]
---


可能是8 9 年前的笔记了,具体时间记不清了,因为是保存在google notes里的,后来自动导入到google doc里了,今天刚好有机会整理一下.当时是6.3版本,现在是8.0了.

LFS-Linux From Scratch 实际上不是什么发行版,是一个指导手册,教你如何去用现有的东西制作一个Linux系统.
建议所有学习linux的人,运维的,无论新手老鸟,如果没做过LFS的一定要做一次,一定会有很大收获.

当时是出于学习的目的,所以在虚拟机上弄,因为LFS是一个自己编译的过程,时间会很长,用虚拟机的好处是可以snapshot


# 安装LFS6.3 (一)

在我的虚拟机上安装,连上客户端以后

### 1.分区格式化和挂载
```
hda1                                                  Primary                Linux                                                                   255.96
hda2                                                  Primary                Linux swap / Solaris                                                    1023.81
hda3                                                  Primary                Linux                                                                   7309.86


Disk /dev/hda: 8589 MB, 8589934592 bytes
15 heads, 63 sectors/track, 17753 cylinders
Units = cylinders of 945 * 512 = 483840 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/hda1               1         529      249921   83  Linux
/dev/hda2             530        2645      999810   82  Linux swap / Solaris
/dev/hda3            2646       17753     7138530   83  Linux


mkfs.ext3 /dev/hda1
mkfs.ext3 /dev/hda3
mkswap /dev/hda2 && swapon /dev/hda2

```
创建并挂载相应的分区和目录

	export LFS=/mnt/lfs
	mkdir -pv $LFS
	mount /dev/hda3 $LFS

### 2.创建源码的基本路径


	mkdir -v $LFS/sources
	chmod -v a+wt $LFS/sources/

创建工具目录

	mkdir -v $LFS/tools
	ln -sv $LFS/tools /

### 3.创建lfs用户和用户组

	groupadd lfs
	useradd -s /bin/bash -g lfs -m -k /dev/null lfs

	passwd lfs

更改相应的目录的权限为lfs

	chown -v lfs $LFS/tools/
	chown -v lfs $LFS/sources

登录到lfs

	su - lfs

初始化用户环境

```
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL PATH
EOF
```

导入环境

	source ~/.bash_profile


### 4.开始工具链的制作

	cd $LFS/sources

安装binutils

	tar xvf /lfs-sources/binutils-2.17.tar.bz2

	cd binutils-2.17/

	mkdir -v ../binutils-build

	cd ../binutils-build

	../binutils-2.17/configure --prefix=/tools --disable-nls --disable-werror

	make;make install

为后面"调整工具链"步骤准备连接器：

```
make -C ld clean
make -C ld LIB_PATH=/tools/lib
cp -v ld/ld-new /tools/bin
rm -rf binutils-**
```

make 参数的含义：

`-C ld clean` 告诉 make 程序删除所有 ld 子目录中编译生成的文件。
`-C ld LIB_PATH=/tools/lib`这个选项重新编译 ld 子目录中的所有文件。在命令行中指定 Makefile 的 LIB_PATH 变量值，使它明确指向临时工具目录，以覆盖默认值。这个变量的值指定了连接器的默认库搜索路径，它在这一章的稍后部分会用到。



安装gcc

```
cd gcc-4.1.2/

mkdir -v ../gcc-build

cd ../gcc-build

CC="gcc -B/usr/bin/" ../gcc-4.1.2/configure --prefix=/tools \
	--with-local-prefix=/tools --disable-nls \
	--enable-shared --enable-languages=c

make bootstrap && make install

ln -vs gcc /tools/bin/cc

rm -rf gcc-*
```

配置选项的含义：

`--with-local-prefix=/tools`这个参数的目的是把 `/usr/local/include` 目录从 gcc 的 include 搜索路径里删除。
这并不是绝对必要，但我们想尽量减小宿主系统的影响，所以才这样做

`--enable-shared`这个参数咋一看有点违反直觉。但只有加上它，才能编译出 libgcc_s.so.1 和 libgcc_eh.a 。Glibc(下一个软件包)的配置脚本只有在找到 libgcc_eh.a 时才能确保产生正确的结果。

`--enable-languages=c`只编译 GCC 软件包中的 C 编译器。我们在本章里不需要其它编译器。

`bootstrap`使用这个参数的目的不仅仅是编译 GCC ，而是重复编译它几次。它用第一次编译生成的程序来第二次编译自己，然后又用第二次编译生成的程序来第三次编译自己，最后比较第二次和第三次编译的结果，以确保编译器能毫无差错的编译自身，这通常表明编译是正确的。


### 5.安装内核头文件

```
tar xvf /lfs-sources/linux-2.6.22.5.tar.bz2
cd linux-2.6.22.5/
make mrproper
make headers_check
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include/
cd ..
rm -rf linux-2.6.22.5
```

配置选项的含义：

`make mrproper`的作用是清楚上一次编译内核时的配置文件 环境等等

`make headers_check`在编译内核时运行`make headers_check`命令检查内核头文件,当你修改了与用户空间相关的内核头文件后建议启用该选项

`make INSTALL_HDR_PATH=dest headers_install` 安装头文件




### 6.安装glibc

```
$ tar xvf /lfs-sources/glibc-2.5.1.tar.bz2
$ cd glibc-2.5.1
$ mkdir -v ../glibc-build
$ cd ../glibc-build
$ ../glibc-2.5.1/configure --prefix=/tools \
 --disable-profile --enable-add-ons \
 --enable-kernel=2.6.0 --with-binutils=/tools/bin \
 --without-gd --with-headers=/tools/include \
 --without-selinux
$ mkdir -v /tools/etc
$ touch /tools/etc/ld.so.conf
$ make && make install

$ cd ..
$ rm -rf glibc-*
```

### 7.调整工具链

```
$ mv -v /tools/bin/{ld,ld-old}
$ mv -v /tools/$(gcc -dumpmachine)/bin/{ld,ld-old}
$ mv -v /tools/bin/{ld-new,ld}
$ ln -sv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld
$ GCC_INCLUDEDIR=`dirname $(gcc -print-libgcc-file-name)`/include &&
find ${GCC_INCLUDEDIR}/* -maxdepth 0 -xtype d -exec rm -rvf '{}' \; &&
rm -vf `grep -l "DO NOT EDIT THIS FILE" ${GCC_INCLUDEDIR}/*` &&
unset GCC_INCLUDEDIR
```

测试

```
$ echo 'main(){}' > dummy.c
$ cc dummy.c
$ readelf -l a.out | grep 'tools'
```

输出`Requesting program interpreter: /tools/lib/ld-linux.so.2`表示正常


### 8.可选的安装Tcl-8.4.15 Expect-5.43.0 DejaGNU-1.4.4

```
$ cd $LFS/sources
$ tar xvf /lfs-sources/tcl8.4.15-src.tar.gz
$ cd tcl8.4.15/unix
$ ./configure --prefix=/tools && make && make install && make install-private-headers
$ ln -sv tclsh /tools/bin/tclsh
```

```
$ cd $LFS/sources
$ tar xvf /lfs-sources/expect-5.43.0.tar.gz
$ cd expect-5.43
$ patch -Np1 -i /lfs-sources/expect-5.43.0-spawn-1.patch
$ cp configure{,.bak}
$ sed 's:/usr/local/bin:/bin:' configure.bak > configure
$ ./configure --prefix=/tools --with-tcl=/tools/lib --with-tclinclude=/tools/include --with-x=no && make
$ make SCRIPTS="" install
```

```
$ cd $LFS/sources
$ tar xvf /lfs-sources/dejagnu-1.4.4.tar.gz
$ cd dejagnu-1.4.4
$ ./configure --prefix=/tools && make install
```


### 9.第2次gcc

```
$ tar xvf /lfs-sources/gcc-4.1.2.tar.bz2
$ cd gcc-4.1.2/
$ cp -v gcc/Makefile.in{,.orig}
$ sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in
$ cp -v gcc/Makefile.in{,.tmp}
$ sed 's/^XCFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in.tmp gcc/Makefile.in
$ patch -Np1 -i /lfs-sources/gcc-4.1.2-specs-1.patch
$ mkdir -v ../gcc-build
$ cd ../gcc-build
$ ../gcc-4.1.2/configure --prefix=/tools \
--with-local-prefix=/tools \
--enable-clocale=gnu --enable-shared \
--enable-threads=posix --enable-__cxa_atexit \
--enable-languages=c,c++ --disable-libstdcxx-pch \
&& make && make install
```

### 10.再次测试工具链的调整，以确保刚刚编译的gcc正确工作

```
echo 'main(){}' > dummy.c
cc dummy.c
readelf -l a.out | grep 'tools'
```

如果输出大致如下


	Requesting program interpreter: /tools/lib/ld-linux.so.2

则表示调整成功，因为所有的库已经连接到了/tools/lib下。

	rm -rf a.out dummy.c



### 11.第2次Binutils

```
$ tar xvf /lfs-sources/binutils-2.17.tar.bz2
$ mkdir -v binutils-build
$ cd binutils-build
$ ../binutils-2.17/configure --prefix=/tools --disable-nls \
--with-lib-path=/tools/lib \
&& make && make install
$ make -C ld clean
$ make -C ld LIB_PATH=/usr/lib:/lib
$ cp -v ld/ld-new /tools/bin
```


### 12.安装ncurses,bash,bzip2,coreutils diffutils,findutils,gawk,gettext,grep,gzip,make,patch,perl,sed,tar,textinfo,util-linux等

```
$ tar xvf /lfs-sources/ncurses-5.6.tar.gz
$ cd ncurses-5.6
$ ./configure --prefix=/tools --with-shared --without-debug --without-ada --enable-overwrite \
&& make && make install
```

安装bash

```
$ tar xvf /lfs-sources/bash-3.2.tar.gz
$ cd bash-3.2
$ patch -Np1 -i /lfs-sources/bash-3.2-fixes-5.patch
$ ./configure --prefix=/tools --without-bash-malloc \
&& make && make install
$ ln -vs bash /tools/bin/sh
```


安装bzip2

```
$ tar xvf /lfs-sources/bzip2-1.0.4.tar.gz
$ cd bzip2-1.0.4/
$ make && make PREFIX=/tools install
```

安装coreutils

```
$ tar xvf /lfs-sources/coreutils-6.9.tar.bz2
$ cd coreutils-6.9/
$ ./configure --prefix=/tools && make && make install
$ cp -v src/su /tools/bin/su-tools
```


安装diffutils

```
$ tar xvf /lfs-sources/diffutils-2.8.1.tar.gz
$ cd diffutils-2.8.1/
$ ./configure --prefix=/tools && make && make install
```

安装findutils

```
$ tar xvf /lfs-sources/findutils-4.2.31.tar.gz
$ cd findutils-4.2.31/
$ ./configure --prefix=/tools && make && make install
```

安装gawk

```
$ tar xvf /lfs-sources/gawk-3.1.5.tar.bz2
$ cd gawk-3.1.5/
$ ./configure --prefix=/tools
$ cat >> config.h << "EOF"
#define HAVE_LANGINFO_CODESET 1
#define HAVE_LC_MESSAGES 1
EOF
$ make && make install
```

安装gettext

```
$ tar xvf /lfs-sources/gettext-0.16.1.tar.gz
$ cd gettext-0.16.1/
$ cd gettext-tools/
$ ./configure --prefix=/tools --disable-shared
$ make -C gnulib-lib
$ make -C src msgfmt
$ cp -v src/msgfmt /tools/bin
```

安装grep

```
$ tar xvf /lfs-sources/grep-2.5.1a.tar.bz2
$ cd grep-2.5.1a/
$ ./configure --prefix=/tools --disable-perl-regexp && make && make install
```

安装gzip

```
$ tar xvf /lfs-sources/gzip-1.3.12.tar.gz
$ cd gzip-1.3.12/
$ ./configure --prefix=/tools && make && make install
```

安装make

```
$ tar xvf /lfs-sources/make-3.81.tar.bz2
$ cd make-3.81/
$ ./configure --prefix=/tools && make && make install
```


安装patch

```
$ tar xvf /lfs-sources/patch-2.5.4.tar.gz
$ cd patch-2.5.4/
$ ./configure --prefix=/tools && make && make install
```
安装perl

```
$ tar xvf /lfs-sources/perl-5.8.8.tar.bz2
$ cd perl-5.8.8/
$ patch -Np1 -i /lfs-sources/perl-5.8.8-libc-2.patch
$ ./configure.gnu --prefix=/tools -Dstatic_ext='Data/Dumper Fcntl IO POSIX'
$ make perl utilities
$ cp -v perl pod/pod2man /tools/bin
$ mkdir -pv /tools/lib/perl5/5.8.8
$ cp -Rv lib/* /tools/lib/perl5/5.8.8
```

安装sed

```
$ tar xvf /lfs-sources/sed-4.1.5.tar.gz
$ cd sed-4.1.5/
$ ./configure --prefix=/tools && make && make install
```

安装tar

```
$ tar xvf /lfs-sources/tar-1.18.tar.bz2
$ cd tar-1.18/
$ ./configure --prefix=/tools && make && make install
```

安装texinfo

```
$ tar xvf /lfs-sources/texinfo-4.9.tar.bz2
$ cd texinfo-4.9/
$ ./configure --prefix=/tools && make && make install
```

安装Util-linux

```
$ tar xvf /lfs-sources/util-linux-2.12r.tar.bz2
$ cd util-linux-2.12r/
$ sed -i 's@/usr/include@/tools/include@g' configure
$ ./configure && make -C lib && make -C mount mount umount && make -C text-utils more
$ cp -v mount/{,u}mount text-utils/more /tools/bin
```


Stripping

这步是可有可无的，如果你打算今后还要用/tools里面的东西，那么可以strip一下来减少占用的磁盘空间，但如果做完目标系统后就删除了，不Strip也可以，反正最后也是要删掉的。

代码:

```
strip --strip-debug /tools/lib/*
strip --strip-unneeded /tools/{,s}bin/*
```

info和man里面的内容在制作过程中没什么用处，所以删掉也没啥关系。

代码:

	rm -rf /tools/{info,man}

	exit


### 13.开始制作目标系统

创建三个重要目录

	chown -R root:root $LFS/tools
	mkdir -pv $LFS/{dev,proc,sys}

创建两个目标系统所必须的设备文件

	mknod -m 600 $LFS/dev/console c 5 1
	mknod -m 666 $LFS/dev/null c 1 3


重新开机后回到工作状态的步骤是：

	1.重新启动计算机，并从LiveCD启动
	2.加载分区
	3.加载交换分区（如果不想用交换分区或者没有交换分区可跳过此步骤）

```
export LFS=/mnt/lfs
mkdir -pv $LFS
mount /dev/hda2 $LFS
swapon /dev/hda1
```

相关知识点：
这时候已经制作好了工具链，因此可以不需要建立根目录下的tools链接了



