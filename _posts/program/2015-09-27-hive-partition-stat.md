---
layout: post
category : tech
title:  "hive : 分组统计排名、top百分比"
tagline: ""
tags : [ "hive", "sql", "rank", "percentile" ] 
---
{% include JB/setup %}

假设表名为 school_score，要按学校分组统计每个学生的成绩排名，以及成绩排名top x%

{% highlight sql %}
select t1.school, t1.id, t1.name, t1.score, 
   t1.rank, 
   floor((100*t1.rank/t2.student_num)/5)*5 as percentile
   from 

   (
    SELECT school, id, name, score, 
    rank() over (PARTITION BY school ORDER BY score DESC) as rank
    FROM school_score
   ) t1 
   left join 
   (
    select school,count(*) as student_num
    from school_score
    group by school
   ) t2

   on t1.school=t2.school
{% endhighlight %}
