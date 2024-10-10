import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';

import 'block_document_decoder.dart';
import 'block_document_encoder.dart';

class MyEditorBlockCodec extends Codec<Document, Map<String, dynamic>> {
  const MyEditorBlockCodec();

  @override
  Converter<Map<String, dynamic>, Document> get decoder =>
      DocumentBlockDecoder();

  @override
  Converter<Document, Map<String, dynamic>> get encoder =>
      DocumentBlockEncoder();
}
