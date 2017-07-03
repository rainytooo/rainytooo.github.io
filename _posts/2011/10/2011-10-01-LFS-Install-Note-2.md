---
layout: post
title: LFS安装笔记二
date: 2011-10-01
category: [devops, server]
tags: [linux, lfs]
---




# 安装LFS6.3 (二)

```
mount -v --bind /dev $LFS/dev
mount -vt devpts devpts $LFS/dev/pts
mount -vt tmpfs shm $LFS/dev/shm
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
```


这里为了方便使用源码包，我将光盘加载到目标系统里

	mkdir $LFS/cdrom
	mount /dev/cdrom $LFS/cdrom


为了方便在制作完后的系统能够直接显示中文，这里可以从网络上下载本人写的一个显示UTF-8编码文字的内核补丁。
使用下面的命令来下载：

	cd $LFS/sources/
	wget http://zdbr.net.cn/download/utf8-kernel-2.6.22.5-core-1.patch.bz2
	wget http://zdbr.net.cn/download/utf8-kernel-2.6.22.5-fonts-1.patch.bz2

解压缩这两个补丁

	bunzip2 utf8-kernel-2.6.22.5-core-1.patch.bz2
	bunzip2 utf8-kernel-2.6.22.5-fonts-1.patch.bz2



chroot到目标系统

```
chroot "$LFS" /tools/bin/env -i \
HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
/tools/bin/bash --login +h
```


建立目标系统的目录结构

```
mkdir -pv /{bin,boot,etc/opt,home,lib,mnt,opt}
mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv /usr/{,local/}share/{doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
for dir in /usr /usr/local; do
	ln -sv share/{man,doc,info} $dir
done
mkdir -pv /var/{lock,log,mail,run,spool}
mkdir -pv /var/{opt,cache,lib/{misc,locate},local}
```

创建几个必要的链接，因为在目标系统的编译过程中，部分编译程序会用绝对路径来寻找命令或文件。

```
ln -sv /tools/bin/{bash,cat,echo,grep,pwd,stty} /bin
ln -sv /tools/bin/perl /usr/bin
ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
ln -sv /tools/lib/libstdc++.so{,.6} /usr/lib
ln -sv bash /bin/sh
touch /etc/mtab
```

创建root及nobody用户和必要的组

```
cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF
```

```
cat > /etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
tape:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
mail:x:34:
nogroup:x:99:
EOF
```
