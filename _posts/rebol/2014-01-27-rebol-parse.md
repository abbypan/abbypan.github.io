---
layout: post
category : tech
title:  "rebol 的 parse 解析"
tagline: "笔记"
tags : [ "rebol", "parse", "regex" ] 
---
{% include JB/setup %}

parse 支持自顶向下解析，通过rebol的dialect支持实现。可替代正则(regex)

## 笔记 [A Parse Tutorial Sort of (Open sourced Rebol)](http://www.codeconscious.com/rebol/parse-tutorial-r3.html)

| 例子 | 说明 |
| ---- | ---- |
| ``help sys/*parse-url/rules`` | url解析
| ``parse input-string [ opt "big" "bird" ]`` | opt 可选项，总是返回success
| ``parse input-string [ "black" space "dog" ]`` | space 表示空格，此外还有newline、tab等关键字
| ``split "brown dog" " "`` | 拆分字符串，结果为 ``[ "brown" "dog" ]``
| ``parse/case "ZZ" [ 2 "Z" ]`` | 加case表示区分大小写，默认不区分
| ``parse {1234567890} [ "123" 5 skip "90" end ]`` | skip跳过5个字符
| ``parse "bird" [ not "big" "bird" ]`` | not 不匹配

### 解析block

当解析对象是一个block，不是string时，会启动datatype的parse

``parse [ 12/Dec/2012 2:30pm ] [ date! time! ]``

``parse [ <div> "Hello" http://rebol.com $1.00 </div> bob@test.com ] [ tag! "Hello" url! money! tag! email! ]``

### 字符集 charset

charset 是字符集，属于bitset，所以匹配速度较快

可以针对charset做集合常见操作，例如union 并、intersection 交、exclude 差、complement 补。

{% highlight rebol %}
>> digit: charset [#"0" - #"9"]
>> parse {2069} [4 digit]
== true
{% endhighlight %}

还可以增加内容，例如数字集合加一个``.``：``digit-dot: insert copy digit "."``

### copy

注意，copy最终写入第1个参数的内容，取决于第2个参数匹配的情况

{% highlight rebol %}
>> parse {123} [copy some-text skip to end]
== true
>> some-text
== "1"
{% endhighlight %}

set 与 copy 用法类似
{% highlight rebol %}
>> parse [ $100 ] [set wallet money!]
== true
>> wallet
== $100
{% endhighlight %}

### while

无限循环：``parse input-string [ while [ any "dog" ] ]``

while 内部的 subrule 匹配fail时，while循环停止。while自身总是返回``success``。

### break 终止当前block匹配

{% highlight rebol %}
parse [ 1 2 end 3 4 5 ] [ some [ integer! | 'end break ] ]
{% endhighlight %}

### debug用``??``

{% highlight rebol %}
>> parse "dog" [ "d" ?? "o" ?? "g" ]
"o": "og"
"g": "g"
== true
{% endhighlight %}

### 不含``|``的word

word-except-bar 不含``|``的word，用``and``组合实现

{% highlight rebol %}
single-word: [ set item word! ]
word-except-bar: [ and not '| single-word ]
{% endhighlight %}

### 高级例子

- 产品收支的解析器：根据每条记录：解析，计算，求和
- rebol/view的vid block 解析器
- parse-analysis.r
- load-parse-tree.r

## 笔记 [REBOL 3 Concepts: Parsing](http://www.rebol.com/r3/docs/concepts/parsing.html)

``parse series rules``

当series是一个string，就按character解析

当series是一个block，就按value解析

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

- to   一直跳到指定的字符串的首部
- thru 一直跳到指定的字符串的尾部

{% highlight rebol %}
page: read http://www.rebol.com/
parse page [thru <title> copy text to </title>]
print text
REBOL Technologies
{% endhighlight %}

### 替换文本

用change/part修改title字段

{% highlight rebol %}
parse page [
    thru <title> begin: to </title> ending:
    (change/part begin "Word Reference Guide" ending)
]
{% endhighlight %}

用change把``?``全换成``!``

{% highlight rebol %}
str: "Where is the turkey? Have you seen the turkey?"
parse str [some [to "?" mark: (change mark "!") skip]]
print str
Where is the turkey! Have you seen the turkey!
{% endhighlight %}

用``remove / insert / :mark``把 time 换成真正的时间

``mark``  取出对应的变量值

``mark:`` 把mark内容置为**当前的位置**

``:mark`` 表示把 mark的内容 插入**当前的位置**

{% highlight rebol %}
str: "at this time, I'd like to see the time change"
parse str [
    some [to "time"
        mark:
        (remove/part mark 4  mark: insert mark now/time)
        :mark
    ]
]
print str
at this 14:42:12, I'd like to see the 14:42:12 change
{% endhighlight %}

### 匹配的内容append到block!

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
{% endhighlight %}

### 把匹配操作封装成对象

循环提取，append到数组中

{% highlight rebol %}
tag-parser: make object! [
    tags: make block! 100
    text: make string! 8000
    html-code: [
        copy tag ["<" thru ">"] (append tags tag) |
        copy txt to "<" (append text txt)
    ]
    parse-tags: func [site [url!]] [
        clear tags clear text
        parse read site [to "<" some html-code]
        foreach tag tags [print tag]
        print text
    ]
]
tag-parser/parse-tags http://www.rebol.com
{% endhighlight %}

### 递归匹配

[REBOL 3 Concepts: Parsing: Recursive Rules](http://www.rebol.com/r3/docs/concepts/parsing-recursion.html)

一个四则运算的实现，简短，清晰，漂亮！


### 匹配次数

- none 是不匹配
- some 是1到多次匹配
- any  是0到多次匹配


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

parse 默认自动拆分空格space、制表符tab、换行newline、逗号comma、分号semicolon，parse/all 不自动拆分上述三类符号

{% highlight rebol %}
parse "here there,everywhere; ok" none
["here" "there" "everywhere" "ok"]

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

### rules的元素组成

[REBOL 3 Concepts: Parsing: Summary of Parse Operations](http://www.rebol.com/r3/docs/concepts/parsing-summary.html)

一堆总结列表，备查

## 笔记 [REBOL Programming/Language Features/Parse/Parse expressions](http://en.wikibooks.org/wiki/REBOL_Programming/Language_Features/Parse/Parse_expressions)

rebol的parse是自顶向下解析，TDPL

解析表达式写成block，如果匹配，就更新input position

parse 有2种情况：
- 解析字符串，terminal symbols are characters
- 解析block, terminal symbols are Rebol values

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

### 在parse的rule block里可以用``()``执行代码

例子：打印 3 行 "great job"

{% highlight rebol %}
rule: [
    set count integer!
    set str string!
    (loop count [print str])
]
parse [3 "great job"] rule
{% endhighlight %}

### 标志后面加``:``取出当前位置到末尾的值

{% highlight rebol %}
>> parse "123" [ "1" mark: to end ]
== true
>> mark
== "23"
{% endhighlight %}

### 解析block

``e1 e2 | e3`` 相当于 ``[ e1 e2 ] | e3``


### 递归匹配

``anbn: [ "a" anbn "b" | "ab" ]``

### 一张parse idioms表格

怎么写parse expression更简洁，**重点**

参考 [parseen.r](http://www.rebol.org/view-script.r?script=parseen.r)

{% highlight rebol %}
a: charset ",;"
a: [ #"," | #";" ]

a: [m n b]
a: [(l: min m n k: n - m) l b [k [b | c: fail] | :c]]
{% endhighlight %}

### 用到local变量

[use-rule.r](http://www.rebol.org/view-script.r?script=use-rule.r)

[evaluate.r](http://www.rebol.org/view-script.r?script=evaluate.r)

### 慎用 change / insert / remove

因为慢

