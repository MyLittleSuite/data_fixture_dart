import 'package:example/models/dog.dart';
import 'package:example/models/owner.dart';
import 'package:example/models/user.dart';
import 'package:test/test.dart';

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

  group('Owner (nested data)', () {
    test('makeSingle contains nested User', () {
      final owner = OwnerFixture.factory().makeSingle();
      expect(owner, isA<Owner>());
      expect(owner.user, isA<User>());
      expect(owner.user.name, isNotEmpty);
      expect(owner.user.email, isNotEmpty);
    });

    test('makeSingle dogs defaults to empty list', () {
      final owner = OwnerFixture.factory().makeSingle();
      expect(owner.dogs, isEmpty);
    });

    test('makeMany produces correct count with distinct ids', () {
      final owners = OwnerFixture.factory().makeMany(3);
      expect(owners.length, 3);
      expect(owners.map((o) => o.id).toList(), [0, 1, 2]);
    });

    test('each owner has independently generated nested User', () {
      final owners = OwnerFixture.factory().makeMany(2);
      // both have valid User instances
      for (final owner in owners) {
        expect(owner.user, isA<User>());
        expect(owner.user.name, isNotEmpty);
      }
    });
  });
}
