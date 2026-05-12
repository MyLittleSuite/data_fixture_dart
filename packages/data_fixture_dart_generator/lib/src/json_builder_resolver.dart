import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

const _jsonSerializableChecker = TypeChecker.fromUrl(
  'package:json_annotation/json_annotation.dart#JsonSerializable',
);
const _freezedChecker = TypeChecker.fromUrl(
  'package:freezed_annotation/freezed_annotation.dart#Freezed',
);

class JsonBuilderResolver {
  /// Returns true if the model has a `toJson()` method or is annotated with
  /// @JsonSerializable / @freezed.
  bool shouldUseToJson(ClassElement classElement) {
    if (classElement.methods.any((m) => m.name == 'toJson')) return true;
    if (_jsonSerializableChecker.hasAnnotationOf(classElement)) return true;
    if (_freezedChecker.hasAnnotationOf(classElement)) return true;
    return false;
  }

  /// Generates the `jsonDefinition()` override body.
  String generate({
    required String className,
    required bool useToJson,
    required List<String> paramNames,
  }) {
    final varName = _varName(className);

    if (useToJson) {
      return '''
  @override
  JsonFixtureDefinition<$className> jsonDefinition() => defineJson(
    ($varName, [int index = 0]) => $varName.toJson(),
  );''';
    }

    final fields = paramNames
        .map((n) => "        '$n': $varName.$n")
        .join(',\n');

    return '''
  @override
  JsonFixtureDefinition<$className> jsonDefinition() => defineJson(
    ($varName, [int index = 0]) => {
$fields,
    },
  );''';
  }

  String _varName(String className) =>
      className[0].toLowerCase() + className.substring(1);
}
