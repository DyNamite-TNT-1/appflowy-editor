import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

import 'html_node_parser.dart';

class MyHTMLBulletedListNodeParser extends MyHTMLNodeParser {
  const MyHTMLBulletedListNodeParser();

  @override
  String get id => BulletedListBlockKeys.type;

  @override
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    assert(node.type == BulletedListBlockKeys.type);

    final html = toHTMLString(
      transformNodeToDomNodes(node, encodeParsers: encodeParsers),
    );

    const start = '<ul>';
    const end = '</ul>';
    if (node.previous?.type != BulletedListBlockKeys.type &&
        node.next?.type != BulletedListBlockKeys.type) {
      return '$start$html$end';
    } else if (node.previous?.type != BulletedListBlockKeys.type) {
      return '$start$html';
    } else if (node.next?.type != BulletedListBlockKeys.type) {
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

    final element = transformDomNodesWithIndent(
      HTMLTags.list,
      [HTMLTags.unorderedList, HTMLTags.list],
      node.indent,
      domNodes: domNodes,
    );

    return [element];
  }
}
