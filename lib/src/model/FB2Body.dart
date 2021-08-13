import 'package:fb2_parse/src/model/FB2Section.dart';

class FB2Body {
  /// title
  late final String? title;

  /// epigraph
  late final String? epigraph;

  /// book chapters
  late final List<FB2Section>? sections;

  FB2Body(final String body) {
    /// parse [title]
    title = RegExp(r"<title>([\s\S]+?)<\/title>").firstMatch(body)?.group(1);

    /// parse [epigraph]
    epigraph = RegExp(r"<epigraph>([\s\S]+?)<\/epigraph>").firstMatch(body)?.group(1);

    /// parse [sections]
    final Iterable<RegExpMatch> _sections = RegExp(r"<section[\s\S]+?>([\s\S]+?)<\/section>").allMatches(body);
    sections = [];
    for (var _section in _sections) {
      sections!.add(FB2Section(_section.group(1)));
    }
  }

  @override
  String toString() {
    return 'FB2Body(title: $title, epigraph: $epigraph, number of sections: ${sections?.length})';
  }
}
