import 'dart:convert';

import 'package:example/pages/editor/plugins/cut_copy_paste/clipboard_service/clipboard_service.dart';
import 'package:super_clipboard/super_clipboard.dart';

/// Used for in-app copy and paste without losing the format.
///
/// It's a Json string representing the copied editor nodes.
final inAppJsonFormat = CustomValueFormat<String>(
  applicationId: 'io.appflowy.InAppJsonType',
  onDecode: (value, platformType) async {
    if (value is PlatformDataProvider) {
      final data = await value.getData(platformType);
      if (data is List<int>) {
        return utf8.decode(data, allowMalformed: true);
      }
      if (data is String) {
        return Uri.decodeFull(data);
      }
    }
    return null;
  },
  onEncode: (value, platformType) => utf8.encode(value),
);

class SuperClipboardService implements ClipboardService {
  SystemClipboard? _getSuperClipboard() {
    return SystemClipboard.instance;
  }

  SystemClipboard _getSuperClipboardOrThrow() {
    final clipboard = _getSuperClipboard();
    if (clipboard == null) {
      // To avoid getting this exception, use _canProvide()
      throw UnsupportedError(
        'Clipboard API is not supported on this platform.',
      );
    }
    return clipboard;
  }

  Future<bool> _canProvide({required DataFormat format}) async {
    final clipboard = _getSuperClipboard();
    if (clipboard == null) {
      return false;
    }
    final reader = await clipboard.read();
    return reader.canProvide(format);
  }

  Future<String?> _provideValueFormatAsString({
    required ValueFormat<String> format,
  }) async {
    final clipboard = _getSuperClipboardOrThrow();
    final reader = await clipboard.read();
    final value = await reader.readValue<String>(format);

    return value;
  }

  @override
  Future<bool> canProvide() async {
    final clipboard = _getSuperClipboard();
    if (clipboard == null) {
      return false;
    }

    final reader = await clipboard.read();
    final availablePlatformFormats = reader.platformFormats;
    print("availablePlatformFormats $availablePlatformFormats");
    return availablePlatformFormats.isNotEmpty;
  }

  @override
  Future<bool> canProvideInAppJson() {
    return _canProvide(format: inAppJsonFormat);
  }

  @override
  Future<bool> canProvidePlainText() {
    return _canProvide(format: Formats.plainText);
  }

  @override
  Future<String?> getInAppJson() {
    return _provideValueFormatAsString(format: inAppJsonFormat);
  }

  @override
  Future<String?> getPlainText() {
    return _provideValueFormatAsString(format: Formats.plainText);
  }

  @override
  Future<void> setData(ClipboardServiceData data) async {
    final plainText = data.plainText;
    final inAppJson = data.inAppJson;

    final item = DataWriterItem();
    if (plainText != null) {
      item.add(Formats.plainText(plainText));
    }

    if (inAppJson != null) {
      item.add(inAppJsonFormat(inAppJson));
    }

    await SystemClipboard.instance?.write([item]);
  }
}
