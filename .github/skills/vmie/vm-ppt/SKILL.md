---
name: vm-ppt
description: Create executive PowerPoint presentations in the exact bundled Virgin Media Ireland VMIE Powerpoint Template format. Use this whenever a user asks for a VMIE, Virgin Media Ireland, CTIO, Liberty Global, board, senior stakeholder, architecture, roadmap, technical strategy, or executive presentation in PowerPoint; the skill requires using the bundled VMIE Powerpoint Template.pptx as the source of truth and preserving its layouts, theme colors, logos, fonts, headers, footers, slide masters, media, and placeholder styling rather than recreating them manually.
---

# VMIE PowerPoint Template Skill

## Purpose

Create executive-ready PowerPoint decks that exactly follow the bundled Virgin Media Ireland template. The output should look like it was authored directly inside the official VMIE PowerPoint template, not recreated from memory.

The skill optimizes for two things:

- Strong executive communication: clear story, quantified business impact, concise decision framing.
- Exact template fidelity: preserve the template's slide master, layouts, logos, footer, colors, typography, placeholder geometry, and media assets.

## Source Of Truth

Use the bundled template file in this skill folder:

```text
VMIE Powerpoint Template.pptx
```

If working in this repository, the path is:

```text
.github/skills/vmie/vm-ppt/VMIE Powerpoint Template.pptx
```

If the skill has been installed somewhere else, resolve the `.pptx` beside this `SKILL.md`. If the template is not available, stop and ask the user for the official VMIE template. Do not substitute a hand-built deck.

## Template Fidelity Rules

These rules are the heart of the skill.

1. Start every output from `VMIE Powerpoint Template.pptx`.
2. Preserve the template package parts: `ppt/slideMasters`, `ppt/slideLayouts`, `ppt/theme`, `ppt/media`, relationships, and notes where present.
3. Preserve the master footer and logo artwork. Do not redraw the Virgin Media logo, Liberty Global logo, CTIO text, separators, page number, or footer group manually.
4. Preserve existing placeholder geometry and paragraph styling. Replace text in template placeholders; avoid adding free-floating text boxes unless there is no usable placeholder.
5. Preserve theme colors and theme fonts. Do not use guessed RGB values or external brand palettes when the template already defines the color.
6. Use template layouts for structure. Do not create a blank `Presentation()` and draw a VMIE-looking deck from scratch.
7. Do not remove, crop, cover, or overlap the footer/header/master artwork. Keep diagrams, images, tables, and charts inside the content area of the selected layout.
8. When using OOXML replacement, carry forward the original paragraph properties from the inventory: font name, font size, bold, color, alignment, bullet level, spacing, and theme color.
9. If a slide needs a diagram or image, use the template's image/content layouts or content placeholders. Keep the visual inside the safe area and away from the bottom-right footer.
10. Validate visually before delivery with thumbnails or slide image export. A deck that is structurally valid but visually off-brand is not finished.

## Verified Template Inventory

The bundled template has been inspected. Use these facts as guardrails, but still inspect the template during deck generation because future template versions may change.

- Slide size: 12.8 in x 7.2 in, widescreen 16:9.
- Template slides: 21 sample slides, 0-indexed.
- Slide layouts: 18 layouts.
- Slide masters: 1 master.
- Media assets: 9 assets, including brand/logo/footer artwork.
- Theme fonts: Arial for major and minor Latin fonts. Template content says VM Circular or Arial; use Arial unless the actual template exposes VM Circular in a placeholder.
- Footer/master artwork: a grouped footer at the lower-right on the master, plus page number text. Preserve it through the master rather than drawing it.

### Theme Colors

Use the theme colors from the template, not approximate substitutes:

| Theme slot | Hex |
|---|---:|
| `dk1` | `000000` |
| `lt1` | `FFFFFF` |
| `dk2` | `322332` |
| `lt2` | `FFD2E5` |
| `accent1` | `FF0909` |
| `accent2` | `5F2878` |
| `accent3` | `9B1478` |
| `accent4` | `C89B64` |
| `accent5` | `FAE519` |
| `accent6` | `64A541` |
| `hlink` | `3E55A0` |
| `folHlink` | `4196D2` |

Use `accent1` for VM red, `accent2` for plum, and other accents only when the selected template slide or chart pattern calls for them.

