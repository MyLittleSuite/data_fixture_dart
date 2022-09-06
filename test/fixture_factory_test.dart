import 'package:data_fixture_dart/data_fixture_dart.dart';
import 'package:test/test.dart';

import 'models/company.dart';
import 'models/dog.dart';
import 'models/person.dart';

void main() {
  final faker = Faker();
  final String expectedString1 = faker.lorem.word();
  final String expectedString2 = faker.lorem.word();
  final DateTime expectedDate1 = faker.date.dateTime();

  test('make one object', () {
    final dog = DogFixture.factory().makeSingle();

    expect(dog.name, isNotNull);
    expect(dog.name.isEmpty, isFalse);
    expect(dog.age, isNotNull);
    expect(dog.age, greaterThan(0));
  });

  test('make one object with redefinition', () {
    final dog = DogFixture.factory().old().makeSingle();

    expect(dog.name, isNotNull);
    expect(dog.name.isEmpty, isFalse);
    expect(dog.age, isNotNull);
    expect(dog.age, equals(20));
  });

  test('make one json object', () {
    final result = PersonFixture.factory().makeJsonObject();

    ["firstName", "lastName", "dogs", "birthday"].forEach((element) {
      expect(result[element], isNotNull);
    });
  });

  test('make one json object with redefinition', () {
    final result = PersonFixture.factory()
        .withFields(firstName: expectedString1, lastName: expectedString2)
        .makeJsonObject();

    expect(result["firstName"], equals(expectedString1));
    expect(result["lastName"], equals(expectedString2));
    expect(result["birthday"], isNull);
  });

  test('make one object with associated json object with redefinition', () {
    final result = PersonFixture.factory()
        .withFields(firstName: expectedString2, lastName: expectedString1)
        .makeSingleWithJsonObject();

    expect(result.object.firstName, equals(expectedString2));
    expect(result.object.lastName, equals(expectedString1));
    expect(result.object.birthday, isNull);

    expect(result.json["firstName"], equals(expectedString2));
    expect(result.json["lastName"], equals(expectedString1));
    expect(result.json["birthday"], isNull);
  });

  test('make many objects', () {
    final results = PersonFixture.factory().makeMany(3);

    expect(results.length, equals(3));
  });

  test('make many objects with redefinition', () {
    final results = PersonFixture.factory()
        .withFields(
          firstName: expectedString1,
          lastName: expectedString2,
          birthday: expectedDate1,
        )
        .makeMany(3);

    expect(results.length, equals(3));
    results.forEach((result) {
      expect(result.firstName, equals(expectedString1));
      expect(result.lastName, equals(expectedString2));
      expect(result.birthday, equals(expectedDate1));
    });
  });

  test('make one object with associated json object', () {
    final result = DogFixture.factory().makeSingleWithJsonObject();

    expect(result.json["name"], equals(result.object.name));
    expect(result.json["age"], equals(result.object.age));
  });

  test('make one json array', () {
    final results = PersonFixture.factory().makeJsonArray(3);

    expect(results.length, equals(3));
    results.forEach((result) {
      ["firstName", "lastName", "dogs", "birthday"].forEach((key) {
        expect(result[key], isNotNull);
      });
    });
  });

  test('make one json array with redefinition', () {
    final results = PersonFixture.factory()
        .withFields(
          firstName: expectedString1,
          lastName: expectedString2,
          birthday: expectedDate1,
        )
        .makeJsonArray(3);

    expect(results.length, equals(3));
    results.forEach((result) {
      expect(result["firstName"], equals(expectedString1));
      expect(result["lastName"], equals(expectedString2));
      expect(result["birthday"], equals(expectedDate1.toIso8601String()));
    });
  });

  test('make many objects with associated json array', () {
    final results = DogFixture.factory().old().makeManyWithJsonArray(3);

    expect(results.length, equals(3));
    results.forEach((result) {
      expect(result.json["name"], equals(result.object.name));
      expect(result.json["age"], equals(result.object.age));
    });
  });

  test('make many objects with associated json array with redefinition', () {
    final results = PersonFixture.factory()
        .withFields(
            firstName: expectedString1,
            lastName: expectedString2,
            birthday: expectedDate1)
        .makeManyWithJsonArray(3);

    expect(results.length, equals(3));
    results.forEach((result) {
      expect(result.object.firstName, equals(expectedString1));
      expect(result.object.lastName, equals(expectedString2));
      expect(result.object.birthday, equals(expectedDate1));

      expect(result.json["firstName"], equals(expectedString1));
      expect(result.json["lastName"], equals(expectedString2));
      expect(result.json["birthday"], equals(expectedDate1.toIso8601String()));
    });
  });

  test('make objects from json', () {
    final companies = CompanyFixture.factory().makeMany(3);
    final results = CompanyFixture.factory().makeJsonArrayFromMany(companies);

    expect(results.length, companies.length);
    results.asMap().forEach((index, result) {
      final company = companies[index];

      expect(result["name"], equals(company.name));

      final employeesResult = result["employees"] as List<Map<String, dynamic>>;
      employeesResult.asMap().forEach((index, result) {
        final employee = company.employees[index];

        expect(result["firstName"], equals(employee.firstName));
        expect(result["lastName"], equals(employee.lastName));
      });
    });
  });

  test('make object from json', () {
    final dog = DogFixture.factory().makeSingle();
    final result = DogFixture.factory().makeJsonObjectFromSingle(dog);

    expect(result["name"], equals(dog.name));
    expect(result["age"], equals(dog.age));
  });
}
