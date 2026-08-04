# Public API stability

## Supported entry point

Applications must import `package:metro_ui/metro_ui.dart`. Files below
`lib/src` are implementation details and may move without a deprecation cycle.
The main library deliberately does not re-export Flutter Material, Widgets, or
Services APIs.

The supported surface consists of:

- Metro widgets, routes, overlay helpers, and picker helpers;
- immutable value objects, enums, formatters, and selection controllers used
  by those widgets;
- semantic theme tokens, component style data, and subtree theme widgets;
- `MetroLocalizations` and its replaceable delegate contract.

Public picker state classes are intentional: a `GlobalKey<MetroDatePickerState>`
or `GlobalKey<MetroTimePickerState>` may call `open()`. Other state, painter,
layout, focus-intent, and interaction implementation types remain private.

## Development releases

Versions below `1.0.0` may make breaking changes when they materially improve
the Metro model or remove an accidental API. Every such change must be listed
in `CHANGELOG.md`, and migration guidance is required when an existing call
site cannot be updated mechanically.

Before `1.0.0`, the exported declaration inventory must be reviewed and the
package must complete the gates in [release checklist](release_checklist.md).
The version number alone must not be used to declare the surface stable.
`tool/check_public_api.dart` keeps that inventory explicit and rejects exported
types or top-level functions that lack declaration-level documentation.

## Stable-release policy

Starting with `1.0.0`:

- removing or renaming a supported declaration, parameter, enum value, or
  behavior contract requires a new major version;
- additive widgets, optional named parameters, theme fields, and localization
  members may ship in a minor version;
- fixes that restore documented behavior may ship in a patch version;
- a replacement API is introduced before the old API is deprecated;
- deprecated APIs remain available for at least two minor releases unless a
  security or platform breakage makes that impossible.

Subclassing or implementing a concrete Metro type is not an extension contract
unless that type explicitly documents one. Prefer composition, component
themes, formatter callbacks, builders, controllers, and Flutter's normal
focus/navigation APIs.

## Change review

Every public API change should answer four questions:

1. Does it represent a durable Modern UI concept rather than one gallery use
   case?
2. Can the behavior be expressed by an existing style, builder, controller, or
   Flutter primitive?
3. Does it preserve pointer, keyboard, semantics, localization, RTL, reduced
   motion, text scaling, and high-contrast behavior?
4. Is the change covered by focused tests and reflected in the README and
   changelog where users will discover it?
