class FixtureFor {
  final Type modelType;
  final String? constructor;
  final bool? hasJson;

  /// Keys are Symbols matching constructor parameter names.
  /// Values are FakerType enum values.
  final Map<Symbol, Object> fields;

  /// Trait name → map of param Symbol → FakerType or FixtureTraitValue.
  final Map<String, Map<Symbol, Object>> traits;

  const FixtureFor(
    this.modelType, {
    this.constructor,
    this.hasJson,
    this.fields = const {},
    this.traits = const {},
  });
}
