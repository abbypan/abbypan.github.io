---
layout: post
category : tech
title:  "Web::Scraper"
tagline: "结构化提取网页内容"
tags : ["perl", "cpan", "web"] 
---
{% include JB/setup %}

## 用 Web::Scraper 解析 html / xml 数据

教程：http://e8y.net/mag/013-web-scraper/

注意：tag如果有大写字母，例如<Message></Message>这种，在Web::Scraper中写解析锚点时，要用小写的message，否则会提取失败

{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;
use Web::Scraper;
use Data::Dumper;
 
my $html =q[
<Message name="testn" value="testv">
<Sub_Message title="abc">just abc</Sub_Message>
<Sub_Message title="efg">just efg</Sub_Message>
</Message>];
 
my $scraper = scraper {
    process_first 'message', 'msg_name' => '@name', 'msg_value' => '@value';

    process 'sub_message' , 'sub_message[]' => {
          'title' => '@title',
          'content' => 'TEXT',
    };
};
 
my $res = $scraper->scrape(\$html);
print Dumper($res);
{% endhighlight %}
