# カレントディレクトリが消えている場合の退避
# 【説明】tmux-resurrect の復元などで、削除済みディレクトリを cwd として
#         シェルが起動することがある。その状態だと zsh が
#         "Current directory does not exist" を出し、Homebrew も
#         cwd を読めないため一切実行できなくなる（brew --prefix を呼ぶ
#         .zshrc の各所でエラーが多発する）。先に $HOME へ逃がしておく。
#         ※ cwd が消えると zsh は $PWD を "." にするが、消えた直後の
#           ディレクトリは vnode が残るため [[ -d $PWD ]] だけでは検知できない。
#           「絶対パスであること」も条件に入れる。
[[ $PWD == /* && -d $PWD ]] || cd -q "$HOME"

# Homebrewのパス
eval "$(/opt/homebrew/bin/brew shellenv)"
