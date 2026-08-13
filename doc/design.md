# Design language and references

## The target

`metro_ui` interprets the Windows 8, Windows 8.1, and Windows Phone 8-era
Modern UI language for Flutter. It is not a pixel-for-pixel clone of a Windows
runtime, nor a compatibility layer for WPF, WinJS, or web frameworks.

The goal is a useful Flutter component library with the recognizable qualities
of that era:

- typography establishes hierarchy before decoration;
- layouts are flat, open, and intentionally geometric;
- a single accent color provides emphasis and selection;
- touch and pointer interactions feel direct and visibly respond to input;
- motion explains navigation or changes in content rather than decorating the
  interface;
- keyboard, touch, mouse, accessibility, RTL, large text, high contrast, and
  reduced-motion support are first-class requirements.

The default language excludes later Fluent ideas such as acrylic, Mica, reveal
highlights, soft shadows, rounded cards, and Windows 11-style surfaces.

## Use the design system

Start from `MetroThemeData.light` or `MetroThemeData.dark` and choose one accent
color. Prefer semantic theme fields such as foreground, surface, border, and
focus colors over hard-coded shades. High-contrast factories provide a reduced
palette with stronger structural borders.

Metro uses squared controls and restrained decoration by default. Do not
uppercase user content automatically; examples may use uppercase labels where
that is part of the original visual language, but application copy and
localization take precedence.

Use motion to maintain spatial context. Components honor Flutter's
reduced-motion settings, so every transition should still communicate a clear
state change when it is disabled.

## How references inform the project

The library has an original, Flutter-native API and implementation. The
following sources inform the work at different levels:

| Reference | Role in this project |
| --- | --- |
| Microsoft Windows 8/8.1 guidance and WinJS | Primary evidence for era-appropriate control behavior, typography, and motion. |
| MahApps.Metro | Corroboration for established Metro terminology and desktop control families. |
| Metro 4 | Corroboration for practical tile, badge, and interaction-state behavior. |
| fluent_ui | A reference for organizing a large Flutter package, themes, localization, tests, and a Gallery. |

The local snapshots in `.vscode/references` are development research material,
not source dependencies. No reference project defines this package's public API
or licenses its code and assets for reuse.

## Design decisions in practice

- Keep application state application-owned when a value may be rejected or
  reconciled; use internal state for transient interaction and animation.
- Use logical start/end APIs so directional layouts mirror naturally.
- Supply semantic labels for icons and non-textual content, and expose values
  and state changes to assistive technologies.
- Layer customization predictably: explicit widget values override the nearest
  component theme, then `MetroThemeData`, then package defaults.
- Prefer a small set of durable controls over imitating every historical
  Windows, WPF, or web-framework widget.

For implementation standards and review expectations, read the
[contribution guide](../CONTRIBUTING.md).
