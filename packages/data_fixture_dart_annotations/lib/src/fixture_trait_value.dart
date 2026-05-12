import 'faker_type.dart';

class FixtureTraitValue {
  final Object? literalValue;
  final FakerType? fakerType;

  const FixtureTraitValue.literal(this.literalValue) : fakerType = null;
  const FixtureTraitValue.faker(FakerType type)
      : fakerType = type,
        literalValue = null;

  bool get isLiteral => fakerType == null;
}
