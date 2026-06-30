# Skill Refactor Reference URLs

Date: 2026-06-30

This index records non-placeholder URLs already referenced by the repo that are
useful for future skill stocktakes. It is intentionally curated: local test URLs,
`example.com`, `yourdomain.com`, and sample API calls are excluded unless they
represent an upstream dependency or update source.

## How This Was Gathered

- Searched current repo docs and skill bodies with `rg 'https?://'`.
- Checked git reflog lines for clone/source URLs.
- Reviewed existing inventory files that already catalog external tools.

## Core Repo And Codex/ECC Sources

| URL | Current references | Why track |
| --- | --- | --- |
| https://github.com/kino-6/MySettings.git | `.git/logs/HEAD`, `.git/logs/refs/remotes/origin/HEAD` | Repository origin observed from git logs. Useful for provenance only. |
| https://github.com/affaan-m/ECC | `README.md`, `inventory/external-ai-tools.md` | Upstream ECC source that shaped this repo's Codex baseline. |
| https://github.com/affaan-m/everything-claude-code | `.agents/skills/configure-ecc/SKILL.md`, `.agents/skills/everything-claude-code/SKILL.md` | Upstream ECC implementation/reference skill source. |
| https://ecc.tools | `.agents/skills/everything-claude-code/SKILL.md` | ECC-generated skill provenance. |
| https://github.com/addyosmani/agent-skills | `README.md` | Imported production engineering skill pack. |
| https://github.com/anthropics/claude-plugins-official/blob/main/plugins/code-simplifier/agents/code-simplifier.md | `.agents/skills/code-simplification/SKILL.md` | Inspiration source for the code simplification skill. |

## Codex And MCP Documentation

| URL | Current references | Why track |
| --- | --- | --- |
| https://developers.openai.com/codex/config-schema.json | `.codex/config.toml` | Codex config schema. |
| https://developers.openai.com/codex/config-reference | `.codex/config.toml` | Codex config reference. |
| https://developers.openai.com/codex/multi-agent | `.codex/config.toml` | Codex multi-agent reference. |
| https://mcp.exa.ai/mcp | `.codex/config.toml` | Exa MCP endpoint configured in the repo baseline. |
| https://modelcontextprotocol.io | `.agents/skills/mcp-server-patterns/SKILL.md` | MCP documentation reference. |
| https://aka.ms/codetour-schema | `.agents/skills/code-tour/SKILL.md` | CodeTour schema reference. |

## Imported Or Candidate External Tools

| URL | Current references | Why track |
| --- | --- | --- |
| https://github.com/chopratejas/headroom | `inventory/external-ai-tools.md` | Candidate MCP/proxy/context compression pilot. |
| https://github.com/NousResearch/hermes-agent | `inventory/external-ai-tools.md` | Reference agent comparison. |
| https://github.com/colbymchenry/codegraph | `inventory/external-ai-tools.md` | Candidate code knowledge graph pilot. |
| https://github.com/mvanhorn/last30days-skill | `inventory/external-ai-tools.md` | Candidate current-events/research skill. |
| https://github.com/harry0703/MoneyPrinterTurbo | `inventory/external-ai-tools.md` | Reference short-video generator. |
| https://github.com/OpenBMB/VoxCPM | `inventory/external-ai-tools.md` | Reference TTS/voice tool. |
| https://github.com/Panniantong/Agent-Reach | `inventory/external-ai-tools.md` | Candidate platform research CLI. |
| https://github.com/Open-LLM-VTuber/Open-LLM-VTuber | `inventory/external-ai-tools.md` | Reference avatar/voice app. |
| https://github.com/PaddlePaddle/PaddleOCR | `inventory/external-ai-tools.md` | Reference OCR toolkit. |
| https://github.com/standardagents/dmux | `.agents/skills/dmux-workflows/SKILL.md` | Multi-agent orchestration tool reference. |
| https://github.com/apps/ecc-tools | `.agents/skills/continuous-learning-v2/SKILL.md` | ECC tooling source for learning/instinct workflows. |

## Security, Performance, And Framework References

| URL | Current references | Why track |
| --- | --- | --- |
| https://owasp.org/www-project-top-ten/ | `.agents/skills/security-review/references/full-guide.md` | Security review reference. |
| https://genai.owasp.org/llm-top-10/ | `.agents/skills/security-and-hardening/SKILL.md`, security checklist references | LLM application security reference. |
| https://nextjs.org/docs/security | `.agents/skills/security-review/references/full-guide.md` | Next.js security reference. |
| https://supabase.com/docs/guides/auth | `.agents/skills/security-review/references/full-guide.md` | Supabase auth/security reference. |
| https://portswigger.net/web-security | `.agents/skills/security-review/references/full-guide.md` | Web Security Academy reference. |
| https://developer.chrome.com/docs/crux/vis | performance checklist references | Field performance data reference. |
| https://react.dev/reference/react/useActionState#usage | `.agents/skills/source-driven-development/SKILL.md` | React API example source. |
| https://react.dev/blog/2024/12/05/react-19#actions | `.agents/skills/source-driven-development/SKILL.md` | React 19 Actions source. |

## Media, Search, And Platform Services

| URL | Current references | Why track |
| --- | --- | --- |
| https://exa.ai | `.agents/skills/exa-search/SKILL.md` | Exa account/API source. |
| https://fal.ai | `.agents/skills/fal-ai-media/SKILL.md` | fal.ai account/API source. |
| https://www.remotion.dev/docs | `.agents/skills/video-editing/SKILL.md` | Remotion documentation reference. |
| https://x.com/affaanmustafa/status/2014040193557471352 | `strategic-compact`, `iterative-retrieval`, `continuous-learning`, `continuous-learning-v2` | Longform Guide reference reused by several skills. Track for duplication and availability. |
| https://github.com/zarazhangrui | `.agents/skills/frontend-slides/SKILL.md` | Visual exploration inspiration reference. |

## Setup Tool Sources

| URL | Current references | Why track |
| --- | --- | --- |
| https://astral.sh/uv/install.sh | `README.md` | uv installer used by setup documentation. |
| https://sh.rustup.rs | `README.md` | Rust/rustup installer used by setup documentation. |

## Referenced Source Names Without URLs

These names appear in repo docs or licenses without a concrete URL in the
current tracked files. Resolve them during a future source refresh before
assuming the intended upstream.

| Name | Current references | Why track |
| --- | --- | --- |
| `hirokita117/yaml-to-html-skill` | `README.md`, `inventory/codex-skills.md`, explainer skill licenses | Imported explainer workflow source is named, but no upstream URL is currently recorded in tracked docs. |

## Excluded URL Patterns

These appeared in the grep pass but are intentionally not tracked as update
references:

- `http://localhost...` and `https://localhost...` examples.
- `https://example.com...` examples.
- `https://yourdomain.com...` placeholders.
- `https://api.example.com...` placeholders.
- Inline sample calls to X/Twitter, ElevenLabs, or other APIs where the URL is
  part of example code rather than a documentation/source decision.
