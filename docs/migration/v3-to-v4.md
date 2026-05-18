# Migrating from v3 to v4

## Overview

v4 is a **Dart 3 release**. The core `data_fixture_dart` API is unchanged — existing factory classes require no modifications. The primary changes are the SDK constraint bump and two new optional packages.

## 1. Update the SDK constraint

```yaml
# pubspec.yaml — before
environment:
  sdk: ">=2.12.0 <3.0.0"

# pubspec.yaml — after
environment:
  sdk: ">=3.0.0 <4.0.0"
```

## 2. Update the package version

```yaml
dependencies:
  data_fixture_dart: ^4.0.0
```

Run:

```shell
dart pub get
```

## 3. No API changes required

All existing `FixtureFactory` and `JsonFixtureFactory` subclasses continue to work without modification. The following APIs are unchanged:

- `FixtureFactory<T>` / `JsonFixtureFactory<T>`
- `FixtureDefinition<T>` / `JsonFixtureDefinition<T>`
- `define()` / `redefine()` / `defineJson()` / `redefineJson()`
- `makeSingle()` / `makeMany(n)` / `makeJsonObject()` / `makeJsonArray(n)`
- `makeSingleWithJsonObject()` / `makeManyWithJsonArray(n)`
- `makeJsonObjectFromSingle()` / `makeJsonArrayFromMany()`
- `FixtureTuple<T>`
- Custom `Faker` injection via `faker:` named parameter

## 4. New optional packages

v4 introduces two new packages for annotation-driven code generation. Adoption is **optional** — you can continue using hand-written factories alongside generated ones.

| Package | Purpose |
|---|---|
| `data_fixture_dart_annotations` | `@FixtureFor` annotation, `FakerType` enum, traits |
| `data_fixture_dart_generator` | `build_runner` generator that reads `@FixtureFor` and produces factory boilerplate |

See the [manual-to-generator migration guide](manual-to-generator.md) if you want to adopt the generator.
