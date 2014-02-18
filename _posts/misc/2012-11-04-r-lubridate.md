---
layout: post
category : tech
title:  "R : lubridate 时间处理"
tagline: ""
tags : [ "r", "lubridate", "date" ] 
---
{% include JB/setup %}

 
资料：http://www.jstatsoft.org/v40/i03/paper

## 解析时间
{% highlight r %}
date <- dmy("01-01-2010")
dmy(c("31.12.2010","01.01.2011"))
{% endhighlight %}

类似函数还有ymd()、hm()、hms()、ymd_hms()等

## 取出月份

    month(date)

## 前一天

    date <- date - days(1)


## 当前时间

    now()


## 时间序列，每2周，共3次

    date + c(0:2) * weeks(2)


## date所在月份的第1天

    floor_date(date, "month")

## date所在月份的最后一天
    ceiling_date(date,"month")

## date最近的月份第1天
    round_date(date,"month")

## 周几

    wday(date)

## 今年的第几天

    yday(date)

## 1秒
    seconds(1)

## 指定时间差

    new_duration(day=5, hour=3, minute=-1)

## 所在时区

    tz()

## 周几、几月用文字而非数字表示(February而非2)，文字不用缩写(February而非Feb)

    month(date,label=TRUE, abbr=FALSE)

## 更新时间

{% highlight r %}
day(date) <- 1
update(date, year=2010, month=1,day=1)
date <- date + hours(3)
{% endhighlight %}


## 时间差

{% highlight r %}
start_2011 <- ymd("2011-01-01")
start_2010 <- ymd("2010-01-01")
span <- start_2011 - start_2010
{% endhighlight %}

int_start(span) 为起始时间，int_end(span)为结束时间

## 换一个起始时间，求相同时间差的新时间窗

    as.interval( difftime(start_2011,start_2010), ymd("2010-03-05") )

## 时长

    60秒  new_duration(60)

    120秒  dminutes(2)

    时间序列  1:3 * dhours(1)

    加时间差  start_2011 + dyears(1)


span <- start_2011 - start_2010

    span 转换回秒数：as.duration(span)

    span 转换成描述（如1 year）：as.period(span)


注意years(1)和dyears(1)的差别：

    start_2012 + years(1)  结果是 "2013-01-01"

    start_2012 + dyears(1) 结果是 "2012-12-31"


## 某个时间差跨越了几个周

    interval / dweeks(1)


## 某个时间差余下了几天(24 days)

    interval  %/% months(1)


## 数据为lakers，包含时间date，比赛类型

按天统计比赛次数，画图：

    qplot(wday(date, label=TRUE, abbr=FALSE), data= lakers, geom="histogram")
