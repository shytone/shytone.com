---
title: GitHub更改历史commit作者信息
tags: git
---
多个git仓库工作，可能需要用不同的作者信息提交，有时候忘记了修改，需要修改log中的作者信息。github给出了以下方法。

<!--more-->

---

## 步骤

- 打开git bash
- 创建项目的全新裸仓库

```shell
git clone --bare https://github.com/user/repo.git
cd repo.git
```

- 复制以下脚本，替换其中信息

```shell
#!/bin/sh

git filter-branch --env-filter ' 
OLD_EMAIL="your-old-email@example.com" # 替换
CORRECT_NAME="Your Correct Name" # 替换
CORRECT_EMAIL="your-correct-email@example.com" # 替换
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```

- 执行
- 查看新git历史有没有错误
- 将正确的历史提交到GitHub

```shell
git push --force --tags origin 'refs/heads/*'
```

- 删除临时clone

```shell
cd ..
rm -rf repo.git
```

---

## 注意

> 警告：这种行为对你的 repo 的历史具有破坏性。如果你的 repo 是与他人协同工作的，重写已发布的历史是一种不好的习惯。仅限紧急情况执行该操作。
> 执行完后重新clone新的repo，因为旧的不会修改。

---

## 参考

[GitHub官方链接](https://help.github.com/articles/changing-author-info/)
