# data_fixture_dart

![data_fixture_dart_ci](https://github.com/MyLittleSuite/data_fixture_dart/workflows/Dart%20CI/badge.svg)
[![Pub](https://img.shields.io/pub/v/data_fixture_dart.svg)](https://pub.dev/packages/data_fixture_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)

Create fake model instances for tests without boilerplate. Define a factory once, call `makeSingle()` or `makeMany(n)` anywhere.

## Packages

| Package | pub.dev | Description |
|---|---|---|
| `data_fixture_dart` | [![Pub](https://img.shields.io/pub/v/data_fixture_dart.svg)](https://pub.dev/packages/data_fixture_dart) | Core library — factory base classes and `faker` re-export |
| `data_fixture_dart_annotations` | [![Pub](https://img.shields.io/pub/v/data_fixture_dart_annotations.svg)](https://pub.dev/packages/data_fixture_dart_annotations) | Annotations for code generation (`@FixtureFor`, `FakerType`, traits) |
| `data_fixture_dart_generator` | [![Pub](https://img.shields.io/pub/v/data_fixture_dart_generator.svg)](https://pub.dev/packages/data_fixture_dart_generator) | `build_runner` generator — produces factory boilerplate from annotations |

---

## Manual approach

Write factory classes by hand. Full control — use arbitrary Dart logic in builders.

### Basic

```dart
import 'package:data_fixture_dart/data_fixture_dart.dart';

class Company {
  final String name;
  final List<Person> employees;

  Company({required this.name, required this.employees});
}

extension CompanyFixture on Company {
  static _CompanyFixtureFactory factory() => _CompanyFixtureFactory();
}

class _CompanyFixtureFactory extends FixtureFactory<Company> {
  @override
  FixtureDefinition<Company> definition() => define(
        (faker, [int index = 0]) => Company(
          name: faker.company.name(),
          employees: PersonFixture.factory().makeMany(5),
        ),
      );

  FixtureDefinition<Company> empty(String name) => redefine(
        (company, [int index = 0]) => Company(
          name: name,
          employees: [],
        ),
      );
}
```

```dart
// Single instance
Company company = CompanyFixture.factory().makeSingle();

// Custom variant
Company empty = CompanyFixture.factory().empty('ACME').make();

// List of 10
List<Company> companies = CompanyFixture.factory().makeMany(10);
```

### JSON fixtures

Extend `JsonFixtureFactory` and override `jsonDefinition()`.

```dart
extension CompanyFixture on Company {
  static _CompanyFixtureFactory factory() => _CompanyFixtureFactory();
}

class _CompanyFixtureFactory extends JsonFixtureFactory<Company> {
  @override
  FixtureDefinition<Company> definition() => define(
        (faker, [int index = 0]) => Company(
          name: faker.company.name(),
          employees: PersonFixture.factory().makeMany(5),
        ),
      );

  @override
  JsonFixtureDefinition<Company> jsonDefinition() => defineJson(
        (company, [int index = 0]) => {
          'name': company.name,
          'employees': PersonFixture.factory().makeJsonArrayFromMany(company.employees),
        },
      );

  JsonFixtureDefinition<Company> empty(String name) => redefineJson(
        (company, [int index = 0]) => Company(
          name: name,
          employees: [],
        ),
      );
}
```

```dart
// JSON object
Map<String, dynamic> json = CompanyFixture.factory().makeJsonObject();

// JSON array of 10
List<Map<String, dynamic>> jsonArray = CompanyFixture.factory().makeJsonArray(10);

// Paired model + JSON
FixtureTuple<Company> tuple = CompanyFixture.factory().makeSingleWithJsonObject();

// JSON from an existing instance
final company = CompanyFixture.factory().makeSingle();
final json = CompanyFixture.factory().makeJsonObjectFromSingle(company);
```

### Custom Faker instance

Pass a seeded or custom-provider `Faker` to `define`/`redefine`.

```dart
class _NewsArticleFixtureFactory extends FixtureFactory<NewsArticle> {
  @override
  FixtureDefinition<NewsArticle> definition() => define(
        (faker, [int index = 0]) => NewsArticle(
          title: faker.lorem.sentence(),
          content: faker.lorem.sentences(3).join(' '),
        ),
        faker: Faker(
          seed: 42,
          provider: FakerDataProvider(
            loremDataProvider: MyCustomLoremDataProvider(),
          ),
        ),
      );
}
```

---

## Generator approach

Let `build_runner` generate factory boilerplate from `@FixtureFor` annotations. Best for models with standard fields where `FakerType` mappings cover your needs.

### Setup

**1. Add dependencies to `pubspec.yaml`:**

```yaml
dependencies:
  data_fixture_dart: ^4.0.0
  data_fixture_dart_annotations: ^1.0.0

dev_dependencies:
  data_fixture_dart_generator: ^1.0.0
  build_runner: ^2.4.0
```

**2. Enable the builder in `build.yaml`** (create the file at the project root if it doesn't exist):

```yaml
targets:
  $default:
    builders:
      data_fixture_dart_generator|fixture_generator:
        enabled: true
```

### Annotate models

Create a Dart file (e.g., `test/fixtures.dart`) and annotate a `void` function with one `@FixtureFor` per model:

```dart
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:my_app/models/dog.dart';
import 'package:my_app/models/user.dart';

@FixtureFor(Dog)
@FixtureFor(User, hasJson: true)
void fixtures() {}
```

**3. Run the generator:**

```shell
dart run build_runner build
```

This produces a `fixtures.fixture.dart` file alongside the annotated file.

### @FixtureFor options

| Parameter | Type | Description |
|---|---|---|
| `modelType` | `Type` | The model class to generate a factory for |
| `constructor` | `String?` | Named constructor to use (default: unnamed) |
| `hasJson` | `bool?` | Generate `JsonFixtureFactory` with `toJson()` |
| `fields` | `Map<Symbol, FakerType>` | Override `FakerType` per constructor parameter |
| `traits` | `Map<String, Map<Symbol, Object>>` | Named variants with overridden field values |

### FakerType values

| Enum value | Generated data |
|---|---|
| `personFirstName` | `faker.person.firstName()` |
| `personLastName` | `faker.person.lastName()` |
| `personName` | `faker.person.name()` |
| `internetEmail` | `faker.internet.email()` |
| `internetUrl` | `faker.internet.httpsUrl()` |
| `dateDateTime` | `faker.date.dateTime()` |
| `loremWord` | `faker.lorem.word()` |
| `loremSentence` | `faker.lorem.sentence()` |
| `randomInt` | `faker.randomGenerator.integer(100)` |
| `randomDouble` | `faker.randomGenerator.decimal()` |
| `addressCity` | `faker.address.city()` |
| `addressCountry` | `faker.address.country()` |
| `phoneNumber` | `faker.phoneNumber.us()` |
| `companyName` | `faker.company.name()` |

### Traits

Traits generate named variant methods on the factory. Use `FakerType` or literal values via `FixtureTraitValue`:

```dart
@FixtureFor(Dog, traits: {
  'old': {#age: FixtureTraitValue.literal(20)},
})
@FixtureFor(User, hasJson: true, traits: {
  'verified': {#isVerified: FixtureTraitValue.literal(true)},
  'withCustomEmail': {#email: FixtureTraitValue.faker(FakerType.internetEmail)},
})
void fixtures() {}
```

Generated usage:

```dart
// Standard factory
Dog dog = DogFixture.factory().makeSingle();

// Trait variant
Dog oldDog = DogFixture.factory().old().makeSingle();

// JSON with trait
Map<String, dynamic> json = UserFixture.factory().verified().makeJsonObject();
```

---

## When to use which approach

| Situation | Approach |
|---|---|
| Standard model, fields map to `FakerType` | Generator |
| Complex builders (computed fields, nested logic, external state) | Manual |
| Need a seeded `Faker` for reproducible tests | Manual |
| Incremental adoption — adding generator to an existing project | Both (mix freely) |

---

## Contributing

`data_fixture_dart` is an open source project. Open an issue for problems or suggestions, or propose fixes via pull request.

## Testing

```shell
dart test
```
