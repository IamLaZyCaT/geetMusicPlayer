import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistPage extends StatefulWidget {
  final List<SongModel> playlistSongs;

  const PlaylistPage({Key? key, required this.playlistSongs}) : super(key: key);

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist'),
      ),
      body: ListView.builder(
        itemCount: widget.playlistSongs.length,
        itemBuilder: (context, index) {
          SongModel song = widget.playlistSongs[index];
          bool isAddlist = widget.playlistSongs.contains(song.id);
          return ListTile(
            title: Text(song.title),
            subtitle: Text(song.displayName),
            leading: QueryArtworkWidget(
              id: widget.playlistSongs[index].id,
              type: ArtworkType.AUDIO,
            ),
            trailing: PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    child: Text(isAddlist
                        ? 'Remove from Playlist'
                        : 'Remove from Playlist'),
                    onTap: () {
                      togglePlaylist(song);
                    },
                  ),
                ];
              },
            ),
          );
        },
      ),
    );
  }

  void togglePlaylist(SongModel song) {
    setState(() {
      if (widget.playlistSongs.contains(song.id)) {
        widget.playlistSongs.remove(song.id);
      }
    });
  }
}
