import 'dart:convert';
import 'package:appcent/models/favorite_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget with ChangeNotifier {
  DetailPage({Key? key, required this.index}) : super(key: key);
  int index;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<List<Detail>> futureDetail;
  final favorite = FavoriteModel();

  @override
  void initState() {
    super.initState();
    futureDetail = fetchDetails(widget.index);
  }

  Future<List<Detail>> fetchDetails(int index) async {
    final response = await http.get(Uri.parse(
        'https://rawg.io/api/games/$index?key=bd4593f79d8a48ba96cc734decc15b60'));
    if (response.statusCode == 200) {
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      List<Detail> details = [];
      Detail detail = Detail(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        metacritic: data['metacritic'],
        released: data['released'],
        background_image: data['background_image'],
      );
      details.add(detail);
      return details;
    } else {
      throw Exception('Failed to load the details of this game');
    }
  }

  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    var myList = context.watch<FavoriteModel>().ids;

    return Scaffold(
      body: FutureBuilder<List<Detail>>(
          future: futureDetail,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Stack(
                        children: [
                          Image.network(snapshot.data![0].background_image),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.orange,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          if (!myList.contains(snapshot.data![0].id)) {
                            context
                                .read<FavoriteModel>()
                                .addID(snapshot.data![0].id);
                          } else {
                            context
                                .read<FavoriteModel>()
                                .removeID(snapshot.data![0].id);
                          }
                        },
                        icon: Icon(
                          myList.contains(snapshot.data![0].id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: myList.contains(snapshot.data![0].id)
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      snapshot.data![0].name,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text("Released date: ${snapshot.data![0].released}",
                        style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                        "Metacritic Score: ${snapshot.data![0].metacritic}",
                        style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                        parse(parse(snapshot.data![0].description).body!.text)
                            .documentElement!
                            .text),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class Detail {
  final int id;
  final String name;
  final String description;
  final int metacritic;
  final String released;
  final String background_image;

  const Detail({
    required this.id,
    required this.name,
    required this.description,
    required this.metacritic,
    required this.released,
    required this.background_image,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      metacritic: json['metacritic'],
      released: json['released'],
      background_image: json['background_image'],
    );
  }
}
