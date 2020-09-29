class InvalidApiRequestException implements Exception {
  List<String> errors;
  InvalidApiRequestException(this.errors);
}
