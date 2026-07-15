# External AI Tools

Generated: 2026-06-10 09:11:40 JST
Updated: 2026-07-07 JST

This file tracks third-party AI tools that may be useful around this Codex/ECC setup.

The repo integration is intentionally light: keep the tools cataloged and routed, but do not vendor large third-party projects or run global installers without a task-specific reason.

2026-07-07 note: reviewed the six fast-growing AI-agent repositories from the
precisox X post `2074294583643848959`. None should become a default install in
this dotfiles repo yet; cataloging and opt-in pilots are the right level.

## Adoption Summary

| Tool | Kind | Bucket | Repo action |
| --- | --- | --- | --- |
| `ECC` | Agent environment bundle | `ADOPT` | Already part of this repo's direction; keep as baseline. |
| `last30days-skill` | Agent skill / research engine | `PILOT` | Add to external tool routing; install globally only when needed. |
| `headroom` | Library / proxy / MCP server | `PILOT` | Candidate for opt-in MCP/proxy trials on large-context sessions. |
| `codegraph` | Local code knowledge graph | `PILOT` | Candidate for code-heavy repos; this dotfiles repo is probably too small to benefit. |
| `codebase-memory-mcp` | Local code knowledge graph / MCP server | `PILOT` | Stronger current candidate than `codegraph` for Codex-aware codebase indexing; keep opt-in and avoid default MCP startup here. |
| `Agent-Reach` | Social/web CLI tool suite | `PILOT` | Useful for platform search; review cookie/session auth before use. |
| `Orca` | Parallel coding-agent ADE | `PILOT` | Candidate desktop/mobile control surface for multi-agent work; overlaps with Codex multi-agent and should not replace the repo baseline yet. |
| `OmniRoute` | AI gateway / provider router | `PILOT` | Potential local endpoint for routing Codex/Claude/Cursor across providers; credential, ToS, and proxy behavior require isolated review. |
| `agency-agents` | Agent persona catalog / installer | `REFERENCE` | Large overlapping agent catalog; import selected agents only after quality/security review. |
| `OpenMontage` | Agentic video production system | `REFERENCE` | Useful for video workflows, but heavy runtime and AGPL surface make it task-specific only. |
| `PaddleOCR` | OCR toolkit | `REFERENCE` | Use for scanned PDFs/images; do not install by default. |
| `VoxCPM` | TTS / voice cloning | `REFERENCE` | Use for TTS experiments with consent and model-cache planning. |
| `MoneyPrinterTurbo` | Short-video generator | `REFERENCE` | Use for video-generation workflows only. |
| `Open-LLM-VTuber` | Local AI VTuber app | `REFERENCE` | Use for avatar/voice companion experiments only. |
| `hermes-agent` | Self-growing AI agent | `REFERENCE` | Interesting comparison point; do not replace Codex/ECC without a separate pilot. |

## Tool Notes

### headroom

- Link: https://github.com/chopratejas/headroom
- Upstream describes it as a local-first context compression layer for tool outputs, logs, RAG chunks, files, and conversation history.
- It exposes library, proxy, agent wrapper, MCP server, and memory-oriented modes.
- Suggested local stance: `PILOT`.
- Why: likely useful when Codex sessions are dominated by large logs or file/RAG outputs.
- Do not default-enable yet: MCP/proxy behavior should be tested against this repo's workflow first.

Potential opt-in commands from upstream:

```bash
pip install "headroom-ai[all]"
npm install headroom-ai
headroom proxy --port 8787
headroom mcp install
```

### hermes-agent

- Link: https://github.com/NousResearch/hermes-agent
- Upstream positions it as an agent that grows with the user.
- Suggested local stance: `REFERENCE`.
- Why: overlaps with Codex/ECC agent workflow and may become a separate operating environment rather than a small repo tool.
- Next step: evaluate in isolation before any global install.

### ECC

- Link: https://github.com/affaan-m/ECC
- Upstream positions ECC as an agent harness performance optimization system for Claude Code, Codex, Opencode, Cursor, and related environments.
- Suggested local stance: `ADOPT`.
- Why: this repo already contains ECC-style `.agents/skills`, Codex guidance, and skill governance.
- Next step: keep this repo's curated subset rather than importing the full upstream surface blindly.

### codegraph

- Link: https://github.com/colbymchenry/codegraph
- Upstream describes it as a pre-indexed code knowledge graph for AI coding agents.
- Suggested local stance: `PILOT`.
- Why: useful for code-heavy repos where agents repeatedly scan the same files.
- This repo is mostly Markdown and shell scripts, so expected benefit here is modest.

### codebase-memory-mcp

- Link: https://github.com/DeusData/codebase-memory-mcp
- Upstream describes it as a high-performance MCP server that indexes codebases into a persistent knowledge graph, supports Codex CLI configuration, and exposes CLI calls for indexing/search/path tracing.
- Suggested local stance: `PILOT`.
- Why: better aligned with this repo's Codex/ECC setup than a generic codegraph tool, especially for larger sibling repos.
- Do not default-enable yet: this dotfiles repo is small, and adding another MCP server to `.codex/config.toml` would increase startup/network/update surface for every session.
- Good pilot shape: install in an ignored sandbox or user-local binary, index one code-heavy repo, then decide whether a commented `.codex/config.toml` example is worthwhile.

