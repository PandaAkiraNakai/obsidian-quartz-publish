---
title: Example note
tags:
  - meta
  - demo
---

> A quick tour of Obsidian-flavored markdown features that Quartz v4 renders.

This page demonstrates the most common syntax you can use across your vault. Quartz will pick all of it up automatically.

## Wikilinks and backlinks

Standard Obsidian wikilinks work out of the box:

- Link to [[index|the home page]].
- Link to a (hypothetical) note: [[my-note]].

Backlinks appear in the right sidebar of every note that is linked from another note.

## Callouts

> [!note]
> Callouts use the same syntax as Obsidian. Supported types include `note`, `info`, `tip`, `warning`, `example`, `quote`, and more.

> [!warning] Custom title
> A warning callout with a custom title.

## Code blocks

```ts
// quartz.config.ts excerpt
const config: QuartzConfig = {
  configuration: {
    pageTitle: "My Digital Garden",
    baseUrl: "tu-dominio.tld",
  },
}
```

Inline code: `npx quartz build`.

## Math (KaTeX)

Inline: $E = mc^2$.

Block:

$$
\int_{-\infty}^{\infty} e^{-x^2} \, dx = \sqrt{\pi}
$$

## Tables

| Feature      | Supported |
| ------------ | --------- |
| Wikilinks    | Yes       |
| Backlinks    | Yes       |
| Graph view   | Yes       |
| Search       | Yes       |
| Dark mode    | Yes       |

## Task lists

- [x] Clone the template
- [x] Replace `content/` with your vault
- [ ] Configure `quartz.config.ts`
- [ ] Deploy

## Footnotes

This sentence has a footnote.[^1]

[^1]: Footnotes render at the bottom of the page.
