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

abstract class ClipboardService {
  Future<bool> canProvideInAppJson();
  Future<String?> getInAppJson();

  Future<bool> canProvidePlainText();
  Future<String?> getPlainText();

  Future<bool> canProvide();

  Future<void> setData(ClipboardServiceData data);
}
