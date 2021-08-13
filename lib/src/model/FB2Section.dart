class FB2Section {
  late final String? title;
  late final String? content;

  FB2Section(String? content) {
    this.content = content;
    title = RegExp(r"<title>([\s\S]+?)<\/title>").firstMatch(content ?? '')?.group(1);
  }
}
