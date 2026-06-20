# ============================================================
# dotfiles 管理 Makefile（GNU Stow ベース・安全ガード付き）
# 使い方: make help
# ============================================================

ROOT     := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
EXCLUDE  := iterm2 hooks claude
PACKAGES := $(filter-out $(EXCLUDE),$(shell cd $(ROOT) && ls -d */ 2>/dev/null | tr -d '/'))
BACKUP   := $(HOME)/.dotfiles-backup/$(shell date +%Y%m%d-%H%M%S)
STOW     := stow --no-folding -d $(ROOT) -t $(HOME)

.DEFAULT_GOAL := help
.PHONY: help doctor dry-run backup link hooks brew brew-personal runtime plugins mcp bootstrap uninstall restore prune brew-cleanup

help:
	@echo "dotfiles Makefile — 主なコマンド"
	@echo ""
	@echo "  make bootstrap     新Mac一括（brew→link→runtime→plugins）"
	@echo "  make dry-run       何が起きるか確認（変更しない）"
	@echo "  make doctor        健全性チェック（変更しない）"
	@echo "  make link          backup→stowリンク→gitleaksフック設置"
	@echo "  make brew          Brewfile(共通)を導入"
	@echo "  make brew-personal Brewfile.personal(個人)を導入"
	@echo "  make runtime       asdf install（言語ランタイム）"
	@echo "  make plugins       vim-plug / TPM プラグイン取得"
	@echo "  make mcp           Claude Code の MCPサーバを登録"
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
	cd $(ROOT) && brew bundle --file=Brewfile

brew-personal:
	cd $(ROOT) && brew bundle --file=Brewfile.personal

runtime:
	@command -v asdf >/dev/null 2>&1 || { echo "asdf が無い。先に make brew"; exit 1; }
	@asdf plugin add nodejs 2>/dev/null || true
	cd $(HOME) && asdf install

plugins:
	@[ -f $(HOME)/.vim/autoload/plug.vim ] || curl -fLo $(HOME)/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@vim +PlugInstall +qall || true
	@[ -d $(HOME)/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm
	@$(HOME)/.tmux/plugins/tpm/bin/install_plugins 2>/dev/null || true

mcp:
	@command -v claude >/dev/null 2>&1 || { echo "claude CLI が無い。Claude Code を先に導入"; exit 1; }
	bash $(ROOT)/claude/mcp-setup.sh

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
	@echo "  4) iTerm2 の設定フォルダを $(ROOT)/iterm2 に向ける（iterm2/README.md参照）"
	@echo "  5) 個人Macなら make brew-personal"

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
