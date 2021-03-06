import 'package:data_fixture_dart/data_fixture_dart.dart';

import 'dog.dart' show Dog, DogFixture;

class Person {
  final String firstName;
  final String lastName;
  final DateTime? birthday;
  final List<Dog> dogs;

  Person({
    required this.firstName,
    required this.lastName,
    this.birthday,
    required this.dogs,
  });
}

extension PersonFixture on Person {
  static _PersonFixtureFactory factory() => _PersonFixtureFactory();
}

class _PersonFixtureFactory extends JsonFixtureFactory<Person> {
  @override
  FixtureDefinition<Person> definition() => define(
        (faker) => Person(
          firstName: faker.person.firstName(),
          lastName: faker.person.lastName(),
          birthday: faker.date.dateTime(),
          dogs: DogFixture.factory().makeMany(10),
        ),
      );

  JsonFixtureDefinition<Person> withFields({
    required String firstName,
    required String lastName,
    DateTime? birthday,
  }) =>
      redefineJson(
        (person) => Person(
          firstName: firstName,
          lastName: lastName,
          birthday: birthday,
          dogs: person.dogs,
        ),
      );

  @override
  JsonFixtureDefinition<Person> jsonDefinition() => defineJson(
        (person) => {
          "firstName": person.firstName,
          "lastName": person.lastName,
          "birthday": person.birthday?.toIso8601String(),
          "dogs": DogFixture.factory().makeJsonArrayFromMany(person.dogs),
        },
      );
}
