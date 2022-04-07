import 'package:data_fixture_dart/data_fixture_dart.dart';
import 'package:data_fixture_dart/makers/json_fixture_maker.dart';
import 'package:data_fixture_dart/misc/fixture_tuple.dart';

/// This class defines the rules to create a JSON Object from a model.
abstract class JsonFixtureFactory<Model> extends FixtureFactory<Model>
    implements JsonFixtureMaker<Model> {
  /// The default JSON model definition.
  JsonFixtureDefinition<Model> jsonDefinition();

  /// Create a new JSON model fixture definition.
  JsonFixtureDefinition<Model> defineJson(
    JsonFixtureDefinitionBuilder<Model> jsonDefinition, {
    FixtureDefinition<Model>? modelDefinition,
  }) =>
      _JsonFixtureDefinition(
        modelDefinition ?? definition(),
        jsonDefinition,
      );

  /// Edit the default JSON fixture definition.
  JsonFixtureDefinition<Model> redefineJson(
    FixtureRedefinitionBuilder<Model> redefinition, {
    Faker? faker,
  }) =>
      _JsonFixtureDefinition(
        redefine(
          redefinition,
          faker: faker,
        ),
        jsonDefinition().jsonDefinition,
      );

  @override
  List<Map<String, dynamic>> makeJsonArray(
    int number, {
    bool growableList = false,
  }) =>
      jsonDefinition().makeJsonArray(number, growableList: growableList);

  @override
  List<Map<String, dynamic>> makeJsonArrayFromMany(
    List<Model> objects, {
    bool growableList = false,
  }) =>
      jsonDefinition().makeJsonArrayFromMany(
        objects,
        growableList: growableList,
      );

  @override
  Map<String, dynamic> makeJsonObject() => jsonDefinition().makeJsonObject();

  @override
  Map<String, dynamic> makeJsonObjectFromSingle(Model object) =>
      jsonDefinition().makeJsonObjectFromSingle(object);

  @override
  List<FixtureTuple<Model>> makeManyWithJsonArray(
    int number, {
    bool growableList = false,
  }) =>
      jsonDefinition().makeManyWithJsonArray(
        number,
        growableList: growableList,
      );

  @override
  FixtureTuple<Model> makeSingleWithJsonObject() =>
      jsonDefinition().makeSingleWithJsonObject();
}

class _JsonFixtureDefinition<Model> extends JsonFixtureDefinition<Model> {
  _JsonFixtureDefinition(
    FixtureDefinition<Model> fixtureDefinition,
    JsonFixtureDefinitionBuilder<Model> jsonDefinition,
  ) : super(fixtureDefinition, jsonDefinition);
}
