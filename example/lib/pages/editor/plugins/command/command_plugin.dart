import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/plugins/menu/menu.dart';
import 'package:flutter/material.dart';

import 'utils.dart';

class Command {
  final String key;
  final String name;
  final List<String> keywords;
  final String? description;
  final void Function(EditorState editorState) handler;

  Command({
    required this.key,
    required this.name,
    required this.keywords,
    this.description,
    required this.handler,
  });
}

class CommandOption extends MenuOption {
  Command command;
  CommandOption({
    required this.command,
  }) : super(key: command.key);
}

class CommandPlugin extends StatefulWidget {
  const CommandPlugin({
    super.key,
    required this.editorState,
    required this.commands,
  });

  final EditorState editorState;
  final List<Command> commands;

  @override
  State<CommandPlugin> createState() => _CommandPluginState();
}

class _CommandPluginState extends State<CommandPlugin> {
  EditorState get editorState => widget.editorState;

  List<Command> get commands => widget.commands;

  List<CommandOption> _filteredCommands = [];

  MenuTextMatch? _findCommandMatch(String text) {
    return checkForSlashSignCommands(text, 0);
  }

  void _executeCommand(
    MenuOption selectedOption,
    Node nodeToReplace,
    void Function() closeMenu,
    MenuTextMatch match,
  ) async {
    final transaction = editorState.transaction
      ..deleteText(
        nodeToReplace,
        match.leadOffset,
        match.replaceableString.length,
      )
      ..afterSelection = Selection.collapsed(
        Position(path: nodeToReplace.path, offset: match.leadOffset),
      );
    await editorState.apply(transaction);
    (selectedOption as CommandOption).command.handler(editorState);
    closeMenu();
  }

  void _onQueryChange(String? query) {
    if (query == null) {
      setState(() {
        _filteredCommands = [];
      });
      return;
    }

    // Remove all spaces from the query and convert to lower case
    final normalizedQuery = query.replaceAll(r'/\s+/g', '').toLowerCase();

    setState(() {
      _filteredCommands = commands
          .where((command) {
            return command.keywords.any((keyword) {
              final normalizedKeyword =
                  keyword.replaceAll(RegExp(r'\s+'), '').toLowerCase();
              return normalizedKeyword.contains(normalizedQuery);
            });
          })
          .map((command) => CommandOption(command: command))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MenuPlugin(
      options: _filteredCommands,
      onQueryChange: _onQueryChange,
      editorState: editorState,
      triggerFn: _findCommandMatch,
      onSelectOption: _executeCommand,
      menuRenderFn: (ItemProps itemProps, String? matchingString) {
        if (_filteredCommands.isEmpty) {
          return _buildNoResultsWidget(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          itemCount: _filteredCommands.length,
          itemBuilder: (context, index) {
            final item = _filteredCommands[index];
            return TextButton(
              child: Text(item.command.name),
              onPressed: () {
                itemProps.selectOptionAndCleanUp(item);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNoResultsWidget(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: SizedBox(
        width: 140,
        child: Material(
          child: Text(
            "No results",
            style: TextStyle(fontSize: 18.0, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

final List<Command> standardCommands = [
  Command(
    key: 'text',
    name: 'text',
    keywords: ['text'],
    handler: (editorState) {
      insertNodeAfterSelection(editorState, paragraphNode());
    },
  ),
  Command(
    key: 'heading1',
    name: 'heading1',
    keywords: ['heading1, h1'],
    handler: (editorState) {
      insertHeadingAfterSelection(editorState, 1);
    },
  ),
  Command(
    key: 'heading2',
    name: 'heading2',
    keywords: ['heading2, h2'],
    handler: (editorState) {
      insertHeadingAfterSelection(editorState, 2);
    },
  ),
  Command(
    key: 'heading3',
    name: 'heading3',
    keywords: ['heading3, h3'],
    handler: (editorState) {
      insertHeadingAfterSelection(editorState, 3);
    },
  ),
  Command(
    key: 'bulleted_list',
    name: 'bulleted list',
    keywords: ['bulleted list', 'list', 'unordered list'],
    handler: (editorState) {
      insertBulletedListAfterSelection(editorState);
    },
  ),
  Command(
    key: 'numbered_list',
    name: 'numbered list',
    keywords: ['numbered list', 'list', 'ordered list'],
    handler: (editorState) {
      insertNumberedListAfterSelection(editorState);
    },
  ),
  Command(
    key: 'checkbox',
    name: 'checkbox',
    keywords: ['todo list', 'list', 'checkbox list'],
    handler: (editorState) {
      insertCheckboxAfterSelection(editorState);
    },
  ),
  Command(
    key: 'quote',
    name: 'quote',
    keywords: ['quote', 'refer'],
    handler: (editorState) {
      insertQuoteAfterSelection(editorState);
    },
  ),
];
