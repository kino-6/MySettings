# MySettings

Mac / WSL / Windows の dotfiles と setup script を管理する repository。
詳細は [README.md](README.md)。

**正本は [.codex/AGENTS.md](.codex/AGENTS.md)。** agent 向けの規律（変更の作法、skill の
置き場所、MCP 方針）はそちらに集約してあり、ここには複製しない。同じ問いに読み手が
2 つあると、片方だけ直して黙ってずれる。

## MCP の版は固定されている

`.codex/config.toml` と `~/.codex/config.toml` の MCP server は**正確な版に固定**してあり、
`@latest` は使わない。`npx -y <pkg>` は起動時に npm が返したものをそのまま実行するので、
固定していないと「信頼された名前 + 新しい版」だけで任意コードがここで動く。

**提案だけする。更新はしない。** この repository で作業するとき、一度だけ:

```bash
bash scripts/mcp-doctor.sh --check
```

非ゼロで終わったら、**どの pin が何日古いかを伝えて止まる**。版を上げるには upstream の
changelog を読む必要があり、それは user の判断。**自分の判断で pin を上げない。`@latest`
に戻さない。** 毎ターンではなくセッションに一度だけ報告する。

## 検証の作法

- shell / lua の検査は `bash scripts/lint.sh`
- skill inventory の drift は `bash .agents/skills/skill-use-manager/scripts/update-inventory.sh --check`
- セキュリティ監査は、**外部ツールを導入せず**この repository 内の読めるコマンドで行う。
  スキャナを落としてきて走らせる手順は、そのスキャナの信頼を丸ごと取り込む
