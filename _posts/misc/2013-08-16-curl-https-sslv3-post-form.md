---
layout: post
category : tech
title:  "curl : 提交 post 请求 到 https 的form，以sslv3为例"
tagline: ""
tags : ["curl", "perl", "post", "https", "form", "sslv3"] 
---
{% include JB/setup %}

{% highlight perl %}
#!/usr/bin/perl
 
use URI::Escape;
 
my $form_url = 'https://www.somedomain.com/someform.php';
my $para = {
    pa => 'xxxx',
    pb => 'yyyy',
    pc => 'cccc',
};
my $escape_paras = escape_paras($para);
 
my $referer_url = 'http://www.somedomain.com';
my $cookie_file = 'somedomain_cookie.txt';
 
my $curl_cmd =
qq[curl -s --sslv3 --insecure -c "$cookie_file" --referer "$referer_url" -d "$escape_paras" "$form_url"];
my $response = `$curl_cmd`;
 
sub escape_paras {
    my ($para_ref) = @_;
 
    my @para_data = map {
        uri_escape($_) . '=' . uri_escape( $para_ref->{$_} )
    } keys(%$para_ref);
 
    return join "&", @para_data;
}
{% endhighlight %}
