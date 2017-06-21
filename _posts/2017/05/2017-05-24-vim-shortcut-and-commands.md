---
layout: post
title: Vim的快捷键和命令
date: 2017-05-24
categories: 
    - ide
    - vim
---



# 快捷键和常用命令

* 1.编辑
* 2.剪贴板
* 3.缓冲区
* 4.移动和跳转
* 5.窗口操作
* 6.搜索和替换
    + 关于搜索的正则表达式
        - 字符
        - 特殊符号
        - 数量
        - 位置
        - 例子
    + 搜索
    + 替换
    + `vimgrep`在文件中搜索
* 7.tab操作
* 8.关键字补全
* 9.netrw模式
* 10.折叠
* 11.帮助
* 12.垂直编辑
* 13.查看环境变量设置等等
* 14.标记
* 15.执行shell命令
* 16.关于动作的影响


### 1.编辑

* `i`                   在光标的字之前
* `a`                   在光标的字之后
* `I`                   在光标的行首
* `A`                   在光标的行尾
* `s`                   删除光标所在行  
* `S`                   删除整行
* `u`                   撤销
* `ctrl + r`            反撤销
* `x`                   向后删除
* `X`                   向前删除
* `c`                   替换单词
* `C`                   替换整行
* `d + w`               删除光标右边的单词,  而且在黏贴板 按p可以粘贴出来
* `dd`                  删除一行,光标所在的行
* `行数dd`              删除指定数量的行
* `r`                   替换
* `o`                   在当前行的下面插入一行
* `O`                   在当前行的上面插入一行
* "多次重复插入字符,比如 3i 然后输入单词go 再按esc就可以得到 gogogo"
* `guu`                 小写(行)
* `gUU`                 大写(行)
* `g~~`                 翻转大小写(行)
* 选中后用o可以在选中文字的前后跳转
* `>>`                  向右给它进当前行
* `<<`                  向左缩进当前行
* `=`                   缩进当前行 （和上面不一样的是，它会对齐缩进）
* `=%`                  把光标位置移到语句块的括号上，然后按=%，缩进整个语句块（%是括号匹配）
* `G=gg` 或 `gg=G`      缩进整个文件（G是到文件结尾，gg是到文件开头）
* `>G`                  从所在行到文件结束进行缩进
* `:read file`          将外部文件读入当前buffer
* `:read !ls -alsh`     将外部命令的结果读入到当前buffer


### 2.剪贴板

* `yy`                  复制一行
* `行数yy`              复制一行多次
* `p`                   粘贴粘贴板的第一个
* `数字p`               粘贴粘贴板的第N个
* `:reg`                查看剪贴板内的内容


### 3.缓冲区

* `:ls`                 查看缓冲区所有文件
    + 用`:ls`以后，在文件的前面会有一些标记
        - `–` （非活动的缓冲区）
        - `a` （当前被激活缓冲区）
        - `h` （隐藏的缓冲区）
        - `%` （当前的缓冲区）
        - `#` （交换缓冲区）
        - `=` （只读缓冲区）
        - `+` （已经更改的缓冲区）
* `:buffer [num]` 或者 `:buffer src/http/ngx_http.c`    直接切换缓冲区文件
* `num<C-^>`            同上
* `:bnext`              缩写 :bn
* `:bprevious`          缩写 :bp
* `:blast`              缩写 :bl
* `:bfirst`             缩写 :bf
* `:cd xx`              切换
* `:pwd`                查看工作目录


### 4.移动和跳转

* `M`                   当前屏幕中间
* `L`                   底部 
* `H`                   顶部
* `G`                   文件底部, `gg`文件顶部
* `h`                   向左    
* `j`                   向下
* `k`                   向上
* `l`                   向右
* `ctrl + f`            翻页 向前
* `ctrl + b`            翻页 向后
* `ctrl + d`            翻页 向前半页
* `ctrl + u`            翻页 向后半页
* `0`                   移动到行首
* `$`                   移动到行尾
* `^`                   移动到当前第一个非空字符
* `%`                   移动到对应括号
* `w`                   下一个word
* `e`                   到word的结尾
* `b`                   上一个word
* " 所有的移动都可以在前面加上数字来多次移动  比如3w  2b  9l "  
* `数字gg`              移动到指定的行
* `gg`                  移动到0行
* `G`                   移动到尾行
* `gt`                  下一个tab
* `gT`                  上一个tab
* `<C-E>`               向下滚屏
* `<C-Y>`               向上滚屏
* `zz`                  让你的光标在屏幕最中间
* `<C-o>`               跳转上一个文件
* `f{char}`             向前查找出现字符的地方
* `F{char}`             向后查找出现字符的地方
* `t{char}`             同f,但是光标在字符左侧
* `T{char}`             同F,但是光标在字符右侧

