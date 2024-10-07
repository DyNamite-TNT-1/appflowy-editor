import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart'
    hide CodeBlockComponentWidget;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomCodeBlockComponentBuilder extends BlockComponentBuilder {
  CustomCodeBlockComponentBuilder({
    super.configuration,
    this.padding = const EdgeInsets.only(
      top: 20,
      left: 20,
      right: 20,
      bottom: 34,
    ),
    this.styleBuilder,
    this.actions = const CodeBlockActions(),
    this.actionWrapperBuilder,
    this.languagePickerBuilder,
    this.copyButtonBuilder,
    this.localizations = const CodeBlockLocalizations(),
    this.showLineNumbers = true,
  });

  final EdgeInsets padding;
  final CodeBlockStyle Function()? styleBuilder;
  final CodeBlockActions actions;
  final Widget Function(
    Node node,
    EditorState editorState,
    Widget child,
  )? actionWrapperBuilder;
  final CodeBlockLanguagePickerBuilder? languagePickerBuilder;
  final CodeBlockCopyBuilder? copyButtonBuilder;
  final CodeBlockLocalizations localizations;
  final bool showLineNumbers;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return CodeBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      padding: padding,
      showActions: showActions(node),
      actionBuilder: (_, state) => actionBuilder(blockComponentContext, state),
      actionWrapperBuilder: actionWrapperBuilder,
      style: styleBuilder?.call(),
      languagePickerBuilder: languagePickerBuilder,
      actions: actions,
      copyButtonBuilder: copyButtonBuilder,
      localizations: localizations,
      showLineNumbers: showLineNumbers,
    );
  }

  @override
  bool validate(Node node) => node.delta != null;
}

class CodeBlockComponentWidget extends BlockComponentStatefulWidget {
  const CodeBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
    this.padding = const EdgeInsets.all(20),
    this.style,
    this.actions = const CodeBlockActions(),
    this.actionWrapperBuilder,
    this.languagePickerBuilder,
    this.copyButtonBuilder,
    this.localizations = const CodeBlockLocalizations(),
    this.showLineNumbers = true,
  });

  final EdgeInsets padding;

  /// The style of the code block.
  ///
  /// If null, theme defaults will be used.
  ///
  final CodeBlockStyle? style;

  /// The actions available for the code block.
  ///
  final CodeBlockActions actions;

  /// The builder for the action widgets.
  ///
  /// Used to override the default action wrapper,
  /// especially useful for mobile adaptation.
  ///
  /// _Note: This renders the [actionBuilder] obsolete!_
  ///
  final Widget Function(
    Node node,
    EditorState editorState,
    Widget child,
  )? actionWrapperBuilder;

  /// Provide a custom Widget for the language picker.
  ///
  /// It is highly recommended to replace the default language picker that
  /// consists of a [DropdownMenu], with a custom picker that fits the
  /// design of your app.
  ///
  final CodeBlockLanguagePickerBuilder? languagePickerBuilder;

  /// Provide a custom Widget for the copy button.
  ///
  /// It is highly recommended to replace the default copy button that
  /// consists of a simple [IconButton], with a custom button that fits the
  /// design of your app.
  ///
  final CodeBlockCopyBuilder? copyButtonBuilder;

  final CodeBlockLocalizations localizations;

  final bool showLineNumbers;

  @override
  State<CodeBlockComponentWidget> createState() =>
      _CodeBlockComponentWidgetState();
}

class _CodeBlockComponentWidgetState extends State<CodeBlockComponentWidget>
    with
        SelectableMixin,
        DefaultSelectableMixin,
        BlockComponentConfigurable,
        BlockComponentTextDirectionMixin {
  // The key used to forward focus to the richtext child
  @override
  final forwardKey = GlobalKey(debugLabel: 'code_flowy_rich_text');

  @override
  GlobalKey<State<StatefulWidget>> blockComponentKey =
      GlobalKey(debugLabel: CodeBlockKeys.type);

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  GlobalKey<State<StatefulWidget>> get containerKey => node.key;

  @override
  Node get node => widget.node;

  @override
  late EditorState editorState;

  @override
  void initState() {
    super.initState();
    editorState = context.read<EditorState>();
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = calculateTextDirection(
      layoutDirection: Directionality.maybeOf(context),
    );

    Widget child = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        color: widget.style?.backgroundColor ??
            Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        textDirection: textDirection,
        children: [
          _buildCodeBlock(context, textDirection),
        ],
      ),
    );

    child = Padding(key: blockComponentKey, padding: padding, child: child);

    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      remoteSelection: editorState.remoteSelections,
      blockColor: editorState.editorStyle.selectionColor,
      supportTypes: const [
        BlockSelectionType.block,
      ],
      child: child,
    );

    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }

    return child;
  }

  Widget _buildCodeBlock(BuildContext context, TextDirection textDirection) {
    final delta = node.delta ?? Delta();
    final linesOfCode = delta.toPlainText().split('\n').length;

    return Padding(
      padding: widget.padding,
      child: Row(
        
        children: [
          if (widget.showLineNumbers) ...[
            _LinesOfCodeNumbers(
              linesOfCode: linesOfCode,
              textStyle: textStyle.copyWith(
                color: widget.style?.foregroundColor ??
                    Theme.of(context)
                        .colorScheme
                        .onSecondaryContainer
                        .withAlpha(155),
              ),
            ),
          ],
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: AppFlowyRichText(
                key: forwardKey,
                delegate: this,
                node: widget.node,
                editorState: editorState,
                placeholderText: placeholderText,
                lineHeight: 1.5,
                textSpanDecorator: (textSpan) => textSpan.updateTextStyle(
                  textStyle,
                ),
                placeholderTextSpanDecorator: (textSpan) =>
                    textSpan.updateTextStyle(
                  placeholderTextStyle,
                ),
                textDirection: textDirection,
                cursorColor: editorState.editorStyle.cursorColor,
                selectionColor: editorState.editorStyle.selectionColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinesOfCodeNumbers extends StatelessWidget {
  const _LinesOfCodeNumbers({
    required this.linesOfCode,
    required this.textStyle,
  });

  final int linesOfCode;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 1; i <= linesOfCode; i++)
            Text(i.toString(), style: textStyle),
        ],
      ),
    );
  }
}
