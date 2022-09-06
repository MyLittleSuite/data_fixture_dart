import 'package:data_fixture_dart/definitions/fixture_definition.dart';
import 'package:data_fixture_dart/makers/fixture_maker.dart';
import 'package:faker/faker.dart';

/// Type alias for fixture redefinition.
typedef FixtureRedefinitionBuilder<Model> = Model Function(Model object);

/// This abstract class specifies the definitions to create an object.
abstract class FixtureFactory<Model> implements FixtureMaker<Model> {
  /// The default model definition.
  FixtureDefinition<Model> definition();

  /// Create a new model fixture definition.
  FixtureDefinition<Model> define(
    FixtureDefinitionBuilder<Model> definition, {
    Faker? faker,
  }) =>
      _FixtureDefinitionImpl(
        definition,
        faker: faker,
      );

  /// Edit the default fixture definition.
  FixtureDefinition<Model> redefine(
    FixtureRedefinitionBuilder<Model> redefinition, {
    Faker? faker,
  }) =>
      _FixtureDefinitionImpl(
        (faker) {
          final model = definition().definition(faker);
          return redefinition(model);
        },
        faker: faker,
      );

  @override
  List<Model> makeMany(int number, {bool growableList = false}) =>
      definition().makeMany(number, growableList: growableList);

  @override
  Model makeSingle() => definition().makeSingle();
}

class _FixtureDefinitionImpl<Model> extends FixtureDefinition<Model> {
  _FixtureDefinitionImpl(
    definition, {
    Faker? faker,
  }) : super(
          definition,
          faker: faker,
        );
}
