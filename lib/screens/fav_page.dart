import 'dart:convert';
import 'package:appcent/models/favorite_model.dart';
import 'package:appcent/screens/details_page.dart';
import 'package:appcent/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class FavoritePage extends StatefulWidget with ChangeNotifier {
  FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  int currentPageIndex = 1;
  late Future<List<Game>> futureGame;

  Future<List<Game>> fetchGame() async {
    final response = await http.get(Uri.parse(
        'https://rawg.io/api/games?key=bd4593f79d8a48ba96cc734decc15b60'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['results'];
      List<Game> games = [];
      for (var u in data) {
        Game game = Game(
          id: u['id'],
          name: u['name'],
          background_image: u['background_image'],
          metacritic: u['metacritic'],
          released: u['released'],
        );
        games.add(game);
      }
      return games;
    } else {
      throw Exception('Failed to load games');
    }
  }

  @override
  void initState() {
    super.initState();
    futureGame = fetchGame();
  }

  @override
  Widget build(BuildContext context) {
    final myList = context.read<FavoriteModel>().ids;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorite Games",
          style: TextStyle(
              color: Colors.orange, fontSize: 22, fontWeight: FontWeight.w400),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: futureGame,
        builder: (context, AsyncSnapshot<List<Game>> snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  if (myList.contains(snapshot.data![index].id)) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(index: snapshot.data![index].id)),
                        ).then((value) => setState(() {}));
                      },
                      child: Card(
                        child: ListTile(
                          leading: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 80,
                              minHeight: 80,
                              maxWidth: 80,
                              maxHeight: 80,
                            ),
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: Image.network(
                                  snapshot.data![index].background_image),
                            ),
                          ),
                          title: Text(snapshot.data![index].name),
                          subtitle: Row(
                            children: [
                              Text(
                                  "Metacritic: ${snapshot.data![index].metacritic.toString()}"),
                              const Text("  -  "),
                              Text(snapshot.data![index].released),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
            if (currentPageIndex == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              size: 30,
            ),
            selectedIcon: Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.favorite_border,
              size: 30,
            ),
            selectedIcon: Icon(Icons.favorite, size: 30),
            label: 'Favorite',
          ),
        ],
      ),
    );
  }
}
