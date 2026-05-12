import 'dart:math';

/// Normalizes a field name: strips underscores, lowercases, removes camelCase boundaries.
String normalize(String name) {
  return name.replaceAll('_', '').toLowerCase();
}

/// Jaro-Winkler similarity between two strings. Returns 0.0..1.0.
double jaroWinkler(String s1, String s2) {
  if (s1 == s2) return 1.0;
  if (s1.isEmpty || s2.isEmpty) return 0.0;

  final matchDistance = max(s1.length, s2.length) ~/ 2 - 1;
  if (matchDistance < 0) return 0.0;

  final s1Matches = List.filled(s1.length, false);
  final s2Matches = List.filled(s2.length, false);

  var matches = 0;
  for (var i = 0; i < s1.length; i++) {
    final start = max(0, i - matchDistance);
    final end = min(s2.length, i + matchDistance + 1);
    for (var j = start; j < end; j++) {
      if (s2Matches[j] || s1[i] != s2[j]) continue;
      s1Matches[i] = true;
      s2Matches[j] = true;
      matches++;
      break;
    }
  }

  if (matches == 0) return 0.0;

  var transpositions = 0;
  var k = 0;
  for (var i = 0; i < s1.length; i++) {
    if (!s1Matches[i]) continue;
    while (!s2Matches[k]) k++;
    if (s1[i] != s2[k]) transpositions++;
    k++;
  }

  final jaro = (matches / s1.length +
          matches / s2.length +
          (matches - transpositions / 2) / matches) /
      3;

  var prefix = 0;
  for (var i = 0; i < min(4, min(s1.length, s2.length)); i++) {
    if (s1[i] != s2[i]) break;
    prefix++;
  }

  return jaro + prefix * 0.1 * (1 - jaro);
}

const double _threshold = 0.85;

/// Dictionary of normalized name patterns → faker code expressions.
const List<(String, String)> _dictionary = [
  ('firstname', 'faker.person.firstName()'),
  ('lastname', 'faker.person.lastName()'),
  ('name', 'faker.person.name()'),
  ('email', 'faker.internet.email()'),
  ('url', 'faker.internet.url()'),
  ('birthday', 'faker.date.dateTime()'),
  ('date', 'faker.date.dateTime()'),
  ('phone', 'faker.phoneNumber.us()'),
  ('city', 'faker.address.city()'),
  ('country', 'faker.address.country()'),
  ('company', 'faker.company.name()'),
  ('description', 'faker.lorem.sentence()'),
  ('title', 'faker.lorem.word()'),
];

/// Returns the best matching faker code expression for [fieldName], or null if
/// no dictionary entry scores above the threshold.
String? bestDictionaryMatch(String fieldName) {
  final normalized = normalize(fieldName);
  String? best;
  var bestScore = _threshold;

  for (final (pattern, code) in _dictionary) {
    final score = jaroWinkler(normalized, pattern);
    if (score >= bestScore) {
      bestScore = score;
      best = code;
    }
  }

  return best;
}
