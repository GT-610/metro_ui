# Metro 4 reference audit

This audit records how Metro 4 supplements the project's primary Windows 8
evidence. The inspected snapshot is Metro 4 `4.5.12-rc1`, from the local
`4.5.12` branch under `.vscode/references/Metro-UI-CSS-4`.

Metro 4 is a mature Metro-style Web framework rather than a Microsoft system
implementation. Its strongest value here is practical component composition:
complete interaction states, live tile face changes, notification badges, and
consistent transition handling. Exact Windows recipes still come from the
[Windows 8 reference audit](reference_audit.md).

## Adopted evidence

| Metro 4 evidence | Flutter mapping |
| --- | --- |
| Tile pointer sectors select left, right, top, or bottom perspective transforms in `source/components/tile/tile.js`; release clears the transform | `MetroTile` keeps pointer-location tilt and the verified WinJS 0.975 press scale |
| Tile hover uses a four-pixel outline and badges occupy logical top-end or bottom-end corners in `tile.less` | Tile hover outline is strengthened to 4px; `MetroTile.badge` supports `topEnd` and `bottomEnd` without introducing rounded geometry |
| Live tiles support `slide-up`, `slide-down`, `slide-left`, `slide-right`, `fade`, `zoom`, `swirl`, and immediate `switch` effects | `MetroLiveTileTransition` adds horizontal slides and zoom; fade, vertical slides, and no-motion switching remain available |
| Tile faces move a complete parent width or height and cross-fade during the effect | Flutter transitions move a complete tile face and clip it to the square surface |
| Buttons use a short state transition and expose configurable pressed/loading composition | `MetroButton` now applies the shared 0.975/167ms direct-manipulation recipe and exposes `pressScale` through its existing style cascade |
| Metro 4 centralizes reusable animation functions instead of embedding one-off CSS in every demo | `MetroEntrance` exposes theme-driven directional and staggered content entrance as a reusable Flutter primitive |

Metro 4 defaults its generic short/base/long transitions to 150/300/1000ms and
its live tile effect to 500ms. These values are corroboration only. The package
retains the more authoritative WinJS 167ms pointer, 367ms popup, 550ms content,
and 1000ms page recipes plus the standard Windows easing curve.

## Deliberate exclusions

- Ripple effects are excluded because Windows 8 direct manipulation uses
  scale, tilt, fill, and outline feedback rather than Material ripples.
- `tabs-material`, material inputs, M3 side navigation, rounded cycles, chips,
  shadows, and card-like surfaces do not define Metro defaults.
- Swirl live tiles are omitted from the default component API because large
  rotation is decorative and weakens the directional information hierarchy.
- Generic CSS framework sizes do not replace verified WinJS control geometry.
- JavaScript DOM APIs, callbacks, and global setup objects are not reproduced;
  the public surface remains immutable and Flutter-native.
