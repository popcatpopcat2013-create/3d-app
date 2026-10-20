/// 12345 -> "12,345"
String formatCount(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
}

/// 5 Mar 2024 14:07 -> "05/03/2024  14:07"
String formatDateTime(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year}  '
      '${two(value.hour)}:${two(value.minute)}';
}
