class DateText {
  static String convertISOToString(String iso) {
    if (iso.isEmpty) return "";
    final DateTime _UTC = DateTime.parse(iso);
    final String _text = "${_UTC.year}년 ${_UTC.month}월 ${_UTC.day}일";
    return _text;
  }
}