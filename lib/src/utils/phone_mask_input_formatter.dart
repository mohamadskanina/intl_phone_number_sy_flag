import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:string_mask/string_mask.dart';

/*
*   Credits
*   https://github.com/DomingosGustavo/flutter_Text_Input_formatter
*   https://github.com/sebdeveloper6952/FlutterMaskedTextInputFormatter
* **/
class PhoneMaskInputFormatter extends TextInputFormatter {
  final String mask;
  final String escapeChar;
  final RegExp regExp = RegExp(r'[^\d]+');

  Map<int, String> _separatorMap;

  PhoneMaskInputFormatter({@required this.mask, this.escapeChar = r'[\d]+'}) {
    assert(mask != null || mask.isNotEmpty);

    final entries = regExp
        .allMatches(mask)
        .map((match) => MapEntry(match.start, match.group(0)));

    _separatorMap = Map.fromEntries(entries);
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    int oldValueLength = oldValue.text.length;
    int newValueLength = newValue.text.length;

    final StringBuffer newText = StringBuffer();
    if (newValueLength > 0 && newValueLength > oldValueLength) {
      bool shouldSeparate = mask[newValueLength - 1].contains(regExp);
      if (newValueLength > mask.length) {
        newText.write(oldValue.text);
        return oldValue.copyWith(
          text: newText.toString(),
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
      if (newValueLength < mask.length && shouldSeparate) {
        String separator = _separatorMap[newValueLength - 1];

        newText.write(oldValue.text +
            separator +
            newValue.text.substring(newValueLength - 1));

        return newValue.copyWith(
          text: newText.toString(),
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }

    return newValue;
  }

  TextEditingValue applyMask(TextEditingValue value) {
    final StringBuffer newText = StringBuffer();
    String newMask = mask.replaceAll(RegExp(r'[\d]'), '#');
    print(mask);
    print(newMask);
    var stringMask = StringMask(newMask);

    String newValue = stringMask.apply(value?.text);

    newText.write(newValue);
    return value.copyWith(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
