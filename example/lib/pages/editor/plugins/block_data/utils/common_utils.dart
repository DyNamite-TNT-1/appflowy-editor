import 'package:appflowy_editor/appflowy_editor.dart';
import '../constants.dart';
import '../node.dart' as block;

extension CommonUtils on Node {
  block.BlockNode convertToBlockData() {
    /// quote conversion not handle here, check quote_utils
    /// list conversion not handle here, check list_utils
    assert(type != QuoteBlockKeys.type && !listTypes.contains(type));

    if (type == codeBlockType) {
      return block.BlockNode(
        type: block.NodeTypes.richTextPreformatted,
      );
    }

    if (type == ParagraphBlockKeys.type) {
      return block.BlockNode(
        type: block.NodeTypes.richTextSection,
        children: [],
        metaData: {
          "indent": indent,
        },
      );
    }

    return block.BlockNode(
      type: block.NodeTypes.richTextSection,
      children: [],
    );
  }

  block.MetaData get getMetaData {
    switch (type) {
      case NumberedListBlockKeys.type:
        return {
          "indent": indent,
          "style": "ordered",
        };
      case BulletedListBlockKeys.type:
        return {
          "indent": indent,
          "style": "bullet",
        };
      case TodoListBlockKeys.type:
        return {
          "indent": indent,
          "style": "todo",
          "value": attributes[TodoListBlockKeys.checked],
        };
      case ParagraphBlockKeys.type:
      default:
        return {
          "indent": indent,
        };
    }
  }
}

block.InlineNode convertTextInsertToInlineNode(
  TextInsert textInsert,
) {
  final text = textInsert.text;
  final attributes = textInsert.attributes;

  if (attributes == null) {
    return block.InlineNode(type: block.NodeTypes.text, text: text);
  }

  return block.InlineNode(
    type: block.NodeTypes.text,
    text: text,
    style: convertAttributesToCssStyle(attributes),
  );
}

Map<String, dynamic> convertAttributesToCssStyle(
  Map<String, dynamic> attributes,
) {
  final cssMap = <String, dynamic>{};

  if (attributes.bold) {
    cssMap['bold'] = true;
  }

  if (attributes.underline) {
    cssMap['underline'] = true;
  }

  if (attributes.strikethrough) {
    cssMap['strikethrough'] = true;
  }

  if (attributes.italic) {
    cssMap['italic'] = true;
  }

  if (attributes.code) {
    cssMap['code'] = true;
  }

  final backgroundColor = attributes.backgroundColor;
  if (backgroundColor != null) {
    cssMap['background-color'] = backgroundColor.toRgbaString();
  }

  final color = attributes.color;
  if (color != null) {
    cssMap['color'] = color.toRgbaString();
  }

  return cssMap;
}

TextInsert convertInlineNodeToTextInsert(
  block.InlineNode inlineNode,
) {
  final text = inlineNode.text;
  final Attributes attributes = convertCssStyleToAttributes(inlineNode.style);

  final textInsert = TextInsert(text, attributes: attributes);

  return textInsert;
}

Map<String, dynamic> convertCssStyleToAttributes(
  Map<String, dynamic> style,
) {
  final attributes = <String, dynamic>{};

  if (style.bold) {
    attributes['bold'] = true;
  }

  if (style.underline) {
    attributes['underline'] = true;
  }

  if (style.strikethrough) {
    attributes['strikethrough'] = true;
  }

  if (style.italic) {
    attributes['italic'] = true;
  }

  if (style.code) {
    attributes['code'] = true;
  }

  //TODO background-color, color

  return attributes;
}
