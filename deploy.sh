#!/bin/bash
hexo deploy -g 2>&1
echo "[INFO] deploy successfully!!!"
echo "[INFO] push github"
MESSAGE="博客更新:`date "+%Y-%m-%d %H:%M:%S"`"
INPUT_MESSAGE=$1
COMMIT_MESSAGE=${INPUT_MESSAGE:-$MESSAGE}
echo $COMMIT_MESSAGE
git add -A .
git commit -m $COMMIT_MESSAGE
git push origin hexo-source