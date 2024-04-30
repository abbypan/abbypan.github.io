---
layout: post
category: program
title:  "perl Encode 字符集编码解码"
tagline: "charset"
tags : ["perl", "cpan", "encode", "unicode", "mysql", "json", "cp936", "utf8", "gbk", "gb2312" ] 
---
{% include JB/setup %}

## utf8乱码

见：[Perl UTF-8 crash course](http://weblog.bulknews.net/post/59317757811/perl-utf-8-crash-course)

贴子大意：

perl打印时会自动按内容修改输出编码(bug)： 
``print "テスト", encode_utf8("テスト")``

指定binmode或命令行添加-C参数可绕过此bug

注意拼接字符串时不要不同编码一起拼： 
``print "テスト". encode_utf8("テスト")``

否则打印出乱码是必然的

## 把 工作愉快！ 变成 5DE54F5C61095FEBFF01

参考： [Unicode 中文部首起始碼位](http://skm.zoomquiet.org/data/20081021112142/)

输入环境编码是 cp936

{% highlight bash %}
echo '工作愉快！' | perl -MEncode -lpe 'Encode::from_to($_, "cp936", "UTF-16BE");$_=uc(unpack("H*",$_))'
{% endhighlight %}

## 用JSON解码字符串后，提交MySQL查询失败的问题

用json格式存mysql查询的条件。

调用JSON模块的from_json函数解码，拼接出mysql查询字符串

{% highlight perl %}
$json_text =  '{ "abc" : "测试" }';
$json_scalar = from_json($json_text, { utf8 => 0 });
$sql_str = "select * from sometable where abc='$json_scalar->{abc}'"
{% endhighlight %}

通过DBI模块将此$sql_str提交到Mysql，查询总是失败。

要用utf8:: downgrade把字符串存储模式换过来才行。

{% highlight perl %}
#!/usr/bin/perl
# 文件是cp936编码
 
use JSON;
use Encode;
use Data::Dumper;
 
my $str = '{ "abc" : "测试" }';
print $str,', ',Dumper($str),"\n";
#{ "abc" : "测试" }, $VAR1 = '{ "abc" : "测试" }';
print "-----\n\n";
 
$t = from_json($str, { utf8 => 0 } );
print $t->{abc},', ', Dumper($t->{abc}),"\n";
#测试, $VAR1 = "\x{b2}\x{e2}\x{ca}\x{d4}";
#=> 可见$t->{abc}内部存储是 UTF8=1
print "-----\n\n";
 
utf8::downgrade($t->{abc}, 1);
print $t->{abc},', ', Dumper($t->{abc}),"\n";
#测试, $VAR1 = '测试';
#=> 通过downgrade把$t->{abc}切回 UTF8=0　内部存储
print "-----\n";
{% endhighlight %}

##  decode后拆分中文字符串的乱码问题

场景：从源文件中读入$id和$name，传给send_to_recv

问题：send_to_recv只能接收一定长度的unicode短消息，需要对$c做解码&切割

注意：decode之后，$c内部标识还是没有变成unicode，要显式调用 utf8::downgrade，不然后面把$c拆成@c_list的时候会出现乱码

{% highlight perl %}
#!/usr/bin/perl
#code file is cp936 enoding
use Encode;

my $message = " : 一二三四一二三四一二三四一二三四一二三四一二三四一二三四一二三四一二三四一二三四一二三四";

while($str = <FILE>){
    my ($id, $name) = /^(\d+)\s*(.*\S)\s*$/;
    next unless($name);

    my $c = $name.$message;
    $c=~s/\n//gs;
    $c=decode('cp936', $c);
    utf8::downgrade($c,1);
    my @c_list = $c=~/(.{1,40})/g;

    print encode("cp936", "$_\n") for @c_list;
    send_to_recv($id, $_) for @c_list;
}
{% endhighlight %}
