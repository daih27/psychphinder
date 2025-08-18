import 'package:diacritic/diacritic.dart';
import 'package:number_to_words_english/number_to_words_english.dart';

class TextPreprocessing {
  static String preprocessForSearch(String text) {
    String processed = removeDiacritics(text).toLowerCase();
    processed = _replaceContractionsAndVariants(processed);
    processed = _replaceNumbersWithWords(processed);
    processed = processed.replaceAll("&", "and");
    processed = processed.replaceAll(RegExp('[^A-Za-z0-9 ]'), ' ');
    processed = processed.replaceAll(RegExp(r'\s+'), ' ').trim();
    return processed;
  }

  static String _replaceContractionsAndVariants(String input) {
    input = input.replaceAll('c\'mon', 'cmon');
    input = input.replaceAll(RegExp(r"\b(\w+)'s\b"), r'$1 is');
    input = input.replaceAll(RegExp(r"\bI'm\b"), 'I am');
    input = input.replaceAll(RegExp(r"\b(\w+)'re\b"), r'$1 are');
    input = input.replaceAll(RegExp(r"\b(\w+)'ll\b"), r'$1 will');
    input = input.replaceAll(RegExp(r"\b(\w+)n't\b"), r'$1 not');
    input = input.replaceAll(RegExp(r"\b(\w+)'d\b"), r'$1 would');
    input = input.replaceAll(RegExp(r"\b(\w+)'ve\b"), r'$1 have');

    return input;
  }

  static String _replaceNumbersWithWords(String input) {
    RegExp regExp = RegExp(r'\d+');
    Iterable<Match> matches = regExp.allMatches(input);
    for (Match match in matches) {
      int number = int.parse(match.group(0)!);
      String word = NumberToWordsEnglish.convert(number);
      input = "$input $word";
    }
    return input;
  }

  static String escapeFts5Query(String query) {
    String escaped = query;
    escaped = escaped.replaceAll('"', '""');
    if (escaped.contains("'") ||
        escaped.contains("(") ||
        escaped.contains(")") ||
        escaped.contains("*") ||
        escaped.contains("-") ||
        escaped.contains("+") ||
        escaped.contains("^") ||
        escaped.contains("~")) {
      escaped = '"$escaped"';
    }
    return escaped;
  }
}
