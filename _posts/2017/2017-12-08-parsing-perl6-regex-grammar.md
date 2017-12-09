---
layout: post
category: tech
title:  "笔记：Parsing with Perl 6 Regexes and Grammars"
tagline: ""
tags: [ "perl" ] 
---
{% include JB/setup %}

* TOC
{:toc}

注意参考 [perl6-doc-grammars](https://docs.perl6.org/language/grammars)

# chap1 源码

    $ git clone https://github.com/apress/perl-6-regexes-and-grammars.git

# chap2 变量

{% highlight perl %}
say %populations.keys.sort;  # Output: (Algiers Berlin Tirana)
say %populations.values.sum; # Output: 7553400

my $macbeth = q:to/END/; # need to put the ; on this line!
When shall we three meet again?
In thunder, lightning, or in rain?
When the hurlyburly's done,
When the battle's lost and won.
END

my $callback = -> $x, $y { $x + $y };
say $callback(1, 2);

class Point {
has $.x;
has $.y;
method magnitude() {
return sqrt($.x * $.x + $.y * $.y);
}
}
my $p = Point.new( x => 5, y => 2 );
say $p.x; # Output: 5
say $p.magnitude(); # Output: 5.3851648071345
{% endhighlight %}

# chap3 正则


{% highlight perl %}
# 双引号解释变量,大括号执行代码
$_ = 3; # the string to be matched against
my $x = 3;
say "yes" if /"$x"/;         # Output: yes
say "yes" if /"{1 + 2}"/;    # Output: yes

# 如果是多行字符串，其内部的行锚点以 ^^ , $$ 标识
# 词语的左右边界标识：<< , >>
# 以及 词语任意边界 <?wb> 非词语边界 <!wb> 词语内部 <?ww> 词语外部 <!ww>

#按行读文件
for '/usr/share/dict/words'.IO.lines -> $word {
    say $word if lc($word) ~~ / ^ .e.rl $ /;
}

# 指定字符集
say 'perl' ~~ / <[aeiou]>/;     # Output: ⌜e⌟

/ <[\d]-[78]+[abc]> /  #除了78之外的数字,以及abc

# Table 3.3 是一些支持Unicode的标识，例如 <:Letter>

/ ^ a ** 4 $ /;           # Matches exactly 4 a's
/ ^ a ** 2..4 $ /;        # Matches between 2 and 4 a's
/ ^ a ** 5..* $ /;        # Matches at least 5 a's
# **?1..5. 非贪婪模式的限定匹配

say '1,24,5' ~~ / [\d+]* % ',' /;   # 配置以','分隔的 \d+ 串，加*表示可以匹配空串

say 'aab' ~~ / a+ | \w+ /;   # 匹配较长的aab
say 'aab' ~~ / ab | aa /;    # 等长的情况下，匹配literals win的 aa
say 'aab' ~~ / a+ || \w+ /;  # || 快速返回最快匹配的aa

/ <phonenumber> & <-[9]>* /  # 匹配不含9的电话号码

say 'up to 200 MB' ~~ / \d+ <?before \s* <[kMGT]>? B > /; #匹配200
say 'up to 200 MB' ~~ / \d+ <!before \s* <[kMGT]>? B > /; #匹配20
say 'up to 200 MB' ~~ / « \d+ » <!before \s* <[kMGT]>? B > /; #匹配失败
say '200,50' ~~ / <?after \, > \d+ /; #匹配50
{% endhighlight %}

# chap4 正则及代码

{% highlight perl %}
rx/ a.b /;
say $str.match(:global, /h.mm\w*/).join('|');
say 'Hello, world'.match(/:i hello/);
say ('abc' ~~ m:g/./).elems;

# :m 匹配修饰符
# :r 禁止回溯

/ ab :i cd /;         # match only the cd case-insensitively
/ [:i ab] cd /;       # match only the ab case-insensitively

:global :g  #下一个匹配尝试在上一次匹配结束点之后
:overlap :ov #下一个匹配尝试在上一次匹配起始点之后
:exhaustive :ex #尝试所有可能的匹配

my @numbers = "1308 5th Avenue".comb(/\d+/);
say '42 eur'.subst( rx:i/ « eur » /, '€');        # Output: 42 €
say "9 of spades".subst(/\d+/, -> $m { $m + 1 }); # Output: 10 of spades
say "9 of spades".subst(/(\d+)/, -> $/ { $0 + 1 }); # Output: 10 of spades

my $ad = 'Buy now! USD 10 per book. Prices double soon to 20.';
$ad ~~ s:g[ \d+ ] = 2 * $/;
say $ad; #Buy now! USD 20 per book. Prices double soon to 40.

my $audience = "\\w+";
my $greeting = 'Hello';
"Hello, world" ~~ / $greeting ', ' <$audience> /  #$audience加<>，按正则解释

my @numbers = 'one', 'two', 'three';
my $regex = / @numbers /;
# is equivalent to writing
my $regex = / [ 'one' | 'two' | 'three' ] /

my $one-byte = / ^ \d ** 0..3 $ <?{ $/.Int <= 255 }> /;
#Table 4.3是代码插入效果表
# { CODE } 是执行perl代码，对正则匹配无影响
# <?{ CODE }> / <!{ CODE }> 是正则断言
# <{ CODE }> / <$STRING> 是按正则解释
{% endhighlight %}

# chap5 正则式提取内容

{% highlight perl %}
# 匹配内容写入数组
if "127.0.0.1" ~~ /(\d+)**4 % "."/ {
    say $0.elems;       # Output: 4
    say $0[3].Str;      # Output: 1
}

#命名匹配
my $str = 'Hello, World';
if $str ~~ / $<greeting>=[\w+] ', ' $<audience>=[\w+] / {
    say $<greeting>.Str;        # Output: Hello
    say $<audience>.Str;        # Output: World
}

#声明匹配
my regex byte {
    \d ** 1..3
    <?{  $/.Int <= 255 }>
}
my $str = '127.0.0.1';
if $str ~~ / ^ <byte> ** 4 % '.' $ / {
    for $<byte>.list -> $byte {
        say $byte.Str;
    }
}

my $str = 'Hello, World';
my regex word { \w+ };
if $str ~~ /<greeting=word> ', ' <audience=word>/ {
    say $<greeting>.Str;        # Output: Hello
    say $<audience>.Str;        # Output: World
}

"abc" ~~ /.(.$<char>=[.])/   # $0.<char> = c

# chap6 正则实现机制

复习了一下编译原理的NFA/DFA


{% highlight perl %}
# : 避免回溯 
/ $<tag>=[ <[a..z]>+: ] /

# {} 切分声明块，取出单个声明块里的最长匹配，因此是ab
say "abc" ~~ /ab | a.* /;       # Output: abc
say "abc" ~~ /ab | a {} .* /;   # Output: ab
{% endhighlight %}
{% endhighlight %}

# chap7 正则技术

{% highlight perl %}
#禁止转义
say Q"a\b";           # Output: a\b
say Q"a\\b";          # Output: a\\b
{% endhighlight %}

测试示例

# chap8 正则复用、组合

{% highlight perl %}
grammar IPv4Address {
    token byte {
        \d ** 1..3
            <?{ $/.Int <= 255 }>
    }
    token TOP {
        <byte> ** 4 % '.'
    }
}

my $str = '127.0.0.1';
if IPv4Address.parse($str) {
    say join ', ', $<byte>.list;
# Output: 127, 0, 0, 1
}

#subparse从字符串开头进行匹配，parse则同时锚定字符串起始位置及终止位置
say IPv4Address.subparse($str, :rule<byte>);       # Output: 127
say IPv4Address.parse($str, :rule<byte>);        # Output: Nil

# role 可以被其他 role/grammar 复用
role ParseInteger {
    token unsigned { <[0..9]>+ }
    token signed   { ['+' | '-']? <unsigned> }
}

role ParseFloat does ParseInteger {
    token escale { <[eE]> <unsigned> }
    ...
}

grammar Sum does ParseFloat {
    token number { <signed> | <float> }
    rule TOP { <number> '+' <number> }
}

#proto regex，相当于列举多种可能的选择
grammar JSON {
    proto token value {*};
    token value:sym<string> { <string> }
    token value:sym<number> { <number> }
    token value:sym<object> { <object> }
    token value:sym<array>  { <array>  }
    token value:sym<true>   { <sym>    }
    token value:sym<false>  { <sym>    }
    token value:sym<null>   { <sym>    }
    # more tokens and rules go here
}

# token/rule 禁止回溯，token不含空格，rule隐含空格
{% endhighlight %}

# chap9 以grammar进行解析

P120

{% highlight perl %}

{% endhighlight %}
