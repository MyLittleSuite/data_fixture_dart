---
title: Example Project Design
date: 2026-05-14
status: approved
---

# Example Project

A standalone Dart package under `example/` that demonstrates the full `data_fixture_dart` generator workflow end-to-end: annotate models, run `build_runner`, get generated factory classes, use them in tests.

## Goals

- Show `@FixtureFor` on a plain Dart model (no JSON)
- Show `@FixtureFor` with `hasJson: true` on a Freezed model
- Show traits (`FixtureTraitValue.literal`)
- Show `fields` override (`FakerType`)
- Show fixtures in both `lib/` (shared) and `test/` (test-only)
- Runnable with `dart test` after `dart run build_runner build`

## Structure

```
example/
├── pubspec.yaml
├── build.yaml
├── lib/
│   ├── models/
│   │   ├── dog.dart
│   │   └── user.dart
│   └── fixtures.dart         # @FixtureFor annotations (lib-level)
└── test/
    ├── fixtures.dart         # @FixtureFor annotations (test-only)
    └── example_test.dart
```

Generated files (not committed):
- `lib/models/user.freezed.dart`
- `lib/models/user.g.dart`
- `lib/fixtures.fixture.dart`
- `test/fixtures.fixture.dart`

## Dependencies

```yaml
dependencies:
  data_fixture_dart:
    path: ../packages/data_fixture_dart
  data_fixture_dart_annotations:
    path: ../packages/data_fixture_dart_annotations
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

dev_dependencies:
  data_fixture_dart_generator:
    path: ../packages/data_fixture_dart_generator
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  test: ^1.25.0
```

## Models

### `lib/models/dog.dart` — plain Dart

```dart
class Dog {
  final int id;
  final String name;
  final int age;
  Dog({required this.id, required this.name, required this.age});
}
```

### `lib/models/user.dart` — Freezed + JSON

```dart
@freezed
class User with _$User {
  const factory User({
    required int id,
    required String name,
    required String email,
    required bool isVerified,
  }) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

## Fixture Annotations

### `lib/fixtures.dart`

Demonstrates traits on both models:

```dart
@FixtureFor(Dog, traits: {
  'old': {#age: FixtureTraitValue.literal(20)},
})
@FixtureFor(User, hasJson: true, traits: {
  'verified': {#isVerified: FixtureTraitValue.literal(true)},
})
void fixtures() {}
```

### `test/fixtures.dart`

Demonstrates `fields` override (test-only variant):

```dart
@FixtureFor(Dog, fields: {#name: FakerType.personFirstName})
void testFixtures() {}
```

## Test

`test/example_test.dart` exercises all public APIs:

- `Dog.factory().makeSingle()` — basic instance
- `Dog.factory().makeMany(3)` — list
- `Dog.factory().old().makeSingle()` — trait: age == 20
- `User.factory().makeSingle()` — Freezed instance
- `User.factory().makeJsonObject()` — JSON map
- `User.factory().verified().makeSingleWithJsonObject()` — tuple, isVerified == true

## Build Workflow

```sh
cd example
dart pub get
dart run build_runner build --delete-conflicting-outputs
dart test
```

`build.yaml` enables the fixture generator for both `lib/` and `test/`:

```yaml
targets:
  $default:
    builders:
      data_fixture_dart_generator|fixture_generator:
        enabled: true
```
