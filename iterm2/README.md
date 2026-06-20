# iTerm2 設定の管理（純正フォルダ同期）

iTerm2 はシンボリックリンク（stow）ではなく、**iTerm2 自身の機能**で設定をこのフォルダに
保存／読み込みする。そのため `make link` の対象外（Makefile の EXCLUDE に登録済み）。

## セットアップ手順（各Macで一度だけ）

1. iTerm2 → **Settings**（⌘,）→ **General** → **Settings** タブ
2. **"Load settings from a custom folder or URL"** にチェックを入れ、このフォルダを指定する:
   ```
   ~/dotfiles/iterm2
   ```
3. 保存方法で **"Save changes to folder when iTerm2 quits"**（終了時に保存）を選ぶ
4. iTerm2 を再起動する

→ 設定ファイル `com.googlecode.iterm2.plist` がこのフォルダに書き出され、Git管理される。

## 新Macでの復元

iTerm2 をインストール後、上記と同じ手順でこのフォルダを指定して再起動すれば、
設定（配色・フォント・プロファイル等）がそのまま復元される。

> 注: plist はバイナリのため `git diff` で中身は読めない（変更の有無のみ分かる）。
