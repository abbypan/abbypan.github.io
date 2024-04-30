---
layout: post
category: program
title:  "windows下安装plantuml"
tagline: ""
tags: [ "plantuml", "java", "graphviz" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# JAVA

假设JAVA安装目录为`d:\software\java`。

配置环境变量:
    JAVA_HOME = d:\software\java
    CLASSPATH = %JAVA_HOME%\lib

在PATH环境变量中新增`%JAVA_HOME%\bin`。

# Graphviz

下载[Graphviz](https://graphviz.gitlab.io/)，假设安装目录为`d:\software\graphviz`。

在PATH环境变量中新增`d:\software\graphviz\bin`。

# plantuml

下载[plantuml](https://plantuml.com/)的jar文件，假设安装目录为`d:\software\plantuml`，文件名为`plantuml.jar`。

在PATH环境变量中新增`d:\software\plantuml`

新建bat文件`d:\software\plantuml\plantuml.bat`，内容为

{% highlight bat %}
java -jar %~dp0plantuml.jar -charset utf8 %*
{% endhighlight %}

# 示例

参考[plantuml-starting](https://plantuml.com/zh/starting)的示例，假设`pic.txt`内容为

    @startuml
    Alice -> Bob: test
    @enduml

命令行执行`plantuml pic.txt`，得到`pic.png`

