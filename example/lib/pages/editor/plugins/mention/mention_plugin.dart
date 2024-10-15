import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/plugins/mention/mention_block/mention_block.dart';
import 'package:example/pages/editor/plugins/mention/utils.dart';
import 'package:example/pages/editor/plugins/menu/menu.dart';
import 'package:flutter/material.dart';

class UserMention {
  String alias; //as mentionkey
  String fullName;

  UserMention({
    required this.alias,
    required this.fullName,
  });
}

class MentionOption extends MenuOption {
  UserMention mention;
  MentionOption({
    required this.mention,
  }) : super(key: mention.alias);
}

class MentionPlugin extends StatefulWidget {
  const MentionPlugin({
    super.key,
    required this.editorState,
    required this.mentions,
  });

  final EditorState editorState;
  final List<UserMention> mentions;

  @override
  State<MentionPlugin> createState() => _MentionPluginState();
}

class _MentionPluginState extends State<MentionPlugin> {
  EditorState get editorState => widget.editorState;

  List<UserMention> get mentions => widget.mentions;

  List<MentionOption> _filteredMentionOptions = [];

  MenuTextMatch? _findMentionMatch(String text) {
    return checkForAtSignCommands(text, 0);
  }

  void _onSelectMention(
    MenuOption selectedOption,
    Node nodeToReplace,
    void Function() closeMenu,
    MenuTextMatch match,
  ) async {
    final mentionOption = (selectedOption as MentionOption);

    final transaction = editorState.transaction
      ..replaceText(
        nodeToReplace,
        match.leadOffset,
        match.replaceableString.length,
        '\$',
        attributes: {
          MentionBlockKeys.mention: {
            MentionBlockKeys.userId: mentionOption.mention.alias,
            MentionBlockKeys.userName: mentionOption.mention.fullName,
          },
        },
      )
      //add a space
      ..insertText(nodeToReplace, match.leadOffset + 1, " ");
    await editorState.apply(transaction);
    closeMenu();
  }

  void _onQueryChange(String? query) {
    if (query == null) {
      setState(() {
        _filteredMentionOptions = [];
      });
      return;
    }

    final normalizedQuery = query.toLowerCase();

    setState(() {
      _filteredMentionOptions = mentions
          .where((mention) {
            final normalizedFullname = mention.fullName.toLowerCase();
            return normalizedFullname.contains(normalizedQuery);
          })
          .map((mention) => MentionOption(mention: mention))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MenuPlugin(
      editorState: editorState,
      onQueryChange: _onQueryChange,
      onSelectOption: _onSelectMention,
      options: _filteredMentionOptions,
      triggerFn: _findMentionMatch,
      menuRenderFn: (ItemProps itemProps, String? matchingString) {
        if (_filteredMentionOptions.isEmpty) {
          return null;
        }

        return ListView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          itemCount: _filteredMentionOptions.length,
          itemBuilder: (context, index) {
            final item = _filteredMentionOptions[index];
            return TextButton(
              child: Text(item.mention.fullName),
              onPressed: () {
                itemProps.selectOptionAndCleanUp(item);
              },
            );
          },
        );
      },
    );
  }
}
