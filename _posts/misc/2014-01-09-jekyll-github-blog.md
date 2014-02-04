---
layout: post
category : tech
title:  "用 Jekyll Bootstrap 在 github 上搭建个人主页"
tagline: ""
tags : ["jekyll", "github", "blog"] 
---
{% include JB/setup %}

最早是用 viki + deplate 搭个人主页；

觉得各种标记麻烦，改成 txt2tags；

觉得txt2tags要自己写css，改成用 Jekyll Bootstrap + github

其实就是吃饱撑的……

## 安装

- 安装教程：[Jekyll QuickStart](http://jekyllbootstrap.com/usage/jekyll-quick-start.html)
- 记得要配置：./_config.yml
- 安装主题：[Using Themes](http://jekyllbootstrap.com/usage/jekyll-theming.html)

## 设置pygments支持语法高亮

_config.yml中设置pygments为true

找一个pygments的css，例如zenburn.css，假设放到/assets/themes目录下

在对应theme的default.html中添加

        <link href="/assets/themes/zenburn.css" rel="stylesheet" type="text/css" media="all">

## 写文章，语法高亮

[Writing posts](http://jekyllrb.com/docs/posts/)

## 新建一个网页
``rake page name="pages/about.md"``

## 新建一篇日志
在_posts目录下新建一个文件，文件名格式为 “年-月-日-标题”，例如 2014-01-07-sample.md
