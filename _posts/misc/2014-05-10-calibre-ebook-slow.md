---
layout: post
category : tech
title:  "用 calibre 转换电子书 进度慢"
tagline: ""
tags : [ "calibre", "kindle", "mobi", "html" ] 
---
{% include JB/setup %}

主要是用calibre把 md 或 html 转换成 mobi 或 azw3 电子书，默认情况下超过5M就会很慢

主要问题出在calibre会默认切分章节，在那边一直很卡

命令行处理方案（指定``chapter-mark``以及``page-breaks-before``）：
``ebook-convert src.html dst.mobi --authors "some_writer" --title "some_book" --chapter-mark "none" --page-breaks-before "/" --max-toc-links 0``

图形界面处理方案：

![calibre_kindle_slown](/assets/posts/calibre_kindle_slown.png)
