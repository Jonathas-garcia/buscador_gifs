import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///import 'package:share/share.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class GifPage extends StatelessWidget {
  final Map gifData;

  GifPage(this.gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async{
              await _shareImageFromUrl(gifData["images"]["fixed_height"]["url"]);
              ///Share.share(gifData["images"]["fixed_height"]["url"]);
            },
          )
        ],
        title: Text(gifData["title"]),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Image.network(gifData["images"]["fixed_height"]["url"]),
      ),
    );
  }
}

Future<void> _shareImageFromUrl(urlImage) async {
  try {
    var request = await HttpClient().getUrl(Uri.parse(urlImage));
    var response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    await Share.file('ESYS AMLOG', 'amlog.gif', bytes, 'image/gif');
  } catch (e) {
    print('error: $e');
  }
}