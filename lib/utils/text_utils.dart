import 'package:intl/intl.dart';

String capitalizeWord(String word) {
  if (word == null || word.isEmpty) {
    return "";
  }
  if (word.length == 1) {
    return word.toUpperCase();
  }

  return word[0].toUpperCase() + word.substring(1).toLowerCase();
}

String getNumberAsSignedString(num number) => "${number > 0 ? "+" : ""}$number";

String dateToString(DateTime date) => DateFormat("yyyy-MM-dd'T'HH:mm:ss.SS").format(date);

/// Convert the given list of Strings to a String made of the comma separated elements of the list and ending with [terminator].
String getStringListAsString(List<String> strings, {String terminator = '.'}) => isEmptyOrNull(strings)
    ? ''
    : strings?.reversed?.fold('.', (String previous, elem) => ', $elem$previous')?.substring(2);

bool isEmptyOrNull(Object object) {
  if (object == null) return true;

  assert(
    object is List || object is String || object is Map,
    'Type must be either String, List or Map. Type = ${object.runtimeType} is not valid.',
  );

  if (object is List) {
    return object.isEmpty;
  }

  if (object is Map) {
    return object.isEmpty;
  }

  if (object is String) {
    return object.isEmpty;
  }

  return false;
}

final String bulletPoint = String.fromCharCode(0x2022);
