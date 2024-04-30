---
layout: post
category: pastime
title:  "绿晋江坑品查看器"
tagline: "www.jjwxc.net"
tags : ["greasemonkey", "jjwxc" ] 
---
{% include JB/setup %}


安装&效果：[绿晋江坑品查看器](http://userscripts.org/scripts/show/115450)

源码：[jjwxc-update-interval](https://github.com/abbypan/jjwxc_update_interval)

绿晋江　( http://www.jjwxc.net )　作品中章节的更新间隔统计图

方便一眼看出这篇文章是否成坑……是否将要成坑……是否曾经是坑……

简易版坑品查看器。。。

![kengpin_1](/assets/posts/ljj_kengpin_1.png)

![kengpin_2](/assets/posts/ljj_kengpin_2.png)
 
做法：根据目录页的更新信息统计出更新时间间隔，利用JScharts画柱状图(因为它画出来比较好看)，利用Google Chart API画饼图(因为它支持中文)。

饼图分类来源：[快乐催文我催我催我催催催　作者：kuandeng（狂等）](http://www.jjwxc.net/comment.php?novelid=370832&commentid=36364&page=1)

分类方式：

    < 4 日更
    <8 周更
    <16 半月更
    <32 月更
    <94 季更
    <184 半年更
    <366 年更
    <732 太阳黑子活动周期更
    更长 冰川周期更

与技术无关的说明：感谢顾漫、自语、润傲三位大人，在目录页上刷来刷去的时候，就会想到做点东西当消遣了。。。
