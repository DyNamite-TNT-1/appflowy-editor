import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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

class ClipboardServiceData {
  const ClipboardServiceData({
    this.plainText,
    this.html,
    this.inAppJson,
  });

  final String? plainText;
  final String? html;
  final String? inAppJson;
}

class ClipboardService {
  static ClipboardServiceData? _mockData;

  Future<void> setData(ClipboardServiceData data) async {
    final plainText = data.plainText;
    final html = data.html;
    final inAppJson = data.inAppJson;

    final item = DataWriterItem();
    if (plainText != null) {
      item.add(Formats.plainText(plainText));
    }
    if (html != null) {
      item.add(Formats.htmlText(html));
    }
    if (inAppJson != null) {
      item.add(inAppJsonFormat(inAppJson));
    }
    await SystemClipboard.instance?.write([item]);
  }

  Future<void> setPlainText(String text) async {
    await SystemClipboard.instance?.write([
      DataWriterItem()..add(Formats.plainText(text)),
    ]);
  }

  Future<ClipboardServiceData> getData() async {
    if (_mockData != null) {
      return _mockData!;
    }

    final reader = await SystemClipboard.instance?.read();

    if (reader == null) {
      return const ClipboardServiceData();
    }

    final plainText = await reader.readValue(Formats.plainText);
    final html = await reader.readValue(Formats.htmlText);
    final inAppJson = await reader.readValue(inAppJsonFormat);

    return ClipboardServiceData(
      plainText: plainText,
      html: html,
      inAppJson: inAppJson,
    );
  }
}

abstract class ClipboardService1 {
  Future<bool> canProvideInAppJson();
  Future<String?> getInAppJson();

   Future<bool> canProvidePlainText();
  Future<String?> getPlainText();

  Future<bool> canPaste();
}
