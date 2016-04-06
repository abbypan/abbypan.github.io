---
layout: post
category : tech
title:  "rvm 安装 jekyll 笔记"
tagline: ""
tags : [ "jekyll", "rvm", "ruby", "redcarpet" ]
---
{% include JB/setup %}

预先安装 ruby，rvm

以配置 ruby 2.1.2 环境为例，

rvm install 2.1.2

在 ~/.bashrc 中设置
``export PATH=/usr/local/rvm/gems/ruby-2.1.2/bin:/usr/local/bin:$PATH``

gem install jekyll

gem install redcarpet

注意，redcarpet是``_config.yml``中设置的markdown引擎，生成站点的速度比较快
