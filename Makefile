# ============================================================
# dotfiles 管理 Makefile（GNU Stow ベース・安全ガード付き）
# 使い方: make help
# ============================================================

ROOT       := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
EXCLUDE    := iterm2 hooks claude
PACKAGES   := $(filter-out $(EXCLUDE),$(shell cd $(ROOT) && ls -d */ 2>/dev/null | tr -d '/'))
BACKUP     := $(HOME)/.dotfiles-backup/$(shell date +%Y%m%d-%H%M%S)
STOW       := stow --no-folding -d $(ROOT) -t $(HOME)
# Homebrew 6+ は非公式tapに信頼登録(brew trust)が必須。bundle前に信頼する。
TRUST_TAPS := supabase/tap domt4/autoupdate

.DEFAULT_GOAL := help
.PHONY: help doctor dry-run backup link hooks brew brew-personal brew-work runtime plugins mcp claude-plugins claude-commands bootstrap uninstall restore prune brew-cleanup

help:
	@echo "dotfiles Makefile — 主なコマンド"
	@echo ""
	@echo "  make bootstrap     新Mac一括（brew→link→runtime→plugins）"
	@echo "  make dry-run       何が起きるか確認（変更しない）"
	@echo "  make doctor        健全性チェック（変更しない）"
	@echo "  make link          backup→stowリンク→gitleaksフック設置"
	@echo "  make brew          Brewfile(共通)を導入（tap信頼も自動）"
	@echo "  make runtime-latest 言語を最新安定版に上げて .tool-versions を更新"
	@echo "  make brew-personal Brewfile.personal(個人)を導入"
	@echo "  make brew-work     Brewfile.work(職場)を導入"
	@echo "  make runtime       asdf install（言語ランタイム）"
	@echo "  make plugins       vim-plug / TPM プラグイン取得"
	@echo "  make mcp           Claude Code の MCPサーバを登録"
	@echo "  make claude-plugins Claude Code のプラグインを導入（要 make brew）"
	@echo "  make claude-commands Claude Code のカスタムコマンドを ~/.claude/commands にリンク"
	@echo "  make uninstall     stowリンクを全削除"
	@echo "  make restore       最新backupから実ファイルを復元"
	@echo "  make prune         リンク切れ(幽霊リンク)を掃除"
	@echo "  make brew-cleanup  Brewfileに無いものを削除（破壊的・確認あり）"
	@echo ""
	@echo "  対象パッケージ: $(PACKAGES)"

doctor:
	@echo "== 必要ツール =="
	@for t in stow brew gitleaks asdf git; do command -v $$t >/dev/null 2>&1 && echo "  ok: $$t" || echo "  MISSING: $$t"; done
	@echo "== ROOTを指すリンク切れ(幽霊リンク) =="
	@find $(HOME) -maxdepth 4 -type l 2>/dev/null | while read l; do tgt=$$(readlink "$$l"); case "$$tgt" in $(ROOT)*) [ -e "$$l" ] || echo "  broken: $$l";; esac; done; echo "  (上に何も無ければOK)"
	@echo "== Brewfile と実機の差分 =="
	@cd $(ROOT) && brew bundle check --file=Brewfile 2>/dev/null || echo "  → 未導入あり。'make brew' を検討"

dry-run:
	@echo "対象: $(PACKAGES)"
	$(STOW) -n -v $(PACKAGES)

backup:
	@for pkg in $(PACKAGES); do cd $(ROOT)/$$pkg && find . -type f | sed 's|^\./||' | while read f; do tgt="$(HOME)/$$f"; if [ -e "$$tgt" ] && [ ! -L "$$tgt" ]; then mkdir -p "$(BACKUP)/$$(dirname "$$f")"; mv "$$tgt" "$(BACKUP)/$$f"; echo "  backup: $$tgt"; fi; done; done; echo "  (退避先: $(BACKUP))"

link: backup hooks
	@mkdir -p $(HOME)/.config
	$(STOW) -v $(PACKAGES)
	@echo "✅ link 完了"

hooks:
	@chmod +x $(ROOT)/hooks/pre-commit
	@cd $(ROOT) && git config core.hooksPath hooks 2>/dev/null && echo "✅ gitleaks pre-commit フック有効化" || echo "  (git init 後に再実行してください)"

brew:
	@for t in $(TRUST_TAPS); do brew tap $$t 2>/dev/null || true; done
	@brew trust --tap $(TRUST_TAPS) 2>/dev/null || true
	cd $(ROOT) && brew bundle --file=Brewfile

brew-personal:
	cd $(ROOT) && brew bundle --file=Brewfile.personal

brew-work:
	cd $(ROOT) && brew bundle --file=Brewfile.work

