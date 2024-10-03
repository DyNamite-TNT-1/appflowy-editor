import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/shortcuts/command/indent_command.dart';

final indentMobileToolbarItem = MobileToolbarItem.action(
  itemIconBuilder: (context, __, ___) => AFMobileIcon(
    afMobileIcons: AFMobileIcons.indent,
    color: MobileToolbarTheme.of(context).iconColor,
  ),
  actionHandler: (_, editorState) {
    $indentCommand.execute(editorState);
  },
);
