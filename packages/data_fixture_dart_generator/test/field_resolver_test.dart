import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:data_fixture_dart_generator/src/faker_type_mapping.dart';
import 'package:data_fixture_dart_generator/src/field_resolver.dart';
import 'package:test/test.dart';

void main() {
  group('fakerTypeToCode', () {
    test('covers all FakerType values', () {
      for (final type in FakerType.values) {
        expect(
          fakerTypeToCode[type],
          isNotNull,
          reason: 'Missing mapping for FakerType.$type',
        );
      }
    });
  });

  group('resolveFieldExpr', () {
    test('layer 3: explicit fields map wins over everything', () {
      expect(
        resolveFieldExpr(
          paramName: 'name',
          dartTypeName: 'String',
          isNullable: false,
          isList: false,
          customTypeName: null,
          explicitFakerType: FakerType.loremSentence,
        ),
        'faker.lorem.sentence()',
      );
    });

    test('layer 2: similarity match for email', () {
      expect(
        resolveFieldExpr(
          paramName: 'email',
          dartTypeName: 'String',
          isNullable: false,
          isList: false,
          customTypeName: null,
          explicitFakerType: null,
        ),
        'faker.internet.email()',
      );
    });

    test('layer 2: similarity match for firstName', () {
      expect(
        resolveFieldExpr(
          paramName: 'firstName',
          dartTypeName: 'String',
          isNullable: false,
          isList: false,
          customTypeName: null,
          explicitFakerType: null,
        ),
        'faker.person.firstName()',
      );
    });

    test('layer 1: String fallback for unmatched name', () {
      expect(
        resolveFieldExpr(
          paramName: 'xyzUnknown',
          dartTypeName: 'String',
          isNullable: false,
          isList: false,
          customTypeName: null,
          explicitFakerType: null,
        ),
        'faker.lorem.word()',
      );
    });

    test('layer 1: int fallback', () {
      expect(
        resolveFieldExpr(
          paramName: 'numItems',
          dartTypeName: 'int',
          isNullable: false,
          isList: false,
          customTypeName: null,
          explicitFakerType: null,
        ),
        'faker.randomGenerator.integer(100)',
      );
    });

    test('layer 1: nullable → null', () {
      expect(
        resolveFieldExpr(
          paramName: 'birthday',
          dartTypeName: 'DateTime',
          isNullable: true,
          isList: false,
          customTypeName: null,
          explicitFakerType: null,
        ),
        'null',
      );
    });

    test('layer 3: explicit FakerType wins over nullable', () {
      expect(
        resolveFieldExpr(
          paramName: 'nickname',
          dartTypeName: 'String',
          isNullable: true,
          isList: false,
          customTypeName: null,
          explicitFakerType: FakerType.personFirstName,
        ),
        'faker.person.firstName()',
      );
    });

    test('id int → index convention', () {
      expect(
        resolveFieldExpr(
          paramName: 'id',
          dartTypeName: 'int',
          isNullable: false,
          isList: false,
          customTypeName: null,
          explicitFakerType: null,
        ),
        'index',
      );
    });

    test('List<T> → []', () {
      expect(
        resolveFieldExpr(
          paramName: 'items',
          dartTypeName: 'List',
          isNullable: false,
          isList: true,
          customTypeName: null,
          explicitFakerType: null,
        ),
        '[]',
      );
    });

    test('custom type → factory call', () {
      expect(
        resolveFieldExpr(
          paramName: 'owner',
          dartTypeName: 'Owner',
          isNullable: false,
          isList: false,
          customTypeName: 'Owner',
          explicitFakerType: null,
        ),
        'OwnerFixture.factory().makeSingle()',
      );
    });
  });
}
