import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fb2_parse/src/model/FB2Body.dart';
import 'package:fb2_parse/src/model/FB2Description.dart';
import 'package:fb2_parse/src/model/FB2Image.dart';

class FB2Book {
  /// path to .fb2 file
  late final String path;

  /// the file itself
  late final File file;

  /// book description
  late final FB2Description description;

  /// main body of the book
  late final FB2Body body;

  /// all images in the book
  late final List<FB2Image> images;

  FB2Book(this.path) {
    file = File(path);
  }

  /// Parsing the book
  Future<void> parse() async {
    final pathLower = path.toLowerCase();

    var res = "";

    if (pathLower.endsWith('.fbz') || pathLower.endsWith('.fb2.zip')) {
      final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
      final fb2 = archive.files
          .firstWhere((file) => file.name.toLowerCase().endsWith('.fb2'));
      final bytes = fb2.content as List<int>;
      res = String.fromCharCodes(bytes);
    } else {
      res = await file.readAsString();
    }

    /// parse [images]
    final Iterable<RegExpMatch> _images =
        RegExp(r'<binary[\s\S]+?>([\s\S]+?)<\/binary>').allMatches(res);
    images = [];
    for (var image in _images) {
      images.add(FB2Image(image.group(0)!));
    }

    /// replacing the fb2 tag <image ...> with html tag <img ...>
    res = res.replaceAllMapped(RegExp(r'<image([\s\S]+?)\/>'), (match) {
      String name = RegExp(r'="#([\s\S]+?)"')
          .firstMatch(match.group(1)!)
          ?.group(1) as String;
      FB2Image? currentImage;
      for (var image in images) {
        if (image.name == name) currentImage = image;
      }
      if (currentImage == null) return match.group(0)!;
      return '<img src="data:image/png;base64, ${currentImage.bytes}"/>';
    });

    /// replacing the fb2 tag <empty-line/> with html tag <br>
    res = res.replaceAllMapped(RegExp(r'<empty-line.?>'), (_) {
      return '<br>';
    });

    /// remove the tag <a l:href ...>
    res = res.replaceAllMapped(
        RegExp(r'<a ([a-zA-Z\:]*)href([\s\S]+?)>([\s\S]+?)<\/a>'), (match) {
      return '${match.group(3)}';
    });

    /// parse [description]
    final String description = RegExp(r"<description>([\s\S]+)<\/description>")
        .firstMatch(res)
        ?.group(1) as String;
    this.description = FB2Description(description);

    /// parse [body]
    final String body =
        RegExp(r"<body>([\s\S]+)<\/body>").firstMatch(res)?.group(1) as String;
    this.body = FB2Body(body);
  }
}
