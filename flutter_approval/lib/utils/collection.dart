extension MultiSelectionList<T> on List<T> {
  List<T> toSelectedList(Set<int> indices) {
    List<T> result = [];
    asMap().forEach((index, value) {
      if (indices.contains(index)) {
        result.add(value);
      }
    });
    return result;
  }
}

extension PrintableFold<T> on Iterable<T> {
  String foldToCommaSeparated(String Function(T) toString) {
    return fold("", (previousValue, element) {
      if (previousValue == "") {
        return toString(element);
      } else {
        return "$previousValue, ${toString(element)}";
      }
    });
  }
}
