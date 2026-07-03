import 'dart:convert';

import 'package:chopper/chopper.dart';

/// Extracts the human-readable message from an RFC 7807 ProblemDetails
/// response body (`detail`, falling back to `title`). Returns null when the
/// body is not a ProblemDetails payload.
String? problemDetailFromResponse(Response<dynamic> response) {
  try {
    final decoded = jsonDecode(response.bodyString);
    if (decoded is Map<String, dynamic>) {
      return (decoded['detail'] ?? decoded['title'])?.toString();
    }
  } catch (_) {
    // Not a ProblemDetails payload — no detail to show.
  }
  return null;
}
