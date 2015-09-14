---
layout: post
category : tech
title:  "Perl : RTF::Writer 生成rtf文件"
tagline: ""
tags : [ "perl", "cpan", "rtf" ] 
---
{% include JB/setup %}

参考：

[RTF::Writer](https://metacpan.org/pod/distribution/RTF-Writer/lib/RTF/Writer.pod)

[rtf pocket guide](https://www.safaribooksonline.com/library/view/rtf-pocket-guide/9781449302047/ch01.html)

{% highlight perl %}
use RTF::Writer;
use utf8;

my $rtf = RTF::Writer->new_to_file("test.rtf");
$rtf->prolog( 'title' => "test", 'author' => "mmm" );

$rtf->paragraph(
    \'\fi480\fs20\b\i',    # 缩进，字号，粗体，斜体
"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试\n"
);

$rtf->paragraph(

    # \sl300\slmult1 行间距, \sb 行前，\sa 行后
    \'\fs25\fi480\sl360\slmult1\sb180\sa280',
"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试\n"
);

#表格
my $decl = RTF::Writer::TableRowDecl->new( 'widths' => [ 900, 1300 ] );
$rtf->row( $decl, '测试', '测试xxxxxxx' );
$rtf->row( $decl, '取值', '取值yyyyyyyyy' );

$rtf->paragraph(
    \'\qc',    #居中
    $rtf->image( 'filename' => "test.png", scalex => 35, scaley => 35 ), #插图
);

$rtf->close;
{% endhighlight %}

![rtf_writer.png](/assets/posts/rtf_writer.png)
