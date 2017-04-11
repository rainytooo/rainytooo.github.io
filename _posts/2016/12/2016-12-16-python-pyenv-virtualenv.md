---
layout: post
title: osx上python3虚拟环境环境搭建
date: 2016-12-16
categories: 
    - language
    - python
---


# content


### 1. 安装pyenv

```
brew install pyenv
```

### 2. 修改zsh的环境变量

```
vim ~/.zshenv
# 添加
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
```

### 3. 设置生效


```
exec $SHELL
```

查看可以安装的python版本

```
pyenv install --list
```


### 4. 安装版本

```
pyenv install 3.5.2
```

查看安装的版本

```
pyenv versions
```


### 5. virtualenv插件

```
brew install pyenv-virtualenv
```


编辑 ~/.zshenv ,添加

```
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
```

设置生效

```
exec $SHELL
```

### 6. 添加虚拟环境

```
pyenv virtualenv 3.5.2 mmbox-py
pyenv activate mmbox-py 
```



### 参考

* https://github.com/yyuu/pyenv/#homebrew-on-mac-os-x
* http://python.jobbole.com/85587/
* http://www.cnblogs.com/npumenglei/p/3719412.html