* `:jumps`              查看jump列表
* `g;`                  条状到上一个跳转位置,可以加count
* `g,`                  跳转到下一个编辑的位置,可以加count

* `<C-i>`               向前, 在jumplist里跳转
* `<C-O>`               向后, 在jumplist里跳转 

* `<C-]>`               跳转tags stack

* `<C-z>`               跳回shell,再次输入fg可以回到vim

### 5.窗口操作

* `<C-W>v`              水平拆分
* `<C-W>s`              垂直拆分
* `<C-w>|`              最大化水平窗口
* `<C-w>_`              最大化垂直窗口
* `<C-w>-`              垂直减少1行,可以加数字之后跟`-`
* `<C-w>=`              平均分窗口 
* `<C-w>+`              垂直增加1行,可以在数字之后跟`+`
* `:vertical resize 数字` 或者 `:vertical resize +|-数字`来重置当前窗口的大小 * `:Ex`                 打开目录
* `:Sex`                在垂直分割的窗口中打开目录
* `:Vex`                在水平分割的窗口中打开目录
* `<C-w> + hjkl`        分屏切换,按照给定的方向
* `:He`  `:He!`         全称为 :Hexplore,在下边分屏浏览目录,加!在上分屏浏览目录
* `:Ve`  `:Ve!`         全称为 :Vexplore 在左边分屏浏览目录,加!在右分屏浏览目录
* `:set scb` `:set scb!`    同步分屏或者取消

### 6.搜索和替换

* `:首行,尾行 s/str1/str2/g`            在指定的范围里搜索并替换
* `g*`                                  查找光标所在单词的字符序列
* `s:`                                  substitute 替换

##### 关于搜索的正则表达式


关于指令和作用以及对结果的处理


字符匹配

* `.`                   匹配任意一个字符
* `[abc]`               匹配方括号中的任意一个字符。可以使用-表示字符范围，
    - 如[a-z0-9]匹 配小写字母和阿拉伯数字。
* `[^abc]`              在方括号内开头使用^符号，表示匹配除方括号中字符之外的任意字符。
* `\d`                  匹配阿拉伯数字，等同于[0-9]。
* `\D`                  匹配阿拉伯数字之外的任意字符，等同于`[^0-9]`
* `\x`                  匹配十六进制数字，等同于[0-9A-Fa-f]
* `\X`                  匹配十六进制数字之外的任意字符，等同于`[^0-9A-Fa-f]`
* `\w`                  匹配单词字母，等同于`[0-9A-Za-z_]`
* `\W`                  匹配单词字母之外的任意字符，等同于`[^0-9A-Za-z_]`
* `\t`                  匹配`<TAB>`字符
* `\s`                  匹配空白字符，等同于`[ \t]`
* `\S`                  匹配非空白字符，等同于`[^ \t]`

符号

