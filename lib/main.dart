import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();

//define on audio pugin
  final OnAudioQuery _audioQuery = OnAudioQuery();

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
      child: Scaffold(
        //search bar in appbar
        appBar: AppBar(
          toolbarHeight: 120,
          title: TextFormField(
            cursorColor: Colors.black,
            controller: _searchController,
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

                          //default values
                          future: _audioQuery.querySongs(
                            orderType: OrderType.ASC_OR_SMALLER,
                            uriType: UriType.EXTERNAL,
                            ignoreCase: true,
                          ),
                          builder: (context, item) {
                            //loading content indicator
                            if (item.data == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            //no songs found
                            if (item.data!.isEmpty) {
                              return const Center(
                                child: Text("No Songs Found"),
                              );
                            }

                            //showing the songs
                            return ListView.builder(
                                itemCount: item.data!.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(item.data![index].title),
                                    subtitle:
                                        Text(item.data![index].displayName),
                                    trailing: const Icon(Icons.more_vert),
                                    leading: QueryArtworkWidget(
                                      id: item.data![index].id,
                                      type: ArtworkType.AUDIO,
                                    ),
                                  );
                                });
                          }),
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
//ensure build method is called
      setState(() {});
    }
  }
}
