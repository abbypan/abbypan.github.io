---
layout: post
category : tech
title:  "Perl : Gearman 分发任务"
tagline: "distribute job"
tags : ["perl", "gearman", "job", "task" ] 
---
{% include JB/setup %}

## 介绍

参考：
- [Gearman and Perl](http://www.slideshare.net/andy.sh/gearman-and-perl)
- [Gearman for MySQL](http://www.slideshare.net/datacharmer/gearman-for-mysql)

以 debian 系统为例，假设 job server为 job.xxx.com，worker为机器W，client为机器C

注意，job/worker/client都可以有多个

## job server，负责任务分发

{% highlight bash %}
sudo apt-get install gearman
sudo gearmand -d
{% endhighlight %}

## worker，负责执行任务

新建一个``worker.pl``，注意worker可以注册多个function，执行不同任务

{% highlight perl %}
use Gearman::Worker;

my $worker = Gearman::Worker->new;
$worker->job_servers('job.xxx.com:4730');
# $worker->job_servers('job.xxx.com:4730', 'job2.yyy.com:4730');

$worker->register_function(
'say_hello' , \&hello
);

$worker->work while 1;

sub hello {
    my $arg = $_[0]->arg;
    return "Hello, $arg";
}
{% endhighlight %}

安装执行

{% highlight bash %}
sudo cpanm Gearman::Worker
perl worker.pl
{% endhighlight %}


## client，负责添加任务

新建一个``client.pl``，注意client可以添加多个task，执行不同任务

{% highlight perl %}
use Gearman::Client;
use Data::Dumper;

my $client = Gearman::Client->new;
$client->job_servers('idouzi.tk:4730');

my ($name) = @ARGV;

# waiting on a set of tasks in parallel
my $taskset = $client->new_task_set;

$taskset->add_task( "say_hello" => $name, {
                on_complete => sub {
                        my ($res) = @_;
                        print Dumper($res), "\n";
                },
        });

$taskset->wait;
{% endhighlight %}

安装执行

{% highlight bash %}
sudo apt-get install libgearman-client-perl
perl client.pl
{% endhighlight %}
