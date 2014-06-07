---
layout: post
category : tech
title:  "Linux : 用 sendemail 指定 发件人，并发送带附件 的邮件"
tagline: "sendEmail"
tags : [ "sendemail", "mail" , "from", "attach"  ] 
---
{% include JB/setup %}

地址：[sendEmail](http://caspian.dotconf.net/menu/Software/SendEmail/)

非常好用，强烈推荐

## 指定 发件人，并发送带附件 的邮件

{% highlight perl %}
sendemail -vv -u "标题" -m "内容" -a "attach.txt" -f from@xxx.com -t somea@bbb.com,otherb@yyy.com
{% endhighlight %}

## 用gmail账号发送邮件
{% highlight perl %}
sendEmail -u '标题' -m '内容' -f mygmail@gmail.com -a someattach.txt -t somerecv@yyy.com -vv -s smtp.gmail.com -xu mygmail -xp 'mygmailpwd'
{% endhighlight %}
