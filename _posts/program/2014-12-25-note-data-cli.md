---
layout: post
category : tech
title:  "笔记：Data Science at the Command Line"
tagline: "tool"
tags : [ "csv", "xlsx", "sql" ] 
---
{% include JB/setup %}

# 查询db，写入csv

``sql2csv --db 'sqlite:///data/song.db' --query 'SELECT * FROM song_info WHERE rate > 4'``

# xlsx 转 csv

in2csv some.xlsx > out.csv

# 从csv取出指定的列

小写 -c 选中，大写 -C 去掉

```
$ cat song.csv | csvcut -c artist,song,id | csvlook

$ echo 'a,b,c,d,e,f,g,h,i\n1,2,3,4,5,6,7,8,9' | > csvcut -c $(seq 1 2 9 | paste -sd,)
a,c,e,g,i
1,3,5,7,9
```

# 从csv取出指定的行

csvgrep -c size -i -r "[1-4]" tips.csv | csvlook

< tips.csv csvsql --query "SELECT * FROM stdin WHERE bill > 40 AND day LIKE '%S%'" | csvlook

< names.csv csvsql --query "SELECT id, first_name || ' ' || last_name AS full_name, born FROM stdin" | csvlook

# 大小写转换
    
``tr '[:upper:]' '[:lower:]'``

# 命令行处理 oauth 认证

curlicue

# 打印偶数行

< some.txt awk '(NR+1)%2'

# 取样

seq 1000 | sample -r 1%

# 首行添加列名

cat word_cnt.txt | header -a word,count

#  删掉首行

< some.txt header -d

# 针对csv执行sql查询

seq 5 | header -a value | csvsql --query "SELECT SUM(value) AS sum FROM stdin"

# 把长字符串按指定宽度截成多行

echo "lsajdflasdjfieqoiutoqedksgfkdj" | fold -w 8

# 命令行抽网页数据

```
$ < wiki.html scrape -b -e 'table.wikitable > tr:not(:first-child)' > table.html
$ < table.html xml2json > table.json
$ < table.json jq -c '.html.body.tr[] | {country: .td[1][],border: .td[2][], surface: .td[3][]}' > countries.json
$ < countries.json json2csv -p -k border,surface > countries.csv
```

xml2json 把html/xml转化为json

json2csv 把 json 转为 csv

# 按行合并多个csv
```
#每个文件用 filenames => species 区分
$ csvstack Iris-*.csv -n species --filenames

#每个文件用 a,b,c => class 区分
csvstack Iris-*.csv -n class -g a,b,c
```

# 按列合并多个csv

paste -d, {bills,customers,datetime}.csv

# 指定列名，关联合并

csvjoin -c species iris.csv

csvsql --query 'SELECT i.sepal_length, i.sepal_width, i.species, m.usda_id FROM iris i JOIN irismeta m ON (i.species = m.species)'

# drake控制数据流

drake，用drip加速启动

# 统计每列取值的去重个数

csvstat some.csv --unique

支持针对各列内容的统计，例如 unique / max / min / sum / mean / median / stdev（标准差）/ nulls（是否有空值）/ freq（频率）/ len（取值的最大字符串长度）

# 用Rio做增强计算

下载：[Rio](https://raw.githubusercontent.com/jeroenjanssens/data-science-at-the-command-line/master/tools/Rio)

< data/tips.csv Rio -e 'df$tip / df$bill * 100' | head

< data/tips.csv Rio -e 'df$percent <- df$tip / df$bill * 100; df' | head

< data/iris.csv Rio -e 'summary(df$sepal_length)'

< dat/iris.csv Rio -e 'cor(df$bill, df$tip)'


安装moments包，并在Rio源码中改一行``REQUIRES="require(moments);"``

$ < data/iris.csv Rio -e 'skewness(df$sepal_length)'  偏态

$ < data/iris.csv Rio -e 'kurtosis(df$petal_width)'   峰态


# 用Rio调用ggplot2画图

比如画多个国家的折线对比图
```
< data/immigration-long.csv Rio -ge 'g+geom_line(aes(x=Period, y=Count, group=Country, color=Country)) + theme(axis.text.x = element_text(angle = -45, hjust = 0))' | display
```

# 用parallel做批量处理

-print0 / -0 是为了处理文件名带空格之类的特殊情况

-j 指定并行数

-k 按顺序执行

--tag 输出结果的时候同时打印输入参数

```
find data -name '*.csv' -print0 | parallel -0 echo "Processing {}"

seq 5 | parallel "echo {}^2 | bc"

#每行只输出第一列
< t.csv parallel -C, echo {1}

#读入首行做为列名，输出其中{name}列
< t.csv parallel -C, --header : echo {name}

#重复执行5次
seq 5 | parallel -N0 "echo The command line rules"

#在指定节点列表执行ifconfig，--nonall表示不传参数执行
#注意：这些节点可以不输入密码，直接在当前机器ssh登陆
parallel --nonall --slf node_list.txt ifconfig
```

# 用tapkee降维

降维一般是无监督的

```
#标准化
< wine-both-clean.csv cols -C type Rio -f scale > wine-both-scaled.csv

#pca降维
< wine-both-scaled.csv cols -C type,quality body tapkee --method pca | header -r x,y,type,quality | Rio-scatter x y type | display
```

# 用weka聚类

```
#csv转arff
weka core.converters.CSVLoader a.csv > a.arff

#arff转csv
weka core.converters.CSVSaver -i a.arff -o b.csv

#EM聚类
weka filters.unsupervised.attribute.AddCluster -W "weka.clusterers.EM -N 5" -i a.arff -o em.arff
```

# 用scikit-learn回归

配置文件

```
[General]
experiment_name = Wine
task = cross_validate
[Input]
train_directory = train
featuresets = [["features.csv"]]
learners = ["LinearRegression","GradientBoostingRegressor","RandomForestRegressor"]
label_col = quality
[Tuning]
grid_search = false
feature_scaling = both
objective = r2
[Output]
log = output
results = output
predictions = output
```

```
#生成3个文件，每个文件为对应回归算法的prediction值与原始数据quality值对比
parallel "csvjoin -c id train/features.csv <(cat output/Wine_features.csv_{}.predictions | tr '\t' ',') | csvcut -c id,quality,prediction > {}" :::  RandomForestRegressor GradientBoostingRegressor LinearRegression

#3个文件合并，加一列learner区分不同算法
csvstack *Regres* -n learner --filenames > predictions.csv
```

# 用bigml分类

要花钱的
