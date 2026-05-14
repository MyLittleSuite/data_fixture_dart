// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// FixtureGenerator
// **************************************************************************

// ignore_for_file: type=lint

import 'package:data_fixture_dart/data_fixture_dart.dart';
import 'package:example/models/dog.dart';

class _$DogFixtureFactory extends FixtureFactory<Dog> {
  @override
  FixtureDefinition<Dog> definition() => define(
        (faker, [int index = 0]) => Dog(
          id: index,
          name: faker.person.firstName(),
          age: faker.randomGenerator.integer(100),
        ),
      );
}

extension DogFixture on Dog {
  static _$DogFixtureFactory factory() => _$DogFixtureFactory();
}
