import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/plugins/mention/mention_block/mention_block.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/models.dart' as block;

extension CommonUtils on Node {
  block.BlockNode convertToBlockData() {
    /// quote conversion not handle here, check quote_utils
    /// list conversion not handle here, check list_utils
    assert(type != QuoteBlockKeys.type && !listTypes.contains(type));

    switch (type) {
      case codeBlockType:
        return _createCodeBlockNode();
      case ParagraphBlockKeys.type:
        return _createParagraphBlockNode();
      default:
        return _createDefaultBlockNode();
    }
  }

  block.BlockNode _createCodeBlockNode() {
    return block.BlockNode(type: block.NodeTypes.richTextPreformatted);
  }

  block.BlockNode _createParagraphBlockNode() {
    return block.BlockNode(
      type: block.NodeTypes.richTextSection,
      metaData: {"indent": indent},
    );
  }

  block.BlockNode _createDefaultBlockNode() {
    return block.BlockNode(
      type: block.NodeTypes.richTextSection,
    );
  }

  block.MetaData get getMetaData {
    switch (type) {
      case NumberedListBlockKeys.type:
        return _createAnotherListMetaData("ordered");
      case BulletedListBlockKeys.type:
        return _createAnotherListMetaData("bullet");
      case TodoListBlockKeys.type:
        return _createTodoListMetaData();
      case ParagraphBlockKeys.type:
      default:
        return {"indent": indent};
    }
  }

  block.MetaData _createAnotherListMetaData(String style) {
    return {
      "indent": indent,
      "style": style,
    };
  }

  block.MetaData _createTodoListMetaData() {
    return {
      "indent": indent,
      "style": "todo",
      "value": attributes[TodoListBlockKeys.checked],
    };
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

  if (attributes[MentionBlockKeys.mention] is Map<String, dynamic>) {
    return _createUserInlineNode(attributes);
  }

  return attributes.href != null
      ? _createLinkInlineNode(text, attributes)
      : _createTextInlineNode(text, attributes);
}

block.InlineNode _createUserInlineNode(Attributes attributes) {
  final mention = attributes[MentionBlockKeys.mention];

  assert(mention is Map<String, dynamic>);

  final userId = mention[MentionBlockKeys.userId];
  final userName = mention[MentionBlockKeys.userName];

  return block.InlineNode(
    type: block.NodeTypes.user,
    style: attributes.convertToStyle(),
    metaData: {
      MentionBlockKeys.userId: userId,
      MentionBlockKeys.userName: userName,
    },
  );
}

block.InlineNode _createLinkInlineNode(String text, Attributes attributes) {
  final href = attributes.href;
  assert(href != null);

  return block.InlineNode(
    type: block.NodeTypes.link,
    text: text.isNotEmpty ? text : href!,
    style: attributes.convertToStyle(),
    metaData: {"url": href},
  );
}

block.InlineNode _createTextInlineNode(String text, Attributes attributes) {
  return block.InlineNode(
    type: block.NodeTypes.text,
    text: text,
    style: attributes.convertToStyle(),
  );
}

TextInsert convertInlineNodeToTextInsert(
  block.InlineNode inlineNode,
) {
  final text = inlineNode.text;
  final Attributes attributes = inlineNode.style.convertToAttributes();

  //If it is user mention
  if (isUserNode(inlineNode, attributes)) {
    return TextInsert('\$', attributes: attributes);
  }

  _addLinkAttributeIfExists(inlineNode, attributes);

  return TextInsert(text, attributes: attributes);
}

bool isUserNode(block.InlineNode inlineNode, Attributes attributes) {
  if (inlineNode.type == block.NodeTypes.user) {
    final userId = inlineNode.metaData[MentionBlockKeys.userId];
    final userName = inlineNode.metaData[MentionBlockKeys.userName];

    if (userId is String && userName is String) {
      attributes[MentionBlockKeys.mention] = {
        MentionBlockKeys.userId: userId,
        MentionBlockKeys.userName: userName,
      };
    }
    return true; // Indicate that it's a user node
  }
  return false; // Not a user node
}

void _addLinkAttributeIfExists(
  block.InlineNode inlineNode,
  Attributes attributes,
) {
  if (inlineNode.type == block.NodeTypes.link) {
    final link = inlineNode.metaData["url"];
    if (link is String) {
      attributes["href"] = link;
    }
  }
}

extension on block.Style {
  bool get strike {
    return (containsKey(block.StyleRichTextKeys.strikethrough) &&
        this[block.StyleRichTextKeys.strikethrough] == true);
  }

  Color? get textColor {
    final textColor = this[block.StyleRichTextKeys.textColor] as String?;
    return textColor?.tryToColor();
  }

  Color? get backgroundColorFromStyle {
    final highlightColor =
        this[block.StyleRichTextKeys.backgroundColor] as String?;
    return highlightColor?.tryToColor();
  }

  Attributes convertToAttributes() {
    final attributes = <String, dynamic>{};

    _addStyleAttributes(attributes);
    _addColorAttributes(attributes);

    return attributes;
  }

  void _addStyleAttributes(Attributes attributes) {
    if (bold) attributes[AppFlowyRichTextKeys.bold] = true;
    if (underline) attributes[AppFlowyRichTextKeys.underline] = true;
    if (strike) attributes[AppFlowyRichTextKeys.strikethrough] = true;
    if (italic) attributes[AppFlowyRichTextKeys.italic] = true;
    if (code) attributes[AppFlowyRichTextKeys.code] = true;
  }

  void _addColorAttributes(Attributes attributes) {
    final backgroundColor = backgroundColorFromStyle;
    if (backgroundColor != null) {
      attributes[AppFlowyRichTextKeys.backgroundColor] =
          backgroundColor.toRgbaString();
    }

    final color = textColor;
    if (color != null) {
      attributes[AppFlowyRichTextKeys.textColor] = color.toRgbaString();
    }
  }
}

extension on Attributes {
  block.Style convertToStyle() {
    final style = <String, dynamic>{};

    _addStyleAttributes(style);
    _addColorAttributes(style);

    return style;
  }

  void _addStyleAttributes(block.Style style) {
    if (bold) style[block.StyleRichTextKeys.bold] = true;
    if (underline) style[block.StyleRichTextKeys.underline] = true;
    if (strikethrough) style[block.StyleRichTextKeys.strikethrough] = true;
    if (italic) style[block.StyleRichTextKeys.italic] = true;
    if (code) style[block.StyleRichTextKeys.code] = true;
  }

  void _addColorAttributes(block.Style style) {
    final backgroundColor = this.backgroundColor;
    if (backgroundColor != null) {
      style[block.StyleRichTextKeys.backgroundColor] =
          backgroundColor.toRgbaString();
    }
    final color = this.color;
    if (color != null) {
      style[block.StyleRichTextKeys.textColor] = color.toRgbaString();
    }
  }
}
