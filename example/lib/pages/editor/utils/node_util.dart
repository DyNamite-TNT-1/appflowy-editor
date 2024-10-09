import 'package:appflowy_editor/appflowy_editor.dart';

typedef MetaData = Map<String, dynamic>;

extension NodeExtension on Node {
  void visitAllDescendants(
    Node node,
    void Function(Node, int) visitor,
    int depth, {
    MetaData? metaData,
  }) {
    final children = node.children;
    for (var child in children) {
      visitor(child, depth + 1);
      if (child.children.isNotEmpty) {
        visitAllDescendants(child, visitor, depth + 1);
      }
    }
  }
}
