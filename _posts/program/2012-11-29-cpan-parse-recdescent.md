---
layout: post
category : tech
title:  "perl Parse::RecDescent 递归下降解析文本"
tagline: "parser"
tags : ["perl", "cpan", "parse" ] 
---
{% include JB/setup %}

## 用 Parse::RecDescent 解析 nginx.conf

注意，这个我写的是阳春版，要是有 # 包在引号里面，可能会解析失败

{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;
use Data::Dump qw/dump/;

use Parse::RecDescent;
$::RD_ERRORS = 1;
$::RD_WARN   = 1;
$::RD_HINT   = 1; # Give out hints to help fix problems.
#$::RD_TRACE   = 1;

my $text = `cat nginx.conf`;

my $grammar = <<'END';
   parse :  CONF(s) /^\Z/ { $item[2] } 
   CONF : CONFKVB | CONFKB | CONFKV
   CONFKVB : KEY VALUE(s) '{' CONF(s) '}'    {  $return = { $item[1] => [ @{$item[2]}, $item[4] ] } }
   CONFKB :  KEY '{' CONF(s) '}'  { $return = { $item[1] =>  $item[3]  } }
   CONFKV :  KEY VALUE(s) /;\s*\n/  { 
       $return =
        $#{$item[2]}==0 ? {$item[1] => $item[2][0]}
        : {$item[1] => $item[2]}
   }      
   KEY : /[a-z_0-9]+/
   VALUE: /"[^"]+?"|'[^']+?'|[^;{}\s]+/
END

my $nginx_parser = new Parse::RecDescent ($grammar);
my $tree = $nginx_parser->parse($text);
dump($tree);
{% endhighlight %}
