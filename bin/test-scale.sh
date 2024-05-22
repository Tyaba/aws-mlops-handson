#!/bin/bash
#
# ref: https://gist.github.com/g105b/34ec96a305b74087d5a64db27d1b9fec
#
target=${1:-"http://127.0.0.1:80"}
while true
do
    date
    # 200 req * 50
    hey -n 200 -c 50 $target
    sleep 5
done