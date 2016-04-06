---
layout: post
category : tech
title:  "Hadoop Streaming ： map reduce 处理"
tagline: ""
tags : [ "hadoop", "streaming", "map", "reduce" ] 
---
{% include JB/setup %}

# 参考

[Hadoop - Streaming](http://www.tutorialspoint.com/hadoop/hadoop_streaming.htm)

[Apache Hadoop Streaming](http://hadoop.apache.org/docs/current/hadoop-streaming/HadoopStreaming.html)

[CPAN Hadoop::Streaming](https://metacpan.org/pod/Hadoop::Streaming)

[RHadoop](https://github.com/RevolutionAnalytics/RHadoop/wiki)

# 用 hadoop fs 导入原始数据

{% highlight bash %}
$ cat ./school_score.txt
111,stu_a,sch_a,90
112,stu_b,sch_a,30
212,stu_c,sch_b,80
213,stu_d,sch_b,80

$ hadoop fs -mkdir -p /user/mytest/school_score

$ hadoop fs -put ./school_score.txt /user/mytest/school_score
{% endhighlight %}

# 编写 map 脚本，按行处理，提取出 school,score

/data/test.map.pl

{% highlight perl %}
!/usr/bin/perl

while(<>){
    chomp;
    my @data = split /,/;  # student_id , student_name, school_name, score
    print "$data[2]\t$data[3]\n";
}
{% endhighlight %}

# 编写 reduce 脚本，按行处理，求各school的score均值

/data/test.reduce.pl

{% highlight perl %}
#!/usr/bin/perl

my %r;
while(<>){
    chomp;
    my @data = split /\t/;
    $r{$data[0]}{score} += $data[1];
    $r{$data[0]}{num}++;
}

while(my ($school, $r) = each %r){
    my $avg_score = $r->{score}/$r->{num};
    print "$school\t$avg_score\n";
}
{% endhighlight %}


# 本地小文件测试 map reduce

{% highlight bash %}
$ cat school_score.txt | perl test.map.pl | sort | perl test.reduce.pl
{% endhighlight %}

# 调用hadoop streaming 运算

{% highlight bash %}
$ hadoop jar /usr/local/hadoop/share/hadoop/tools/lib/hadoop-streaming-*.jar \
-D mapred.job.name='ScoreAvg' \
-input /user/mytest/school_score \
-output /user/mytest/school_score_avg  \
-mapper /data/test.map.pl  \
-reducer /data/test.reduce.pl
{% endhighlight %}

# 查看运算结果

{% highlight bash %}
$ hadoop fs -cat /user/mytest/school_score_avg/*
{% endhighlight %}
