import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

abstract class MyHTMLNodeParser extends HTMLNodeParser {
  const MyHTMLNodeParser();

  /// Returns the result representing the outermost element containing the
  /// nested structure and the provided DOM nodes.
  ///
  /// ### Example:
  /// ```dart
  /// final result = transformDomNodesWithIndent(
  ///   'div',
  ///   ['p', 'span'],
  ///   2,
  ///   domNodes: [dom.Text('Hello, World!')],
  /// );
  /// //The result will be a structure like:
  /// <div>
  ///   <p>
  ///     <span>
  ///       <p>
  ///         <span>
  ///           Hello, World!
  ///         </span>
  ///       </p>
  ///     </span>
  ///   </p>
  /// </div>
  /// ```
  dom.Element transformDomNodesWithIndent(
    String outerTag,
    List<String> innerTags,
    int indent, {
    required List<dom.Node> domNodes,
  }) {
    // Create the outer element
    final outer = dom.Element.tag(outerTag);

    // If innerTags is empty or indent is less than 1, just append nodes to outer
    if (innerTags.isEmpty || indent < 1) {
      for (var node in domNodes) {
        outer.append(node);
      }
      return outer;
    }

    dom.Element currentElement = outer;

    for (int i = 0; i < indent; i++) {
      // Create a new level of inner tags for this indentation
      for (int j = 0; j < innerTags.length; j++) {
        final innerElement = dom.Element.tag(innerTags[j]);
        currentElement.append(innerElement);
        currentElement =
            innerElement; // Move to the newly created inner element
      }
    }

    // Append the provided DOM nodes to the innermost element
    for (var node in domNodes) {
      currentElement.append(node);
    }

    return outer;
  }
}
