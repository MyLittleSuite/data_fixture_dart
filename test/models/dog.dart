import 'package:data_fixture_dart/data_fixture_dart.dart';

class Dog {
  final String name;
  final int age;

  Dog({this.name, this.age});
}

extension DogFixture on Dog {
  static _DogFixtureFactory factory() => _DogFixtureFactory();
}

class _DogFixtureFactory extends JsonFixtureFactory<Dog> {
  @override
  FixtureDefinition<Dog> definition() => define(
        (faker) => Dog(
          name: faker.person.name(),
          age: faker.randomGenerator.integer(15, min: 1),
        ),
      );

  JsonFixtureDefinition<Dog> old() => redefineJson(
        (dog) => Dog(
          name: dog.name,
          age: 20,
        ),
      );

  @override
  JsonFixtureDefinition<Dog> jsonDefinition() => defineJson(
        (dog) => {
          "name": dog.name,
          "age": dog.age,
        },
      );
}
