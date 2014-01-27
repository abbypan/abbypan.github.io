---
layout: post
category : tech
title:  "Rebol 的 Parse"
tagline: "笔记"
tags : ["rebol", "parse", "regex"] 
---
{% include JB/setup %}

## rebol wiki 上的 parse 介绍

见：[REBOL Programming/Language Features/Parse/Parse expressions](http://en.wikibooks.org/wiki/REBOL_Programming/Language_Features/Parse/Parse_expressions)

parse 支持自顶向下解析，通过rebol的dialect支持实现。可替代正则(regex)

### Parse expression matching

parse 表达至有两种情况：
- when parsing strings, terminal symbols are characters
- when parsing blocks, terminal symbols are Rebol values

解析表达式写成block，如果匹配，就更新input position

### NONE 空

{% highlight rebol %}
parse "" [#[none]]
; == true
parse [] [#[none]]
; == true
{% endhighlight %}

### Character 字符
{% highlight rebol %}
parse "a" [#"a"]
; == true
{% endhighlight %}

