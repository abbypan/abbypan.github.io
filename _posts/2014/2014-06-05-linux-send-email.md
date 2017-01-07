---
layout: post
category : tech
title:  "Linux : 用 sendemail 指定 发件人，并发送带附件的邮件"
tagline: "sendEmail"
tags : [ "sendemail", "mail", "smtp" ] 
---
{% include JB/setup %}

地址：[sendEmail](http://caspian.dotconf.net/menu/Software/SendEmail/)

非常好用，强烈推荐

## 指定 发件人，并发送带附件 的邮件

{% highlight perl %}
sendemail -vv -u '标题' -m '内容' -a 'someattach.txt' -f somefrom@xxx.com -t somea@yyy.com,otherb@zzz.com
{% endhighlight %}

## 用gmail账号发送邮件

见：[Raspberry pi 使用sendemail发gmail邮件](http://blog.csdn.net/homeway999/article/details/8642286)

{% highlight perl %}
sendEmail -u '标题' -m '内容' -f mygmail@gmail.com -a someattach.txt -t somerecv@yyy.com -vv -s smtp.gmail.com -xu mygmail -xp 'mygmailpwd'
{% endhighlight %}

## 用qq邮箱账号发送带附件的邮件

打开qq邮箱的imap/smtp功能：[如何打开POP3/SMTP/IMAP功能？](http://service.mail.qq.com/cgi-bin/help?subtype=1&&no=166&&id=28)

假设邮箱用户名为 someusr, 打开imap/smtp之后获得的独立密码为 xxxxyyyyzzzzxxxx

{% highlight perl %}
sendEmail -u '标题' -m '内容' -f someusr@qq.com -a someattach.txt -t somerecv@yyy.com -vv -s smtp.qq.com:587 -o tls=yes -xu someusr -xp 'xxxxyyyyzzzzxxxx'
{% endhighlight %}

## windows环境

最好加上 ``-o message-charset=gb2312``
