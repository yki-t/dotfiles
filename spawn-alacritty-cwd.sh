#!/bin/bash

# 現在のディレクトリを取得
CWD=$(pwd)
# 新しいAlacrittyインスタンスを現在のディレクトリで開く
open -na Alacritty --args --working-directory "$CWD"
