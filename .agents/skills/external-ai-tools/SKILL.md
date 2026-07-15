---
name: external-ai-tools
description: Use when evaluating, installing, or routing third-party AI agent tools, MCP servers, agent skills, research utilities, code-indexing tools, OCR, TTS, VTuber, or video-generation projects into this repo's Codex/ECC workflow.
---

# External AI Tools

Use this skill when a task involves third-party AI tooling that may be a skill, MCP server, CLI, local model app, media generator, or research utility.

Do not install or vendor third-party tools blindly. Classify first, then choose the lightest integration that gives the repo value.

## Buckets

- `ADOPT`: small enough and directly useful for this repo's agent workflow.
- `PILOT`: promising, but needs an opt-in test before becoming daily workflow.
- `REFERENCE`: useful catalog entry only; install when a concrete task needs it.
- `SKIP`: not appropriate for this repo, unsafe, stale, or redundant.

## Current External Tool Map

| Tool | Bucket | Use |
| --- | --- | --- |
| `ECC` | `ADOPT` | Baseline Codex/ECC setup and repo skill governance. |
| `last30days-skill` | `PILOT` | Current social/web research skill when timely community signal is needed. |
| `headroom` | `PILOT` | Token compression, MCP/proxy experiments, large logs, and codebase exploration. |
| `codegraph` | `PILOT` | Local code knowledge graph experiments on code-heavy repos. |
| `codebase-memory-mcp` | `PILOT` | Codex-aware code knowledge graph/MCP experiments on larger sibling repos. |
| `Agent-Reach` | `PILOT` | API-key-light social/web CLI access; review auth/cookie handling first. |
| `Orca` | `PILOT` | Optional desktop/mobile control surface for parallel coding agents. |
| `OmniRoute` | `PILOT` | Local AI gateway/provider router; isolate and review credentials/ToS first. |
| `agency-agents` | `REFERENCE` | Large agent persona catalog; import selected agents only after review. |
| `OpenMontage` | `REFERENCE` | Agentic video production system for concrete media tasks only. |
| `PaddleOCR` | `REFERENCE` | OCR/PDF/image extraction tasks. |
| `VoxCPM` | `REFERENCE` | Multilingual TTS and voice cloning experiments. |
| `MoneyPrinterTurbo` | `REFERENCE` | Short-video generation workflows. |
| `Open-LLM-VTuber` | `REFERENCE` | Local voice/Live2D AI companion experiments. |
| `hermes-agent` | `REFERENCE` | Self-growing agent comparison; avoid replacing Codex/ECC without a pilot. |

## Install Safety Checklist

Before installing anything from this map:

1. Read the upstream README and license.
2. Prefer isolated installation: `uv tool`, `pipx`, `npx`, Docker, or a clone under an ignored sandbox.
3. Do not add API keys, cookies, browser sessions, tokens, or model caches to this repo.
4. Check whether the tool writes to global agent config such as `~/.codex`, `~/.claude`, shell rc files, or MCP config.
5. For MCP/proxy tools, run them as opt-in local services before making them default.
6. For voice cloning, scraping, and platform automation tools, confirm consent, platform rules, and data handling before use.

## Routing

- Use `last30days-skill` for recent market/community research.
- Use `headroom` when context size, logs, RAG chunks, or tool-output volume is the bottleneck.
- Use `codebase-memory-mcp` or `codegraph` when a code-heavy repo repeatedly burns tokens on file discovery.
- Use `Agent-Reach` when the task needs social/video platform search and the user accepts cookie/session-based tools.
- Use `Orca` only when a multi-agent coding task needs an external fleet-management UI.
- Use `OmniRoute` only for an isolated AI-gateway pilot after reviewing credential handling and provider rules.
- Use `agency-agents` only as a source catalog for selectively reviewed personas.
- Use `PaddleOCR` when documents are images or scanned PDFs.
- Use `OpenMontage`, `VoxCPM`, `MoneyPrinterTurbo`, or `Open-LLM-VTuber` only for media/voice/avatar tasks.

## Reference

The maintained source list and adoption notes live in:

- `inventory/external-ai-tools.md`
