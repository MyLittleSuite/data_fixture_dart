/// This class define a fixture maker.
abstract class FixtureMaker<Model> {
  /// Create a list of models.
  List<Model> makeMany(int number);

  /// Create a single model.
  Model makeSingle();
}
