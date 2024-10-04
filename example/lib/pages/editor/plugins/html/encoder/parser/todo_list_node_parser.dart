import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

import 'html_node_parser.dart';

class MyHTMLTodoListNodeParser extends MyHTMLNodeParser {
  const MyHTMLTodoListNodeParser();

  @override
  String get id => TodoListBlockKeys.type;

  @override
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    assert(node.type == TodoListBlockKeys.type);

    final html = toHTMLString(
      transformNodeToDomNodes(node, encodeParsers: encodeParsers),
    );

    const start = '<ul>';
    const end = '</ul>';
    if (node.previous?.type != TodoListBlockKeys.type &&
        node.next?.type != TodoListBlockKeys.type) {
      return '$start$html$end';
    } else if (node.previous?.type != TodoListBlockKeys.type) {
      return '$start$html';
    } else if (node.next?.type != TodoListBlockKeys.type) {
      return '$html$end';
    } else {
      return html;
    }
  }

  @override
  List<dom.Node> transformNodeToDomNodes(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    final delta = node.delta ?? Delta();
    final domNodes = deltaHTMLEncoder.convert(delta);

    final indent = node.indent;
  
    final inner = dom.Element.tag(HTMLTags.list);

    inner.attributes['role'] = 'checkbox';
    final checked =
        node.attributes[TodoListBlockKeys.checked] as bool? ?? false;
    inner.attributes['aria-checked'] = '$checked';

    for (var node in domNodes) {
      inner.append(node);
    }

    dom.Element currentElement = inner;

    for (int i = indent - 1; i >= 0; i--) {
      final liElement = dom.Element.tag(HTMLTags.list);
      final ulElement = dom.Element.tag(HTMLTags.unorderedList);

      ulElement.append(currentElement);
      liElement.append(ulElement);
      currentElement = liElement;
    }
    return [currentElement];
  }
}
