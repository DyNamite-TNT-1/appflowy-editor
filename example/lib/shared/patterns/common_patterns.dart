const _hrefPattern =
    r'https?://(?:www\.)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(?:/[^\s]*)?';
final hrefRegex = RegExp(_hrefPattern);
