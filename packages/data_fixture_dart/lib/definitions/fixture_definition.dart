import 'package:data_fixture_dart/makers/fixture_maker.dart';
import 'package:faker/faker.dart';

/// Type alias for fixture definition.
typedef FixtureDefinitionBuilder<Model> = Model Function(Faker faker,
    [int index]);

/// This defines a fixture to generate the model.
abstract class FixtureDefinition<Model> implements FixtureMaker<Model> {
  FixtureDefinition(
    this.definition, {
    Faker? faker,
  }) : this.faker = faker ?? Faker();

  final FixtureDefinitionBuilder<Model> definition;
  final Faker faker;

  @override
  List<Model> makeMany(
    int number, {
    bool growableList = false,
  }) =>
      List.generate(
        number,
        (int index) => definition(faker, index),
        growable: growableList,
      );

  @override
  Model makeSingle() => makeMany(1).first;
}
