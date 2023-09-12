---
layout: post
category: tech
title:  "git删除部分commit"
tagline: ""
tags: [ "git" ] 
---
{% include JB/setup %}

* TOC
{:toc}

参考: [How do I delete a commit from a branch?](https://stackoverflow.com/a/46049102)

假设branch为patch-1，准备删除commit 1

    commit 0 : b16a1aa
    commit 1 : <any_hash>
    commit 2 : 1a5197b
    commit 3 : 330da83

git指令如下

    git checkout b16a1aa
    git checkout -b repair
    git cherry-pick 1a5197b
    git cherry-pick 330a83
    git checkout patch-1
    git reset --hard b16a1aa
    git merge repair 
    git push -f origin patch-1
