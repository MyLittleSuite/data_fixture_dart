import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';

import 'constructor_resolver.dart';
import 'faker_type_mapping.dart';

class TraitGenerator {
  /// Generates a named trait method for a factory.
  ///
  /// [traitName] e.g. `'old'`
  /// [overrides] map of paramName → code expression string
  /// [params] all constructor params (for defaults: `varName.paramName`)
  /// [callPrefix] e.g. `Dog` or `Dog.fromData`
  /// [isJsonFactory] whether factory extends JsonFixtureFactory
  String generate({
    required String traitName,
    required String className,
    required List<ResolvedParam> params,
    required String callPrefix,
    required Map<String, String> overrides, // paramName → code expression
    required bool isJsonFactory,
  }) {
    final varName = className[0].toLowerCase() + className.substring(1);
    final returnType = isJsonFactory
        ? 'JsonFixtureDefinition<$className>'
        : 'FixtureDefinition<$className>';
    final redefineMethod = isJsonFactory ? 'redefineJson' : 'redefine';

    final paramExprList = params.map((p) {
      final expr = overrides[p.name] ?? '$varName.${p.name}';
      return p.isNamed ? '${p.name}: $expr' : expr;
    }).toList();
    final paramExprs = paramExprList.isEmpty
        ? ''
        : '\n      ${paramExprList.join(',\n      ')},\n    ';

    return '''
  $returnType $traitName() => $redefineMethod(
    ($varName, [int index = 0]) => $callPrefix($paramExprs),
  );''';
  }

  /// Converts a trait override value to a Dart code string.
  /// Pass either a [fakerType] or a [literalValue] (int, double, bool, String, or null).
  static String overrideToExpr(Object? literalValue, FakerType? fakerType) {
    if (fakerType != null) {
      return fakerTypeToCode[fakerType] ??
          (throw StateError('No code mapping for FakerType.$fakerType'));
    }
    if (literalValue == null) return 'null';
    if (literalValue is String) return "'$literalValue'";
    return '$literalValue'; // int, double, bool
  }
}
