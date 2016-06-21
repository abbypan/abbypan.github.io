---
layout: post
category : tech
title:  "Perl : Mojolicious::Lite 笔记"
tagline: "note"
tags : [ "perl", "cpan", "web" ] 
---
{% include JB/setup %}

## 直接显示字符串

{% highlight perl %}
my $s = 'test';
$self->render( text => "<pre>$s</pre>" ); 
{% endhighlight %}

## 下载文件

{% highlight perl %}
use File::Slurp qw/read_file/;

my $bin_f = 'test.mobi';
my $format = 'mobi';
my $bin = read_file($bin_f,  binmode => ':raw');

$self->res->headers->content_type("application/octet-stream") if($format!~/^(txt|html)$/);
$self->res->headers->content_disposition(qq[attachment; filename="$bin_f"]);
$self->render( text => $data, format => $format );
{% endhighlight %}

## 显示字符串、或下载文件

{% highlight perl %}
sub res_attach_file {
    my ( $self, $data, %opt) = @_;
    if ( ! %opt ) {
        $self->render( text => $data );
    }
    else {
        if ( $opt{format} !~ /^(txt|html)$/ ) {
            $self->res->headers->content_type("application/octet-stream");
        }
        $self->res->headers->content_disposition(qq[attachment; filename="$opt{file}"]);
        $self->render( text => $data, format => $opt{format} );
    }
}
{% endhighlight %}
