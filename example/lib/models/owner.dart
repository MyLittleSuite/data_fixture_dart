import 'package:example/models/dog.dart';
import 'package:example/models/user.dart';

class Owner {
  final int id;
  final String name;
  final User user;
  final List<Dog> dogs;

  Owner({
    required this.id,
    required this.name,
    required this.user,
    required this.dogs,
  });
}
