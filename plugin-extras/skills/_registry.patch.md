# Registry Patch — New Skills (2026-06-10)

Apply these manually to `_registry.md`. Two sections need updating.

---

## 1. Frontend section — replace the `Algorithmic Art` row and add 4 new rows

**Find this row:**
```
| Algorithmic Art | `algorithmic-art/` | Creating algorithmic art using p5.js with seeded randomness and interactive parameter exploration. Use when users request creating art using code, generative art, algorithmic art, flow fields, or particle systems. |
```

**Replace with:**
```
| Algorithmic Art | `algorithmic-art/` | Create browser-based visual art using p5.js — 7 modes: generative, data viz, interactive, animation, 3D (WebGL), image processing, audio-reactive. Export to HTML/PNG/GIF/MP4. Use for generative art, algorithmic art, flow fields, particle systems, creative coding, or any p5.js visual. |
| Design Md | `design-md/` | Google's open DESIGN.md specification for describing visual identities to coding agents. YAML tokens + Markdown rationale + `npx @google/design.md` CLI for WCAG validation and W3C DTCG/Tailwind export. Use for formal, agent-consumable design system documentation. Distinct from design-system-tokens (internal CSS token architecture). |
| Popular Web Designs | `popular-web-designs/` | 54 real-world design systems (Stripe, Linear, Vercel, Supabase, Apple, Notion, Cursor, PostHog, etc.) as ready-to-use HTML/CSS reference. Exact color palettes, typography hierarchies, component specs, shadow systems, and font substitutions. Use when building UI that should match a specific company's aesthetic. Full detailed templates for Linear, Stripe, Vercel; compact reference for all 54. |
| Sketch | `sketch/` | Generate 2–3 interactive HTML design variants to explore UI directions side-by-side. Intake → variants → comparison table with trade-offs → opinionated recommendation. Use for early design exploration, comparing layout stances, or "sketch this screen" / "show me variants". Promotes to mockup when direction is chosen. |
```

---

## 2. Media section — add 2 new rows after the existing `Excalidraw` row

**Find this row:**
```
| Excalidraw | `excalidraw/` | Brand-themed Excalidraw diagrams for project documentation |
```

**Add these two rows after it:**
```
| Architecture Diagram | `architecture-diagram/` | Generate dark-themed technical architecture diagrams as self-contained HTML/SVG files (browser-only, no renderer needed). Semantic color system per component type (frontend=cyan, backend=emerald, database=violet, cloud=amber, security=rose, message bus=orange, external=slate). Use for system architecture, cloud infrastructure, microservice topology, and deployment diagrams. |
| Ascii Art | `ascii-art/` | Create text-based ASCII art using the right tool — banners (pyfiglet/asciified API), speech bubbles (cowsay), decorative borders (boxes), image conversion (ascii-image-converter/jp2a), pre-made art (ascii.co.uk), and LLM-generated custom art. Decision-routing framework picks the best tool per request. |
```

---

## 3. Productivity section — add 1 new row (alphabetically near "Internal Comms")

**Find:**
```
| Internal Comms | `internal-comms/` | ...
```

**Add before it:**
```
| Humanizer | `humanizer/` | Remove AI writing patterns from text to make it sound natural and human. Covers 29 documented LLM output patterns (AI vocabulary, copula avoidance, em-dash overuse, sycophantic tone, etc.) plus voice calibration from a writing sample. Use when asked to humanize, de-AI, un-ChatGPT, or rewrite drafts (blogs, docs, emails, PRs, releases). MIT licensed. |
```

---

## Also rename these two staged files

```powershell
# In plugin-extras/skills/algorithmic-art/
Move-Item SKILL.new.md SKILL.md -Force

# In plugin/commands/
Move-Item ui-brief.new.md ui-brief.md -Force
```
