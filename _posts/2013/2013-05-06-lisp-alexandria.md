---
layout: post
category : tech
title:  "Lisp 库 Alexandria Manual"
tagline: "笔记"
tags : [ "lisp", "alexandria" ] 
---
{% include JB/setup %}

见：http://common-lisp.net/project/alexandria/draft/alexandria.html

## Hash Tables

{% highlight lisp %}
; 根据alist初始化一个hash
> (defvar x (alexandria:alist-hash-table '((1 . 2) (3 . 4))))
X
> x
#S(HASH-TABLE :TEST FASTHASH-EQL (3 . 4) (1 . 2))

; 根据key从hash取出value，如果之前没有这个key，就将其置为default的值
> (alexandria.0.dev:ensure-gethash 1 x)
2 ;
T
> (alexandria.0.dev:ensure-gethash 9 x 3)
3 ;
NIL
> x
#S(HASH-TABLE :TEST FASTHASH-EQL (9 . 3) (3 . 4) (1 . 2))

; 拷贝hash
> (defvar y (alexandria:copy-hash-table x))
Y
> y
#S(HASH-TABLE :TEST FASTHASH-EQL (1 . 2) (3 . 4) (9 . 3))


; 取出hash的key，挨个调function处理
> (alexandria:maphash-keys #'(lambda (k) (print (* 2 k))) x)
18
6
2
NIL

; 取出hash的vaule，挨个调function处理
> (alexandria:maphash-values #'(lambda (k) (print (* 2 k))) x)
6
8
4
NIL

> (alexandria:hash-table-keys x)
(1 3 9)

> (alexandria:hash-table-values x)
(2 4 3)

> (alexandria:hash-table-alist x)
((1 . 2) (3 . 4) (9 . 3))

> (alexandria:hash-table-plist x)
(1 2 3 4 9 3)

> (alexandria:plist-hash-table '(1 2 3 4 9 3))
#S(HASH-TABLE :TEST FASTHASH-EQL (9 . 3) (3 . 4) (1 . 2))
{% endhighlight %}

## Data and Control Flow

定义常数 define-constant name initial-value 

类似于perl的smart match

{% highlight lisp %}
           (defun dcase (x)
             (destructuring-case x
               ((:foo a b)
                (format nil "foo: ~S, ~S" a b))
               ((:bar &key a b)
                (format nil "bar, ~S, ~S" a b))
               (((:alt1 :alt2) a)
                (format nil "alt: ~S" a))
               ((t &rest rest)
                (format nil "unknown: ~S" rest))))
    

            (dcase (list :foo 1 2))        ; => "foo: 1, 2"
            (dcase (list :bar :a 1 :b 2))  ; => "bar: 1, 2"
            (dcase (list :alt1 1))         ; => "alt: 1"
            (dcase (list :alt2 2))         ; => "alt: 2"
            (dcase (list :quux 1 2 3))     ; => "unknown: 1, 2, 3"
{% endhighlight %}

返回second-form的结果 multiple-value-prog2 first-form second-form &body forms

命名的lambda函数 named-lambda name lambda-list &body body

switch 没有匹配项的时候返回default的内容

cswitch 没有匹配项的时候抛出一个warning，程序继续执行

eswitch 没有匹配项的时候抛出一个error，程序中止

xor 异或

disjoin predicate &rest more-predicates 相当于对参数做(or (predicate var) (more-predicates var))

conjoin predicate &rest more-predicates 相当于对参数做(and (predicate var) (more-predicates var))

compose相当于把指定的几个函数从右到左合成一个新函数，类似于 f(g(h(x))) 这种
{% highlight lisp %}
> (mapcar (alexandria:compose #'list (lambda (x) (incf x)) #'sqrt) '( 4 9 ))
((3) (4))
{% endhighlight %}

multiple-value-compose 与 compose类似，但是返回多个值

curry函数
{% highlight lisp %}
>  (funcall (alexandria:curry #'+ 9) 2)
11
{% endhighlight %}

rcurry与curry类似，就是参数顺序提到最前面了
{% highlight lisp %}
>  (funcall (alexandria:rcurry #'list 3 1) 2)
(2 3 1)
>  (funcall (alexandria:curry #'list 3 1) 2)
(3 1 2)
{% endhighlight %}

## Conses

## 数组

复制数组  copy-array array

将文件内容读入字符串  read-file-into-string pathname &key buffer-size external-format

## Numbers

{% highlight lisp %}
; maxf 将变量跟另一个值对比，并将改变量设置为二者中的较大值
; minf 类似
> (defvar a 4)
A
> a
4
> (alexandria:maxf a 3)
4
> a
4
> (alexandria:maxf a 5)
5
> a
5

; 组合数学，里面从n个里面取k个, n! / ( k! * (n-k)! )
> (alexandria:binomial-coefficient 4 2)
6

; 组合数学，从n个里面取k个（顺序不同），n! / (n-k)!
> (alexandria:count-permutations 4 2)
6

; 把返回数限定在指定区间内，指定的数值如果比下界小则返回下界，比上界大则返回上界，否则返回原值
> (alexandria:clamp 4 1 3)
3
> (alexandria:clamp 4 1 5)
4
> (alexandria:clamp 4 6 8)
6

;根据系数v返回a、b之间的线性插值 ( a +  v * (b - a) )
;参考 http://game.ceeger.com/Script/Mathf/Mathf.Lerp.html
> (alexandria:lerp 0.5 3 7)
5.0
> (alexandria:lerp 0.3 3 7)
4.2

;阶乘 
> (alexandria.0.dev:factorial 5)
120

; 组合排列，没有一个数在原来的位置上
; 参考 http://mathworld.wolfram.com/Subfactorial.html
> (alexandria:subfactorial 3)
2 ;
0.5751562

; 高斯随机数
; 参考：http://www.taygeta.com/random/gaussian.html
> (alexandria:gaussian-random 3 5)
3.0690623595539472d0 ;
3.112880900596418d0


; 数值序列，指定序列长度、起始数值、单步长度
(iota 4) => (0 1 2 3)
(iota 3 :start 1 :step 1.0)   => (1.0 2.0 3.0)
(iota 3 :start -1 :step -1/2) => (-1 -3/2 -2)


; map-iota生成类似iota的序列，然后对序列中每个数值调用指定function
> (alexandria:map-iota #'print 3 :start 1 :step 1.0)
1.0
2.0
3.0
3

; mean 均值
; median 中位数
; variance 方差
; standard-deviation 标准差
> (alexandria:median '(2 4 9))
4
{% endhighlight %}
