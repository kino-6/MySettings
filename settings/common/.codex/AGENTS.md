# ECC for Codex CLI

This is the local Codex guidance for this machine. Project repositories can add their own AGENTS.md guidance.

<!-- 正本は MySettings の settings/common/.codex/AGENTS.md。mac-setup.sh / wsl-setup.sh が ~/.codex/AGENTS.md へ配置する。
     日本語・判断の節は settings/common/.claude/CLAUDE.md と同じ内容（Claude Code と Codex で読むファイルが違うため）。 -->
## 日本語で答え、言葉を作らない

英語の返答や見慣れない言葉があると、読む人は聞き返すか読み直すことになる。
この節は依頼者への応答（返答・報告・質問）についての決まり。思考・tool 呼び出し・作業用のメモは何語でもよい。

- 返答は日本語で書く。英語の資料・コード・skill を読み書きした直後でも、返答は日本語に戻す
- 英語のまま残すのは、コード・コマンド・ファイル名・識別子・エラーメッセージの引用だけ
- repo に書く文書や commit message は、その repo の慣習に合わせる。返答の言語とは別に決める
- 自分で作った呼び名を使わない。依頼者が使った言葉か、一般に通じる用語で書く
- 比喩を名前にしない。英語をカタカナにしただけの言葉も避け、日本語で言い換える
- 新しい言葉がどうしても要るときは、最初に使う箇所で平易に説明する

## 判断を求めるとき

判断材料を出さずに「どうしますか？」「あなたの判断です」と聞くことは禁止する。判断を返すのは、材料をそろえた後に限る。

- まず自分で決められないかを考える。元に戻せて、依頼の範囲内で、好みが関わらないことは、決めて実行し、何を決めたかを報告する
- 聞くのは、相手にしか決められないことだけにする。好み、優先順位、費用や危険を受け入れるか、範囲を広げるか、の 4 つ
- 判断の根拠が手元にないときは、すぐに聞かず、似た事例を調べる。同じ repo の過去の判断（commit・履歴・記録）、ほかのローカルのプロジェクト、公開されている事例の順に当たる。調べた結果は判断材料として添える
- 聞くときは次をそろえる
  - 具体的な選択肢（「やる / やらない」だけにしない）
  - 選択肢ごとに何が変わるか、費用・時間・危険
  - 自分の推奨と、その理由
  - 返事がないときにどうするか
- 推奨がはっきりしているなら、聞かずに推奨どおり進め、やめたいときの戻し方を書く
- 報告の最後を、毎回質問で終えない

## Docs vs code

When a repository's documentation and its existing code disagree, follow the conventions used in the existing code, and in your final reply point out each inconsistency you found between the documentation and the code.

## Model

The model is set in `~/.codex/config.toml` (`model = ...`). It is not restated here,
because a copy goes stale.

## Skills Discovery

Skills are loaded from `~/.codex/skills/` and from project `.agents/skills/` when present. Each skill contains:
- `SKILL.md` — Detailed instructions and workflow
- `agents/openai.yaml` — Codex interface metadata

Available skills:
- tdd-workflow — Test-driven development with 80%+ coverage
- security-review — Comprehensive security checklist
- coding-standards — Universal coding standards
- frontend-patterns — React/Next.js patterns
- frontend-slides — Viewport-safe HTML presentations and PPTX-to-web conversion
- article-writing — Long-form writing from notes and voice references
- content-engine — Platform-native social content and repurposing
- market-research — Source-attributed market and competitor research
- investor-materials — Decks, memos, models, and one-pagers
- investor-outreach — Personalized investor outreach and follow-ups
- backend-patterns — API design, database, caching
- e2e-testing — Playwright E2E tests
- eval-harness — Eval-driven development
- strategic-compact — Context management
- api-design — REST API design patterns
- verification-loop — Build, test, lint, typecheck, security
- deep-research — Multi-source research with firecrawl and exa MCPs
- exa-search — Neural search via Exa MCP for web, code, and companies
- x-api — X/Twitter API integration for posting, threads, and analytics
- crosspost — Multi-platform content distribution
- fal-ai-media — AI image/video/audio generation via fal.ai
- dmux-workflows — Multi-agent orchestration with dmux
- documentation-lookup — API and release-note verification
- mcp-server-patterns — MCP server design and implementation patterns
- product-capability — Product capability definition and delivery framing

## MCP Servers

Treat the project-local `.codex/config.toml` as the default Codex baseline for ECC. The current ECC baseline enables GitHub, Context7, Exa, Memory, Playwright, and Sequential Thinking; add heavier extras in `~/.codex/config.toml` only when a task actually needs them.

ECC's canonical Codex section name is `[mcp_servers.context7]`. The launcher package remains `@upstash/context7-mcp`; only the TOML section name is normalized for consistency with `codex mcp list` and the reference config.

### config.toml usage

This repository tracks the ECC Codex baseline directly in `.codex/config.toml`.
Keep host-specific credentials, notification commands, and heavier optional MCP
servers in `~/.codex/config.toml` instead of committing them here.

## External Action Boundaries

Treat networked tools as read-only by default. Search, inspect, and draft freely within the user's requested scope, but require explicit user approval before posting, publishing, pushing, merging, opening paid jobs, dispatching remote agents, changing third-party resources, or modifying credentials.

When approval is ambiguous, produce a local plan or draft artifact instead of taking the external action. Preserve user config and private state unless the user specifically asks for a scoped change.

## Multi-Agent Support

Codex now supports multi-agent workflows behind the experimental `features.multi_agent` flag.

- Enable it in `.codex/config.toml` with `[features] multi_agent = true`
- Define project-local roles under `[agents.<name>]`
- Point each role at a TOML layer under `.codex/agents/`
- Use `/agent` inside Codex CLI to inspect and steer child agents

Sample role configs in this repo:
- `.codex/agents/explorer.toml` — read-only evidence gathering
- `.codex/agents/reviewer.toml` — correctness/security review
- `.codex/agents/docs-researcher.toml` — API and release-note verification

## Key Differences from Claude Code

| Feature | Claude Code | Codex CLI |
|---------|------------|-----------|
| Hooks | 8+ event types | Not yet supported |
| Context file | CLAUDE.md + AGENTS.md | AGENTS.md only |
| Skills | Skills loaded via plugin | `.agents/skills/` directory |
| Commands | `/slash` commands | Instruction-based |
| Agents | Subagent Task tool | Multi-agent via `/agent` and `[agents.<name>]` roles |
| Security | Hook-based enforcement | Instruction + sandbox |
| MCP | Full support | Supported via `config.toml` and `codex mcp add` |

## Security Without Hooks

Since Codex lacks hooks, security enforcement is instruction-based:
1. Always validate inputs at system boundaries
2. Never hardcode secrets — use environment variables
3. Run `npm audit` / `pip audit` before committing
4. Review `git diff` before every push
5. Use `sandbox_mode = "workspace-write"` in config
