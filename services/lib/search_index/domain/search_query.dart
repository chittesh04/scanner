class SearchQuery {
  const SearchQuery(this.text, {this.tags = const []});
  final String text;
  final List<String> tags;
}
