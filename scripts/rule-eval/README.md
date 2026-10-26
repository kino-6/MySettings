# rule-eval

agent への規則（CLAUDE.md / AGENTS.md に書くもの）を、入れる前に効果を測るための一式。

## 使い方

1. 試したい規則を `candidate.md` に書く
2. `bash scripts/rule-eval/all.sh`（各課題 × 2 条件 × 3 回。`REPS=1` で回数を変えられる）
3. `python3 scripts/rule-eval/summary.py scripts/rule-eval/results/<日付>.jsonl`

## 何と何を比べるか

- `base`: 今の `~/.claude/CLAUDE.md` のまま
- `rules`: それに加えて、実行ディレクトリに `candidate.md` を `CLAUDE.md` として置く

つまり「今の設定」と「今の設定 + 試したい規則」の比較になる。
`results/2026-10-26.jsonl` は、user レベルにコードの規則がまだ無かったときの結果。
その規則は採用済みなので、同じ規則で回し直しても差は出ない。

## 測るもの

各課題の `test_hidden.py`（agent には見せない）が通るか。加えて `measure.py` が数える次の値。

- Python: 行数、try、エラーの握りつぶし、raise、入口以外での検証、1 回しか使わない関数、docstring
- HTML: 行数、画面の文字数、ラベル・ボタン・見出し以外の説明文

## 費用と限界

- 30 回で API 換算約 5.4 ドル、約 6 分（2026-10-26）
- テストは正常な入力しか見ていない
- 人のいない実行なので、「聞いてから足す」のような質問の振る舞いは測れない
- 30 回は少ない。分かるのは傾向まで

## 課題の足し方

`tasks/<名前>/` に次を置く。

- `prompt.txt`: agent への依頼
- `test_hidden.py`: 正しさの確認
- `task.json`: 対象ファイル、公開関数、入口の関数、言語（`py` / `html`）
- `seed/`（任意）: 実行前に置いておく既存コード
