import 'package:data_fixture_dart/definitions/fixture_definition.dart';
import 'package:data_fixture_dart/makers/json_fixture_maker.dart';
import 'package:data_fixture_dart/misc/fixture_tuple.dart';

/// Type alias for JSON fixture definition.
typedef JsonFixtureDefinitionBuilder<Model> = Map<String, dynamic> Function(
    Model model);

/// It defines a fixture to generate the model and the associated JSON.
class JsonFixtureDefinition<Model> extends JsonFixtureMaker<Model> {
  final FixtureDefinition<Model> fixtureDefinition;
  final JsonFixtureDefinitionBuilder<Model> jsonDefinition;

  JsonFixtureDefinition(this.fixtureDefinition, this.jsonDefinition);

  @override
  List<Map<String, dynamic>> makeJsonArray(
    int number, {
    bool growableList = false,
  }) =>
      List.generate(
        number,
        (_) => jsonDefinition(fixtureDefinition.makeSingle()),
        growable: growableList,
      );

  @override
  List<Map<String, dynamic>> makeJsonArrayFromMany(
    List<Model> objects, {
    bool growableList = false,
  }) =>
      objects.map(jsonDefinition).toList(growable: growableList);

  @override
  Map<String, dynamic> makeJsonObject() => makeJsonArray(1).first;

  @override
  Map<String, dynamic> makeJsonObjectFromSingle(Model object) {
    assert(object != null);
    return makeJsonArrayFromMany([object]).first;
  }

  @override
  List<FixtureTuple<Model>> makeManyWithJsonArray(
    int number, {
    bool growableList = false,
  }) =>
      List.generate(
        number,
        (_) {
          final model = fixtureDefinition.makeSingle();
          final json = jsonDefinition(model);
          return FixtureTuple<Model>(object: model, json: json);
        },
        growable: growableList,
      );

  @override
  FixtureTuple<Model> makeSingleWithJsonObject() =>
      makeManyWithJsonArray(1).first;

  @override
  List<Model> makeMany(int number, {bool growableList = false}) =>
      fixtureDefinition.makeMany(
        number,
        growableList: growableList,
      );

  @override
  Model makeSingle() => fixtureDefinition.makeSingle();
}
