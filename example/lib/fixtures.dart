import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';
import 'package:example/models/dog.dart';
import 'package:example/models/owner.dart';
import 'package:example/models/user.dart';

@FixtureFor(Dog, traits: {
  'old': {#age: FixtureTraitValue.literal(20)},
})
@FixtureFor(User, hasJson: true, traits: {
  'verified': {#isVerified: FixtureTraitValue.literal(true)},
})
@FixtureFor(Owner)
void fixtures() {}
