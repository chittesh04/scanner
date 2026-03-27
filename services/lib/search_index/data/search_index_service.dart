class SearchIndexService {
  final Map<String, Set<String>> _index = {};

  void indexDocument(String documentId, String text) {
    final tokens = text.toLowerCase().split(RegExp(r'\\s+')).where((t) => t.isNotEmpty);
    for (final token in tokens) {
      _index.putIfAbsent(token, () => <String>{}).add(documentId);
    }
  }

  Set<String> search(String query) {
    final tokens = query.toLowerCase().split(RegExp(r'\\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return <String>{};
    Set<String>? current;
    for (final token in tokens) {
      final docs = _index[token] ?? <String>{};
      current = current == null ? {...docs} : current.intersection(docs);
    }
    return current ?? <String>{};
  }
}
