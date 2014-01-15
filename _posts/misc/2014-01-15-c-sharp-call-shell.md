---
layout: post
category: tech
title: "C sharp 执行shell命令，并输出执行结果"
tagline: "C sharp call shell"
tags: ["csharp" , "shell" "stdout" ] 
---
{% include JB/setup %}

参考：[how-to-execute-command-line-in-c-get-std-out-results](http://stackoverflow.com/questions/206323/how-to-execute-command-line-in-c-get-std-out-results)

## 源码

{% highlight csharp %}
//testshell.cs
using System;
using System.IO;
using System.Diagnostics;

class TestShell
{
    public static void Main()
    {

        string[] args = Environment.GetCommandLineArgs();
        string shell_path = args[1];
        string shell_var = args[2];

        Process robot = new Process();

        robot.StartInfo.FileName = "cmd";
        robot.StartInfo.Arguments = "/C \"" + 
            shell_path + "\" " + shell_var ;

        robot.StartInfo.UseShellExecute = false;
        robot.StartInfo.RedirectStandardOutput = true;
        robot.Start();    

        Console.WriteLine(robot.StandardOutput.ReadToEnd());
        robot.WaitForExit();
    }
}
{% endhighlight %}


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
