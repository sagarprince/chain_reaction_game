const int _ASCII_END = 0x7f;

const int _DIGIT = 0x1;

const int _LOWER = 0x2;

const int _UNDERSCORE = 0x4;

const int _UPPER = 0x8;

const int _ALPHA = _LOWER | _UPPER;

const int _ALPHA_NUM = _ALPHA | _DIGIT;

final List<int> _ascii = <int>[
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  0,
  0,
  0,
  0,
  4,
  0,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  0,
  0,
  0,
  0,
  0
];

String camelize(String string, [bool lower = false]) {
  if (string == null) {
    throw ArgumentError("string: $string");
  }

  if (string.isEmpty) {
    return string;
  }

  string = string.toLowerCase();
  var capitilize = true;
  var length = string.length;
  var position = 0;
  var remove = false;
  var sb = StringBuffer();
  for (var i = 0; i < length; i++) {
    var s = string[i];
    var c = s.codeUnitAt(0);
    var flag = 0;
    if (c <= _ASCII_END) {
      flag = _ascii[c];
    }

    if (capitilize && flag & _ALPHA != 0) {
      if (lower && position == 0) {
        sb.write(s);
      } else {
        sb.write(s.toUpperCase());
      }

      capitilize = false;
      remove = true;
      position++;
    } else {
      if (flag & _UNDERSCORE != 0) {
        if (!remove) {
          sb.write(s);
          remove = true;
        }

        capitilize = true;
      } else {
        if (flag & _ALPHA_NUM != 0) {
          capitilize = false;
          remove = true;
        } else {
          capitilize = true;
          remove = false;
          position = 0;
        }

        sb.write(s);
      }
    }
  }

  return sb.toString();
}
