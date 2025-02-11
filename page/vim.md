---
layout: page
title: "Vim"
---
{% include JB/setup %}

* TOC
{:toc}

## 简单入门

| 资料 | 简介 |
| ---- | ---- |
| 七个有效的文本编辑习惯 | 经典
| [最佳vim技巧](http://bbs.byr.cn/wForum/elite.php?file=/groups/sci.faq/Linux/linuxSoftUsage/VI/M.1116044565.s0) | 经典
| [不是打vi的广告](http://greenisland.csie.nctu.edu.tw/wp/category/comuter/vim/) | 实例
| vim hacks | PPT

## 站点

| 站点 | 简介 |
| ---- | ---- |
| [vi Complete Key Binding List](http://hea-www.harvard.edu/%7Efine/Tech/vi.html) | 不错的手册页
| [Efficient Editing With vim](http://robertames.com/files/vim-editing.html) | 不错，可以看
| [Colors Sampler Packer](http://www.vim.org/scripts/script.php?script_id=625) | 一堆color scheme配色
| [vim tips wiki](http://vim.wikia.com/) | wiki
| [vim参考手册](http://vimcdoc.sourceforge.net/doc/) | 碰到问题再查
| [vim](http://www.vim.org) | 官网


## 书籍

| 时间 | 书籍 | 读后感 |
| ---- | ---- | ------ |
| 2001 | Vi IMproved | 很赞，命令有截图。附录Quick Reference超赞。就是书太厚了
| 2010 | hacking vim | 中规中矩的工具书
| 2008 | Vi(1) Tips | vi基础操作介绍，还行吧

## 插件

| 插件 | 用途 |
| ---- | ---- |
| [LargeFile](http://www.vim.org/scripts/script.php?script_id=1506) | 打开大文件不会卡住
| [perl-support](http://www.vim.org/script.php?script_id=556) | perl开发
| [NERD Commenter](http://www.vim.org/scripts/script.php?script_id=1218) | 代码注释
| [honza / vim-snippets](https://github.com/honza/vim-snippets) | 代码补全
| [neocomplcache](http://www.vim.org/scripts/script.php?script_id=2620) | 函数补全
| [surround.vim](http://www.vim.org/scripts/script.php?script_id=1697) | word两边加引号标签
| [simplefold.vim](http://www.vim.org/scripts/script.php?script_id=1868) | ``<leader>f``进行折叠

## 配置

### 打开当前文件所在路径下的其他文件

见：[Tip #2: easy edit of files in the same directory](http://www.vim.org/tips/tip.php?tip_id=2)

{% highlight vim %}
if has("unix") 
map ,e :e <C-R>=expand("%:p:h") . "/"<CR> 
else 
map ,e :e <C-R>=expand("%:p:h") . "\"<CR> 
endif 
{% endhighlight %}

### Perl-Support 设置

#### 快捷键

先在``~/.vimrc``设置： ``let g:Perl_MapLeader  = ','``

| 按键 | 作用 |
| ---- | ---- |
| ,cfr | 块状说明 |
| ,cfu | 函数说明 |
| ,isu | 函数说明 |
| ,ii | 读文件（Ctrl-j跳转到下一个输入点） |
| ,io | 写文件 |
| ,ip | print "\n"; |
| ,pb | ``[:blank:]`` |
| ,rr | 运行脚本 |
| ,rs | 检查语法 |
| .ra | 指定脚本运行的参数 |
| ,rd | 开始debug (也可以按F9) |
| ,rp | 阅读perldoc |
| ,ry | 运行perltidy整理代码 |
| ,hp | perl-support的帮助信息 |

#### 时间格式

{% highlight vim %}
let g:Perl_TimestampFormat= '%Y-%m-%d %H:%M:%S'
let g:Perl_FormatDate            = '%Y-%m-%d'
let g:Perl_FormatTime            = '%H:%M:%S'
let g:Perl_FormatYear            = 'Year %Y'   
{% endhighlight %}

### Nerd Commenter 代码注释

| 按键 | 作用 |
| ---- | ---- |
| ,cc |	把选中的行注释掉 |
| ,cn |	把选中的行注释掉，已注释过的行仍继续加注释符 |
| ,c<space> | 反注释选中的行 |
| ,c$ | 从光标开始处注释掉当前行 |
| ,cA | 在当前行结尾处添加注释 |

### 自动识别打开的中文乱码

把[fencview.vim](http://www.vim.org/scripts/script.php?script_id=1708)扔到``~/.vim/plugin``下

在``~/.vimrc``中设置``let g:fencview_autodetect=1``

###  Windows下的相关编码设置

参考：[vim、gvim在windows下中文乱码的终极解决方案](http://blog.csdn.net/rehung/archive/2007/09/21/1794293.aspx)

{% highlight vim %}
language mes zh_CN.GBK
set langmenu=zh_CN.UTF-8
set fileencodings=utf-8,cp936,big5,euc-jp,utf-bom,iso8859-1
set encoding=cp936
set termencoding=cp936
set fileencoding=utf-8
{% endhighlight %}

### 正则式very magic

[enchanted.vim](http://www.vim.org/scripts/script.php?script_id=4849) 让vim正则式一直very magic，省敲字

需要预先安装[CRDispatcher.vim](http://www.vim.org/scripts/script.php?script_id=4856)

very magic 参考：[vim-regexes-are-awesome](http://briancarper.net/blog/448/vim-regexes-are-awesome)
