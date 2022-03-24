# data_fixture_dart

![data_fixture_dart_ci](https://github.com/MyLittleSuite/data_fixture_dart/workflows/Dart/badge.svg)
[![Pub](https://img.shields.io/pub/v/data_fixture_dart.svg)](https://pub.dev/packages/data_fixture_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)

Create data models easily, with no headache.

## Usage

### Basic
1. Create a new file to define the fixture factory for a model.
```dart
import 'package:data_fixture_dart/data_fixture_dart.dart';

class Company {
  final String name;
  final List<Person> employees;

  Company({this.name, this.employees});
}

extension CompanyFixture on Company {
  static _CompanyFixtureFactory factory() => _CompanyFixtureFactory();
}

class _CompanyFixtureFactory extends FixtureFactory<Company> {
  @override
  FixtureDefinition<Company> definition() => define(
        (faker) => Company(
          name: faker.company.name(),
          employees: PersonFixture.factory().makeMany(5),
        ),
      );

  // If you need to override a model field, simply define a function that returns a `FixtureDefinition`.
  // To redefine the default definition, you must use the `redefine` function.
  FixtureDefinition<Company> empty(String name) => redefine(
        (company) => Company(
          name: name,
          employees: [],
        ),
      );
}
```

2. Then you can build the model by using its factory.
```dart
// Create a single object of type Company.
CompanyFixture.factory().makeSingle();
// Create a single object of type Company with no employees.
CompanyFixture.factory().empty("EmptyCompany").make();

// Create 10 objects of type Company.
CompanyFixture.factory().makeMany(10);
// Create 10 objects of type Company with no employees.
CompanyFixture.factory().empty("EmptyCompany").makeMany(10);
```

### JSON Fixtures
A factory can create a JSON Object from a generated model.
1. First, you have to extend `JSONFixtureFactory` protocol to the model factory.
```dart
import 'package:data_fixture_dart/data_fixture_dart.dart';

extension CompanyFixture on Company {
  static _CompanyFixtureFactory factory() => _CompanyFixtureFactory();
}

class _CompanyFixtureFactory extends JsonFixtureFactory<Company> {
  @override
  FixtureDefinition<Company> definition() => define(
        (faker) => Company(
          name: faker.company.name(),
          employees: PersonFixture.factory().makeMany(5),
        ),
      );

  // This function define the json definition, using the default definition (function `definition()`).
  @override
  JsonFixtureDefinition<Company> jsonDefinition() => defineJson(
        (company) => {
          "name": company.name,
          "employees":
              PersonFixture.factory().makeJsonArrayFromMany(company.employees),
        },
      );

  // If you need to generate the JSON Object of an empty company, change the return type to `JSONFixtureDefinition`
  // Previously the return was `FixtureDefinition`.
  JsonFixtureDefinition<Company> empty(String name) => redefineJson(
        (company) => Company(
          name: name,
          employees: [],
        ),
      );
}
```

2. Now you can generate the JSON Object of the model.
```dart
// Create a single JSON object of type Company.
CompanyFixture.factory().makeJsonObject();
// Create a single JSON object of type Company with no employees.
CompanyFixture.factory().empty("EmptyCompany").makeJsonObject();

// Create a JSON Array of 10 objects of type Company.
CompanyFixture.factory().makeJsonArray(10)
// Create a JSON Array of 10 objects of type Company with no employees.
CompanyFixture.factory().empty("EmptyCompany").makeJsonArray(10);

// Create a Company object with its relative JSON object.
CompanyFixture.factory().makeSingleWithJsonObject();
// Create 10 Company object with its relative JSON objects.
CompanyFixture.factory().makeManyWithJsonArray(10);
```

3. With `JsonFixtureFactory` you can create a JSON from an external model object.
```dart
final company = CompanyFixture.factory.makeSingle();
final JSONObject = CompanyFixture.factory.makeJsonObjectFromSingle(from: company);

final companies = CompanyFixture.factory.makeMany(3);
final JSONArray = CompanyFixture.factory.makeJsonArrayFromMany(from: companies);
```

## Contributing
data_fixture_dart is an open source project, so feel free to contribute.
You can open an issue for problems or suggestions, and you can propose your own fixes by opening a pull request with the changes.
