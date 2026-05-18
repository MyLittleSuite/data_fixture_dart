// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// FixtureGenerator
// **************************************************************************

// ignore_for_file: type=lint

import 'package:data_fixture_dart/data_fixture_dart.dart';
import 'package:example/models/dog.dart';
import 'package:example/models/user.dart';
import 'package:example/models/owner.dart';

class _$DogFixtureFactory extends FixtureFactory<Dog> {
  @override
  FixtureDefinition<Dog> definition() => define(
        (faker, [int index = 0]) => Dog(
          id: index,
          name: faker.person.name(),
          age: faker.randomGenerator.integer(100),
        ),
      );

  FixtureDefinition<Dog> old() => redefine(
        (dog, [int index = 0]) => Dog(
          id: dog.id,
          name: dog.name,
          age: 20,
        ),
      );
}

extension DogFixture on Dog {
  static _$DogFixtureFactory factory() => _$DogFixtureFactory();
}

class _$UserFixtureFactory extends JsonFixtureFactory<User> {
  @override
  FixtureDefinition<User> definition() => define(
        (faker, [int index = 0]) => User(
          id: index,
          name: faker.person.name(),
          email: faker.internet.email(),
          isVerified: faker.randomGenerator.boolean(),
        ),
      );

  @override
  JsonFixtureDefinition<User> jsonDefinition() => defineJson(
        (user, [int index = 0]) => user.toJson(),
      );

  JsonFixtureDefinition<User> verified() => redefineJson(
        (user, [int index = 0]) => User(
          id: user.id,
          name: user.name,
          email: user.email,
          isVerified: true,
        ),
      );
}

extension UserFixture on User {
  static _$UserFixtureFactory factory() => _$UserFixtureFactory();
}

class _$OwnerFixtureFactory extends FixtureFactory<Owner> {
  @override
  FixtureDefinition<Owner> definition() => define(
        (faker, [int index = 0]) => Owner(
          id: index,
          name: faker.person.name(),
          user: UserFixture.factory().makeSingle(),
          dogs: [],
        ),
      );
}

extension OwnerFixture on Owner {
  static _$OwnerFixtureFactory factory() => _$OwnerFixtureFactory();
}
