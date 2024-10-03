import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/shortcuts/command/outdent_command.dart';

final outdentMobileToolbarItem = MobileToolbarItem.action(
  itemIconBuilder: (context, __, ___) => AFMobileIcon(
    afMobileIcons: AFMobileIcons.outdent,
    color: MobileToolbarTheme.of(context).iconColor,
  ),
  actionHandler: (_, editorState) {
    $outdentCommand.execute(editorState);
  },
);
