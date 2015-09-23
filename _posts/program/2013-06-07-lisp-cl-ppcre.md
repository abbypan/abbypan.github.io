---
layout: post
category : tech
title:  "common lisp 的正则库 cl-ppcre"
tagline: ""
tags : [ "lisp", "regex" ] 
---
{% include JB/setup %}

common lisp 的正则库 cl-ppcre : http://weitz.de/cl-ppcre/ 

## 提取括号匹配内容到列表
{% highlight lisp %}
* (scan-to-strings "(([^b])*)b" "aaabd")
"aaab"
#("aaa" "a")
{% endhighlight %}

## 提取括号匹配内容到指定变量
{% highlight lisp %}
* (register-groups-bind (fname lname (#'parse-integer date month year))
      ("(\\w+)\\s+(\\w+)\\s+(\\d{1,2})\\.(\\d{1,2})\\.(\\d{4})" "Frank Zappa 21.12.1940")
    (list fname lname (encode-universal-time 0 0 0 date month year 0)))
("Frank" "Zappa" 1292889600) 
{% endhighlight %}

## 提取匹配内容到指定变量

{% highlight lisp %}
* (all-matches-as-strings "\\w*" "foo bar baz")
("foo" "" "bar" "" "baz" "")
{% endhighlight %}

## 分割字符串

{% highlight lisp %}
* (split "(\\s+)" "foo bar   baz")
("foo" "bar" "baz")
{% endhighlight %}
 
## 替换

{% highlight lisp %}
* (regex-replace "(?i)fo+" "FOO bar" "frob")
"frob bar"
T
{% endhighlight %}

## 全部替换
{% highlight lisp %}
* (regex-replace-all "(?i)f(o+)" "foo Fooo FOOOO bar" "fr\\1b" :preserve-case t)
"froob Frooob FROOOOB bar" 
{% endhighlight %}

## 字符串反引用，相当于perl里的quotemeta
{% highlight lisp %}
* (quote-meta-chars "[a-z]*")
"\\[a\\-z\\]\\*"
{% endhighlight %}
