class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://servlink-production.up.railway.app',
  );

  static String normalizeApiBaseUrl(String input) {
    var value = input.trim();
    if (value.isEmpty) return '';

    final hasScheme =
        value.startsWith('http://') || value.startsWith('https://');
    if (!hasScheme) {
      final lower = value.toLowerCase();
      final looksLocal = lower.startsWith('localhost') ||
          lower.startsWith('127.') ||
          lower.startsWith('10.') ||
          lower.startsWith('192.168.') ||
          lower.startsWith('172.16.') ||
          lower.startsWith('172.17.') ||
          lower.startsWith('172.18.') ||
          lower.startsWith('172.19.') ||
          lower.startsWith('172.2') ||
          lower.startsWith('172.3') ||
          lower.contains(':8080') ||
          lower.contains(':3000') ||
          lower.contains(':8000') ||
          lower.endsWith('.local');

      value = looksLocal ? 'http://$value' : 'https://$value';
    }

    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }

    final lower = value.toLowerCase();
    if (lower.endsWith('/api')) {
      value = value.substring(0, value.length - 4);
    }

    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }

    return value;
  }

  static bool isLocalBaseUrl(String baseUrl) {
    final url = normalizeApiBaseUrl(baseUrl).toLowerCase();
    if (url.isEmpty) return false;
    return url.contains('localhost') ||
        url.contains('127.') ||
        url.contains('10.') ||
        url.contains('192.168.') ||
        url.contains('172.16.') ||
        url.contains('172.17.') ||
        url.contains('172.18.') ||
        url.contains('172.19.') ||
        url.contains('172.2') ||
        url.contains('172.3') ||
        url.contains('.local');
  }
}
