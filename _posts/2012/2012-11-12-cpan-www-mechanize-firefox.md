---
layout: post
category : tech
title:  "perl WWW::Mechanize::Firefox 浏览器自动操作"
tagline: "firefox自动操作"
tags : ["perl", "cpan", "firefox" , "web" ] 
---
{% include JB/setup %}

## 调用 click 之后 脚本卡住的问题
见：[Clicking on a link makes the Perl script wait forever](http://search.cpan.org/%7Ecorion/WWW-Mechanize-Firefox-0.71/lib/WWW/Mechanize/Firefox/Troubleshooting.pod#___top)

``$mech->click('#a_link');``

调用之后， WWW::Mechanize::Firefox 会等待下一次web请求结束，才算结束

如果此次点击没有触发新的web请求，就会导致脚本卡住

解决方案是跟WWW::Mechanize::Firefox说这回点击后不等web请求

``$mech->click({ selector => '#a_link', synchronize => 0 });``

## Firefox 内存暴涨

见：[Mech is a big memory pig! I'm running out of RAM!](http://search.cpan.org/dist/WWW-Mechanize/lib/WWW/Mechanize/FAQ.pod#___top)

在初始化时指定 stack_depth ，例如

{% highlight perl %}
 my $mech = WWW::Mechanize::Firefox->new(
        ssl_opts  => { verify_hostname => 0, },
        autoclose => 1,
        bufsize   => 1024 * 1024 * 5,
        stack_depth => 1,
    );
{% endhighlight %}

此外，还要注意firefox保存的历史页面配置，见[Browser.sessionhistory.max total viewers](http://kb.mozillazine.org/Browser.sessionhistory.max_total_viewers)

可以在 about:config 中，把 browser.sessionhistory.max_total_viewers 设成3或5

## 自动刷etao红包，不过没中，估计没写对
{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;
use WWW::Mechanize::Firefox;

while (1) {
    print "hongbao...n";

    my $mech = WWW::Mechanize::Firefox->new( 
    autoclose => 0, 
    activate => 1 );

    eval {
        $mech->get('http://1111.etao.com/?spm=0.0.0.190.t2ON2X&tb_lm_id=etao_zhc_jianli');
        $mech->click( { 
            xpath => '//a[@id="J_LotteryCtl"]',
            synchronize => 0 } );

        sleep 7;
        $mech->autoclose_tab(1);
    };
} ## end while (1)
{% endhighlight %}
