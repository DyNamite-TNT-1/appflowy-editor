import 'package:appflowy_editor/appflowy_editor.dart' hide HTMLTags;
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';
import 'package:example/pages/editor/plugins/html/encoder/parser/html_parser.dart';
import 'package:example/pages/editor/plugins/html/html_document_decoder.dart';
import 'package:html/dom.dart' as dom;

class MyHTMLCodeBlockNodeParser extends MyHTMLNodeParser {
  const MyHTMLCodeBlockNodeParser();

  @override
  String get id => CodeBlockKeys.type;

  @override
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    final html = toHTMLString(
      transformNodeToDomNodes(node, encodeParsers: encodeParsers),
    );
    return html;
  }

  @override
  List<dom.Node> transformNodeToDomNodes(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    final delta = node.delta ?? Delta();
    final domNodes = deltaHTMLEncoder.convert(delta);
    if (domNodes.isEmpty) {
      return [dom.Element.tag(HTMLTags.br)];
    }

    //replace new lines with <br> tags
    final updatedDomNodes = replaceNewLinesWithBrTag(domNodes);

    final element =
        wrapChildrenNodesWithTagName(HTMLTags.pre, childNodes: updatedDomNodes);
    return [element];
  }
}
