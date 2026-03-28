---
trigger: always_on
---

# Flutter Design System Rules

## Theme Access
Always obtain theme colors and data via `Theme.of(context)`. The design system is defined in `lib/main.dart` within the `ThemeData` and its `ColorScheme`.

## Color Usage
- **Semantic Colors**: Use `Theme.of(context).colorScheme` for all UI elements.
  - `primary`: For main branding and primary actions.
  - `secondary`: For accents, selections (e.g., orange highlights), and secondary actions.
  - `surface`: For cards, containers, and backgrounds of list items.
  - `shadow`: For elevation effects.
  - `onSurface`, `onPrimary`, `onSecondary`: For text/icons layered on their respective backgrounds.
- **Hardcoded Colors**: NEVER use `Colors.black`, `Colors.white`, or specific color constants (like `Colors.orange`) directly in widgets.

## Modern APIs & Deprecations
- **Opacity**: NEVER use the deprecated `withOpacity(double)` method. 
- **Modern Alternative**: ALWAYS use `withValues(alpha: double)` for adjusting color transparency.
  - Example: `Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)`

## Widget Optimization
- **Const Containers**: Be aware that using `Theme.of(context)` removes the ability to make the parent widget or specific properties (like `TextStyle` or `BoxDecoration`) `const`. Ensure you remove `const` keyword when introducing theme-based dynamic colors.