### Layout Reference

These are PowerPoint layout indices as exposed by the template:

| Index | Layout name | Best use |
|---:|---|---|
| 0 | Cover Slide Red | Primary opening slide |
| 1 | Cover Slide Plum | Alternative opening slide |
| 2 | Section Divider Red | Main section divider |
| 3 | Section Divider Plum | Alternative section divider |
| 4 | Text Content - One Column | General narrative, executive summary, problem, benefits |
| 5 | Text Content - Two Columns | Comparisons, investment/resources, before/after |
| 6 | Text Content - Three Columns | Exactly three distinct items or phases |
| 7 | Title Only | Architecture diagrams, charts, large visuals |
| 8 | Blank | Only when another layout cannot support the content |
| 9 | Content on Red | High-impact callout, risks, recommendation |
| 10 | Content on Plum | Strategic callout or alternative high-impact slide |
| 11 | Content on White and Red | Split narrative with red panel |
| 12 | Content on White and Plum | Split narrative with plum panel |
| 13 | Half White Half Red Content | Multi-point red-section layout |
| 14 | Half White Half Plum Content | Multi-point plum-section layout |
| 15 | Content with Image Red | Text plus image, red treatment |
| 16 | Content with Image Plum | Text plus image, plum treatment |
| 17 | Image Content Frame | Image/video/content frame slide |

## Preferred Creation Workflow

Use the template-based `.pptx` workflow, not HTML-to-PPTX and not a blank python-pptx deck.

### 1. Inspect The Template For The Current Run

Before creating content, inspect the template so the deck matches the actual file the user supplied or bundled.

Preferred tools when available from the `pptx` skill:

```bash
python -m markitdown "VMIE Powerpoint Template.pptx" > template-content.md
python <pptx-skill>/scripts/thumbnail.py "VMIE Powerpoint Template.pptx" template-thumbnails --cols 4
python <pptx-skill>/scripts/inventory.py "VMIE Powerpoint Template.pptx" template-inventory.json
```

Also inspect `ppt/theme/theme1.xml`, `ppt/slideLayouts`, and `ppt/slideMasters` when exact colors, fonts, or layout behavior are uncertain.

### 2. Build The Executive Story

Extract from the user's plain text:

- Audience and decision needed.
- Current state and pain.
- Recommended solution.
- Financial impact, operational impact, customer impact, risk reduction.
- Timeline, phases, resources, and dependencies.
- Risks, mitigations, and explicit next steps.

Use business language first. Put technical details in diagrams or appendix slides unless the audience is explicitly technical.

### 3. Map Content To Real Template Layouts

Choose layouts based on actual content shape:

- Use layout 0 for the main cover unless the user asks for plum.
- Use layout 4 for most text-heavy content.
- Use layout 5 only when there are exactly two comparable groups.
- Use layout 6 only when there are exactly three comparable groups.
- Use layout 7 for diagrams and charts.
- Use layouts 9 or 10 for high-impact recommendations, risks, or decisions.
- Use image layouts 15, 16, or 17 only when an image or diagram will be inserted.

Never force content into a layout because it looks attractive. Empty placeholders, mismatched columns, and crowded diagrams make the result look off-template.

### 4. Clone Template Slides, Then Replace Content

For maximum fidelity, duplicate/rearrange template slides and replace text in place.

Preferred command pattern when the `pptx` scripts are available:

```bash
python <pptx-skill>/scripts/rearrange.py "VMIE Powerpoint Template.pptx" working.pptx 0,4,4,5,7,6,4,5,9,9,2,4
python <pptx-skill>/scripts/inventory.py working.pptx text-inventory.json
```

Then create `replacement-text.json` from the real `text-inventory.json`:

- Reference only slide and shape IDs that exist.
- Preserve paragraph properties from the inventory.
- Use `paragraphs`, not ad hoc plain strings.
- For bullets, set `"bullet": true` and `"level": 0`; do not include a bullet glyph in the text.
- Clear unused placeholder text by omitting `paragraphs` for those shapes only when that shape is genuinely unused.

Apply replacements:

```bash
python <pptx-skill>/scripts/replace.py working.pptx replacement-text.json output.pptx
```

If the `pptx` scripts are unavailable, use an equivalent OOXML or python-pptx approach that starts from the template and uses its slide layouts. The fallback still has to preserve the master, theme, layouts, media, and footer. Do not fall back to a hand-built blank presentation.

