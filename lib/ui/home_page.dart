import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

///import 'package:share/share.dart';

import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String search;

  int offset = 0;

  Future<Map> getGifs() async {
    http.Response response;
    if (search == null || search.isEmpty) {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=FVRPMsywHxojlvg29pKbHCpIpesHvzFG&limit=20&rating=G");
    } else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=FVRPMsywHxojlvg29pKbHCpIpesHvzFG&q=$search&limit=19&offset=$offset&rating=G&lang=en");
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onSubmitted: (text) {
                setState(() {
                  search = text;
                  offset = 0;
                });
              },
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white))),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Container();
                      } else {
                        return createGifTable(context, snapshot);
                      }
                  }
                }),
          )
        ],
      ),
    );
  }

  int getCount(List data) {
    if (search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget createGifTable(context, snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (search == null || index < snapshot.data["data"].length) {
            return GestureDetector(
                onLongPress: () async {
                  await _shareImageFromUrl(snapshot.data["data"][index]["images"]
                  ["fixed_height"]["url"]);
                  /*Share.share(snapshot.data["data"][index]["images"]
                      ["fixed_height"]["url"]);*/
                },
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GifPage(snapshot.data["data"][index])));
                },
                child: FadeInImage.memoryNetwork(
                    image: snapshot.data["data"][index]["images"]
                        ["fixed_height"]["url"],
                    placeholder: kTransparentImage,
                    height: 300.0,
                    fit: BoxFit.cover));
          } else {
            return Container(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    offset += 19;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70),
                    Text("Carregar mais...",
                        style: TextStyle(color: Colors.white, fontSize: 22.0))
                  ],
                ),
              ),
            );
          }
        });
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
