# git中rebase和merge的区别是什么

>区别：
>1、rebase把当前的commit放到公共分支的最后面，merge把当前的commit和公共分支合并在一起；
>2、用merge命令解决完冲突后会产生一个commit，而用rebase命令解决完冲突后不会产生额外的commit。



**git中rebase和merge的区别是什么**

rebase会把当前分支的 commit 放到公共分支的最后面,所以叫变基。就好像从公共分支又重新拉出来这个分支一样。

举例:如果从 master 拉个feature分支出来,然后提交了几个 commit,这个时候刚好有人把他开发的东西合并到 master 了,这个时候 master 就比你拉分支的时候多了几个 commit,如果这个时候你 rebase master 的话，就会把你当前的几个 commit，放到那个人 commit 的后面。

![16.png](https://img.php.cn/upload/image/621/160/488/1641536819829078.png)

merge会把公共分支和你当前的commit 合并在一起，形成一个新的 commit 提交

![17.png](https://img.php.cn/upload/image/595/435/910/1641536824110062.png)

采用merge和rebase后，git log的区别，merge命令不会保留merge的分支的commit：

![18.png](https://img.php.cn/upload/image/663/802/826/1641536873570539.png)

处理冲突的方式：

- （一股脑）使用merge命令合并分支，解决完冲突，执行git add .和git commit -m'fix conflict'。这个时候会产生一个commit。
- （交互式）使用rebase命令合并分支，解决完冲突，执行git add .和git rebase --continue，不会产生额外的commit。这样的好处是，‘干净’，分支上不会有无意义的解决分支的commit；坏处，如果合并的分支中存在多个commit，需要重复处理多次冲突。

git pull和git pull --rebase区别：git pull做了两个操作分别是‘获取’和合并。所以加了rebase就是以rebase的方式进行合并分支，默认为merge。

参考：https://www.php.cn/tool/git/487227.html