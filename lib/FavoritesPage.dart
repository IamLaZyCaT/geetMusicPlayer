import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavoritesPage extends StatefulWidget {
  final Set<int> favoriteSongs;

  FavoritesPage({Key? key, required this.favoriteSongs}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> playlistSongs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Songs'),
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          List<SongModel>? allSongs = snapshot.data;
          if (allSongs == null || allSongs.isEmpty) {
            return Center(
              child: Text('No Songs Found'),
            );
          }

          // Filter the list of all songs based on favorite song IDs
          List<SongModel> favoriteSongsList = allSongs
              .where((song) => widget.favoriteSongs.contains(song.id))
              .toList();

          if (favoriteSongsList.isEmpty) {
            return Center(
              child: Text('No Favorite Songs Found'),
            );
          }

          return ListView.builder(
            itemCount: favoriteSongsList.length,
            itemBuilder: (context, index) {
              SongModel song = favoriteSongsList[index];
              bool isFavorite = widget.favoriteSongs.contains(song.id);

              return ListTile(
                title: Text(song.title),
                subtitle: Text(song.displayName),
                trailing: PopupMenuButton(
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: Text(isFavorite
                            ? 'Remove from Favorites'
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
                  id: allSongs[index].id,
                  type: ArtworkType.AUDIO,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void toggleFavorite(SongModel song) {
    setState(() {
      if (widget.favoriteSongs.contains(song.id)) {
        widget.favoriteSongs.remove(song.id);
      } else {
        widget.favoriteSongs.add(song.id);
      }
    });
  }

  void addToPlaylist(SongModel song) {
    setState(() {
      playlistSongs.add(song);
    });
  }
}
