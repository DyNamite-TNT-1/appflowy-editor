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
}
