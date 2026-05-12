import 'package:data_fixture_dart_generator/src/similarity.dart';
import 'package:test/test.dart';

void main() {
  group('normalize', () {
    test('camelCase → lowercase', () => expect(normalize('firstName'), 'firstname'));
    test('snake_case → lowercase no underscore', () => expect(normalize('first_name'), 'firstname'));
    test('already lowercase', () => expect(normalize('email'), 'email'));
  });

  group('jaroWinkler', () {
    test('identical strings score 1.0', () => expect(jaroWinkler('email', 'email'), 1.0));
    test('empty strings score 0.0', () => expect(jaroWinkler('', 'email'), 0.0));
    test('firstname vs firstname above threshold',
        () => expect(jaroWinkler('firstname', 'firstname'), greaterThanOrEqualTo(0.85)));
    test('fn vs firstname below threshold',
        () => expect(jaroWinkler('fn', 'firstname'), lessThan(0.85)));
    test('bday vs birthday below threshold',
        () => expect(jaroWinkler('bday', 'birthday'), lessThan(0.85)));
    test('surname vs lastname below threshold',
        () => expect(jaroWinkler('surname', 'lastname'), lessThan(0.85)));
  });

  group('bestDictionaryMatch', () {
    test('firstName → personFirstName code', () {
      final result = bestDictionaryMatch('firstName');
      expect(result, 'faker.person.firstName()');
    });
    test('email → internetEmail code', () {
      final result = bestDictionaryMatch('email');
      expect(result, 'faker.internet.email()');
    });
    test('unknownXyz → null (below threshold)', () {
      final result = bestDictionaryMatch('unknownXyz');
      expect(result, isNull);
    });
    // 'userEmail' normalizes to 'useremail' which scores ~0.44 against 'email'
    // (Jaro-Winkler penalizes the extra prefix heavily), so no match is expected.
    test('userEmail → null (useremail too different from email)', () {
      final result = bestDictionaryMatch('userEmail');
      expect(result, isNull);
    });
  });
}
