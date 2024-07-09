---
layout: post
category: program
title:  "WWW::Mechanize::Chrome headless 提交表单"
tagline: ""
tags: [ "perl", "headless", "chrome", "web", "cookie" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

Mechanize控制chrome headless提交表单，成功登录。

LWP利用cookie获取目标文件。

{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;
use WWW::Mechanize::Chrome;
use Log::Log4perl qw(:easy);
use File::Slurp qw/write_file/;
use LWP;

my $base_url = "https://www.someweb.org";
my $usr = 'xxxxxxxxxxxxxxxx';
my $pwd = 'ppppppppppppppp';
my $content_url = "$base_url/sometxt";

my ($dst_fname) = @ARGV;
$dst_fname ||= "some.txt";

unlink($dst_fname);

Log::Log4perl->easy_init($ERROR);  # $TRACE

my $mech = WWW::Mechanize::Chrome->new(
          headless => 1,
          autoclose => 1, 
          autodie => 0, 
          launch_arg => [
'--ignore-certificate-errors', 
 '--disable-gpu', 
 '--no-sandbox', 
          ], 
);

for my $i ( 1 .. 10 ){
    $mech->get($base_url."/auth/login");
    sleep(20);

    my $username = $mech->xpath('//input[@name="user"]', single => 1 );
    continue unless($username);
    $username->set_attribute('value', $usr);
    sleep(1);

    my $password_field = $mech->xpath('//*[@id="password"]', single => 1 );
    continue unless($password_field);
    $password_field->set_attribute('value', $pwd);
    sleep(1);

    $mech->form_number(1);
    #print $mech->current_form->get_attribute('innerHTML'), "\n";
    
    $mech->click({ xpath=> '//input[@name="btnLogin"]', single => 1 }); 

    sleep(10);
    my $cookie_jar = $mech->cookie_jar;
    get_content($cookie_jar, $content_url, $dst_fname);
    last;
}

sub get_content {
    my ($cookie_jar, $content_url, $dst_fname) = @_;

    my $browser = LWP::UserAgent->new;
    $browser->cookie_jar($cookie_jar);

    #$browser->get($content_url);
    my $response = $browser->get($content_url);

    if ($response->is_success) {
        my $c = $response->decoded_content;
        write_file($dst_fname, $c);
    }
    else {
        die $response->status_line;
    }
    return $dst_fname;
}
{% endhighlight %}
