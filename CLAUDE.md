# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Test fixture library for Dart/Flutter projects. Solves the problem of creating realistic fake model instances in tests without boilerplate. Instead of hand-crafting constructors with dummy data in every test file, you define a factory once and call `makeSingle()` / `makeMany(n)` anywhere.

Core dependency is `package:faker` (re-exported), which supplies realistic random data (names, dates, companies, etc.).

### When to use which method

| Need | Method |
|---|---|
| Model instance for a test | `makeSingle()` / `makeMany(n)` |
| JSON map (e.g. to test a deserializer) | `makeJsonObject()` / `makeJsonArray(n)` |
| Both model + JSON in sync (e.g. to test round-trip serialization) | `makeSingleWithJsonObject()` / `makeManyWithJsonArray(n)` |
| JSON from already-existing model instances | `makeJsonObjectFromSingle(obj)` / `makeJsonArrayFromMany(list)` |
| Edge-case variant (different fields, empty list, etc.) | define a named method returning `redefine()` / `redefineJson()` |

## Commands

```shell
dart test                # run all tests
dart test test/foo_test.dart  # run single test file
dart analyze             # static analysis
```

## Architecture

Pure Dart package — no Flutter dependency. Published to pub.dev as `data_fixture_dart`.

### Layer responsibilities

**Makers** (`lib/makers/`) — abstract interfaces only:
- `FixtureMaker<Model>` — `makeSingle()`, `makeMany(int)`
- `JsonFixtureMaker<Model>` extends above — adds JSON output methods

**Definitions** (`lib/definitions/`) — concrete generation logic:
- `FixtureDefinition<Model>` — holds a `FixtureDefinitionBuilder` (a `(Faker, [int index]) => Model` lambda) and a `Faker` instance; `makeMany` drives the lambda via `List.generate`, passing `index`
- `JsonFixtureDefinition<Model>` — wraps a `FixtureDefinition` + a `JsonFixtureDefinitionBuilder` (`(Model, [int index]) => Map<String, dynamic>`); JSON generation always generates the model first, then maps it to JSON

**Factories** (`lib/factories/`) — public API consumed by users:
- `FixtureFactory<Model>` — abstract; users override `definition()` returning a `FixtureDefinition`. Provides `define()` (new definition) and `redefine()` (mutate result of `definition()`) helpers
- `JsonFixtureFactory<Model>` extends `FixtureFactory` — users also override `jsonDefinition()`. Adds `defineJson()` and `redefineJson()` helpers

**Misc** (`lib/misc/`):
- `FixtureTuple<T>` — value object pairing `object` + `json`; returned by `makeSingleWithJsonObject()` / `makeManyWithJsonArray()`

### Key design rules

- `redefine()` calls `definition().definition(faker, index)` internally, then passes the result to the user's lambda — so partial overrides are cheap (just change the fields you care about).
- `redefineJson()` reuses `jsonDefinition().jsonDefinition` (the builder), so JSON shape stays the same when you only want to change the model.
- `index` is exposed to both builder lambdas so generated collections can have stable, predictable field values (e.g., sequential IDs in tests).
- Custom `Faker` instances (with seed or custom providers) can be injected via the `faker:` named parameter on `define`/`redefine`.
- The library re-exports `package:faker/faker.dart` so consumers only need one import.

### Convention for test fixtures

Factories are private (`_FooFixtureFactory`) and exposed via an extension method on the model:

```dart
extension FooFixture on Foo {
  static _FooFixtureFactory factory() => _FooFixtureFactory();
}
```

Custom definitions (e.g., `empty()`, `withFields()`) return `FixtureDefinition<Model>` or `JsonFixtureDefinition<Model>` so callers can chain directly into `makeSingle()` / `makeJsonObject()` etc.
