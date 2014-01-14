---
layout: post
category : tech
title:  "ChartDirector 安装 （Perl版）"
tagline: "解析文本"
tags : ["perl", "chart", "ChartDirector", "pie" ] 
---
{% include JB/setup %}
 
下载Perl版本的压缩档：[ChartDirector](http://www.advsofteng.com/download.html)，解压到某个目录下，例如/data/chart_director

在/data/chart_director/lib/fonts子目录中放入字体文件，例如微软雅黑字体msyh.ttf

在perl程序中指定/data/chart_director/lib，通过use perlchartdir调用之

如果有中文，要decode转换成unicode才不会乱码

{% highlight perl %}
#!/usr/bin/perl
#源文件是utf8编码
use lib '/data/chart_director/lib';
use perlchartdir;
use Encode;
 
my $angle = 0;
my $clockwise = 1;
 
my $data = [25, 18, 15];
my @labels = map { decode('utf-8', $_) } ("中文1", "中文2", "中文3");
 
my $c = new PieChart(300, 240);
$c->setPieSize(140, 130, 80);
$c->addTitle("Start Angle = $angle degrees\nDirection = Clockwise","msyh.ttf", 12);
$c->setDefaultFonts('msyh.ttf','msyh.ttf');
 
$c->setStartAngle($angle, $clockwise);
$c->set3D();
$c->setData($data, \@labels);
$c->setExplode(0);
 
$c->makeChart("anglepie.png")
{% endhighlight %}
