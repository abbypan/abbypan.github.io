---
layout: post
category : tech
title:  "perl 命令行 :  按行合并多个文件，同时加入原始文件名"
tagline: ""
tags : [ "perl", "merge", "file" ] 
---
{% include JB/setup %}

# windows 

{% highlight bash %}
$ perl -lne "print $ARGV,',',$_"  dir1/file1.txt dir2/file2.txt > file_merge.txt
{% endhighlight %}

# linux 

注意linux环境用单引号，避免bash解释变量

{% highlight bash %}
$ perl -lne 'print $ARGV,",",$_' dir1/file1.txt dir2/file2.txt > file_merge.txt
{% endhighlight %}
