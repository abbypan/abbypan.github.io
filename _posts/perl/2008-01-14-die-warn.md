---
layout: post
category : tech
title:  "Perl : die 与 warn"
tagline: ""
tags : ["perl"] 
---
{% include JB/setup %}

$!包含的信息，仅对系统请求失败时有效。当写子程序时，应当使用die 而非exit来表示程序出了问题。

die 和warn 产生的信息，以及Perl 内部产生的提示(complaints)信息将自动传到STDERR 上。

die会自动将Perl 程序的名字和行数输出在消息的末尾，如果不想要函数及文件的名字出现，只需在die消息后面加上换行符。一般情况下，如果用法错误则在消息后面加上换行符；如果是其它错误，需要利用它来调试，则不要加上换行符。

warn 函数像die 那样工作，但warn不会从程序中退出，而die会从程序中退出。

现在要把STDERR重定向到log文件，执行了die语句，但接受错误的文件没有打开，则perl将使用之前的连接。因为对于STDIN/STDOUT/STDERR来说，除非perl成功的打开新连接，否则旧连接不会关闭。
