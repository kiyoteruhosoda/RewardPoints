# flutterbase

Flutter + SQLite native mobile app following Domain-Driven Design.

## Repository Structure

```
lib/
  app/
    di/              # Dependency injection wiring
    bootstrap/       # App startup
  presentation/
    pages/           # Screen-level widgets
    widgets/         # Reusable UI components (ui/)
    viewmodels/      # UI state management
  application/
    usecases/        # One class per business operation
    dto/             # Input/output data transfer objects
  domain/
    entities/        # Identity-bearing domain objects
    value_objects/   # Immutable value types
    repositories/    # Abstract interfaces (no implementations here)
    services/        # Domain logic spanning multiple entities
  infrastructure/
    db/
      sqlite/
        migrations/  # Versioned schema changes
        dao/         # SQL operations
        rows/        # DB row models
    repositories/    # Concrete repository implementations
    mappers/         # Row ↔ Domain model conversion
  shared/
    utils/
    errors/

.claude/
  rules/             # Behavior rules for all tasks
  skills/            # Step-by-step task procedures
```

## Skills

Task procedures are in `.claude/skills/`. Load the relevant skill before starting work.

- `implement-feature.md` — add a new feature end-to-end
- `add-usecase.md` — create an Application layer UseCase
- `add-entity.md` — create a Domain entity + value objects
- `add-repository.md` — add repository interface + SQLite implementation
- `add-widget.md` — create a reusable UI widget
- `write-tests.md` — write domain / usecase / infrastructure tests
- `create-pr.md` — prepare and open a pull request
