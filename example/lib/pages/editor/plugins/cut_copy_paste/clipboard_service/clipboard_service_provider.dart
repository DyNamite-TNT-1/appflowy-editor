import 'package:example/pages/editor/plugins/cut_copy_paste/clipboard_service/clipboard_service.dart';
import 'package:example/pages/editor/plugins/cut_copy_paste/clipboard_service/super_clipboard_service.dart';

class ClipboardServiceProvider {
  const ClipboardServiceProvider._();
  static final ClipboardService _instance = SuperClipboardService();

  static ClipboardService get instance => _instance;
}
