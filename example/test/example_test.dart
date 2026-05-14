import 'package:example/models/dog.dart';
import 'package:example/models/user.dart';
import 'package:test/test.dart';

import 'fixtures.fixture.dart' hide DogFixture;
import '../lib/fixtures.fixture.dart';

void main() {
  group('Dog', () {
    test('makeSingle', () {
      final dog = DogFixture.factory().makeSingle();
      expect(dog, isA<Dog>());
    });

    test('makeMany', () {
      final dogs = DogFixture.factory().makeMany(3);
      expect(dogs.length, 3);
    });

    test('old trait sets age to 20', () {
      final dog = DogFixture.factory().old().makeSingle();
      expect(dog.age, 20);
    });
  });

  group('User', () {
    test('makeSingle', () {
      final user = UserFixture.factory().makeSingle();
      expect(user, isA<User>());
    });

    test('makeJsonObject', () {
      final json = UserFixture.factory().makeJsonObject();
      expect(json, isA<Map<String, dynamic>>());
      expect(json.containsKey('name'), isTrue);
    });

    test('verified trait sets isVerified to true', () {
      final tuple = UserFixture.factory().verified().makeSingleWithJsonObject();
      expect(tuple.object.isVerified, isTrue);
      expect(tuple.json['isVerified'], isTrue);
    });
  });
}
