---
layout: post
title: 用pyenv安装python时错误 Missing the zlib
subtitle: The Python zlib extension was not compiled. Missing the zlib
date: 2019-01-30
category: [language, python]
tags: [python, brew, pyenv]
published: false
---

邻近春节,每年到了这个时候我都要整理一下开发环境, 把该更新的都更新了, 什么编辑器,ide,sdk,等等做一次升级.
今天再更新我的开发环境的时候,用pyenv安装python时错误 Missing the zlib

```
python-build: use openssl from homebrew
python-build: use readline from homebrew
Downloading Python-2.7.15.tar.xz...
-> https://www.python.org/ftp/python/2.7.15/Python-2.7.15.tar.xz
Installing Python-2.7.15...
python-build: use readline from homebrew
ERROR: The Python zlib extension was not compiled. Missing the zlib?

Please consult to the Wiki page to fix the problem.
https://github.com/pyenv/pyenv/wiki/Common-build-problems


BUILD FAILED (OS X 10.14.2 using python-build 20180424)

Inspect or clean up the working tree at /var/folders/mq/x_p70p7x5z57b60ms_r4jmm00000gn/T/python-build.
20190130113948.42625
Results logged to /var/folders/mq/x_p70p7x5z57b60ms_r4jmm00000gn/T/python-build.20190130113948.42625.l
og

Last 10 log lines:
rm -f /Users/vincent/.pyenv/versions/2.7.15/share/man/man1/python.1
(cd /Users/vincent/.pyenv/versions/2.7.15/share/man/man1; ln -s python2.1 python.1)
if test "xno" != "xno"  ; then \
                case no in \
                        upgrade) ensurepip="--upgrade" ;; \
                        install|*) ensurepip="" ;; \
                esac; \
                 ./python.exe -E -m ensurepip \
                        $ensurepip --root=/ ; \
        fi
```

解决办法

### 1.用brew安装zlib
```
brew install zlib
```

### 2.设置环境变量

```
# For compilers to find zlib you may need to set:
  export LDFLAGS="-L/usr/local/opt/zlib/lib"
  export CPPFLAGS="-I/usr/local/opt/zlib/include"

# For pkg-config to find zlib you may need to set:
  export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"
```
### 3.再次安装

```
pyenv install 2.7.15
```

成功