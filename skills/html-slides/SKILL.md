---
name: html-slides
description: >
  Create visual HTML slide decks for presentations. Use this skill whenever the user wants to make slides,
  a presentation, a deck, huddle comms, briefing slides, or anything that involves presenting information
  slide-by-slide. Also triggers when the user wants to convert bullet points or notes into a presentable format,
  or asks to "make this into a deck." Handles the full flow: optional template extraction from .pptx,
  narrative interview, and HTML slide generation with built-in keyboard navigation.
---

# HTML Slide Deck Creator

Build single-file HTML slide decks that are visual, succinct, and presentation-ready.

## Workflow

### Phase 1: Template Intake (optional)

If the user provides a .pptx file as a visual reference:

1. Locate the file (ask if path is ambiguous)
2. Extract theme via zip/XML parsing (no external dependencies):
   - Color scheme from `ppt/theme/theme1.xml` → accent colors, dark/light base
   - Font family from major/minor font definitions
   - Note layout patterns (centered title slides, two-column content, etc.)
3. Store extracted palette and fonts as the design basis

If no template provided, use a clean default:
- Dark background (#000), white text, gold accent (#FFC100)
- Arial/system sans-serif
- Left accent bar on content slides

### Phase 2: Narrative Interview

Goal: understand the story arc before writing any HTML. Adapt questions based on what the user has already shared.

Core dimensions to cover (skip what's already clear from context):
- **Audience**: who's in the room, how many, their relationship to the content
- **Tone**: motivating, informing, persuading, reassuring, matter-of-fact
- **Key messages**: the 2-4 things people should walk away remembering
- **Structure/flow**: what comes first, what builds on what, where's the emotional arc
- **Display context**: projector resolution, screen size, room lighting — determines base font sizing
- **Content details**: names, dates, specifics that make slides concrete

Interview style:
- Ask focused questions, grouped logically (not a wall of 15 questions)
- If user provides a dump of context, extract what you can and ask only about gaps
- Confirm the slide outline explicitly before building: list slide titles + 1-line summary each
- Wait for "good to go" or equivalent before generating HTML

### Phase 3: Build HTML Slides

Generate a single self-contained HTML file.

#### Structure
```html
<!DOCTYPE html>
<html>
<head><!-- styles, no external deps --></head>
<body>
  <div id="slide-id" class="slide">...</div>
  <!-- one div per slide -->
  <script><!-- navigation logic --></script>
</body>
</html>
```

#### Design principles
- Each slide is full-viewport (100vw × 100vh)
- Visual-first: large typography, minimal text, generous whitespace
- Bullet points should be scannable — one idea per bullet, short phrases not sentences
- Use accent color for emphasis (key names, terms, highlights)
- Highlight boxes for supplementary notes or callouts
- Slide content should be understandable at a glance while reading, yet sparse enough to present over

#### Font sizing by display context
- **Projector / large screen (low res)**: h1 4.5rem, h2 3.2rem, body 1.8rem
- **Monitor / high-res screen**: h1 3.2rem, h2 2.4rem, body 1.4rem
- **Default (unknown)**: use projector sizing — better too big than too small

#### Built-in navigation
Every deck includes this script pattern:

```javascript
(function() {
  const slides = [/* array of slide IDs */];
  let current = 0;

  function goTo(i) {
    current = Math.max(0, Math.min(slides.length - 1, i));
    document.getElementById(slides[current]).scrollIntoView({ behavior: 'smooth' });
  }

  document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowRight' || e.key === 'ArrowDown') { e.preventDefault(); goTo(current + 1); }
    if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') { e.preventDefault(); goTo(current - 1); }
  });

  document.addEventListener('click', function() { goTo(current + 1); });

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const idx = slides.indexOf(entry.target.id);
        if (idx !== -1) current = idx;
      }
    });
  }, { threshold: 0.5 });

  slides.forEach(id => observer.observe(document.getElementById(id)));
})();
```

- Arrow keys (left/right and up/down) navigate between slides
- Click anywhere advances to next slide
- Manual scroll syncs the current index via IntersectionObserver
- Smooth scroll between slides
- Add `scroll-behavior: smooth` to body

#### Slide IDs
Use meaningful, descriptive IDs (not `slide-1`, `slide-2`). Examples: `title`, `context`, `od-changes`, `principles`, `cta`.

### Phase 4: Iterate

After delivering the first draft:
- Accept change requests conversationally (reorder, rephrase, resize, add/remove)
- Apply edits surgically — don't regenerate the whole file for small changes
- If user requests reordering, update both the HTML order and the navigation array

## Slide count guidance

- Default suggestion: 5-8 slides for a focused message
- Title + close are almost always warranted
- One idea per slide — if a slide has more than 4-5 bullets, consider splitting

## Common slide types

| Type | Pattern |
|------|---------|
| Title | Centered h1 + subtitle, minimal |
| Context/Setup | Tag + h2 + 1-2 sentences or short list |
| Content | Tag + h2 + bullet list, optional highlight box |
| Two-column | Grid layout for comparisons or paired concepts |
| Quote/Spotlight | Large quote or callout + supporting bullets |
| CTA/Close | Centered message + action items |

## What NOT to do

- Don't use external dependencies (CDNs, frameworks, Google Fonts)
- Don't add animations or transitions beyond smooth scroll
- Don't create multi-file structures — everything in one HTML file
- Don't write paragraph-length bullets — if it needs a paragraph, it needs its own slide
- Don't default to light backgrounds for projector contexts (dark reads better in most rooms)
