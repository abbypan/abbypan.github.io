---
layout: post
category: program
title:  "hash : 构造冲突串使hash退化为链表"
tagline: ""
tags : [ "hash" , "perl", "security", "attack" ] 
---
{% include JB/setup %}

论文：[CrosbyWallach_UsenixSec2003.pdf](http://www.cs.rice.edu/~scrosby/hash/CrosbyWallach_UsenixSec2003.pdf)

先汗一个，这论文都整出来多少年了……

问题在于各基础语言用的是“伪HASH”，桶长较小，冲突串容易构造。

加随机数初始化，且限制提交字符的串长度缓解。

参考：

[2007_28C3_Effective_DoS_on_web_application_platforms.pdf](http://events.ccc.de/congress/2011/Fahrplan/attachments/2007_28C3_Effective_DoS_on_web_application_platforms.pdf)

[perlsec.html#Algorithmic-Complexity-Attacks](http://perldoc.perl.org/perlsec.html#Algorithmic-Complexity-Attacks)

perl5.8.1之后，大体上是加个随机种子[PERL_HASH_SEED](http://perldoc.perl.org/perlrun.html#PERL_HASH_SEED)，且运行时一些操作可以动态改变hash值在桶内的位置，增加构造冲突串的复杂度。

由于这个随机处理，两次执行相同脚本，相同hash打出来的key顺序也不同。并且每次插入hash值也会导致key顺序发生变动。perl并不保证hash的key顺序一直固定。

可以把PERL_HASH_SEED置0，则不做随机处理，用于一些特殊的函数，如List::Util::shuffle()。

可以参考这个说明：http://perldoc.perl.org/Hash/Util.html
