# 我的第一篇博客随笔
*****
## Git  
> 我的一次使用Git，不知踩了多少吭。只有踩过更多的吭才会想方设法的去填玩这些坑。
> 接下来给大家分享一下我是怎么一步一步填满这些吭的

1. Git push 
	> git push 前一定要pull ，否则会报错。
	**删除远程分支**
	``` bash
		$ git push origin :<branch-name> # 提交一个空的分支，覆盖它。
	```
2. Git pull
> If you wish to set tracking information for this branch 				      you can do so with

 ![](http://liushaojun.github.io/images/0A806D56-E0AA-48B3-943C-F2AF9E1B5ADE.png)
	    git branch --set-upstream master origin<branch>
		看到第二个提示，我现在知道了一种解决方案。也就是指定当前的工作目录工作分支，	跟远程的仓库，分支之前的链接关系
		比如我们设置master 对应远程仓库的master 分支
		`git branch --set-upstream master origin/master`
		这样在我们每次都想push或者pull 的时候，只需输入 git push 或者 git pull 即可。在此之前，我们必须指定想要push 或者pull 的远程分支。
		`git push origin master `
		`git pull origin master`
		
3. Git commit


