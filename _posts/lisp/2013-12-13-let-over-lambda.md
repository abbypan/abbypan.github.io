---
layout: post
category : tech
title:  "Let Over Lambda"
tagline: "笔记"
tags : ["lisp" ] 
---
{% include JB/setup %}

## Introduction

程序的关键在于合适的抽象，这样才不会有一堆重复的代码，增加更多复杂度

宏很强大，宏很灵活，宏无所不能，BLABLABLA......

正如学C一定要理解指针啥时候用，学LISP一定要理解宏啥时候用

风格是给不知道啥时该用语言的啥特性的人准备的（中枪一片）

看此书之前，最好熟读 On Lisp

宏又被描述为元编程meta-program

先理解一下On Lisp的几个宏，例如mkstr、symb、group、flatten等等

## Closures

lisp的闭包一般就是先 let 分配变量，然后返回一个lambda匿名函数，所以叫let over lambda。

在lisp中，变量没有类型，只有值才有类型。

关于lexical scope（词法作用域）和 dynamic scope（动态作用域），注意，现代编程语言基本都是用的lexical scope，因为dynamic scope的函数结果与调用环境紧耦合，同名变量可能引发错误，可参考：CSE 341 -- Lexical and Dynamic Scoping

闭包大多建立在 lexical scope之上

lisp可通过defvar定义dynamic scope的special variables，经常会在变量名前后加 * 号，例如 *special-var*

lexical variables 是在编译阶段分配的symbol

通过declare指定优化条件，指导编译器生成变量，例如 (declare (optimize (speed 3) (safety 0)))

lambda 是个symbol，自身是个宏（注意看实现代码），作用是：生成一个宏，展开时会call指定的function

生成的lambda没法直接像函数一样在form调用，得用funcall或apply调

defun里面定义的lambda，如果不在let包围的lexical scope内（null lexical），就会在编译期的时候生成，后续都是直接调用，不用重复生成；如果是let + lambda组合(non-null lexical)，则是在运行期动态生成，每调一次生成一次

假设一个函数生成闭包，如果该函数被compile，则闭包也会连着被compile；但如果闭包在 non-null lexical 环境下生成，它就没法被compile

其实闭包也可看做是包含一些状态变量（与perl中的state变量含义基本相同）的函数

对象object常用于指代某些数据、程序的集合。闭包类似于只有funcall一个method的对象；对象类似于可以用不同方式funcall的闭包，例如计数器的闭包，可以生成增、减两个lambda（这边的口水话真不少）

初始化一个闭包的方式，所谓的 lambda over  let over lambda

{% highlight lisp %}
(lambda ()
 (let ((cnt 0))
  (lambda () (incf cnt))))
{% endhighlight %}

其实就相当于一个匿名类class

如果是用defun定义，则相当于显式指定外层lambda的名字，只是写的时候省掉了lambda的关键字

{% highlight lisp %}
(defun  cnt-class()
 (let ((cnt 0))
  (lambda () (incf cnt))))
{% endhighlight %}

给了一个block-scanner的闭包例子，检查几个连续的字符串是否能够匹配预先给定的字符串

{% highlight lisp %}
(defvar scanner 
 (block-scanner "jihad"))   ; 指定待匹配的字符串为jihad

# (funcall scanner "the ji")   ; 匹配了 ji

NIL
* (funcall scanner "had tomorrow.")  ;继续匹配了 had

T 
{% endhighlight %}

又给了个闭包之间共享变量的例子，就是在defun外再套一次let，所谓的 Let Over Lambda Over Let Over Lambda

有了闭包可以没有类class，blablabla。。。

## Macro Basics

举例 sleep-units， 有小时、分钟、秒、毫秒、微秒等时间单位

而在lisp中，是用一个symbol来标记一个指定的单位，检查symbol是否相同的速度是很快di

函数调用``(sleep-units% '.5 'h)``

宏调用``(sleep-units .5 h)``

sleep-units的调用在编译期就确定了参数取值，因此速度会比sleep-units%快；但同时，sleep-units也就没法在运行期动态确定unit类型

{% highlight lisp %}
    ; 错误，宏调用期望的是一个symbol，而这边传入的是一个以if开头的列表
    (sleep-units 1 (if super-slow-mode 'd 'h))   
{% endhighlight %}

一个nlet宏的例子(name let)

