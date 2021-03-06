import 'package:data_fixture_dart/data_fixture_dart.dart';
import 'package:data_fixture_dart/definitions/fixture_definition.dart';
import 'package:data_fixture_dart/definitions/json_fixture_definition.dart';
import 'package:data_fixture_dart/makers/json_fixture_maker.dart';
import 'package:data_fixture_dart/misc/fixture_tuple.dart';

/// This class defines the rules to create a JSON Object from a model.
abstract class JsonFixtureFactory<Model> extends FixtureFactory<Model>
    implements JsonFixtureMaker<Model> {
  /// The default JSON model definition.
  JsonFixtureDefinition<Model> jsonDefinition();

  /// Create a new JSON model fixture definition.
  JsonFixtureDefinition<Model> defineJson(
    Map<String, dynamic> Function(Model) jsonDefinition, {
    FixtureDefinition<Model>? modelDefinition,
  }) =>
      JsonFixtureDefinition(
        modelDefinition ?? definition(),
        jsonDefinition,
      );

  /// Edit the default JSON fixture definition.
  JsonFixtureDefinition<Model> redefineJson(
          Model Function(Model) redefinition) =>
      JsonFixtureDefinition(
        redefine(redefinition),
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
