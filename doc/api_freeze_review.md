# 1.0 API freeze review

This review records the public surface approved for the `1.0.0` release
candidate. It does not change the package version or claim that hosted release
gates have passed.

Reviewed locally on 2026-08-04.

## Scope

- `package:metro_ui/metro_ui.dart` remains the only supported entry point.
- `tool/public_api_declarations.txt` contains 143 exported declarations in
  sorted order and is the freeze manifest.
- `dart run tool/check_public_api.dart` verifies that every exported type or
  top-level function is documented and represented by the manifest.
- Dartdoc 9.0.8 generates the public library with zero warnings and zero
  errors.
- The [component coverage audit](component_coverage.md) maps the candidate to
  the mature references and separates 1.0 scope from additive 1.x candidates
  and later Fluent exclusions.

## Review decisions

- Component names consistently use the `Metro` prefix and established Modern
  UI terminology: Button, Tile, Pivot, CommandBar, FlipView, SearchBox,
  NumberBox, picker, slider, and data-grid families.
- Stateful inputs use controlled application values where rejecting or
  reconciling a request matters. Internal state is limited to transient focus,
  hover, draft, animation, paging, and overlay behavior.
- Complex callback signatures have named typedefs where they recur or form a
  meaningful contract. Immutable item, range, time, sort, and theme objects
  remain public value/configuration types.
- Every component theme follows the same precedence: widget style, nearest
  component theme, application `MetroThemeData`, then Metro defaults.
- `MetroDatePickerState` and `MetroTimePickerState` are the only intentionally
  public widget state classes so a `GlobalKey` can invoke `open()`. Painters,
  intents, render/layout helpers, overlay machinery, and other widget states
  remain private.
- Flutter Material, Cupertino, Widgets, and Services libraries are not
  re-exported. Applications keep explicit control of their Flutter imports.
- Localization remains replaceable through `MetroLocalizations`; adding future
  default strings is an additive minor-version change under the compatibility
  policy.

## Freeze decision

The current 143-declaration inventory is approved as the `1.0.0` release
candidate surface. Any declaration, parameter, enum-value, nullability, or
documented behavior change before the release must update the manifest,
changelog, focused tests, and this review. After `1.0.0`, changes follow
`api_stability.md` and semantic versioning.

The freeze must be reconfirmed from the intended release commit after hosted CI
succeeds. Gallery deployment is not part of the current release gate.
