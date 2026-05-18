import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:example/models/dog.dart';

@FixtureFor(Dog, fields: {#name: FakerType.personFirstName})
void testFixtures() {}
