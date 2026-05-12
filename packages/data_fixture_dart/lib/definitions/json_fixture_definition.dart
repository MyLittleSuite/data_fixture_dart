import 'package:data_fixture_dart/definitions/fixture_definition.dart';
import 'package:data_fixture_dart/makers/json_fixture_maker.dart';
import 'package:data_fixture_dart/misc/fixture_tuple.dart';

/// Type alias for JSON fixture definition.
typedef JsonFixtureDefinitionBuilder<Model> = Map<String, dynamic>
    Function(Model object, [int index]);

/// It defines a fixture to generate the model and the associated JSON.
abstract class JsonFixtureDefinition<Model> extends JsonFixtureMaker<Model> {
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
        (int index) => jsonDefinition(fixtureDefinition.makeSingle(), index),
        growable: growableList,
      );

  @override
  List<Map<String, dynamic>> makeJsonArrayFromMany(
    List<Model> objects, {
    bool growableList = false,
  }) {
    return objects.map((Model model) {
      return jsonDefinition(model, objects.indexOf(model));
    }).toList(growable: growableList);
  }

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
  }) {
    return fixtureDefinition
        .makeMany(number)
        .asMap()
        .entries
        .map((MapEntry<int, Model> entry) {
      final Map<String, dynamic> json = jsonDefinition(entry.value, entry.key);
      return FixtureTuple(object: entry.value, json: json);
    }).toList(growable: growableList);
  }

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
