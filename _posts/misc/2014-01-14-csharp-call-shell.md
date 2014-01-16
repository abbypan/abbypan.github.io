---
layout: post
category: tech
title: "C sharp 执行shell命令，并输出执行结果"
tagline: "C sharp call shell"
tags: ["csharp" , "shell","stdout" ] 
---
{% include JB/setup %}

参考：[how-to-execute-command-line-in-c-get-std-out-results](http://stackoverflow.com/questions/206323/how-to-execute-command-line-in-c-get-std-out-results)

## 源码

{% highlight csharp %}
//testshell.cs
using System;
using System.IO;
using System.Diagnostics;

class TestShell {
    public static void Main()
    {

        string[] args = Environment.GetCommandLineArgs();
        string exe = args[1];
        string param = args[2];
        TestShellData x = new TestShellData();
        string data = x.ShellData(exe, param);
        Console.WriteLine(data);
    }
}

class TestShellData
{

    public string ShellData(string exe, string param){
        string some_cmd = '"' + exe + '"' +
                              ' ' +  '"' + param + '"'; 

        Process robot = new Process();
        robot.StartInfo.FileName = "cmd";
        robot.StartInfo.Arguments = "/C \"" + some_cmd + '"';
        robot.StartInfo.UseShellExecute = false;
        robot.StartInfo.RedirectStandardOutput = true;
        robot.Start();    
        
        string data = robot.StandardOutput.ReadToEnd();
        robot.WaitForExit();
        return data;
    }
}
{% endhighlight %}

## 安装c#编译环境

安装[Microsoft Windows SDK for Windows 7 and .NET Framework 4](http://www.microsoft.com/en-us/download/confirmation.aspx?id=8279)

假设安装目录为: ``C:\Windows\Microsoft.NET\Framework64\v4.0.30319``

把该目录加入PATH环境变量后，``csc.exe``可以在命令行直接调用

## 编译并使用

{% highlight bat %}
> csc /target:exe testshell.cs
> .\testshell.exe "perl" "-v"

This is perl 5, version 14, subversion 4 (v5.14.4) built for MSWin32-x86-multi-thread

Copyright 1987-2013, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.
{% endhighlight %}
