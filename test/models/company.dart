import 'package:data_fixture_dart/data_fixture_dart.dart';

import 'person.dart';

class Company {
  final String name;
  final List<Person> employees;

  Company({this.name, this.employees});
}

extension CompanyFixture on Company {
  static _CompanyFixtureFactory factory() => _CompanyFixtureFactory();
}

class _CompanyFixtureFactory extends JsonFixtureFactory<Company> {
  @override
  FixtureDefinition<Company> definition() => define(
        (faker) => Company(
          name: faker.company.name(),
          employees: PersonFixture.factory().makeMany(5),
        ),
      );

  FixtureDefinition<Company> empty() => redefine(
        (company) => Company(
          name: company.name,
          employees: [],
        ),
      );

  @override
  JsonFixtureDefinition<Company> jsonDefinition() => defineJson(
        jsonDefinition: (company) => {
          "name": company.name,
          "employees":
              PersonFixture.factory().makeJsonArrayFromMany(company.employees),
        },
      );
}
