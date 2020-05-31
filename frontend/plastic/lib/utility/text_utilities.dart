enum TextChangeType { Added, Removed, Substituted }

class TextChangeDetails {
  final TextChangeType type;
  final String difference;

  TextChangeDetails({this.type, this.difference});
}

/// Returns details about what text was changed in a string.
TextChangeDetails getTextChangeDetails(String a, String b) {
  String difference = '';
  TextChangeType type;
  if (a.length > b.length) {
    type = TextChangeType.Removed;
  } else if (a.length < b.length) {
    type = TextChangeType.Added;
  } else {
    type = TextChangeType.Substituted;
  }
  if (a.length > b.length)
    for (var i = 0; i < a.length; i++) {
      if (i >= b.length) {
        difference = a.substring(i);
        break;
      }
      if (a[i] != b[i]) {
        difference += b[i];
      } else {
        if (difference.length != 0) {
          break;
        }
      }
    }
  else
    for (var i = 0; i < b.length; i++) {
      if (i >= a.length) {
        difference = b.substring(i);
        break;
      }
      if (a[i] != b[i]) {
        difference += a[i];
      } else {
        if (difference.length != 0) {
          break;
        }
      }
    }
  return TextChangeDetails(type: type, difference: difference);
}
