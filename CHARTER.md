# CHARTER.md — MySettings の作業列

> 作業のブレークダウンは [Tasks.md](Tasks.md)。**Tasks.md の毎周の入口でこのファイルも読む。**

本線ごとに目的・ゴール・完了の判断を置く。repo 全体の方針は [.codex/AGENTS.md](.codex/AGENTS.md)。

## 本線 A — 夜間の AI 作業を朝に見る（2026-10-31〜）

### 目的

夜のあいだに AI に任せた作業を、朝に 1 か所で見られるようにする。何が終わり、何が人の判断を待ち、何が止まったかを、repo を 1 つずつ開かずに知る。

### ゴール（2026-10-31）

`python3 .agents/skills/morning-board/scripts/board.py` 1 回で、`~/work` の各 repo について、夜間の commit、`[x]` になった行、`[~]`・`[!]`・`[-]` の行、いま動いている session が出る。

### アプローチ

- 材料は各 repo の Tasks.md、git の記録、`claude agents --json`（Claude Code 組み込みの Agent View）。外部ツールは入れない
- 選ばなかった道: 会話記録の閲覧ツール（`~/.claude/projects/` を丸ごと読む第三者製）。session 単位で、作業の列の単位では見せないため

### 範囲

入る: 読むだけの集計と表示。Tasks.md の箇条書きと表の 2 形式。
入らない: 他の repo への書き込み、通知、常駐、Codex の会話記録。

### 完了の判断

T001〜T005 で達成（2026-10-31）。以後の改良は、skill の試験（`scripts/test_board.py`）と `bash scripts/check.sh` が通ることを条件に、行を立てて進める。

## 本線 B — Codex 公式実装との整合（2026-11-08〜）

### 目的

Codex の設定・profile・hook・AGENTS.md を、現行の公式 CLI の仕様に合わせる。効かない設定を残すと、効いていると思い込んだまま運用が進む。

### 完了の判断

T013 で達成（2026-11-08）。`bash scripts/check-codex-config.sh` が通る。経過は `.agents/ecc-workflow/tasks/2026-11-08-codex-upstream/`。

## 制約と規則

- 公開 repo なので、出力例や試験データに実在の home の絶対パスや個人の作業内容を入れない
- 作業の規則は [task-queue-loop の work-rules](.agents/skills/task-queue-loop/templates/work-rules.md)
