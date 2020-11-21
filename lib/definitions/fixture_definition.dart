import 'package:data_fixture_dart/makers/fixture_maker.dart';
import 'package:faker/faker.dart';

/// This defines a fixture to generate the model.
class FixtureDefinition<Model> implements FixtureMaker<Model> {
  final Model Function(Faker) definition;
  final Faker faker = Faker();

  FixtureDefinition(this.definition) {
    assert(definition != null);
  }

  @override
  List<Model> makeMany(int number) {
    assert(number != null && number > 0);
    return List.generate(
      number,
      (_) => definition(faker),
      growable: false,
    );
  }

  @override
  Model makeSingle() => makeMany(1).first;
}
