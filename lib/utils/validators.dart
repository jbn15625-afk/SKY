final _anyScheme = RegExp(r'^[a-z][a-z\d+.-]*:', caseSensitive: false);
final _httpScheme = RegExp(r'^https?://', caseSensitive: false);

/// يطبّع الرابط بنفس منطق موقع الويب، ويرمي [FormatException] برسالة عربية
/// عندما يكون الرابط غير صحيح.
String normalizeUrl(String value, String label, {bool required = false}) {
  final text = value.trim();
  if (text.isEmpty) {
    if (required) throw FormatException('أدخل رابط $label.');
    return '';
  }

  if (_anyScheme.hasMatch(text) && !_httpScheme.hasMatch(text)) {
    throw FormatException('رابط $label غير صحيح.');
  }

  final normalized = _httpScheme.hasMatch(text)
      ? text
      : text.startsWith('//')
          ? 'https:$text'
          : 'https://$text';

  final uri = Uri.tryParse(normalized);
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    throw FormatException('رابط $label غير صحيح.');
  }
  return uri.toString();
}

/// دالة تحقق جاهزة لحقول الروابط في النماذج.
String? urlValidator(String? value, String label, {bool required = false}) {
  try {
    normalizeUrl(value ?? '', label, required: required);
    return null;
  } on FormatException catch (error) {
    return error.message;
  }
}

/// عدد صحيح اختياري ضمن [min, max]. الحقل الفارغ يعني 0.
String? optionalIntValidator(
  String? value,
  String label, {
  int min = 0,
  int? max,
}) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return null;
  final number = int.tryParse(text);
  if (number == null || number < min || (max != null && number > max)) {
    return 'تحقق من قيمة $label.';
  }
  return null;
}

int parseOptionalInt(String? value) => int.tryParse((value ?? '').trim()) ?? 0;
