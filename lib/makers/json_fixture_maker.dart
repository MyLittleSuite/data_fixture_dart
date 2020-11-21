import 'package:data_fixture_dart/makers/fixture_maker.dart';
import 'package:data_fixture_dart/misc/FixtureTuple.dart';

/// This class define a JSON fixture maker.
abstract class JsonFixtureMaker<Model> extends FixtureMaker<Model> {
  /// Create a JSON Array of models.
  List<Map<String, dynamic>> makeJsonArray(int number);

  /// Create a JSON Array of a sequence of models.
  List<Map<String, dynamic>> makeJsonArrayFromMany(List<Model> objects);

  /// Create an array of both model and its relative JSON Object.
  List<FixtureTuple<Model>> makeManyWithJsonArray(int number);

  /// Create a JSON Object.
  Map<String, dynamic> makeJsonObject();

  /// Create a JSON Object from a model.
  Map<String, dynamic> makeJsonObjectFromSingle(Model object);

  /// Create a tuple of model and its relative JSON Object.
  FixtureTuple<Model> makeSingleWithJsonObject();
}
