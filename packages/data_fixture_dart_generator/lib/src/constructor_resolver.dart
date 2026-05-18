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
  final ClassElement? customClassElement; // non-null when customTypeName != null
  final ClassElement? listElementClassElement; // non-null when isList && element type is custom class

  const ResolvedParam({
    required this.name,
    required this.dartTypeName,
    required this.isNullable,
    required this.isNamed,
    required this.isList,
    this.customTypeName,
    this.customClassElement,
    this.listElementClassElement,
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
    final constructors = classElement.constructors;
    if (name != null && name.isNotEmpty) {
      for (final c in constructors) {
        if (c.name == name) return c;
      }
      throw StateError('Constructor "$name" not found on ${classElement.name}');
    }
    // Prefer unnamed constructor; fall back to first.
    for (final c in constructors) {
      if (c.name.isEmpty) return c;
    }
    return constructors.first;
  }

  ResolvedParam _resolveParam(ParameterElement p) {
    final type = p.type;
    final isNullable = type.nullabilitySuffix == NullabilitySuffix.question;
    final isList = type.isDartCoreList;

    String typeName;
    String? customType;
    ClassElement? customClassEl;
    ClassElement? listElementClassEl;

    const knownTypes = {'int', 'double', 'String', 'bool', 'DateTime', 'List', 'Map'};

    if (type is InterfaceType) {
      typeName = type.element.name;
      if (isList) {
        // Extract element type for List<T> for nested auto-gen tracking
        if (type.typeArguments.isNotEmpty) {
          final elementType = type.typeArguments.first;
          if (elementType is InterfaceType &&
              elementType.element is ClassElement &&
              elementType.element is! EnumElement &&
              !knownTypes.contains(elementType.element.name)) {
            listElementClassEl = elementType.element as ClassElement;
          }
        }
      } else if (type.element is! EnumElement && !knownTypes.contains(typeName)) {
        // Enums cannot have a FixtureFactory — leave customType null so the
        // field resolver emits a TODO placeholder instead of makeSingle().
        customType = typeName;
        customClassEl = type.element is ClassElement ? type.element as ClassElement : null;
      }
    } else {
      // ignore: deprecated_member_use
      typeName = type.getDisplayString(withNullability: false);
    }

    return ResolvedParam(
      name: p.name,
      dartTypeName: typeName,
      isNullable: isNullable,
      isNamed: p.isNamed,
      isList: isList,
      customTypeName: customType,
      customClassElement: customClassEl,
      listElementClassElement: listElementClassEl,
    );
  }
}
