/// Normalizes a crawl-link URL to a domain-agnostic comparison key.
///
/// Providers rotate domains regularly (that's what the server's Domain
/// Update job is for), so matching search-result URLs against stored
/// crawl-link URLs must ignore scheme and host. The key is the decoded,
/// lowercased path (no trailing slash) plus the sorted query parameters
/// when present.
String? normalizeCrawlUrlKey(String? url) {
  if (url == null || url.trim().isEmpty) {
    return null;
  }
  final value = url.trim();
  String path;
  String query = '';
  final uri = Uri.tryParse(value);
  if (uri != null && uri.hasAuthority) {
    path = uri.path;
    query = uri.query;
  } else {
    path = value;
    final queryIndex = path.indexOf('?');
    if (queryIndex >= 0) {
      query = path.substring(queryIndex + 1);
      path = path.substring(0, queryIndex);
    }
  }
  // Decode BEFORE lowercasing — '%C3%8B' (Ë) must end up as 'ë', which
  // lowercasing the still-encoded form would miss.
  path = _safeDecode(path).toLowerCase();
  if (query.isNotEmpty) {
    final params = _safeDecode(query).toLowerCase().split('&')..sort();
    query = params.join('&');
  }
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  if (!path.startsWith('/')) {
    path = '/$path';
  }
  return query.isEmpty ? path : '$path?$query';
}

String _safeDecode(String input) {
  try {
    return Uri.decodeComponent(input);
  } on FormatException {
    // Malformed percent-encoding — compare the raw value instead.
    return input;
  }
}
