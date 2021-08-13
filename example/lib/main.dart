import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:fb2_parse/fb2_parse.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Material App', home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    return Scaffold(
      appBar: AppBar(
        title: Text('Material App Bar'),
      ),
      body: Center(
          child: TextButton(
        child: Text('Open fb2'),
        onPressed: () async {
          /// Pick File
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result == null) return;

          /// if the file extension is not fb2 or zip (fb2 files are often zipped)
          if (result.files.first.extension != 'fb2' && result.files.first.extension != 'zip') return;

          /// path to the picked file
          String path = result.paths.first!;

          /// encode zip
          if (result.files.first.extension == 'zip') {
            final bytes = File(result.files.first.path!).readAsBytesSync();
            final archive = ZipDecoder().decodeBytes(bytes);
            String pathOut = (await getApplicationDocumentsDirectory()).path;
            File file = File(pathOut + archive.first.name)
              ..createSync()
              ..writeAsBytesSync(archive.first.content);
            path = file.path;
          }

          /// parse fb2 file
          FB2Book _book = FB2Book(path);
          await _book.parse();

          /// open new Page
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return SafeArea(
              child: Scaffold(body: SizedBox.expand(

                  /// the content of the fb2 file is html
                  child: WebView(onWebViewCreated: (WebViewController webViewController) async {
                final WebViewController _controller = webViewController;

                /// load data. You can add design tags
                await _controller.loadUrl(Uri.dataFromString('''
                              <style>
                              body{
                                background-color: blue; 
                              } 
                              p {
                                background-color: yellow; 
                                color: black; 
                              }
                              </style>
                                <body>
                                  ${_book.body.sections![0].content}
                                <body/>
                                ''', mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
              }))),
            );
          }));
        },
      )),
    );
  }
}
