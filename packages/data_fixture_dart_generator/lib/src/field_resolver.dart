import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';

import 'faker_type_mapping.dart';
import 'similarity.dart';

/// Resolves the faker code expression for a constructor parameter.
/// Pure function — no analyzer dependency. Takes pre-extracted type info.
String resolveFieldExpr({
  required String paramName,
  required String dartTypeName,
  required bool isNullable,
  required bool isList,
  required String? customTypeName, // non-null when type is a custom class
  required FakerType? explicitFakerType, // layer 3 override
}) {
  // Layer 3: explicit @FixtureFor fields map override
  if (explicitFakerType != null) {
    return fakerTypeToCode[explicitFakerType]!;
  }

  // Nullable: return null before any other resolution
  if (isNullable) return 'null';

  // id convention
  if (paramName.toLowerCase() == 'id' && dartTypeName == 'int') return 'index';

  // Layer 2: similarity-based name matching
  final similarityMatch = bestDictionaryMatch(paramName);
  if (similarityMatch != null) return similarityMatch;

  // Layer 1: type-based default
  return _typeDefault(dartTypeName, isList, customTypeName);
}

String _typeDefault(String typeName, bool isList, String? customTypeName) {
  if (isList) return '[]';
  return switch (typeName) {
    'int' => 'faker.randomGenerator.integer(100)',
    'double' => 'faker.randomGenerator.decimal()',
    'String' => 'faker.lorem.word()',
    'bool' => 'faker.randomGenerator.boolean()',
    'DateTime' => 'faker.date.dateTime()',
    _ => customTypeName != null
        ? '${customTypeName}Fixture.factory().makeSingle()'
        : '/* TODO: provide value for $typeName */',
  };
}
