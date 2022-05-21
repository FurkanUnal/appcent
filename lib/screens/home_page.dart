import 'dart:convert';
import 'package:appcent/screens/details_page.dart';
import 'package:appcent/screens/fav_page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  PageController pageController = PageController();

  late Future<List<Game>> futureGame;

  int currentPageIndex = 0;
  int searchLength = 0;
  bool searchBool = false;
  String searchString = "";

  @override
  void initState() {
    super.initState();
    futureGame = fetchGame();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: TextField(
          onChanged: (String value) {
            setState(() {
              searchString = value.toLowerCase();
              searchLength = value.length;
              if (searchLength >= 3) {
                searchBool = true;
              } else {
                searchBool = false;
              }
            });
          },
          cursorColor: Colors.orange,
          cursorHeight: 28,
          controller: searchController,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
            suffixIcon: Icon(
              Icons.search,
              color: Colors.orange,
            ),
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.orange, fontSize: 22),
          ),
        ),
      ),
      body: Column(
        children: [
          if (searchBool) ...[
            Expanded(
              child: FutureBuilder(
                future: futureGame,
                builder: (context, AsyncSnapshot<List<Game>> snapshot) {
                  if (snapshot.hasData) {
                    return Center(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (snapshot.data![index].name
                              .toLowerCase()
                              .contains(searchString)) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailPage(
                                          index: snapshot.data![index].id)),
                                );
                              },
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
                            );
                          }
                          return Container();
                        },
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 25),
                    child: SizedBox(
                      height: 200,
                      child: FutureBuilder<List<Game>>(
                          future: futureGame,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return PageView(
                                controller: pageController,
                                children: <Widget>[
                                  AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                                index: snapshot.data![0].id),
                                          ),
                                        );
                                      },
                                      child: Image(
                                          image: NetworkImage(snapshot
                                              .data![0].background_image),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                                index: snapshot.data![1].id),
                                          ),
                                        );
                                      },
                                      child: Image(
                                          image: NetworkImage(snapshot
                                              .data![1].background_image),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                                index: snapshot.data![2].id),
                                          ),
                                        );
                                      },
                                      child: Image(
                                          image: NetworkImage(snapshot
                                              .data![2].background_image),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          }),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    child: SmoothPageIndicator(
                      controller: pageController,
                      count: 3,
                      effect: const ExpandingDotsEffect(
                          radius: 8,
                          dotHeight: 8,
                          dotWidth: 8,
                          dotColor: Colors.black,
                          activeDotColor: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Game>>(
                      future: futureGame,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              itemCount: snapshot.data!.length - 3,
                              itemBuilder: (context, index) {
                                return Card(
                                  elevation: 3,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailPage(
                                              index:
                                                  snapshot.data![index + 3].id),
                                        ),
                                      );
                                    },
                                    leading: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minWidth: 64,
                                        minHeight: 64,
                                        maxWidth: 64,
                                        maxHeight: 64,
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 4 / 3,
                                        child: Image.network(snapshot
                                            .data![index + 3].background_image),
                                      ),
                                    ),
                                    title: Text(snapshot.data![index + 3].name),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                            "Metacritic: ${snapshot.data![index + 3].metacritic.toString()}"),
                                        const Text("  -  "),
                                        Text(snapshot.data![index + 3].released,
                                            textAlign: TextAlign.right),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
            if (currentPageIndex == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritePage()),
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

class Game {
  final int id;
  final String name;
  final String background_image;
  final int metacritic;
  final String released;

  const Game(
      {required this.id,
      required this.name,
      required this.background_image,
      required this.metacritic,
      required this.released});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      name: json['name'],
      background_image: json['background_image'],
      metacritic: json['metacritic'],
      released: json['released'],
    );
  }
}
