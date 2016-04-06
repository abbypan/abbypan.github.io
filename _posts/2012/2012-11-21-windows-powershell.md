---
layout: post
category : tech
title:  "Windows PowerShell"
tagline: "笔记"
tags : [ "windows", "powershell" ]
---
{% include JB/setup %}

## 简单入门

[powershell-notes.pdf](http://www.ansatt.hig.no/erikh/tutorial-powershell/powershell-notes.pdf)

## 提示无法执行 ps1

``set-executionpolicy remotesigned``

## 批量 move 文件到指定的子目录

{% highlight powershell %}
Get-ChildItem -Filter "*.*" |ForEach-Object {
   $f = $_.name;

   $d=$f -replace "-.*","";
   mkdir $d;

Move-Item $f $d$f;
}
{% endhighlight %}

## 命令行参数
``$args``

## 下载文件

{% highlight powershell %}
Invoke-WebRequest  "http://xxx.xxx.xxx/yyy.mp3" -Method GET -OutFile "yyy.mp3";
{% endhighlight %}

## 转换utf8编码的文件为本地编码（一般是gbk)

{% highlight powershell %}
cat utf8_some.txt -Encoding utf8 > gbk_some.txt
{% endhighlight %}