* `\*`                  匹配 * 字符
* `\.`                  匹配 . 字符
* `\/`                  匹配 / 字符
* `\\`                  匹配 \ 字符
* `\[`                  匹配 [ 字符


数量

* `*`                   匹配0-任意个
* `\`                   匹配1-任意个
* `\?`                  匹配0-1个
* `\{n,m}`              匹配n-m个
* `\{n}`                匹配n个
* `\{n,}`               匹配n-任意个
* `\{,m}`               匹配0-m个

位置

* `$`                   匹配行尾
* `^`                   匹配行首
* `\<`                  匹配单词词首
* `\>`                  匹配单词词尾


##### 搜索

* `*`和`#`                              分别是查找下一个和上一个光标下的字符
* `/`是搜索, `s`是替换, 搜索的前面加上g以后后面要跟处理方式
* `/ + word `  `/word\c`                开始搜索, 加`\c`是指大小写敏感的查找,`/\cworkd`也可以`\c`大小写不敏感,`\C`大小写敏感
* `/word/数字`                          搜索之后定位都指定的位置offset,注意这里是行,可以加减`/word/-2`
* `/word/e`                             搜索之后定位到最后
* `/word/e+1`                           搜索之后光标定位到最后一个出现的位置的右侧1个位置,反之`/word/e-1`是左侧一个位置
* `/word/b`                             同上,移动到第一个,后面可以可以跟`+1`或者`-1`
* `//`                                  重复上一个搜索,后面可以加参数`e,b和数字`
* `? + word`                            反向搜索
* `n`                                   下一个  
* `N`                                   上一个
* `:nohl` `:noh`或者`:nohlsearch`       搜索结束后,去除高亮.
* 模糊搜索
    + `/word*`                              这里要注意`*`代表后面可以出现任意字符,而`/a*`不是,是指a出现0次或者多次,所以会匹配全局,也就是说单个单词的时候比较特殊,`/a*`等同于`/\(a\)*`这个要注意 单个单词的时候意义不一样
    + `/\(ab\)*`                            匹配"ab", "abab", "ababab", 
    + `/ab+`                                匹配"ab", "abb", "abbb",b有1个或者多个
    + `/ascb\=`                             匹配"asc"和"ascb"等同于`/ascb\{0,1}`
    + `/asc\{0,3}`                          c出现0,1,2,3次都可以
        - `\{,4}`           0, 1, 2, 3 or 4                                         
        - `\{3,}`           3, 4, 5, etc.                                           
        - `\{0,1}`          0 or 1, same as \=                                      
        - `\{0,}`           0 or more, same as *                                    
        - `\{1,}`           1 or more, same as \+                                   
        - `\{3}`            3
        - `\{-}`            最小化匹配,带`-`都是非贪婪模式,优先匹配最小,最短的
        - `/word\{-1,3}`    非贪婪模式

##### 替换


* `%`的意思就是`1,$` 从头到尾
* `.`是当前行

帮助里的解释`:[range]s[ubstitute]/{pattern}/{string}/[flags] [count]`, 也就是`:[范围]s/表达式/字符串/[标识符][数量]`,

`标识符`是用来定义替换处理的一些参数的,如是否需要确认,

* `&`                   使用上一个模式,必须在第一个位置
* `c`                   替换的时候需要确认
* `g`                   全部替换
* `e`                   如果出现错误,不要显示错误信息
* `i`                   大小写不敏感
* `I`                   大小写敏感
* `n`                   打印有多少匹配,而不真正替换,`c`就会被忽略
* `p`                   打印最后一个匹配的行
* `#`                   同`p`加上行号
* `l`                   同`p`但是以`:list`的方式打印
* `r`                   只有在配合`:&`或者`:s`没有任何参数的时候使用



##### vimgrep 在文件中(files)查找

语法`:vim[grep] /{partern}/[g][j] fileregx`
	没有参数g的话,则行只查找一次关键字.反之会查找所有的关键字.
	没有参数j的话,查找后,VIM会跳转至第一个关键字所在的文件.反之,只更新结果列表(quickfix).

示例

```
:vimgrep /pip/ **/*.md
```

查找完毕以后,可以用`:copen`来在quickfix里列出结果


### 7.tab操作

* `:tabnew`                 打开新的tab,可以加参数
* `:tabedit`                新tab编辑,可以加参数
* `:tabfirst`
* `:tablast`
* `:tabonly`
* `:tabfind`
* `:tabnext`
* `:tabprevious`

### 8.关键字补全

* `<C-n>`               Vim就开始搜索所有文件里出现的词，搜索完成了就会出现一个下拉列表
* `<C-p>`               配合`<C-n>`回到刚输入的地方进行补全
* `Ctrl + X` 和 `Ctrl + D` 宏定义补齐
* `Ctrl + X` 和 `Ctrl + ]` 是Tag 补齐
* `Ctrl + X` 和 `Ctrl + F` 是文件名 补齐
* `Ctrl + X` 和 `Ctrl + I` 也是关键词补齐，但是关键后会有个文件名，告诉你这个关键词在哪个文件中
* `Ctrl + X` 和 `Ctrl +V` 是表达式补齐
* `Ctrl + X` 和 `Ctrl +L` 这可以对整个行补齐，变态吧。

### 9.netrw模式

* `<F1>`   netrw 给出帮助
* `<cr>`   netrw 进入目录或者打开文件                  
* `<del>`  netrw 试图删除文件/目录                    
* `-`    netrw 往上一层目录                           
* `a`    切换普通显示方式、隐藏方式 (不显示匹配 g:netrw_list_hide 的文件) 和显示方式 (只显示匹配 g:netrw_list_hide 的文件)
* `c`    使浏览中的目录成为当前目录                     
* `C`    设置编辑窗口                                 
* `d`    建立新目录                                  
* `D`    试图删除文件/目录                            
* `gb`   切换到收入书签的目录                          
* `gh`   快速隐藏/显示点文件                           
* `<c-h>`  编辑文件隐藏列表                           
* `i`    在瘦、长、宽和树状列表方式循环                 
* `<c-l>`  使 netrw 刷新目录列表                      
* `mb`   把当前目录加入书签                            
* `mc`   把带标记文件复制到标记目标目录中                
* `md`   对带标记文件进行比较 (不超过 3 个)             
* `me`   把带标记文件放到参数列表中并编辑之              
* `mf`   标记文件                                    
* `mh`   切换带标记文件的后缀在隐藏列表中的存在与否       
* `mm`   把带标记文件移动到标记目标目录中                
* `mp`   打印带标记文件                               
* `mr`   标记满足 shell 风格的 `|regexp|` 的文件         
* `mt`   使当前浏览目录成为标记文件的目标目录            
* `mT`   对带标记文件应用 ctags                       
* `mu`   撤销所有带标记文件的标记                      
* `mx`   对带标记文件应用任意外壳命令                   
* `mz`   对带标记文件压缩/解压缩                       
* `o`    用水平分割在新浏览窗口中进入光标所在的文件/目录   
* `O`    获取光标指定的文件                            
* `p`    预览文件                                    
* `P`    在前次使用的窗口中浏览                        
* `qb`   列出书签内的目录和历史                        
* `qf`   显示文件信息                                 
* `r`    反转排序顺序                                 
* `R`    给指定的文件或目录换名                        
* `s`    选择排序风格: 按名字、时间或文件大小            
* `S`    指定按名排序时的后缀优先级                     
* `t`    在新标签页里进入光标所在的文件/目录             
* `u`    切换到较早访问的目录                          
* `U`    切换到较迟访问的目录                          
* `v`    用垂直分割在新浏览窗口中进入光标所在的文件/目录   
* `x`    用指定程序阅读文件                            
* `X`    用 `|system()|` 执行光标所在的文件              
* `%`    在 netrw 当前目录打开新文件                  


### 10.折叠

* `zf`     创建折叠的命令，可以在一个可视区域上使用该命令；
* `zd`     删除当前行的折叠；
* `zD`     删除当前行的折叠；
* `zfap`   折叠光标所在的段；
* `zo`     打开折叠的文本；
* `zc`     收起折叠；
* `za`     打开/关闭当前折叠；
* `zr`     打开嵌套的折行；
* `zm`     收起嵌套的折行；
* `zR`     (zO)  打开所有折行；
* `zM`     (zC)  收起所有折行；
* `zj`     跳到下一个折叠处；
* `zk`     跳到上一个折叠处；
* `zi`     enable/disable fold;

### 11.帮助

* `:help` or `:h`           进入帮助
* `<C-]>`                   进入一个主题
* `<C-T>`或者`<C-O>`        返回
* `:help` or `:h 主题`      进入一个帮助主题
* `:help word`，接着键入`CTRL-D`可以看到匹配"word"的帮助主题。也可用`:helpgrep word`。
* `:map`                    查询所有map
* `:map <key>`              查询此快捷键


### 12.垂直编辑

* `<C-v>`                   进入垂直可视化模式
	- `<S-i>` or `<S-a>`    插入模式,然后插入你想要的字符,最后按两次`ESC`,即可完成垂直批量编辑
	- `d`                   删除 
	- `c`                   替换


### 13.查看环境变量设置等等

* `:abbreviate`             list abbreviations
* `:args`                   argument list
* `:augroup`                augroups
* `:autocmd`                list auto-commands
* `:buffers`                list buffers
* `:breaklist`              list current breakpoints
* `:cabbrev`                list command mode abbreviations
* `:changes`                changes
* `:cmap`                   list command mode maps
* `:command`                list commands
* `:compiler`               list compiler scripts
* `:digraphs`               digraphs
* `:file`                   print filename, cursor position and status (like Ctrl-G)
* `:filetype`               on/off settings for filetype detect/plugins/indent
* `:function`               list user-defined functions (names and argument lists but not the full code)
* `:function Foo`           user-defined function Foo() (full code list)
* `:highlight`              highlight groups
* `:history c`              command history
* `:history =`              expression history
* `:history s`              search history
* `:history`                your commands
* `:iabbrev`                list insert mode abbreviations
* `:imap`                   list insert mode maps
* `:intro`                  the Vim splash screen, with summary version info
* `:jumps`                  your movements
* `:language`               current language settings
* `:let`                    all variables
* `:let FooBar`             variable FooBar
* `:let g:`                 global variables
* `:let v:`                 Vim variables
* `:list`                   buffer lines (many similar commands)
* `:lmap`                   language mappings (set by keymap or by lmap)
* `:ls`                     buffers
* `:ls!`                    buffers, including "unlisted" buffers
* `:map!`                   Insert and Command-line mode maps (imap, cmap)
* `:map`                    Normal and Visual mode maps (nmap, vmap, xmap, smap, omap)
* `:map<buffer>`            buffer local Normal and Visual mode maps
* `:map!<buffer>`           buffer local Insert and Command-line mode maps
* `:marks`                  marks
* `:menu`                   menu items
* `:messages`               message history
* `:nmap`                   Normal-mode mappings only
* `:omap`                   Operator-pending mode mappings only
* `:print`                  display buffer lines (useful after :g or with a range)
* `:reg`                    registers
* `:scriptnames`            all scripts sourced so far
* `:set all`                all options, including defaults
* `:setglobal`              global option values
* `:setlocal`               local option values
* `:set`                    options with non-default value
* `:set termcap`            list terminal codes and terminal keys
* `:smap`                   Select-mode mappings only
* `:spellinfo`              spellfiles used
* `:syntax`                 syntax items
* `:syn sync`               current syntax sync mode
* `:tabs`                   tab pages
* `:tags`                   tag stack contents
* `:undolist`               leaves of the undo tree
* `:verbose`                show info about where a map or autocmd or function is defined
* `:version`                list version and build options
* `:vmap`                   Visual and Select mode mappings only
* `:winpos`                 Vim window position (gui)
* `:xmap`                   visual mode maps only


### 14.标记

* `m{a-z}`                   标记光标所在位置，局部标记，只用于当前文件.
* `m{A-Z}`                   标记光标所在位置，全局标记.标记之后，退出Vim， 重新启动，标记仍然有效.
* \`{a-z}                    移动到标记位置.
* '{a-z}                     移动到标记行的行首.
* \`{0-9}                    回到上[2-10]次关闭vim时最后离开的位置.
* \`                         移动到上次编辑的位置.''也可以，不过\`\`精确到列，而''精确到行 .如果想跳转到更老的位置，可以按`<C-o>`，跳转到更新的位置用`<C-i>`.
* \`"                        移动到上次离开的地方.
* \`.                        移动到最后改动的地方.
* `:marks`                   显示所有标记.
* `:delmarks a b`            删除标记a和b.
* `:delmarks a-c`            删除标记a、b和c.
* `:delmarks a c-f`          删除标记a、c、d、e、f.
* `:delmarks!`               删除当前缓冲区的所有标记.
* `:help mark-motions`       查看更多关于mark的知识.


### 15.执行shell命令

* `:!{program}`              执行命令
* `:r !{program}`            执行命令并读取命令的输出,最常用的就是日期`:r !date`
    + 补充一下,在n模式下,直接`!!date`,等同于`:.!date`   
* `:w !{program}`            执行命令并将文本作为命令的输入
* `:[range]!{program}`       过滤字符在命令里


### 16.关于动作的影响motions

* `a`                       全部all
* `i`                       在内部inside
* `t`                       直到till
* `f`                       向前find forword
* `F`                       向后find backword

例子

* `daw`                     删除整个单词
* `yfg`                     知道出现g的地方复制,包含g
* `di[`                     删除整个`[]`内的部分
* `da[`                     删除整个`[]`包含符号的部分

### 其它

* `:echo @%`            当前文件 
* `:DiffOrig`           查看当前文件和刚加载的时候的diff
* `:diffoff`            当前窗口关闭diff模式
* `:ls`                 显示现有的buffer
* `:cd ..`              进入父目录
* `:cd -`               将目录切换到上一个目录,不是父目录
* `:args`               显示目前打开的文件
* `:lcd %:p:h`          更改到当前文件所在的目录
* `!!date`              插入时间日期
* `:call mkdir('xx')`   创建目录
* `ga`                  查看光标处字符的ascii码
* `g8`                  查看光标处字符的utf-8编码
* 按`v`键进入选择模式，然后移动光标选择你要的文本，按`u`转小写，按`U`转大写
* 按`v` 键进入选择模式，然后按h,j,k,l移动光标，选择文本，然后按`y`进行复制,按`p`进行粘贴.
* `:set fenc`           查看和设置文件编码
* `:history c`          查看命令执行的历史
* `:history =`          表达式历史
* `:history s`          查找历史
* `:history`            同history c

