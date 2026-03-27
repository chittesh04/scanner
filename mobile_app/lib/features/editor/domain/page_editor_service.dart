class PageEditorService {
  List<String> reorderPages(List<String> pageIds, int oldIndex, int newIndex) {
    final clone = [...pageIds];
    final page = clone.removeAt(oldIndex);
    clone.insert(newIndex, page);
    return clone;
  }

  List<String> deletePage(List<String> pageIds, String pageId) {
    return pageIds.where((id) => id != pageId).toList(growable: false);
  }
}
