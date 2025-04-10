import 'package:data_fixture_dart/data_fixture_dart.dart';

import 'person.dart' as model;

class Company {
  final int id;
  final String name;
  final List<model.Person> employees;

  Company({
    required this.id,
    required this.name,
    required this.employees,
  });
}

extension CompanyFixture on Company {
  static _CompanyFixtureFactory factory() => _CompanyFixtureFactory();
}

class _CompanyFixtureFactory extends JsonFixtureFactory<Company> {
  @override
  FixtureDefinition<Company> definition() => define(
        (faker, [int i = 0]) => Company(
          id: i,
          name: faker.company.name(),
          employees: model.PersonFixture.factory().makeMany(5),
        ),
      );

  FixtureDefinition<Company> empty() => redefine(
        (company, [int i = 0]) => Company(
          id: i,
          name: company.name,
          employees: [],
        ),
      );

  @override
  JsonFixtureDefinition<Company> jsonDefinition() => defineJson(
        (company, [int i = 0]) => {
          "id": i,
          "name": company.name,
          "employees": model.PersonFixture.factory()
              .makeJsonArrayFromMany(company.employees),
        },
      );
}
