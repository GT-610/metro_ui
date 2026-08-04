# Design principles

## Typography leads

Page hierarchy should be readable before color or borders are considered.
Metro's type ramp uses large, light-weight headers and restrained body text.
The default ramp is based on the characteristic 40, 29.333, 20, 14, and 12
logical-pixel levels found in mature Metro implementations.

Controls must not uppercase user content automatically. Examples may use
uppercase labels where the original language did, but localization and author
intent take priority.

## One accent, semantic neutrals

A theme has one high-saturation accent and a neutral light or dark foundation.
The accent is stable when brightness changes. Content placed on an accent must
use a foreground chosen from the accent's luminance; white is not universally
readable, especially on yellow and lime.

Color fields describe purpose (`foreground`, `surface`, `border`, `focus`), not
a particular shade number. Components resolve their interaction state from
those semantic colors.

High-contrast mode reduces neutral variation and strengthens structural
separation, but it does not make state color-only. Selection glyphs, focus
outlines, text, geometry, and semantics remain available independently of the
highlight color. Applications opt into an explicit high-contrast theme that
responds to `MediaQuery.highContrast`; platform colors may be substituted when
the host can provide them.

## Flat, square, and direct

Core components use zero-radius geometry, solid fills, fine borders, and no
elevation. Shadows are reserved for future overlays where separation cannot be
communicated by layout alone.

The outlined circular glyph used by Windows 8 AppBar commands is a documented
control-specific exception. It does not establish a general rounded-corner
language for buttons, fields, tiles, or surfaces.

Tiles are direct-manipulation surfaces. Pointer location may influence their
pressed transform, but activation must remain identical for pointer, keyboard,
and assistive technology users.

## State is part of the design

Every interactive component must define enabled, disabled, hovered, focused,
and pressed behavior. Selected controls will additionally define selected and
inactive-selection states. Widget-level styles override local component
themes, application component themes, and finally library defaults.

## Motion explains relationships

Local feedback is fast. Navigation is slower and directional. Entrance and
exit motion should explain where content came from or went, rather than merely
decorate the screen.

All motion is optional. Components must honor `MediaQuery.disableAnimations`
and `MediaQuery.accessibleNavigation` without losing information or input.

## Flutter-native behavior

The library reproduces design intent, not WPF implementation details. Public
APIs follow Flutter conventions (`FocusNode`, `VoidCallback`,
`WidgetStateProperty`, immutable theme data) and avoid application-level state
management, routing, window management, or screenshot caches.
