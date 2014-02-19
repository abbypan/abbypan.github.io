---
layout: post
category : tech
title:  "File::Find::Rule"
tagline: "笔记"
tags : ["perl", "cpan", "file" ] 
---
{% include JB/setup %}

见：http://www.perladvent.org/2002/11th/
{% highlight perl %}
#!/usr/bin/perl
my $last_week = time() - ( 7 * 24 * 60 * 60 );

my @files = File::Find::Rule->file
                            ->name('*.mp3')
                            ->size(">=200K")
                            ->mtime("<$last_week")
                            ->in("/home/mark/mp3");
{% endhighlight %}
