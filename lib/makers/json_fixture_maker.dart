import 'package:data_fixture_dart/makers/fixture_maker.dart';
import 'package:data_fixture_dart/misc/fixture_tuple.dart';

/// This class define a JSON fixture maker.
abstract class JsonFixtureMaker<Model> extends FixtureMaker<Model> {
  /// Create a JSON Array of models.
  List<Map<String, dynamic>> makeJsonArray(int number,
      {bool growableList = false});

  /// Create a JSON Array of a sequence of models.
  List<Map<String, dynamic>> makeJsonArrayFromMany(List<Model> objects,
      {bool growableList = false});

  /// Create an array of both model and its relative JSON Object.
  List<FixtureTuple<Model>> makeManyWithJsonArray(int number,
      {bool growableList = false});

  /// Create a JSON Object.
  Map<String, dynamic> makeJsonObject();

  /// Create a JSON Object from a model.
  Map<String, dynamic> makeJsonObjectFromSingle(Model object);

  /// Create a tuple of model and its relative JSON Object.
  FixtureTuple<Model> makeSingleWithJsonObject();
}
