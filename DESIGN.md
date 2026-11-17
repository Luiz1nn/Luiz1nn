# GitHub overview · Luis Fernando

## Product

Public profile README for `github.com/Luiz1nn`. Introduce Luis Fernando, show a small selection of work and help visitors continue to the portfolio. Primary action: **Explore my portfolio**.

## Audience and voice

People evaluating the work for engineering roles or collaboration. Keep the existing English language, write directly and use confirmed projects and contributions. The IFTO education entry comes from the previous profile README; other professional content follows the portfolio.

## Mood

Editorial, technical and restrained, following the existing portfolio. Use typography, spacing and thin dividers rather than technology badges or decorative animation.

## Brand

Design system source: `Luiz1nn/luizinn-portfolio`, especially `src/app/globals.css`, `src/components/portfolio-page.tsx` and its `DESIGN.md`. Public reference: https://luiz1nn.dev.

| Token | Dark | Light |
| --- | --- | --- |
| background | `#0a0a0a` | `#fafafa` |
| foreground | `#f5f5f5` | `#111111` |
| muted-foreground | `#8a8a8a` | `#696969` |
| border | `#262626` | `#dedede` |
| accent | `#b7ff64` | `#b7ff64` |

Archivo is used for the banner's identity and headline; JetBrains Mono is used for its metadata and LF identifier. Glyphs are converted to paths so the SVG does not depend on fonts or external services at runtime. The rest of the README uses GitHub's native Markdown typography and link treatment.

## References

- `README.md`: visible profile content and native links.
- `assets/profile-hero-{desktop,mobile}.svg`: two responsive banners with embedded light/dark palettes.
- `scripts/build-banner.swift`: native CoreText generator with font and text-width assertions. No package dependencies.
- GitHub's [picture element documentation](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#the-picture-element) and MDN's [inherited color scheme in SVG images](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@media/prefers-color-scheme#embedded_elements).

To regenerate on macOS, provide Archivo SemiBold, Archivo Regular and JetBrains Mono Regular TTF files:

```sh
swift scripts/build-banner.swift /path/to/Archivo-SemiBold.ttf /path/to/Archivo-Regular.ttf /path/to/JetBrainsMono-Regular.ttf assets
```

The Archivo files are available in the portfolio's `public/fonts`; JetBrains Mono is maintained at https://github.com/JetBrains/JetBrainsMono.

## Constraints and states

- The scope is the profile README; GitHub owns the surrounding interface and native interaction states.
- Viewport selection uses a supported `<picture>` source through 767 px. SVG media queries inherit the embedding element's `color-scheme`, so the GitHub theme wins when it differs from the operating system. Source SVGs are 800 × 288 and 360 × 288; they scale to the README width.
- SVGs contain vector paths, a title and description. The HTML image also has meaningful alt text. The core professional description, projects and contact links remain native text if the banner fails to load.
- Links retain GitHub's normal, hover and keyboard-focus behavior. There are no forms, custom loading states or animated assets.
- The existing workflow publishes its snake animation to the separate `output` branch and is outside this change.

### Verification

- The generator passed its font identity, text-width and vertical-bounds assertions for both adaptive SVGs.
- GitHub's Markdown renderer preserved the picture sources, alt text, native links and section structure.
- Browser previews at 1440 px and 390 px passed in dark and light GitHub themes without horizontal overflow. The OS theme was deliberately opposite in each case; rendered screenshot pixels matched the portfolio backgrounds (`#0a0a0a` and `#fafafa`).
- The image-failure preview retained meaningful alt text, the professional description, all three projects and all six native links. Keyboard Tab moved between the contact links.
- SVG structure checks confirmed valid XML, all expected palette values and no external resources, scripts or foreign objects.
- Self-review increased the mobile metadata size, shortened the cloud label to avoid an isolated last word and made the Zard contribution link explicit. The image has an integer width of 1100 px, matching the portfolio content cap; GitHub's native max-width rule scales it down to the profile column.

## Decisions log

- 2026-11-17 — Apply the portfolio's existing palette and typography to the GitHub overview, keeping English and native Markdown content. User approved light/dark, desktop/mobile and image fallback coverage.
- 2026-11-17 — Use two self-contained SVG variants with four visual states to preserve the original fonts and readable mobile type without third-party image generators or font downloads at runtime.
- 2026-11-17 — Select Cadastro 4.0, Zard UI and Node.js Microservices to show product delivery, open-source contributions and backend architecture without copying the whole portfolio into the profile.
- 2026-11-17 — Add theme-aware CSS inside the SVGs after a pixel probe reproduced a light banner inside a forced-dark GitHub page. Palette selection must follow the page's color scheme even when the OS preference differs.

- 2026-11-17 — Keep viewport selection outside the theme conditions: GitHub's themed-picture component replaces theme media queries and drops combined width conditions. The picture source now handles only width; the embedded SVG handles theme.

## Open questions

None for the approved scope. Any new result, role or metric must be verified before adding it.
