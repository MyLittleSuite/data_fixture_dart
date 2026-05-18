# Migrating from manual factories to the generator

The generator produces the same `FixtureFactory` / `JsonFixtureFactory` boilerplate you'd write by hand. Manual factories remain fully supported — you can adopt the generator incrementally, one model at a time.

## When to use the generator

| Use the generator | Stick with manual |
|---|---|
| Standard model fields that map to `FakerType` | Complex builder logic (computed fields, conditional branching) |
| Traits with literal overrides | Seeded `Faker` for reproducible tests |
| Nested models with standard fields (auto-discovered) | Nested factories with cross-model logic beyond `makeSingle()` |
| Reducing boilerplate in large test suites | |

## Setup

**1. Add packages to `pubspec.yaml`:**

```yaml
dependencies:
  data_fixture_dart_annotations: ^1.0.0

dev_dependencies:
  data_fixture_dart_generator: ^1.0.0
  build_runner: ^2.4.0
```

**2. Enable the builder in `build.yaml`** (create at project root if missing):

```yaml
targets:
  $default:
    builders:
      data_fixture_dart_generator|fixture_generator:
        enabled: true
```

## Before and after

### Model without JSON

**Before — hand-written factory:**

```dart
extension DogFixture on Dog {
  static _DogFixtureFactory factory() => _DogFixtureFactory();
}

class _DogFixtureFactory extends FixtureFactory<Dog> {
  @override
  FixtureDefinition<Dog> definition() => define(
        (faker, [int index = 0]) => Dog(
          id: index,
          name: faker.person.name(),
          age: faker.randomGenerator.integer(100),
        ),
      );
}
```

**After — annotation:**

```dart
// fixtures.dart
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:my_app/models/dog.dart';

@FixtureFor(Dog)
void fixtures() {}
```

Run `dart run build_runner build`. The generator produces `fixtures.fixture.dart` with an equivalent `_$DogFixtureFactory` and a `DogFixture` extension.

### Model with JSON

**Before:**

```dart
class _UserFixtureFactory extends JsonFixtureFactory<User> {
  @override
  FixtureDefinition<User> definition() => define(
        (faker, [int index = 0]) => User(
          id: index,
          name: faker.person.name(),
          email: faker.internet.email(),
        ),
      );

  @override
  JsonFixtureDefinition<User> jsonDefinition() => defineJson(
        (user, [int index = 0]) => user.toJson(),
      );
}
```

**After:**

```dart
@FixtureFor(User, hasJson: true)
void fixtures() {}
```

`hasJson: true` tells the generator to extend `JsonFixtureFactory` and call `toJson()` in `jsonDefinition`. Your model must expose a `toJson()` method (e.g., via `json_serializable`).

## Migrating traits

**Before — hand-written trait method:**

```dart
FixtureDefinition<Dog> old() => redefine(
      (dog, [int index = 0]) => Dog(
        id: dog.id,
        name: dog.name,
        age: 20,
      ),
    );
```

**After — annotation trait:**

```dart
@FixtureFor(Dog, traits: {
  'old': {#age: FixtureTraitValue.literal(20)},
})
void fixtures() {}
```

For fields that should use a faker method rather than a literal:

```dart
@FixtureFor(User, traits: {
  'withRandomEmail': {#email: FixtureTraitValue.faker(FakerType.internetEmail)},
})
void fixtures() {}
```

## Overriding field faker types

By default the generator infers a `FakerType` from the parameter name using fuzzy matching. Override any field explicitly:

```dart
@FixtureFor(
  Product,
  fields: {
    #title: FakerType.loremSentence,
    #price: FakerType.randomDouble,
  },
)
void fixtures() {}
```

## Multiple models in one file

All `@FixtureFor` annotations on a single function are generated together:

```dart
@FixtureFor(Dog, traits: {'old': {#age: FixtureTraitValue.literal(20)}})
@FixtureFor(User, hasJson: true)
@FixtureFor(Product, fields: {#price: FakerType.randomDouble})
void fixtures() {}
```

## Nested models

Declare only the top-level model. The generator auto-discovers nested custom types and produces a base factory for each.

**Before — hand-written nested factories:**

```dart
class _OwnerFixtureFactory extends FixtureFactory<Owner> {
  @override
  FixtureDefinition<Owner> definition() => define(
        (faker, [int index = 0]) => Owner(
          id: index,
          name: faker.person.name(),
          user: UserFixture.factory().makeSingle(),
          dogs: DogFixture.factory().makeMany(3),
        ),
      );
}
```

**After — one annotation, nested factories auto-generated:**

```dart
@FixtureFor(Owner)
void fixtures() {}
```

The generator produces factory classes for `Owner`, `User`, and `Dog`. `List<Dog>` defaults to `[]` in the generated definition — override via a trait or manual factory if you need a populated list.

If a nested type already has its own `@FixtureFor`, the explicit declaration takes precedence and no duplicate is generated.

## Running the generator

```shell
# One-off build
dart run build_runner build

# Watch mode during development
dart run build_runner watch
```

Generated files end in `.fixture.dart` and contain a `// GENERATED CODE - DO NOT MODIFY BY HAND` header. Commit them alongside your source files.
