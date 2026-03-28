---
trigger: always_on
---

# Core Logic Utilities Rule

## Objective
To maintain a clean, maintainable, and testable codebase by preventing logic duplication and keeping UI/Bloc components focused on their primary responsibilities.

## Rule
Whenever implementing core domain logic—especially mathematical calculations, data transformations, or hardware-specific protocol logic—that is used in more than one place (or is complex enough to be potentially recurring), it MUST be packaged into a utility class in the `lib/utils/` directory.

### Guidelines
1. **Stateless Logic**: Utility methods should be `static` and pure wherever possible (input in, output out).
2. **Naming**: Use descriptive class names (e.g., `FrequencyUtils`, `MusicalNotesUtils`).
3. **Domain Separation**
4. **No UI in Utils**: Utilities should never depend on `BuildContext` or UI-specific types unless absolutely necessary for the transformation logic.
5. **Centralized Constants**: Move domain-specific constants into the relevant utility class to ensure a single source of truth.

## Benefits
- **DRY (Don't Repeat Yourself)**: Changes to core math only need to happen in one file.
- **Improved Testing**: Logic in utils can be unit tested in isolation without mocking entire Bloc states or Widget trees.
- **Code Readability**: Screens and Blocs become more declarative.