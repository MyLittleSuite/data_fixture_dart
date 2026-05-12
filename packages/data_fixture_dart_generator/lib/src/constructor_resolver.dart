import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

class ResolvedParam {
  final String name;
  final String dartTypeName;
  final bool isNullable;
  final bool isNamed;
  final bool isList;
  final String? customTypeName; // non-null when type is an unknown class

  const ResolvedParam({
    required this.name,
    required this.dartTypeName,
    required this.isNullable,
    required this.isNamed,
    required this.isList,
    this.customTypeName,
  });
}

/// Finds the target constructor and extracts its parameters as [ResolvedParam]s.
class ConstructorResolver {
  /// [constructorName] is null → unnamed constructor, '' → also unnamed.
  List<ResolvedParam> resolve(ClassElement classElement, String? constructorName) {
    final constructor = _findConstructor(classElement, constructorName);
    return constructor.parameters.map(_resolveParam).toList();
  }

  /// Returns the call prefix: e.g. `Dog` or `Dog.fromData`.
  String callPrefix(ClassElement classElement, String? constructorName) {
    final name = constructorName?.isNotEmpty == true ? constructorName! : null;
    return name != null ? '${classElement.name}.$name' : classElement.name;
  }

  ConstructorElement _findConstructor(ClassElement classElement, String? name) {
    if (name != null && name.isNotEmpty) {
      return classElement.constructors.firstWhere(
        (c) => c.name == name,
        orElse: () => throw StateError(
          'Constructor "$name" not found on ${classElement.name}',
        ),
      );
    }
    return classElement.constructors.firstWhere(
      (c) => c.name.isEmpty,
      orElse: () => classElement.constructors.first,
    );
  }

  ResolvedParam _resolveParam(ParameterElement p) {
    final type = p.type;
    final isNullable = type.nullabilitySuffix == NullabilitySuffix.question;
    final isList = type.isDartCoreList;

    // Extract base type name
    String typeName;
    String? customType;

    if (type is InterfaceType) {
      typeName = type.element.name;
      final knownTypes = {'int', 'double', 'String', 'bool', 'DateTime', 'List', 'Map'};
      if (!knownTypes.contains(typeName)) {
        customType = typeName;
      }
    } else {
      typeName = type.getDisplayString();
    }

    return ResolvedParam(
      name: p.name,
      dartTypeName: typeName,
      isNullable: isNullable,
      isNamed: p.isNamed,
      isList: isList,
      customTypeName: customType,
    );
  }
}
