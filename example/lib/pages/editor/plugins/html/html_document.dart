import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'html_document_decoder.dart';


/// Converts a html to [Document].
Document $htmlToDocument(String html) {
  return const MyEditorHTMLCodec().decode(html);
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
