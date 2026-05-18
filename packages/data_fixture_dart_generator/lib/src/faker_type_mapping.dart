import 'package:data_fixture_dart_annotations/data_fixture_dart_annotations.dart';

const Map<FakerType, String> fakerTypeToCode = {
  FakerType.personFirstName: 'faker.person.firstName()',
  FakerType.personLastName: 'faker.person.lastName()',
  FakerType.personName: 'faker.person.name()',
  FakerType.internetEmail: 'faker.internet.email()',
  FakerType.internetUrl: 'faker.internet.url()',
  FakerType.dateDateTime: 'faker.date.dateTime()',
  FakerType.loremWord: 'faker.lorem.word()',
  FakerType.loremSentence: 'faker.lorem.sentence()',
  FakerType.randomInt: 'faker.randomGenerator.integer(100)',
  FakerType.randomDouble: 'faker.randomGenerator.decimal()',
  FakerType.addressCity: 'faker.address.city()',
  FakerType.addressCountry: 'faker.address.country()',
  FakerType.phoneNumber: 'faker.phoneNumber.us()',
  FakerType.companyName: 'faker.company.name()',
};
