---
layout: post
category : tech
title:  "语法解析相关：REGEX 正则，BNF，RPN"
tagline: "解析文本"
tags : ["perl", "regex", "bnf", "rebol", "rpn", "parse" ] 
---
{% include JB/setup %}

## 基础

很不错的基础介绍：
[Regular Expressions, BNF and RPN](http://www.school-portal.co.uk/GroupDownloadFile.asp?GroupId=1010236&ResourceId=4537281)

编译原理的基础介绍有很多。简洁精要，需要功力。

参考：[A2 Computing](http://www.school-portal.co.uk/GroupHomepage.asp?GroupId=1010236)

吐槽正则的：
[Regular Expressions: Now You Have Two Problems](http://www.codinghorror.com/blog/2008/06/regular-expressions-now-you-have-two-problems.html)

于我心有戚戚焉。不过《精通正则表达式》还是要看的，看完就知道某些高级技巧走火入魔，更想用BNF，哈哈！ 

## Rebol的Parse

见：
- [REBOL 3 Concepts: Parsing: Parsing Blocks and Dialects](http://www.rebol.com/r3/docs/concepts/parsing-dialects.html)
- [REBOL 3 Concepts: Parsing: Evaluation](http://www.rebol.com/r3/docs/concepts/parsing-evaluation.html)

### 在parse的block里可以用``()``执行代码

例子：打印 3 行 "great job"

{% highlight rebol %}
rule: [
    set count integer!
    set str string!
    (loop count [print str])
]
parse [3 "great job"] rule
{% endhighlight %}

### 嵌套block解析，用into

例子：把 "Ukiah", 10:30 提取到info变量

{% highlight rebol %}
rule: [
    set date date!
    set info into [string! time!]]
]
data: [10-Jan-2000 ["Ukiah" 10:30]]
print parse data rule

print info
{% endhighlight %}

### 匹配文本 copy text to
{% highlight rebol %}
parse page [thru <title> copy text to </title>]
print text
REBOL/Core Dictionary
{% endhighlight %}

### 全局匹配 any 
{% highlight rebol %}
page: read http://www.rebol.com/index.html
tables: make block! 20
parse page [
    any [to "<table" mark: thru ">"
        (append tables index? mark)
    ]
]

foreach table tables [
    print ["table found at index:" table]
]
; table found at index: 836
; table found at index: 2076
; table found at index: 3747
; table found at index: 3815
; table found at index: 4027
; table found at index: 4415
; table found at index: 6050
; table found at index: 6556
; table found at index: 7229
; table found at index: 8268
{% endhighlight %}

### 多次匹配

none 是不匹配

{% highlight rebol %}
[3 "a" 2 "b"]
aaabb

[1 3 "a" "b"]
ab aab aaab

[some "a" "b"]
ab aab aaab aaaab

[any "a" "b"]
b ab aab aaab aaaab

[any "a" "b"]
b ab aab aaab aaaab
{% endhighlight %}

### 替换文本 change/remove/insert

{% highlight rebol %}
parse page [
    thru <title> begin: to </title> ending:
    (change/part begin "Word Reference Guide" ending)
]
parse page [thru <title> copy text to </title>]
print text
; Word Reference Guide

str: "Where is the turkey? Have you seen the turkey?"
parse str [some [to "?" mark: (change mark "!") skip]]
print str
; Where is the turkey! Have you seen the turkey!

str: "at this time, I'd like to see the time change"
parse str [
    some [to "time"
        mark:
        (remove/part mark 4  mark: insert mark now/time)
        :mark
    ]
]
print str
; at this 14:42:12, I'd like to see the 14:42:12 change

{% endhighlight %}

### 拆分字符串 split

parse 默认自动拆分空格、制表符、换行符(space/tab/line)，parse/all 不自动拆分上述三类符号

{% highlight rebol %}
parse "707-467-8000" "-"
["707" "467" "8000"]

parse/all "Harry, 1011 Main St., Ukiah" ","
; ["Harry" " 1011 Main St." " Ukiah"]

parse "Harry, 1011 Main St., Ukiah" ","
; ["Harry" "1011" "Main" "St." "Ukiah"]
{% endhighlight %}

### 字符集合
{% highlight rebol %}
;补集
spacer: charset reduce [tab newline #" "]
non-space: complement spacer

;并集
digit: charset [#"0" - #"9"]
alpha: charset [#"A" - #"Z" #"a" - #"z"]
alphanum: union alpha digit
{% endhighlight %}

### 递归匹配
见：[REBOL 3 Concepts: Parsing: Recursive Rules](http://www.rebol.com/r3/docs/concepts/parsing-recursion.html)

简短，清晰，漂亮！

### 跳过某些内容

- skip 跳过1个character，可指定跳过几次
- to   一直跳到指定的字符（不包含结尾字符）
- thru 一直跳到指定的字符（包含结尾字符）

{% highlight rebol %}
page: read http://www.rebol.com/
parse page [thru <title> copy text to </title>]
print text
REBOL Technologies
{% endhighlight %}

### 总结

见：[REBOL 3 Concepts: Parsing: Summary of Parse Operations](http://www.rebol.com/r3/docs/concepts/parsing-summary.html)
