String cleanString(String dirtyString) {
  return dirtyString.replaceAll(RegExp(r'[^\w\s]+'), ' ');
}