runtime:
	@command -v asdf >/dev/null 2>&1 || { echo "asdf が無い。先に make brew"; exit 1; }
	@asdf plugin add nodejs 2>/dev/null || true
	cd $(HOME) && asdf install

# 言語を最新の安定版に上げて .tool-versions に記録する。
# asdf は latest を自動追従しないので、上げたいときに明示的に叩く。
# ※ nodejs プラグインの版一覧は .node-build が持っている。古いままだと
#    新しい版が見えないため、プラグイン更新を先に行う。
runtime-latest:
	@command -v asdf >/dev/null 2>&1 || { echo "asdf が無い。先に make brew"; exit 1; }
	@asdf plugin update nodejs
	@v=$$(asdf latest nodejs); echo "nodejs の最新: $$v"; \
	  asdf install nodejs $$v; \
	  printf 'nodejs %s\n' "$$v" > $(ROOT)/asdf/.tool-versions; \
	  echo "asdf/.tool-versions を更新した。git diff で確認して commit すること"
	@echo ""
	@echo "Python は uv が管理する。最新にするなら:"
	@echo "  uv python install --reinstall"

plugins:
	@[ -f $(HOME)/.vim/autoload/plug.vim ] || curl -fLo $(HOME)/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@vim +PlugInstall +qall || true
	@[ -d $(HOME)/.config/zsh/fzf-tab ] || git clone --depth 1 https://github.com/Aloxaf/fzf-tab $(HOME)/.config/zsh/fzf-tab
	@[ -d $(HOME)/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm
	@$(HOME)/.tmux/plugins/tpm/bin/install_plugins 2>/dev/null || true

mcp:
	@command -v claude >/dev/null 2>&1 || { echo "claude CLI が無い。Claude Code を先に導入"; exit 1; }
	bash $(ROOT)/claude/mcp-setup.sh

claude-plugins:
	@command -v claude >/dev/null 2>&1 || { echo "claude CLI が無い。Claude Code を先に導入"; exit 1; }
	bash $(ROOT)/claude/plugin-setup.sh

# カスタムコマンド(.md)は Claude Code が書き換えないため symlink で共有できる。
# ~/.claude 自体は会話ログ等が同居するので丸ごとはリンクしない（claude/README.md 参照）。
claude-commands:
	@mkdir -p $(HOME)/.claude/commands
	@for f in $(ROOT)/claude/commands/*.md; do \
	  ln -sfn "$$f" "$(HOME)/.claude/commands/$$(basename "$$f")"; \
	  echo "  link: ~/.claude/commands/$$(basename "$$f")"; \
	done
	@echo "✅ claude-commands 完了"

bootstrap:
	$(MAKE) brew
	$(MAKE) link
	$(MAKE) runtime
	$(MAKE) plugins
	@echo ""
	@echo "🎉 bootstrap 完了。残りの手動ステップ:"
	@echo "  1) cp zsh/.zshenv.example ~/.zshenv          # トークンを記入"
	@echo "  2) cp git/.gitconfig.local.example ~/.gitconfig.local  # メールを記入"
	@echo "  3) make mcp                                  # MCPサーバ登録（要 ~/.zshenv）"
	@echo "  4) make claude-plugins                       # Claude Code のプラグイン導入"
	@echo "     make claude-commands                      # Claude Code のカスタムコマンド"
	@echo "  5) brew autoupdate start --upgrade           # brew自動更新を有効化"
	@echo "  6) iTerm2 の設定フォルダを $(ROOT)/iterm2 に向ける（iterm2/README.md参照）"
	@echo "  7) 個人Macなら make brew-personal / 職場Macなら make brew-work"

uninstall:
	$(STOW) -D -v $(PACKAGES)
	@echo "✅ リンク削除完了"

restore:
	@latest=$$(ls -1d $(HOME)/.dotfiles-backup/*/ 2>/dev/null | tail -1); [ -n "$$latest" ] || { echo "backupが見つかりません"; exit 1; }; echo "復元元: $$latest"; cd "$$latest" && find . -type f | sed 's|^\./||' | while read f; do mkdir -p "$(HOME)/$$(dirname "$$f")"; cp "$$f" "$(HOME)/$$f"; echo "  restore: $$f"; done

prune:
	@find $(HOME) -maxdepth 4 -type l 2>/dev/null | while read l; do tgt=$$(readlink "$$l"); case "$$tgt" in $(ROOT)*) [ -e "$$l" ] || { rm "$$l"; echo "  removed: $$l"; };; esac; done; echo "✅ prune 完了"

brew-cleanup:
	@echo "⚠️  Brewfile に記載の無いものをアンインストールします。"
	@printf "続行しますか? [y/N] "; read a; [ "$$a" = y ] || { echo "中止"; exit 1; }
	cd $(ROOT) && brew bundle cleanup --file=Brewfile --force
