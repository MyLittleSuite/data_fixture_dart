/// A tuple of object and its relative json.
class FixtureTuple<T> {
  /// The object.
  final T object;

  /// The associated json object.
  final Map<String, dynamic> json;

  FixtureTuple({
    required this.object,
    required this.json,
  });
}
