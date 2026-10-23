# Reference audit

This document records the measurements and colors that the package treats as
era evidence, and every place where a widget deliberately departs from them.
Read it before changing a visual value: most numbers in `lib/src` are copied
from these tables, not invented, and an unexplained change is a regression.

## Sources

| Source | Role |
| --- | --- |
| WinJS 3.0.1 `ui-light.css` and `ui-dark.css` | Primary evidence for control metrics, state colors, typography, and motion of Windows 8.1 Store apps. |
| Microsoft Windows 8.1 tile asset guidance | Tile artwork sizes of 70, 150, 310 by 150, and 310 pixels. |
| Microsoft Windows Phone 8 interaction guidance | Touch press feedback (scale and tile tilt) that Windows 8 desktop did not use. |
| Metro 4 | Corroboration for tile badges, live-face effects, and short state transitions. |
| MahApps.Metro | Corroboration for Metro terminology and desktop control families. |

WinJS 3.0.1 is the last 8.1-era stylesheet in that project. WinJS 4 moved to
Windows 10 styling, so its `win-button` and surface values are not evidence for
this package.

## Typography

| Style | Era value | Package token |
| --- | --- | --- |
| Page header | 42pt, weight 200, line height 1.1429, no letter spacing | `MetroTypography.hero` (56 logical pixels) |
| Section header | 20pt, weight 200, line height 1.2 | `MetroTypography.subheader` (26.667) |
| Strong body | 11pt, weight 600, line height 1.3636 | `bodyStrong`, `button` |
| Body | 11pt, weight 400, line height 1.3636 | `body` |
| Small text | 11pt, weight 300 | not exposed |
| Caption | 9pt, weight 400, line height 1.6667 | `caption` |
| Tracking | 0.02 em on body text | `letterSpacing: 0.28` at body size |

