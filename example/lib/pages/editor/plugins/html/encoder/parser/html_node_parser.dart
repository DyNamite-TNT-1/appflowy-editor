import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

abstract class MyHTMLNodeParser extends HTMLNodeParser {
  const MyHTMLNodeParser();

  /// ### Example:
  /// ```dart
  /// final result = transformDomNodesWithIndent(
  ///   'div',
  ///   ['p', 'span'],
  ///   2,
  ///   domNodes: [dom.Text('Hello, World!')],
  /// );
  /// //The result will be a structure like:
  /// <p>
  ///   <span>
  ///     <p>
  ///       <span>
  ///         <div>
  ///           Hello, World!
  ///         </div>
  ///       </span>
  ///     </p>
  ///   </span>
  /// </p>
  /// ```
  dom.Element transformDomNodesWithIndent(
    String innerTag,
    List<String> outerTags,
    int indent, {
    required List<dom.Node> domNodes,
  }) {
    final inner = dom.Element.tag(innerTag);

    for (var node in domNodes) {
      inner.append(node);
    }

    if (outerTags.isEmpty || indent < 1) {
      return inner;
    }

    dom.Element currentElement = inner;

    for (int i = indent - 1; i >= 0; i--) {
      for (int j = outerTags.length - 1; j >= 0; j--) {
        final outerElement = dom.Element.tag(outerTags[j]);
        outerElement.append(currentElement);
        currentElement = outerElement;
      }
    }

    return currentElement;
  }

  List<dom.Node> replaceNewLinesWithBrTag(List<dom.Node> nodes) {
    List<dom.Node> modifiedNodes = [];

    for (dom.Node node in nodes) {
      // Process each node and replace new lines
      dom.Node modifiedNode = _replaceNewLinesInNode(node);
      modifiedNodes.add(modifiedNode);
    }

    return modifiedNodes;
  }

  dom.Node _replaceNewLinesInNode(dom.Node node) {
    if (node is dom.Text) {
      dom.Text textNode = node;
      List<String> parts = textNode.text.split('\n');

      dom.DocumentFragment fragment = dom.DocumentFragment();

      for (int i = 0; i < parts.length; i++) {
        fragment.append(dom.Text(parts[i]));
        if (i < parts.length - 1) {
          fragment.append(dom.Element.tag(HTMLTags.br));
        }
      }

      return fragment;
    } else if (node is dom.Element) {
      // Create a new element of the same tag
      dom.Element newElement = dom.Element.tag(node.localName);
      // Copy attributes
      newElement.attributes = node.attributes;

      // Process each child node
      // node.children not working here, use node.nodes instead
      for (dom.Node child in node.nodes) {
        dom.Node modifiedChild = _replaceNewLinesInNode(child);
        newElement.append(modifiedChild);
      }

      return newElement;
    }

    return node; // Return the node unchanged if it's not a text or element node
  }
}
