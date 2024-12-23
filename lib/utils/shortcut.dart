const _speechShortcut = {
  "verb": "v.",
  "noun": "n.",
  "adjective": "adj.",
  "adverb": "adv.",
  "pronoun": "pron.",
  "preposition": "prep.",
  "conjunction": "conj.",
  "interjection": "int."
};

const kAppBarPadding = 10.0;
const kMaxAcquaintance = 5;
const kRemindLength = 7;
const kMenuDividerHeight = 8.0;

String speechShortcut(String partOfSpeech, {int length = 0}) {
  final shortcut =
      _speechShortcut[partOfSpeech] ?? '${partOfSpeech.substring(0, 3)}.';
  return shortcut.length < length
      ? ' ' * (length - shortcut.length) + shortcut
      : shortcut;
}
