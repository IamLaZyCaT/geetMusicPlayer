import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();

//define on audio pugin
  final OnAudioQuery _audioQuery = OnAudioQuery();

//define every song
  List<SongModel> songs = [];

  //defining seaching song
  List<SongModel> filteredSongs = [];

//request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      //search bar in appbar
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 120,
          title: TextFormField(
            cursorColor: Colors.black,
            controller: _searchController,
            onChanged: (value) {
              filterSongs(value);
            },
            decoration: InputDecoration(
              hintText: 'Search...',
              // Add a clear button to the search bar
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.black,
                ),
                onPressed: () => _searchController.clear(),
              ),
              // Add a search icon or button to the search bar
              prefixIcon: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                onPressed: () {
                  // Perform the search here
                  String searchQuery = _searchController.text;
                  filterSongs(searchQuery);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //making two floating action button
                  SizedBox(
                    height: 100,
                    width: 150,
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.black,
                      label: const Column(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 35,
                          ),
                          Text(
                            "Favorite",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    width: 150,
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.black,
                      label: const Column(
                        children: [
                          Icon(
                            Icons.playlist_play,
                            color: Colors.white,
                            size: 35,
                          ),
                          Text(
                            "Playlist",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  const Text(
                    "All Songs",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SingleChildScrollView(
                    child: SizedBox(
                      height: 500,
                      child: FutureBuilder<List<SongModel>>(
                        // Querying the songs
                        future: _audioQuery.querySongs(
                          orderType: OrderType.ASC_OR_SMALLER,
                          uriType: UriType.EXTERNAL,
                          ignoreCase: true,
                        ),
                        builder: (context, snapshot) {
                          // Loading indicator while fetching songs
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasData) {
                            songs = snapshot.data!;
                            // No songs found
                            if (songs.isEmpty) {
                              return const Center(
                                child: Text("No Songs Found"),
                              );
                            }

                            // Filtering the songs based on the search query
                            List<SongModel> displayedSongs =
                                filteredSongs.isNotEmpty
                                    ? filteredSongs
                                    : songs;

                            // Displaying the filtered songs
                            return ListView.builder(
                              itemCount: displayedSongs.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(displayedSongs[index].title),
                                  subtitle:
                                      Text(displayedSongs[index].displayName),
                                  trailing: const Icon(Icons.more_vert),
                                  leading: QueryArtworkWidget(
                                    id: displayedSongs[index].id,
                                    type: ArtworkType.AUDIO,
                                  ),
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            // Error occurred while fetching songs
                            return Center(
                              child: Text("Error: ${snapshot.error}"),
                            );
                          } else {
                            // No songs found
                            return const Center(
                              child: Text("No Songs Found"),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void requestStoragePermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  void filterSongs(String query) {
    setState(() {
      // If search query is empty, display all songs
      if (query.isEmpty) {
        filteredSongs = [];
      } else {
        // Filter the songs based on the search query
        filteredSongs = songs.where((song) {
          return song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.displayName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }
}
