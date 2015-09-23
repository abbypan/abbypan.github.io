---
layout: post
category : tech
title:  "Perl : Sys::AlarmCall 设置事件超时"
tagline: "alarm"
tags : ["perl", "alarm", "timeout", "cpan" ] 
---
{% include JB/setup %}

来源：[perlfaq8-如何讓一個緩慢的事件過時？](http://perl.org.tw/docs/faq/perlfaq/perlfaq8.html#_p_w_C_L_H)

参考：[Signals](http://www.perl.org/CPAN/doc/manual/html/pod/perlipc.html#Signals)

用 alarm() 函数，或 Sys::AlarmCall

{% highlight perl %}
use Sys::AlarmCall;
$result = alarm_call($timeout1,$func1,@args1);
@result = alarm_call($timeout2,$func2,@args2);
{% endhighlight %}
