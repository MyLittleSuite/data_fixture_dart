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

  group('FixtureGenerator - nested auto-generation', () {
    test('auto-generates base factory for nested custom type', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/engine.dart': '''
class Engine {
  final int horsepower;
  Engine({required this.horsepower});
}
''',
          'a|lib/car.dart': '''
import 'package:a/engine.dart';
class Car {
  final int id;
  final Engine engine;
  Car({required this.id, required this.engine});
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/car.dart';

@FixtureFor(Car)
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(allOf(
            contains('_\$CarFixtureFactory extends FixtureFactory<Car>'),
            contains('engine: EngineFixture.factory().makeSingle()'),
            contains('_\$EngineFixtureFactory extends FixtureFactory<Engine>'),
            contains('extension EngineFixture on Engine'),
          )),
        },
      );
    });

    test('auto-generates base factory for List<CustomType> element', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/wheel.dart': '''
class Wheel {
  final String brand;
  Wheel({required this.brand});
}
''',
          'a|lib/car.dart': '''
import 'package:a/wheel.dart';
class Car {
  final int id;
  final List<Wheel> wheels;
  Car({required this.id, required this.wheels});
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/car.dart';

@FixtureFor(Car)
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(allOf(
            contains('_\$CarFixtureFactory extends FixtureFactory<Car>'),
            contains('_\$WheelFixtureFactory extends FixtureFactory<Wheel>'),
            contains('extension WheelFixture on Wheel'),
          )),
        },
      );
    });

    test('hasJson propagates to nested type with toJson()', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/engine.dart': '''
class Engine {
  final int horsepower;
  Engine({required this.horsepower});
  Map<String, dynamic> toJson() => {'horsepower': horsepower};
}
''',
          'a|lib/car.dart': '''
import 'package:a/engine.dart';
class Car {
  final int id;
  final Engine engine;
  Car({required this.id, required this.engine});
  Map<String, dynamic> toJson() => {'id': id, 'engine': engine.toJson()};
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/car.dart';

@FixtureFor(Car, hasJson: true)
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(allOf(
            contains('_\$CarFixtureFactory extends JsonFixtureFactory<Car>'),
            contains('_\$EngineFixtureFactory extends JsonFixtureFactory<Engine>'),
            contains('engine.toJson()'),
          )),
        },
      );
    });

    test('hasJson does not make nested JsonFixtureFactory when nested has no toJson()', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/engine.dart': '''
class Engine {
  final int horsepower;
  Engine({required this.horsepower});
}
''',
          'a|lib/car.dart': '''
import 'package:a/engine.dart';
class Car {
  final int id;
  final Engine engine;
  Car({required this.id, required this.engine});
  Map<String, dynamic> toJson() => {'id': id};
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/car.dart';

@FixtureFor(Car, hasJson: true)
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(allOf(
            contains('_\$CarFixtureFactory extends JsonFixtureFactory<Car>'),
            contains('_\$EngineFixtureFactory extends FixtureFactory<Engine>'),
          )),
        },
      );
    });

    test('explicit @FixtureFor for nested type wins over auto-gen', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/engine.dart': '''
class Engine {
  final int horsepower;
  Engine({required this.horsepower});
}
''',
          'a|lib/car.dart': '''
import 'package:a/engine.dart';
class Car {
  final int id;
  final Engine engine;
  Car({required this.id, required this.engine});
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/car.dart';
import 'package:a/engine.dart';

@FixtureFor(Car)
@FixtureFor(Engine)
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(
            // Engine factory appears exactly once (from explicit @FixtureFor, not duplicated)
            isNot(contains('class _\$EngineFixtureFactory extends FixtureFactory<Engine> {\n'
                '  @override\n'
                '  FixtureDefinition<Engine> definition()'
                '\n'
                'class _\$EngineFixtureFactory')),
          ),
        },
      );
    });

    test('auto-gen recurses through multiple levels', () async {
      await testBuilder(
        fixtureGeneratorBuilder(BuilderOptions.empty),
        {
          'a|lib/spark_plug.dart': '''
class SparkPlug {
  final String brand;
  SparkPlug({required this.brand});
}
''',
          'a|lib/engine.dart': '''
import 'package:a/spark_plug.dart';
class Engine {
  final int horsepower;
  final SparkPlug plug;
  Engine({required this.horsepower, required this.plug});
}
''',
          'a|lib/car.dart': '''
import 'package:a/engine.dart';
class Car {
  final int id;
  final Engine engine;
  Car({required this.id, required this.engine});
}
''',
          'a|test/fixtures.dart': '''
import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:a/car.dart';

@FixtureFor(Car)
void fixtures() {}
''',
        },
        readerWriter: await _makeReader(),
        outputs: {
          'a|test/fixtures.fixture.dart': decodedMatches(allOf(
            contains('_\$CarFixtureFactory'),
            contains('_\$EngineFixtureFactory'),
            contains('_\$SparkPlugFixtureFactory'),
            contains('extension SparkPlugFixture on SparkPlug'),
          )),
        },
      );
    });
  });

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