Potential upstream install path:

```bash
curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/scripts/setup.sh | bash
```

### last30days-skill

- Link: https://github.com/mvanhorn/last30days-skill
- Upstream describes it as an agent-led search engine across Reddit, X, YouTube, Hacker News, Polymarket, GitHub, and the web.
- Suggested local stance: `PILOT`.
- Why: strong fit for timely research tasks and source-backed market/community briefs.
- Do not vendor the whole project by default; use its supported installer when needed.

Potential upstream install command:

```bash
npx skills add mvanhorn/last30days-skill -g
```

### MoneyPrinterTurbo

- Link: https://github.com/harry0703/MoneyPrinterTurbo
- Upstream describes it as one-click short-video generation using AI LLMs.
- Suggested local stance: `REFERENCE`.
- Why: useful for content/video tasks, but unrelated to normal MySettings maintenance.

### VoxCPM

- Link: https://github.com/OpenBMB/VoxCPM
- Upstream describes VoxCPM2 as tokenizer-free multilingual TTS with voice design and true-to-life cloning.
- Suggested local stance: `REFERENCE`.
- Why: useful for TTS experiments; not a default developer setup tool.
- Safety note: voice cloning should require consent and clear data handling.

### Agent-Reach

- Link: https://github.com/Panniantong/Agent-Reach
- Upstream describes it as a CLI for reading/searching Twitter/X, Reddit, YouTube, GitHub, Bilibili, and Xiaohongshu with zero API fees.
- Suggested local stance: `PILOT`.
- Why: complements research workflows.
- Safety note: cookie/browser-session based auth needs explicit review before use.
- 2026-07-07 review: still useful, but keep dedicated throwaway accounts for cookie-backed platforms and prefer `--safe` / `--dry-run` before install.

### agency-agents

- Link: https://github.com/msitarzewski/agency-agents
- Upstream describes it as a large catalog of specialized AI agent personas with installers for Claude Code, Codex, Cursor, Gemini CLI, OpenCode, and related tools.
- Suggested local stance: `REFERENCE`.
- Why: this repo already curates `.agents/skills` and local Codex skills; bulk-importing another large persona catalog would create overlap and review debt.
- Possible future pilot: selectively compare a few missing roles, such as codebase onboarding or incident response, before importing any one agent into `.agents/skills`.

### OpenMontage

- Link: https://github.com/calesthio/OpenMontage
- Upstream describes it as an agentic video production system with pipelines, tools, and agent skills for scripts, assets, editing, and rendering.
- Suggested local stance: `REFERENCE`.
- Why: valuable for a concrete video-production task, but not a default developer environment dependency.
- Safety note: AGPL licensing, FFmpeg/Node/Python dependencies, and media-provider credentials make this a task-local sandbox candidate, not a dotfiles baseline tool.

### Orca

- Link: https://github.com/stablyai/orca
- Upstream describes it as an ADE for working with a fleet of parallel coding agents, available on desktop and mobile and installable on macOS with Homebrew cask.
- Suggested local stance: `PILOT`.
- Why: relevant to Codex multi-agent workflows, but it overlaps with this repo's built-in `.codex` multi-agent roles.
- Do not add to `Brewfile` yet: only install once there is a specific parallel-agent workflow to test.

Potential upstream install command:

```bash
brew install --cask stablyai/orca/orca
```

### OmniRoute

- Link: https://github.com/diegosouzapw/OmniRoute
- Upstream describes it as an OpenAI-compatible AI gateway for routing many coding agents through one endpoint with provider fallback and token compression.
- Suggested local stance: `PILOT`.
- Why: could reduce provider-limit friction across Codex, Claude Code, Cursor, and related tools.
- Do not default-enable yet: it centralizes credentials, changes model routing semantics, and advertises proxy/fingerprint behavior that needs careful ToS and security review.

Potential upstream install command:

```bash
npm install -g omniroute
```

### Open-LLM-VTuber

- Link: https://github.com/Open-LLM-VTuber/Open-LLM-VTuber
- Upstream describes it as a local cross-platform voice-interactive AI companion with Live2D avatar support.
- Suggested local stance: `REFERENCE`.
- Why: large app/runtime footprint; install only for a concrete avatar/voice task.

### PaddleOCR

- Link: https://github.com/PaddlePaddle/PaddleOCR
- Upstream describes it as an OCR toolkit that converts PDFs/images into structured data for AI and supports 100+ languages.
- Suggested local stance: `REFERENCE`.
- Why: high-value when OCR is needed, but unnecessary as a default MySettings dependency.

## Suggested Next Pilots

1. `last30days-skill`: try as a global user skill when the next current-events or market-research task appears.
2. `codebase-memory-mcp`: test on a code-heavy sibling repo before adding any Codex MCP config example here.
3. `headroom`: test as MCP/proxy only on a large-log or large-repo session.
4. `Orca`: test only when a real multi-agent coding workflow needs a desktop/mobile control surface.
5. `OmniRoute`: test only in a local sandbox after reviewing credential storage, provider ToS, and routing logs.
6. `Agent-Reach`: test only after reviewing cookie/session handling and platform rules.
