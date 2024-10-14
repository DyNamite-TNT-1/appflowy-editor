import '../menu/menu.dart';

const String punctuation =
    '\\.,\\+\\*\\?\\\$\\@\\|#{}\\(\\)\\^\\-\\[\\]\\\\/!%\'"~=<>_:;';

const String name = "r'\\b[A-Z][^\\s$punctuation]'";

const Map<String, String> documentMentionsRegex = {
  'name': name,
  'punctuation': punctuation,
};

final String punc = documentMentionsRegex['punctuation']!;

final String triggers = ['@'].join('');

// Chars we expect to see in a mention (non-space, non-punctuation).
final String validChars = '[^$triggers$punc\\s]';

final String validJoins = '(?:\\.[ |\$]| |[$punc]|)';

const int lengthLimit = 75;

final RegExp atSignMentionsRegex = RegExp(
  '(^|\\s|\\()([$triggers]((?:$validChars$validJoins){0,$lengthLimit}))\$',
);

// 50 is the longest alias length limit.
const int aliasLengthLimit = 50;

final RegExp atSignMentionsRegexAliasRegex = RegExp(
  '(^|\\s|\\()([$triggers]((?:$validChars){0,$aliasLengthLimit}))\$',
);

MenuTextMatch? checkForAtSignCommands(String text, int minMatchLength) {
  final match = atSignMentionsRegex.firstMatch(text) ??
      atSignMentionsRegexAliasRegex.firstMatch(text);

  if (match != null) {
    final maybeLeadingWhitespace = match.group(1) ?? '';
    final matchingString = match.group(3) ?? '';

    if (matchingString.length >= minMatchLength) {
      return MenuTextMatch(
        match.start + maybeLeadingWhitespace.length,
        matchingString,
        match.group(2) ?? '',
      );
    }
  }
  return null;
}
