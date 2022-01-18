---
layout: post
category: tech
title:  "Eclipse + Maven 新建 java project，导出可执行的jar"
tagline: ""
tags: [ "java", "eclipse", "maven", "jar" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# install

## java 

openjdk-17-jdk: https://openjdk.java.net/projects/jdk/17/

应设置`JAVA_HOME`环境变量

## maven

maven: https://maven.apache.org/

windows下需要配置maven到PATH环境变量

archlinux下安装目录为 /opt/maven/。

maven本地仓库的默认目录为`$HOME/.m2/repository`。在maven的安装目录中找到`conf/settings.xml`, 把`settings.xml`拷到`$HOME/.m2/`目录下。

修改`$HOME/.m2/settings.xmls`，自行配置添加mirror url，例如：

        <mirrors>
            <mirror>
                <id>nexus-aliyun</id>
                <mirrorOf>central</mirrorOf>
                <name>Nexus aliyun</name>
                <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
            </mirror>
        </mirrors>


## eclipse ide

eclipse-java: https://www.eclipse.org/downloads/

# develop

假设 eclipse 的 project 文件夹为`$HOME/eclipse-workspace`

参考: [Building Java Projects with Maven](https://spring.io/guides/gs/maven/)

## eclipse maven project

    eclipse -> file -> new -> other -> maven -> maven project -> next 
                -> create a simple project, use default workspace location -> next
                -> group id: com.abbypan.justfortest, artifact id: HelloWorld, version: 0.0.1-snapshot, packaging: jar, Name: HelloWorld, Description: HelloWorld
                -> finish

会生成`$HOME/eclipse-workspace/HelloWorld`的目录，注意该目录下有当前工程的pom.xml配置文件。

## 引用其他jar包

假设需要使用 joda-time 2.10.13 包，则在pom.xml中添加

    <dependencies>
            <dependency>
                <groupId>joda-time</groupId>
                <artifactId>joda-time</artifactId>
                <version>2.10.13</version>
            </dependency>
    </dependencies>

## 编写代码

    cd $HOME/eclipse-workspace/HelloWorld/
    mkdir -p src/main/java/com/abbypan/justfortest/
    cd src/main/java/com/abbypan/justfortest

编写`HelloWorld.java`和 `Greeter.java`代码。

可以在java代码中直接`import org.joda.time.LocalTime;`，引用joda-time。注意要在 eclipse 的 HelloWorld Project 右键选中 maven -> update Project，自动下载所引用的jar包。


## 导出可执行的jar

在pom.xml中添加maven.compiler、build的配置。注意设置mainClass，`HelloWorld.java`中的main函数可以做为入口。

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>

    <build>
            <plugins>

            <plugin>
              <groupId>org.apache.maven.plugins</groupId>
              <artifactId>maven-compiler-plugin</artifactId>
              <version>3.9.0</version>
              <configuration>
                <release>17</release>
              </configuration>
            </plugin>

                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-shade-plugin</artifactId>
                    <version>3.2.4</version>
                    <executions>
                        <execution>
                            <phase>package</phase>
                            <goals>
                                <goal>shade</goal>
                            </goals>
                            <configuration>
                                <transformers>
                                    <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                        <mainClass>com.abbypan.justfortest.HelloWorld</mainClass>
                                    </transformer>
                                </transformers>
                            </configuration>
                        </execution>
                    </executions>
                </plugin>
            </plugins>
        </build>


在 eclipse 的 HelloWorld Project 右键选中 maven -> update Project，自动下载所引用的jar包。

在 eclipse 的 HelloWorld Project 右键选中 run as -> mvn clean，自动下载相关的maven plugins。

在 eclipse 的 HelloWorld Project 右键选中 run as -> java application，测试HelloWorld通过。


    cd $HOME/eclipse-workspace/HelloWorld/
    mvn compile
    mvn package

将生成 target/HelloWorld-0.0.1-SNAPSHOT.jar

测试jar包：

    $ java -jar target/HelloWorld-0.0.1-SNAPSHOT.jar com.abbypan.justfortest.HelloWorld "abbypan"
    The current local time is: 23:21:05.252
    Hello world : abbypan


存档：[eclipse_maven_helloworld](https://github.com/abbypan/eclipse_maven_helloworld)
