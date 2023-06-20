import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'FavoritesPage.dart';
import 'PlaylistPage.dart';

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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> songs = [];
  List<SongModel> filteredSongs = [];
  Set<int> favoriteSongs = {};
  List<SongModel> playlistSongs = [];

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
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.black,
                ),
                onPressed: () => _searchController.clear(),
              ),
              prefixIcon: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                onPressed: () {
                  // Perform the search here
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
                          ),
                        ],
                      ),
                      onPressed: navigateToFavorites,
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
                          ),
                        ],
                      ),
                      onPressed: navigateToPlaylist,
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
                      child: filteredSongs.isEmpty
                          ? const Center(
                              child: Text("No Songs Found"),
                            )
                          : ListView.builder(
                              itemCount: filteredSongs.length,
                              itemBuilder: (context, index) {
                                SongModel song = filteredSongs[index];
                                bool isFavorite =
                                    favoriteSongs.contains(song.id);
                                return ListTile(
                                  title: Text(song.title),
                                  subtitle: Text(song.displayName),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        PopupMenuItem(
                                          child: Text(isFavorite
                                              ? 'Add to Favorites'
                                              : 'Add to Favorites'),
                                          onTap: () {
                                            toggleFavorite(song);
                                          },
                                        ),
                                        PopupMenuItem(
                                          child: Text('Add to Playlist'),
                                          onTap: () {
                                            addToPlaylist(song);
                                          },
                                        ),
                                      ];
                                    },
                                  ),
                                  leading: QueryArtworkWidget(
                                    id: songs[index].id,
                                    type: ArtworkType.AUDIO,
                                  ),
                                );
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
      loadSongs();
    }
  }

  void loadSongs() async {
    List<SongModel> allSongs = await _audioQuery.querySongs(
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    setState(() {
      songs = allSongs;
      filteredSongs = allSongs;
    });
  }

  void filterSongs(String keyword) {
    setState(() {
      filteredSongs = songs.where((song) {
        return song.title.toLowerCase().contains(keyword.toLowerCase()) ||
            song.displayName.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    });
  }

  void toggleFavorite(SongModel song) {
    setState(() {
      if (favoriteSongs.contains(song.id)) {
        favoriteSongs.remove(song.id);
      } else {
        favoriteSongs.add(song.id);
      }
    });
  }

  void addToPlaylist(SongModel song) {
    setState(() {
      playlistSongs.add(song);
    });
  }

  void navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesPage(
          favoriteSongs: favoriteSongs,
        ),
      ),
    );
  }

  void navigateToPlaylist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistPage(
          playlistSongs: playlistSongs,
        ),
      ),
    );
  }
}