{% highlight lisp %}
(defmacro nlet (n letargs &rest body)
 `(labels ((,n ,(mapcar #'car letargs)
             ,@body))
     (,n ,@(mapcar #'cadr letargs))))

* (macroexpand
    '(nlet fact ((n n))
        (if (zerop n)
         1
         (* n (fact (- n 1))))))

(LABELS ((FACT (N)
          (IF (ZEROP N)
           1
           (* N (FACT (- N 1))))))
 (FACT N))

T
{% endhighlight %}


函数会对它的所有参数求值，然后把这些求值结果绑定到调用的环境中，再执行之前生成的lambda机器码

宏不对直接对参数求职，而是把它们嵌入一些lisp代码块中，令其执行某些特定的操作

如果碰到尾递归调用已定义的name let， scheme会默认优化，不会增加栈空间；common lisp可能会栈溢出。

关于 free variable 的介绍，blablabla。。。

讨论 nif 的宏展开，变量命名冲突的问题，用gensym解决

lisp-1 与 lisp-2，主要差别有一点，是否为函数提供分离的名字空间。参考 Lisp-1与Lisp-2比较

defmacro/g! 的宏实现，自动找出g!开头的变量，加上gensym声明，省得打那么多字

{% highlight lisp %}
(defmacro defmacro/g! (name args &rest body)
 (let ((syms (remove-duplicates
              (remove-if-not #'g!-symbol-p
               (flatten body)))))
  `(defmacro ,name ,args
      (let ,(mapcar
             (lambda (s)
              `(,s (gensym ,(subseq
                          (symbol-name s)
                          2))))
             syms)
       ,@body))))

    * (macroexpand-1
            '(defmacro/g! nif (expr pos zero neg)
                `(let ((,g!result ,expr))
                    (cond ((plusp ,g!result) ,pos)
                     ((zerop ,g!result) ,zero)
                     (t ,neg)))))

(DEFMACRO NIF (EXPR POS ZERO NEG)
 (LET ((G!RESULT (GENSYM "RESULT")))
  `(LET ((,G!RESULT ,EXPR))
      (COND ((PLUSP ,G!RESULT) ,POS)
       ((ZEROP ,G!RESULT) ,ZERO)
       (T ,NEG)))))
    T 
{% endhighlight %}

双层的defmacro/g!那个junk-outer没搞懂

Paradigms Of Artificial Intelligence Programming: Case Studies in COMMON LISP 的 Once-only: A Lesson in Macrology 的宏实现值得仔细学习

once-only 是对传入宏的表达式只求值一次，将值绑定到新变量，在后续代码中使用该变量的值，避免side-effect

一个重点的宏实现demacro!，同时支持只求值一次（once-only），自动加gensym

{% highlight lisp %}
(defmacro defmacro! (name args &rest body)
 (let* ((os (remove-if-not #'o!-symbol-p args))    ;抽出o!开头的变量名
        (gs (mapcar #'o!-symbol-to-g!-symbol os))) ;将o!x 转换为 g!x
  `(defmacro/g! ,name ,args
      `(let ,(mapcar #'list (list ,@gs) (list ,@os))  ;(let (g!x o!x) (g!y o!y))赋值，此时o!x只求值一次
          ,(progn ,@body)))))

(defmacro! square (o!x)
 `(* ,g!x ,g!x))

    * (macroexpand
            '(square (incf x)))

(LET ((#:X1633 (INCF X)))
 (* #:X1633 #:X1633))
    T
{% endhighlight %}


dynamic variable的取值决定于该表达式什么时候执行，而非它在何处被定义或被编译；lexical varible与之相反。

注意下面这个虽然是let over lambda，但它不是lexical闭包，因为它被解析求值一次后，下回调用直接返回绑定的temp-special值了

{% highlight lisp %}
    * (let ((temp-special 'whatever)) 
            (lambda () temp-special)) 

#<FUNCTION :LAMBDA NIL TEMP-SPECIAL>
{% endhighlight %}


扯了一通common lisp的 Duality of Syntax 有多好，唉，口水话太多，有空再领略其中深意吧

喷了一把 *special-var* 的code style

## Read Macros

\#. 开头的form在读入的时候被求值，而不是等到整个外层form被求值的时候

{% highlight lisp %}
* '(football-game
            (game-started-at
#.(get-internal-real-time))
            (coin-flip
#.(if (zerop (random 2)) 'heads 'tails)))

    (FOOTBALL-GAME
     (GAME-STARTED-AT 309)
     (COIN-FLIP TAILS))
{% endhighlight %}

Backquote \` 不是lisp必须的，但是宏重度使用此符号，虽然一堆人抱怨这个很晕

\` 负责停止evaluate一个form，而 , 可以暂停此效果临时evaluate（称为 unquote)

{% highlight lisp %}
    ; 1) regular unquote

    * (let ((s 'hello))
            `(,s world))

(HELLO WORLD)


; 2) splicing unquote

* (let ((s '(b c d)))
        `(a . ,s)) ; 只能在列表尾部接一下

(A B C D)

    * (let ((s '(b c d)))
            `(a ,@s e)) ; 可以在列表中间展开插入，重新分配空间

(A B C D E) 


; 3) destructive splicing unquote

* (defvar to-splice '(B C D))

TO-SPLICE
* `(A ,.to-splice E)  ; to-splice 尾部接上了E

(A B C D E)
    * to-splice

(B C D E)
{% endhighlight %}

危险的用法

{% highlight lisp %}
(defun dangerous-use-of-bq ()
 `(a ,.'(b c d) e)) 
{% endhighlight %}

第一次调 dangerous-use-of-bq 会得到 (A B C D E)，同时 ‘(b c d) 变成了 '(b c d e)；第二次就会导致死循环，因为 '(b c d e) 尾部的e又要指向自身了

一种解决方案是

{% highlight lisp %}
(defun safer-use-of-bq ()
 `(a ,.(mapcar #'identity '(b c d))  e))

{% endhighlight %}

``defun |#"-reader|``比较简单，就是读stream，直到碰上 "# 就停止

``(set-dispatch-macro-character #\# #\" #'|#"-reader|)``

参考 set-dispatch-macro-character

``defun |#>-reader|``山寨perl的 << 多行字符串，代码可以看看

CL-PPCRE 是lisp的正则库，跟perl的pcre有些不同：
- CL-PPCRE很快，因为它是用lisp实现di，运行时编译。。。c编译器编译的程序没法去折腾c编译器本身，所以用C写的pcre引擎优化的没lisp彻底，blablabla
- CL-PPCRE不限制匹配字符串，可以自定义一些格式匹配，即所谓的DSL （我咋觉得perl的Parse::RecDescent也能搞这些呢，唔，可能没lisp的S表达式灵活）
- CL-PPCRE语法自由度更大

搞了一个 segment-reader 的函数，跟perl的字符串/g匹配差不多

正则匹配和替换的宏

{% highlight lisp %}
#+cl-ppcre
(defmacro! match-mode-ppcre-lambda-form (o!args)
 ``(lambda (,',g!str)
     (cl-ppcre:scan
      ,(car ,g!args)
      ,',g!str)))

#+cl-ppcre
(defmacro! subst-mode-ppcre-lambda-form (o!args)
 ``(lambda (,',g!str)
     (cl-ppcre:regex-replace-all
      ,(car ,g!args)
      ,',g!str
      ,(cadr ,g!args))))
{% endhighlight %}

注意，上面的宏都以两个反引号\`\`开始，生成的是一个列表list，而不是待evaluate的expression

后面接着``defun |#~-reader|``山寨perl的 =~m//, =~s//，用到了上面两个宏
搞好之后就能这么替换字符串了：

``(funcall #~s/abc/def/ "Testing abc testing abc")``

打印循环结构的例子（注意最后的nil不能省，不然卡住死循环）

{% highlight lisp %}
* (let ((*print-circle* t))
        (print '#1=(hello . #1#))
        nil)

#1=(HELLO . #1#)
    NIL
{% endhighlight %}

lisp的read macro示例是v587的，lisp-reader 、lisp-printer

一个安全措施是置 *read-eval* 为 nil，禁止从不可信的源读入数据做为代码执行

另一个安全措施是禁止 #. 宏

还有一个是destructuring-bind指定参数绑定

剩下的是lisp error检查更...的blablabla... common lisp 检查

## Programs That Program

lisp不是函数式语言，人家想咋改就咋改，可以比命令式还命令式，也可以比函数式还函数式，blablabla。。。

``defmacro! defunits%``，有两层反引号\`

\`与 , 结合，调整代码在运行期的执行先后顺序

defun defunits-chaining% 递归调用

defmacro! defunits%%  单位转换

defmacro! defunits 加上一些安全检查

``defun tree-leaves%%``和 defmacro tree-leaves，两者对比，tree-leaves的用法比较简洁。（与perl的 匿名函数sub {} 加 默认变量 $_ 组合有点类似，lisp版的写法更简短一点）

注意 tree-leaves里的x，没声明直接往上写，嵌入了一个implicit lexical variable bound，所谓violate lexical transparency

高级一点的macrolet

Macrolet is a COMMON LISP special form that introduces new macros into its enclosed lexical scope.

macrolet-defined macros will be expanded by the lisp system when it code-walks your expressions.

支持在不同的lexical contexts下进行不同的macro expand => defmacro没法这么牛x

code-walking是lisp系统在对一个表达式进行编译或求值之前要做的一些检查

对于macrolet指定的表达式在编译或求值时，lisp系统会先code-walk一下，并做宏展开

nlet-tail 裸实现尾递归，macrolet + tagbody + go 省栈空间，这个看着比较晕

两个命名比较：second 表示想要的东西是啥(What)，cadr 表示怎么拿到想要的(How)

又一堆口水，lisp的car、cdr函数组合成cadr这种风格挺好,blablabla……

写个宏cxr%，无限组合car/cdr（这个宏木啥特别的）

cxr宏比较有意思，基于cxr%优化了2点：
- n可以传变量进去
- 搞成尾递归节省栈空间，省的n比较大（例如n>10）时，原来的版本展开的inline代码搞太长，不划算

def-english-list-accessors 批量命名多个宏，这个不错

with-all-cxrs 根据指定的'cxr字符串动态生成lambda

dlambda 支持通过key指定运行闭包中的某个函数（类似一个类支持多个方法，尼玛看到这，绝对知道类的好处了）
{% highlight lisp %}
> (setf (symbol-function 'count-test)
        (let ((count 0))
             (dlambda
              (:inc () (incf count))
              (:dec () (decf count)))))
#<FUNCTION :LAMBDA (&REST #:ARGS8148)
    (CASE (CAR #:ARGS8148) 
     ((:INC) (APPLY (LAMBDA NIL (INCF COUNT)) (CDR #:ARGS8148)))
     ((:DEC) (APPLY (LAMBDA NIL (DECF COUNT)) (CDR #:ARGS8148))))

> (count-test :inc)
    1

    (defmacro! dlambda (&rest ds)
     `(lambda (&rest ,g!args)
         (case (car ,g!args)
          ,@(mapcar
              (lambda (d)
               `(,(if (eq t (car d)) t (list (car d)))
                   (apply (lambda ,@(cdr d))
                    ,(if (eq t (car d)) g!args `(cdr ,g!args)))))
              ds)
         )))
{% endhighlight %}

## Anaphoric Macros 

An anaphoric macro is one that deliberately captures a variable from forms supplied to the macro.

On Lisp中的 alambda 是一个anaphoric宏，capture的变量是其中的self 

{% highlight lisp %}
    (defmacro alambda (parms &body body)
     `(labels ((self ,parms ,@body))
#'self))

    > (alambda (n)
            (if (> n 0)
             (cons n (self (- n 1)))))
#<FUNCTION SELF (N) (BLOCK SELF (IF (> N 0) (CONS N (SELF (- N 1)))))>

{% endhighlight %}

``defun |#`-reader|``的用法举例，注意可能隐含了a1、a2、a3等参数定义

alet% 宏调整了let body里某些语句的执行顺序，注意看this前后 

alet 与alet% 大体相同，就是加了个指针功能，每次碰到'invert就返回不一样的lambda，注意宏里面用到了alambda的self，alet的this 

{% highlight lisp %}
(alet ((acc 0))
 (alambda (n)
  (if (eq n 'invert)
   (setq this
    (lambda (n)
     (if (eq n 'invert)
      (setq this #'self)
      (decf acc n))))
   (incf acc n))))
{% endhighlight %}

也就是通过alet + alambda 在运行期间动态改变实际执行的代码片断

用labels实现了going-up/going-down的版本，清楚多了

再用alet-fsm，引入了一个state用于切换labels定义的多个lambda
{% highlight lisp %}
(alet ((acc 0))
 (alet-fsm
  (going-up (n)
   (if (eq n 'invert)
    (state going-down)
    (incf acc n)))
  (going-down (n)
   (if (eq n 'invert)
    (state going-up)
    (decf acc n))))) 
{% endhighlight %}

alet-fsm是个anaphor injection的例子，虽然引入了this，可是光看lexical context的外层代码是没有出现di（押一个桔子，多碰到几次这种，bug就要出来了）

作者说free variable injection写法类似于c指针写法，有N种风格建议（茴字有4种写法，哈哈）

free variable injection常用于两个宏之间通信，复杂度较高，blablabla。。。

ichain-before / ichain-after 注意多个before时，后面的先执行，具体看代码

ichain-intercept% / ichain-intercept 作用类似于参数检查，引入的block为intercept、g!intercept

Hotpatching Closures 运行期动态改变调用的闭包

以 alet-hotpatch%、alet-hotpatch为例，区别在于后者用了dlambda

为了避免alet-hotpatch中this被unwant captured，又优化了一版let-hotpatch，换成上文中的g!this，即所谓的几个宏组合使用成一个整体，与外界隔开。（方法满工巧，就是组合调用的背景略复杂）

上文中demacro!是在sub-lexical scope中绑定变量

指向sub-lexical scope变量的symbol只有在宏展开之前传到lisp的raw lists才会生效（绕不绕呀）

demacro!预处理了g!开头的参数，the G-bang symbols are sub-lexically bound。

举例 junk / junk2 对比，junk中g!var会被替换成#:VAR1663，而junk2调用返回生成g!var字符串的宏，生成的g!var是在sub-lexical scope中，不会再转换成gensyms（这边区别明显）

因此，如果一些symbol reference出现在不同场合，可能展开的结果就不同，例如junk3

另一个例子是with-all-cxrs，宏参数往里传就不要（所以写法有学问）

sublet是搞sub-lexical binding的指令，在看sublet之前得研究let-binding-transform先，不过这个transform比较简单

sublet还用到了tree-leaves。可以看到它的宏展开不保留原来的符号a，而是生成了一个新的标记，连``'a``都自动转过去了。

``sublet*``把 body 先做了一次 macroexpand-1，这样body里的宏引用的变量名就可以预先展开了。这个称为supre sub-lexical scope。
``sublet*``解决了上面的 injector-for-a 问题。不过只能展开一层，嵌套还是不行。原因是“nested macros in the expression are not expanded by macroexpand-1”

``sublet*``这类宏，可以调整宏展开时，可见的变量，form展开的方式。对宏编程的宏。（确实工巧）

另一本书 Lisp in Small Pieces 

pandoriclet 宏，支持根据key进行 变量取值、赋值、执行指定代码，注意这边也用到了this。有些还没定义也可以先写上要用。

What we have done is created an inter-closure protocol, or message passing system, for communicating between closures.

扯了一通generalised variable

Defsetf 宏  implicitly binds gensyms around provided forms

with-pandoric uses symbol-macrolet to install these generalised variables as seemingly new lexical variables with the same names as the closed-over variables. 这些变量由 pandoriclet定义，但lexical contexts分离

跟 Hotpatching Closures 的差别在于，这回的pandoric更精巧，Hotpatching 整个共享lexical binding

Macros are not for inlining, compilers are for inlining

plambda 宏

plambda creates another anaphor—self. While the anaphor this refers to the actual closure that is to be invoked, self refers to the indirection environment that calls this closure.

plambda 和 with-pandoric 可以重写lexical scope。

eval对form求值时，是在一个null lexical环境下的，所以下面这个会出错：
{% highlight lisp %}
* (let ((x 1))
    (eval
      '(+ x 1)))

Error: The variable X is unbound.
{% endhighlight %}

eval 比较慢，而且经常出错，还有限制。所以，想用eval的时候，先想想能不能用宏。

pandoric-eval 先用plambda把变量搞成闭包，传到eval，变成dynamic环境变量生效
{% highlight lisp %}
* (let ((x 1))
    (pandoric-eval (x)
      '(+ 1 x)))

2
{% endhighlight %}

这几段比较晕

## More Efficiency Topics

lisp 就是比较快，blablabla...

看 Edi Weitz 的 CL-PPCRE，blablabla...
