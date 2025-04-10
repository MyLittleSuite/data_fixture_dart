import 'package:data_fixture_dart/definitions/fixture_definition.dart';
import 'package:data_fixture_dart/makers/json_fixture_maker.dart';
import 'package:data_fixture_dart/misc/fixture_tuple.dart';

/// Type alias for JSON fixture definition.
typedef JsonFixtureDefinitionBuilder<Model> = Map<String, dynamic>
    Function(Model object, [int i]);

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
        (i) => jsonDefinition(fixtureDefinition.makeSingle(), i),
        growable: growableList,
      );

  @override
  List<Map<String, dynamic>> makeJsonArrayFromMany(
    List<Model> objects, {
    bool growableList = false,
  }) {
    final List<Map<String, dynamic>> res = [];

    for (int i = 0; i < objects.length; i++) {
      res.add(jsonDefinition(objects[i], i));
    }

    return res.toList(growable: growableList);
  }
  // objects.map(jsonDefinition).toList(growable: growableList);

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
    final models = fixtureDefinition.makeMany(number);
    final List<FixtureTuple<Model>> items = [];

    for (int i = 0; i < models.length; i++) {
      final json = jsonDefinition(models[i], i);
      items.add(FixtureTuple<Model>(object: models[i], json: json));
    }

    return items.toList(growable: growableList);
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