The era ramp has no 30pt or 15pt step; `header`, `title`, and `tileTitle` are
later Metro conventions kept for hierarchy, see [Deviations](#deviations).

## Controls

Values are CSS pixels at scale 100. Light theme first, dark theme where it
differs.

### Buttons

| Property | Era value | Package |
| --- | --- | --- |
| Minimum size | 90 by 32, 2px border, 4/8 padding | identical |
| Label | 11pt, weight 600 | identical |
| Standard fill | `rgba(182,182,182,0.7)`, border `rgba(0,0,0,0.2)` | identical |
| Standard hover | `rgba(205,205,205,0.82)`, border `rgba(164,164,164,0.45)` | identical |
| Standard pressed | black fill, black border, white text | identical |
| Disabled | `rgba(202,202,202,0.4)`, border `rgba(0,0,0,0.08)`, text `rgba(0,0,0,0.4)` | identical |
| Dark standard | transparent fill, white border, hover `rgba(255,255,255,0.13)`, pressed white on black | identical |

### Entry fields

Text input, combo box, number box, search box, and picker segments share one
treatment, implemented in `MetroFieldSurface`.

| Property | Era value | Package |
| --- | --- | --- |
| Text input height | 28, 2px border, 0/8 padding | identical |
| Affordance field height | 32 (intrinsic select) | identical |
| Fill | `rgba(255,255,255,0.8)`, hover `0.87`, focus `#ffffff` | identical |
| Border | `rgba(0,0,0,0.27)`, hover `0.44`, focus `0.6`, dark invisible | identical |
| Disabled | `rgba(202,202,202,0.4)` fill, border `rgba(0,0,0,0.15)`, text `0.4`; dark transparent with white `0.4` border | identical |
| Placeholder | `rgba(0,0,0,0.6)`, disabled `0.22` | identical |
| Search action button | 28 wide, panel fill, glyph `rgba(0,0,0,0.6)`, accent while the field has focus, `#5f37be` on hover, inverts on press | identical |
| Clear affordance | no permanent fill, `#dedede` on hover, inverts on press | identical |

The dark theme keeps light fields with black text, exactly as the era did.

### Selection

| Control | Era value | Package |
| --- | --- | --- |
| Check box | 21 square, fill `rgba(255,255,255,0.8)`, border `rgba(0,0,0,0.27)`, hover border `0.44`, pressed black fill with white glyph | identical |
| Radio button | 23 square with the same surface rules | identical |
| Toggle switch | track 50 by 19 with a 2px border, thumb 12 by 19 overhanging the border by 2 on its resting side, fill inset 1 with a 2px gap before the thumb | identical |
| Toggle off fill | `rgba(0,0,0,0.35)`, hover `0.29`, pressed `0.26`; dark `0.26` / `0.29` / `0.35` | identical |
| Toggle disabled | border `0.2`, thumb `#929292` light and `#7e7e7e` dark | identical |

### Navigation and surfaces

| Control | Era value | Package |
| --- | --- | --- |
| App bar | `#f0f0f0` light, `#000000` dark, 80 tall, commands at least 100 by 80 | identical |
| Command glyph ring | 40 by 40, 2px, hover fill `rgba(0,0,0,0.13)`, checked ring filled with the bar foreground | identical |
| Command label | 9pt | `caption` |
| Back button | 45 by 45 including a 2px ring (41 plus border), hover `0.13`, pressed inversion | identical |
| Pivot header | 45pt, weight 400, 0/9 padding, 19 content inset, 72 header band | identical |
| FlipView navigation | 69 by 39 blocks, fill `rgba(213,213,213,0.35)`, hover `rgba(215,215,215,0.94)`, pressed `rgba(41,41,41,0.74)`, glyph `rgba(0,0,0,0.6)` | identical |
| Tooltip | `#ffffff` panel, `#808080` 2px border, text `rgba(0,0,0,0.6)`, padding 10/6/10/7, maximum width 380 | identical |
| Flyout | 346 wide (345 plus border), header padding 40/32, content padding 40/33, header on the panel surface, label 20pt | identical |
| Place list (navigation rail) | Accent-tinted rail with text-only items, no icons, no dividers, no ring around the current place, and a full-width brighter accent bar; horizontal place bars use 210 wide items | `MetroListTile` with a rail style and `showSelectionMark: false` |
| Slider | 11px track and thumb, upper fill `rgba(0,0,0,0.1)`, hover `0.15`, disabled `0.2` and thumb `#929292`, ticks `0.5` | identical |

### Tiles

| Property | Era value | Package |
| --- | --- | --- |
| Asset sizes | 70, 150, 310 by 150, 310 pixels | `MetroTileSize.small`, `square`, `wide`, `large` |
| Grid | 150 extent with a 10 gutter derives all four sizes | `MetroTileThemeData` defaults |
| Content | White tile text on every vivid accent fill, including the orange and teal tiles | `MetroColorScheme.tileForegroundFor`, white until the fill passes 0.45 luminance |
| Selection | accent fill, white content, end-corner check mark | identical |

## Deviations

These are intentional. Change them only with a design decision, not silently.

| Deviation | Why |
| --- | --- |
| Press scale of 0.975 on buttons, list tiles, and tiles, plus the tile tilt | Windows Phone 8 touch feedback; the desktop did not scale pressed controls. Applications can pass a scale of 1 to opt out. |
| Tile badge draws a translucent chip behind the content | Metro 4 keeps the count readable on arbitrary tile art; the operating system badge had no backdrop. |
| Focus outlines follow the keyboard only | The era suppressed focus visuals for pointer input and drew them on keyboard navigation; the package draws them whenever a control holds focus, so application shells that own a tinted surface gate them per build. |
| Hover on a tile adds a 4px outline, and hover on a list tile a light wash | Windows 8 list controls revealed a selection affordance instead of a wash; a Flutter package needs a pointer affordance that does not imply selection. |
| `header`, `title`, and `tileTitle` type steps, and the 30pt and 15pt sizes | The era ramp jumps from 42pt to 20pt to 11pt; the extra steps come from later Metro libraries and keep hierarchy usable in application layouts. |
| Combo box and search suggestions use a Flutter popup with 40px rows | The era used native drop-downs and suggestion panes; the Flutter equivalents are keyboard accessible and viewport aware. |
| Picker dialogs scroll in columns | Windows 8 desktop used segmented drop-downs; the scrolling dialog is a keyboard-accessible adaptation. |
| Dialogs keep a 2px frame | The era content dialog was a borderless panel over a dimmed surface; a frame keeps the panel legible over arbitrary application content. |
| Row heights of 52 and 44 in lists and the data grid | The era did not fix list row heights; these are package measurements that keep touch targets comfortable. |
| High-contrast palettes | Windows 8 read system colors; the package ships explicit high-contrast schemes so tests and previews are deterministic. |

## Adding or changing a control

1. Find the era value in a primary source and record it in this file.
2. Prefer the shared tokens in `lib/src/theme` and `MetroFieldSurface` over new
   literals.
3. If the implementation must differ, add a row to the deviations table with
   the reason.
4. Regenerate the visual baselines and note the new pixels in the changelog.