### 5. Insert Diagrams, Images, Charts, And Tables Carefully

For architecture diagrams:

- Prefer layout 7, 15, 16, or 17.
- Keep diagrams readable at projection size.
- Use template theme colors for diagram accents.
- Avoid dense architecture maps on executive slides. Use appendix zoom-ins for detail.
- Do not cover the footer or page number.

For charts:

- Keep chart styling flat and simple.
- Use the template accent colors.
- Use direct labels where possible.
- Avoid effects, gradients, heavy shadows, and chart clutter unless the template already uses them.

For tables:

- Keep tables short.
- Use template text sizes and theme colors.
- Split dense tables across appendix slides rather than shrinking text below readability.

## Standard Executive Deck Structure

Use this as the default unless the user gives a different structure:

1. Cover: title, subtitle, audience/context.
2. Executive Summary: situation, challenge, recommendation, business impact, investment, key risk.
3. Current State: quantified pain and why change is needed.
4. Recommended Approach: what is being proposed and why.
5. Solution Architecture or Operating Model: visual overview.
6. Delivery Roadmap: phases, timeline, and outcomes.
7. Business Benefits: financial, operational, customer, strategic, and risk impact.
8. Investment and Resources: cost, people, vendor/support needs.
9. Risks and Mitigations: honest risks with concrete mitigations.
10. Recommendation and Next Steps: decision request, owner, dates, success measures.
11. Appendix Divider.
12. Appendix Detail Slides: cost model, technical architecture, migration plan, security/compliance, assumptions.

Keep the main deck concise. If a slide does not help the audience make the decision, move it to the appendix or remove it.

## Content Style

- Lead with business value, not technical implementation detail.
- Quantify claims whenever possible: cost, time, percentage, risk, volume, capacity, customer impact.
- Keep each slide to one primary message.
- Keep titles short and direct.
- Keep bullets short; avoid more than five bullets in one text area.
- Use appendix slides for detailed technical evidence.
- State the recommendation clearly and early.

## Exact Branding Checklist

Before delivery, verify:

- The output `.pptx` was created from `VMIE Powerpoint Template.pptx`.
- Slide size remains 12.8 in x 7.2 in.
- The theme file and theme colors remain from the template.
- The slide master and all selected layouts remain from the template.
- The footer is inherited from the master and appears in the correct place on content slides.
- The cover slide uses the template cover layout and does not have a manually drawn footer.
- VM and Liberty Global logos are preserved from template media/master artwork.
- Fonts and paragraph styles match the source placeholders.
- No freehand title boxes, manual footer boxes, or hand-drawn logo approximations were added.
- No placeholder text from the template remains unless intentionally retained.
- Text does not overflow or overlap.
- Images, diagrams, charts, and tables do not cover the footer.
- The deck passes visual thumbnail review.

## Visual Validation Workflow

Generate thumbnails and inspect them before handing over the deck:

```bash
python <pptx-skill>/scripts/thumbnail.py output.pptx output-thumbnails --cols 4
```

Check every thumbnail for:

- Template fidelity versus the original sample slides.
- Footer/logo visibility and alignment.
- Header/title alignment and font size.
- Text overflow, cutoff, or overlap.
- Empty placeholders.
- Low contrast.
- Diagrams or charts that are too small to read.

If thumbnails show drift from the template, fix the deck and regenerate. Do not explain away visible template drift.

## Common Failure Modes To Avoid

- Creating a blank deck and manually setting VM red, Arial, and logo images.
- Recreating the footer with text boxes and images instead of inheriting the master footer.
- Using approximate colors like `E10A0A` when the template theme defines `FF0909`.
- Hardcoding logo sizes from memory instead of preserving template media/master shapes.
- Adding title boxes with custom fill/border instead of using template title placeholders.
- Using a three-column layout for two items or a two-column layout for unrelated content.
- Shrinking text to fit instead of splitting content across slides.
- Delivering without thumbnail review.

## Output Expectation

Return a `.pptx` file that remains editable in PowerPoint and appears to use the official VMIE template natively. In the final response, mention that the deck was generated from the bundled VMIE template and summarize any validation performed, especially thumbnail review or OOXML/template preservation checks.