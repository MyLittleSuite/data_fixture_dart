import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/fixture_generator.dart';

Builder fixtureGeneratorBuilder(BuilderOptions options) =>
    LibraryBuilder(FixtureGenerator(), generatedExtension: '.fixture.dart');
