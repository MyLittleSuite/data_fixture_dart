import 'package:data_fixture_dart/definitions/fixture_definition.dart';
import 'package:data_fixture_dart/makers/json_fixture_maker.dart';
import 'package:data_fixture_dart/misc/FixtureTuple.dart';

/// It defines a fixture to generate the model and the associated JSON.
class JsonFixtureDefinition<Model> extends JsonFixtureMaker<Model> {
  final FixtureDefinition<Model> fixtureDefinition;
  final Map<String, dynamic> Function(Model) jsonDefinition;

  JsonFixtureDefinition(this.fixtureDefinition, this.jsonDefinition) {
    assert(fixtureDefinition != null);
    assert(jsonDefinition != null);
  }

  @override
  List<Map<String, dynamic>> makeJsonArray(int number) {
    assert(number != null && number > 0);
    return List.generate(
      number,
      (_) => jsonDefinition(fixtureDefinition.makeSingle()),
      growable: false,
    );
  }

  @override
  List<Map<String, dynamic>> makeJsonArrayFromMany(List<Model> objects) {
    assert(objects != null);
    return objects.map(jsonDefinition).toList(growable: false);
  }

  @override
  Map<String, dynamic> makeJsonObject() => makeJsonArray(1).first;

  @override
  Map<String, dynamic> makeJsonObjectFromSingle(Model object) {
    assert(object != null);
    return makeJsonArrayFromMany([object]).first;
  }

  @override
  List<FixtureTuple<Model>> makeManyWithJsonArray(int number) {
    assert(number != null && number > 0);
    return List.generate(
      number,
      (_) {
        final model = fixtureDefinition.makeSingle();
        final json = jsonDefinition(model);
        return FixtureTuple(model, json);
      },
      growable: false,
    );
  }

  @override
  FixtureTuple<Model> makeSingleWithJsonObject() => makeManyWithJsonArray(1).first;

  @override
  List<Model> makeMany(int number) => fixtureDefinition.makeMany(number);

  @override
  Model makeSingle() => fixtureDefinition.makeSingle();
}
