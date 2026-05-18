import 'package:data_fixture_dart/data_fixture_dart.dart';

class Dog {
  final int id;
  final String name;
  final int age;

  Dog({
    required this.id,
    required this.name,
    required this.age,
  });
}

extension DogFixture on Dog {
  static _DogFixtureFactory factory() => _DogFixtureFactory();
}

class _DogFixtureFactory extends JsonFixtureFactory<Dog> {
  @override
  FixtureDefinition<Dog> definition() => define(
        (faker, [int index = 0]) => Dog(
          id: index,
          name: faker.person.name(),
          age: faker.randomGenerator.integer(15, min: 1),
        ),
      );

  JsonFixtureDefinition<Dog> old() => redefineJson(
        (dog, [int index = 0]) => Dog(
          id: index,
          name: dog.name,
          age: 20,
        ),
      );

  @override
  JsonFixtureDefinition<Dog> jsonDefinition() => defineJson(
        (dog, [int index = 0]) => {
          "id": index,
          "name": dog.name,
          "age": dog.age,
        },
      );
}
