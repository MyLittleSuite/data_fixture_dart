import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:data_fixture_dart_generator/builder.dart';
import 'package:test/test.dart';

/// Creates a [TestReaderWriter] pre-loaded with all real isolate sources.
/// Each test gets a fresh one to avoid asset cross-contamination.
Future<TestReaderWriter> _makeReader() async {
  final rw = TestReaderWriter(rootPackage: 'a');
  await rw.testing.loadIsolateSources();
  return rw;
}

void main() {

  group('FixtureGenerator', () {
    test('generates FixtureFactory for plain model', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/dog.dart': '''
class Dog {
  final int id;
  final String name;
  final int age;
  Dog({required this.id, required this.name, required this.age});
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/dog.dart';

@FixtureFor(Dog)
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(allOf(
            contains('_\$DogFixtureFactory extends FixtureFactory<Dog>'),
            contains('extension DogFixture on Dog'),
          )),
        },
      );
    });

    test('id int field uses index convention', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/dog.dart': '''
class Dog {
  final int id;
  final String name;
  Dog({required this.id, required this.name});
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/dog.dart';

@FixtureFor(Dog)
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(contains('id: index')),
        },
      );
    });

    test('explicit fields override wins', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/dog.dart': '''
class Dog {
  final String name;
  Dog({required this.name});
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/dog.dart';

@FixtureFor(Dog, fields: {#name: FakerType.loremSentence})
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(contains('faker.lorem.sentence()')),
        },
      );
    });

    test('named constructor', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/dog.dart': '''
class Dog {
  final String name;
  Dog.fromData({required this.name});
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/dog.dart';

@FixtureFor(Dog, constructor: 'fromData')
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(contains('Dog.fromData(')),
        },
      );
    });

    test('hasJson: true generates JsonFixtureFactory with toJson', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/dog.dart': '''
class Dog {
  final String name;
  Dog({required this.name});
  Map<String, dynamic> toJson() => {'name': name};
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/dog.dart';

@FixtureFor(Dog, hasJson: true)
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(allOf(
            contains('JsonFixtureFactory<Dog>'),
            contains('dog.toJson()'),
          )),
        },
      );
    });

    test('trait generates named method', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/dog.dart': '''
class Dog {
  final int age;
  Dog({required this.age});
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/dog.dart';

@FixtureFor(Dog, traits: {
  'old': {#age: FixtureTraitValue.literal(20)},
})
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(allOf(
            contains('FixtureDefinition<Dog> old()'),
            contains('age: 20'),
          )),
        },
      );
    });

    test('positional constructor params', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/point.dart': '''
class Point {
  final int x;
  final int y;
  Point(this.x, this.y);
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/point.dart';

@FixtureFor(Point)
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(allOf(
            contains('_\$PointFixtureFactory extends FixtureFactory<Point>'),
            contains('extension PointFixture on Point'),
          )),
        },
      );
    });
  });
}
