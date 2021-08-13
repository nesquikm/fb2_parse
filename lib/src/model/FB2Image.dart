class FB2Image {
  /// image in base64
  late final String bytes;

  /// content type (png or jpeg)
  late final String contentType;

  /// image name
  late final String name;

  FB2Image(final String binary) {
    contentType = RegExp(r'content-type="([\s\S]+?)"').firstMatch(binary)?.group(1) as String;
    name = RegExp(r'id="([\s\S]+?)"').firstMatch(binary)?.group(1) as String;
    bytes = RegExp(r'<binary[\s\S]+?>([\s\S]+)<\/binary>').firstMatch(binary)?.group(1) as String;
  }

  @override
  String toString() {
    return 'FB2Image(name: $name)';
  }
}
