/// Utility functions for formatting FCM topic names
class TopicFormatter {
  /// Format topic name for FCM compatibility
  /// Replaces Turkish characters and spaces to make them compatible with FCM topic naming rules
  static String formatTopicName(String topic) {
    return topic
        .replaceAll(' ', '_')
        .replaceAll('İ', 'I')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ğ', 'g')
        .replaceAll('ş', 's')
        .replaceAll('ç', 'c')
        .replaceAll('Ö', 'O')
        .replaceAll('Ü', 'U')
        .replaceAll('Ğ', 'G')
        .replaceAll('Ş', 'S')
        .replaceAll('Ç', 'C');
  }
}