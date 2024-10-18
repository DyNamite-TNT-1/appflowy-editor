import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mention_user_block.dart';

class MentionBlockKeys {
  const MentionBlockKeys._();

  static const mention = "mention";
  static const userId = "user_id";
  static const userName = 'user_name';
}

Node mentionNode({
  required String userId,
  String? userName,
}) {
  return paragraphNode(
    delta: Delta(
      operations: [
        TextInsert(
          '\$',
          attributes: {
            MentionBlockKeys.mention: {
              MentionBlockKeys.userId: userId,
              MentionBlockKeys.userName: userName,
            },
          },
        ),
      ],
    ),
  );
}

class MentionBlock extends StatefulWidget {
  const MentionBlock({
    super.key,
    required this.mention,
    required this.node,
    required this.index,
    required this.textStyle,
  });

  final Map<String, dynamic> mention;
  final Node node;
  final int index;
  final TextStyle? textStyle;

  @override
  State<MentionBlock> createState() => _MentionBlockState();
}

class _MentionBlockState extends State<MentionBlock> with SelectableMixin {
  final mentionKey = GlobalKey(debugLabel: 'mention_key');
  RenderBox? get _renderBox => context.findRenderObject() as RenderBox?;

  @override
  Widget build(BuildContext context) {
    final editorState = context.read<EditorState>();
    final String? userId = widget.mention[MentionBlockKeys.userId] as String?;
    final String? userName =
        widget.mention[MentionBlockKeys.userName] as String?;
    if (userId == null) {
      return const SizedBox.shrink();
    }

    return MentionUserBlock(
      key: mentionKey,
      editorState: editorState,
      userId: userId,
      userName: userName,
      node: widget.node,
      textStyle: widget.textStyle,
      index: widget.index,
    );
  }

  @override
  Rect? getCursorRectInPosition(
    Position position, {
    bool shiftWithBaseOffset = false,
  }) {
    if (_renderBox == null) {
      return null;
    }
    return getRectsInSelection(
      Selection.collapsed(position),
      shiftWithBaseOffset: shiftWithBaseOffset,
    ).firstOrNull;
    // final size = _renderBox!.size;
    // return Rect.fromLTWH(-size.width / 2.0, 0, size.width, size.height);
  }

  @override
  Position end() {
    // TODO: implement end
    throw UnimplementedError();
  }

  @override
  Position start() {
    // TODO: implement start
    throw UnimplementedError();
  }

  @override
  Rect getBlockRect({bool shiftWithBaseOffset = false}) {
    // TODO: implement getBlockRect
    throw UnimplementedError();
  }

  @override
  Position getPositionInOffset(Offset start) {
    // TODO: implement getPositionInOffset
    throw UnimplementedError();
  }

  @override
  List<Rect> getRectsInSelection(
    Selection selection, {
    bool shiftWithBaseOffset = false,
  }) {
    if (_renderBox == null) {
      return [];
    }
    final parentBox = widget.node.key.currentContext?.findRenderObject();
    final mentionBox = mentionKey.currentContext?.findRenderObject();

    if (parentBox is RenderBox && mentionBox is RenderBox) {
      return [
        mentionBox.localToGlobal(Offset.zero, ancestor: parentBox) &
            mentionBox.size,
      ];
    }
    return [Offset.zero & _renderBox!.size];
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) {
    // TODO: implement getSelectionInRange
    throw UnimplementedError();
  }

  @override
  Offset localToGlobal(Offset offset, {bool shiftWithBaseOffset = false}) {
    // TODO: implement localToGlobal
    throw UnimplementedError();
  }
}
