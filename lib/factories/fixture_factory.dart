import 'package:data_fixture_dart/definitions/fixture_definition.dart';
import 'package:data_fixture_dart/makers/fixture_maker.dart';
import 'package:faker/faker.dart';
import 'package:meta/meta.dart';

/// This abstract class specifies the definitions to create an object.
abstract class FixtureFactory<Model> implements FixtureMaker<Model> {
  /// The default model definition.
  FixtureDefinition<Model> definition();

  /// Create a new model fixture definition.
  @protected
  FixtureDefinition<Model> define(Model Function(Faker) definition) =>
      FixtureDefinition(definition);

  /// Edit the default fixture definition.
  @protected
  FixtureDefinition<Model> redefine(Model Function(Model) redefinition) =>
      FixtureDefinition((faker) {
        final model = definition().definition(faker);
        return redefinition(model);
      });

  @override
  List<Model> makeMany(int number) => definition().makeMany(number);

  @override
  Model makeSingle() => definition().makeSingle();
}
