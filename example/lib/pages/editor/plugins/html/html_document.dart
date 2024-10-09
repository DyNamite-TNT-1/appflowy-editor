import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'html_document_decoder.dart';
import 'encoder/parser/html_parser.dart';

/// Converts a html to [Document].
Document $htmlToDocument(String html) {
  return const MyEditorHTMLCodec().decode(html);
}

/// Converts a [Document] to html.
String $documentToHTML(
  Document document, {
  List<HTMLNodeParser> customParsers = const [],
}) {
  return MyEditorHTMLCodec(
    encodeParsers: [
      ...customParsers,
      const HTMLTextNodeParser(),
      const MyHTMLBulletedListNodeParser(),
      const MyHTMLNumberedListNodeParser(),
      const MyHTMLTodoListNodeParser(),
      const MyHTMLCodeBlockNodeParser(),
      const HTMLQuoteNodeParser(),
      const HTMLHeadingNodeParser(),
      const HTMLImageNodeParser(),
      const HtmlTableNodeParser(),
      // const HTMLDividerNodeParser(),
    ],
  ).encode(document);
}

class MyEditorHTMLCodec extends Codec<Document, String> {
  const MyEditorHTMLCodec({
    this.encodeParsers = const [],
  });

  final List<HTMLNodeParser> encodeParsers;

  @override
  Converter<String, Document> get decoder => MyDocumentHTMLDecoder();

  @override
  Converter<Document, String> get encoder =>
      DocumentHTMLEncoder(encodeParsers: encodeParsers);
}
