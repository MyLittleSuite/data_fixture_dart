import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'constructor_resolver.dart';
import 'field_resolver.dart';
import 'json_builder_resolver.dart';
import 'trait_generator.dart';

const _fixtureForChecker = TypeChecker.fromRuntime(FixtureFor);

class FixtureGenerator extends Generator {
  final _constructorResolver = ConstructorResolver();
  final _jsonResolver = JsonBuilderResolver();
  final _traitGen = TraitGenerator();

  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final imports = <String>{
      "import 'package:data_fixture_dart/data_fixture_dart.dart';",
    };

    final bodies = StringBuffer();

    for (final element in library.allElements) {
      for (final annotation in _fixtureForChecker.annotationsOf(element)) {
        final output = _generateForAnnotation(ConstantReader(annotation), imports);
        bodies.writeln(output);
      }
    }

    if (bodies.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('// ignore_for_file: type=lint');
    buffer.writeln();
    for (final imp in imports) {
      buffer.writeln(imp);
    }
    buffer.writeln();
    buffer.write(bodies);

    return buffer.toString();
  }

  String _generateForAnnotation(
    ConstantReader annotation,
    Set<String> imports,
  ) {
    // Read model type
    final modelTypeValue = annotation.read('modelType').typeValue;
    final element = (modelTypeValue as InterfaceType).element;
    if (element is! ClassElement || element.isAbstract) {
      throw InvalidGenerationSourceError(
        '@FixtureFor requires a concrete, non-abstract class. '
        '"${element.name}" is not a valid target.',
        element: element,
      );
    }
    final classElement = element;
    final className = classElement.name;

    // Add model import — normalize asset: URIs to package: form
    final uri = classElement.library.source.uri;
    final importUri = _normalizeUri(uri);
    imports.add("import '$importUri';");

    // Read annotation params
    final constructorName = annotation.peek('constructor')?.stringValue;
    final hasJsonOverride = annotation.peek('hasJson')?.boolValue;

    // Resolve constructor params
    final params = _constructorResolver.resolve(classElement, constructorName);
    final callPrefix = _constructorResolver.callPrefix(classElement, constructorName);

    // Build explicit fields map: paramName → FakerType
    // fields annotation is Map<Symbol, Object> but only FakerType values are supported here.
    final explicitFields = <String, FakerType>{};
    final fieldsMap = annotation.read('fields').mapValue;
    fieldsMap.forEach((keyObj, valueObj) {
      final paramName = keyObj!.toSymbolValue()!;
      final enumIndex = valueObj!.getField('index')?.toIntValue();
      if (enumIndex == null || enumIndex >= FakerType.values.length) {
        throw InvalidGenerationSourceError(
          '@FixtureFor fields map value for #$paramName must be a FakerType enum value.',
          element: classElement,
        );
      }
      explicitFields[paramName] = FakerType.values[enumIndex];
    });

    // Resolve faker expression per param
    final paramExprList = params.map((p) {
      final expr = resolveFieldExpr(
        paramName: p.name,
        dartTypeName: p.dartTypeName,
        isNullable: p.isNullable,
        isList: p.isList,
        customTypeName: p.customTypeName,
        explicitFakerType: explicitFields[p.name],
      );
      return p.isNamed ? '${p.name}: $expr' : expr;
    }).toList();
    final paramExprs = paramExprList.isEmpty
        ? ''
        : '\n      ${paramExprList.join(',\n      ')},\n    ';

    // Determine JSON strategy
    final useToJson = hasJsonOverride ?? _jsonResolver.shouldUseToJson(classElement);
    final isJsonFactory = useToJson;

    // Resolve traits
    final traitsMap = annotation.read('traits').mapValue;
    final traitMethods = StringBuffer();
    traitsMap.forEach((traitKeyObj, traitValueObj) {
      final traitName = traitKeyObj!.toStringValue()!;
      if (!RegExp(r'^[a-zA-Z_$][a-zA-Z0-9_$]*$').hasMatch(traitName)) {
        throw InvalidGenerationSourceError(
          'Trait name "$traitName" is not a valid Dart identifier.',
          element: classElement,
        );
      }
      final overrides = <String, String>{};

      traitValueObj!.toMapValue()!.forEach((paramKeyObj, paramValueObj) {
        final paramName = paramKeyObj!.toSymbolValue()!;
        final typeDisplayName = paramValueObj!.type
            ?.getDisplayString(withNullability: false) // ignore: deprecated_member_use
            ;

        if (typeDisplayName == 'FakerType') {
          final enumIndex = paramValueObj.getField('index')!.toIntValue()!;
          overrides[paramName] =
              TraitGenerator.overrideToExpr(null, FakerType.values[enumIndex]);
        } else {
          // FixtureTraitValue
          final fakerTypeField = paramValueObj.getField('fakerType');
          final fakerTypeIndex = fakerTypeField?.getField('index')?.toIntValue();
          if (fakerTypeIndex != null) {
            overrides[paramName] = TraitGenerator.overrideToExpr(
              null,
              FakerType.values[fakerTypeIndex],
            );
          } else {
            final literalObj = paramValueObj.getField('literalValue');
            final literal = literalObj?.toIntValue() ??
                literalObj?.toDoubleValue() ??
                literalObj?.toBoolValue() ??
                literalObj?.toStringValue();
            overrides[paramName] = TraitGenerator.overrideToExpr(literal, null);
          }
        }
      });

      traitMethods.writeln(_traitGen.generate(
        traitName: traitName,
        className: className,
        params: params,
        callPrefix: callPrefix,
        overrides: overrides,
        isJsonFactory: isJsonFactory,
      ));
    });

    final baseClass = isJsonFactory
        ? 'JsonFixtureFactory<$className>'
        : 'FixtureFactory<$className>';

    final definitionBody = '''
  @override
  FixtureDefinition<$className> definition() => define(
    (faker, [int index = 0]) => $callPrefix($paramExprs),
  );''';

    final jsonBody = isJsonFactory
        ? _jsonResolver.generate(
            className: className,
            useToJson: useToJson,
            paramNames: params.map((p) => p.name).toList(),
          )
        : '';

    final traitSection = traitMethods.isNotEmpty ? '\n$traitMethods' : '';

    return '''
class _\$${className}FixtureFactory extends $baseClass {
$definitionBody
${jsonBody.isNotEmpty ? '\n$jsonBody\n' : ''}$traitSection}

extension ${className}Fixture on $className {
  static _\$${className}FixtureFactory factory() => _\$${className}FixtureFactory();
}
''';
  }

  String _normalizeUri(Uri uri) {
    if (uri.scheme == 'asset') {
      // asset:pkg/lib/path/file.dart → package:pkg/path/file.dart
      final segments = uri.pathSegments;
      if (segments.length >= 3 && segments[1] == 'lib') {
        final packageName = segments[0];
        final rest = segments.sublist(2).join('/');
        return 'package:$packageName/$rest';
      }
    }
    return uri.toString();
  }
}
