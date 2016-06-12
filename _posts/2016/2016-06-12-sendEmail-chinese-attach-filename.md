---
layout: post
category : tech
title:  "用 sendEmail 发送带中文名的邮件附件，下载时附件文件名乱码的问题"
tagline: "chinese"
tags : [ "sendEmail", "chinese" ] 
---
{% include JB/setup %}

## sendEmail示例

[sendEmail](https://github.com/mogaal/sendemail) 是一个非常好用的邮件发送工具，此处省略500字……

    sendEmail -u 华夏 -m 华夏 -o message-charset=utf8 -f xxx@xxx.com -t yyy@yyy.com -a 华夏.txt

## 乱码场景

以下bug场景由耗子发现……

sendEmail将邮件正文内容以及附件文件以unicode编码发送

![sendEmail-unicode.png](/assets/posts/sendEmail-unicode.png)

用 QQ邮箱、网易邮箱 接收邮件后，附件名称正常显示，但下载时自动乱码

![sendEmail-chn-err.png](/assets/posts/sendEmail-chn-err.png)

## 相关信息

[Sending MIME-encoded email attachments with utf-8 filenames](http://stackoverflow.com/questions/27435066/sending-mime-encoded-email-attachments-with-utf-8-filenames)

[How to encode the filename parameter of Content-Disposition header in HTTP?](http://stackoverflow.com/questions/93551/how-to-encode-the-filename-parameter-of-content-disposition-header-in-http/6745788#6745788)

[RFC5987: Character Set and Language Encoding for Hypertext Transfer Protocol (HTTP) Header Field Parameters](https://tools.ietf.org/html/rfc5987)

其中RFC5987描述了unicode字符的格式，例如：

    foo: bar; title*=UTF-8''%c2%a3%20and%20%e2%82%ac%20rates

因此，邮件附件名称的场景也类似，在Content-Disposition头部设置相同格式的filename即可。

## 处理方案

[sendEmail compare changes](https://github.com/mogaal/sendemail/compare/master...abbypan:master)

![sendEmail-diff](/assets/posts/sendEmail-diff.png)

修正之后，网易邮箱的附件能够正常下载：

![sendEmail-163](/assets/posts/sendEmail-chn-163.png)

QQ邮箱仍然乱码，估计还有其他编码兼容问题，暂时不管了。
