import 'package:data_fixture_dart/makers/fixture_maker.dart';
import 'package:faker/faker.dart';

/// Type alias for fixture definition.
typedef FixtureDefinitionBuilder<Model> = Model Function(Faker faker);

/// This defines a fixture to generate the model.
class FixtureDefinition<Model> implements FixtureMaker<Model> {
  final FixtureDefinitionBuilder<Model> definition;
  final Faker faker = Faker();

  FixtureDefinition(this.definition);

  @override
  List<Model> makeMany(
    int number, {
    bool growableList = false,
  }) =>
      List.generate(
        number,
        (_) => definition(faker),
        growable: growableList,
      );

  @override
  Model makeSingle() => makeMany(1).first;
}
