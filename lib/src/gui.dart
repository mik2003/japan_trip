import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'logic.dart';
import 'map.dart';
import 'sheets_api.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'JapanTrip',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = Placeholder();
      case 2:
        page = LocationsPage();
      case 3:
        page = MapPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    
    List<(Icon, String)> navigationDestinations = [
      (Icon(Icons.home), 'Home'),
      (Icon(Icons.person), 'Login'),
      (Icon(Icons.place), 'Locations'),
      (Icon(Icons.map), 'Map')
    ];

    List<NavigationDestination> navigationBarDestinations = [];
    List<NavigationRailDestination> navigationRailDestinations = [];

    for (final item in navigationDestinations) {
      navigationBarDestinations.add(
        NavigationDestination(icon: item.$1, label: item.$2)
      );
      navigationRailDestinations.add(
        NavigationRailDestination(icon: item.$1, label: Text(item.$2))
      );
    }
      
    return OrientationBuilder(
      builder: (context, orientation) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        if (orientation == Orientation.portrait) {
          return Scaffold(
            body: Center(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
            bottomNavigationBar: NavigationBar(
              destinations: navigationBarDestinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          );
        } else {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    destinations: navigationRailDestinations,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: page,
                  ),
                ),
              ]
            ),
          );
        }
      }
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
        ListTile(
          leading: Icon(Icons.favorite),
          title: Text(pair.asLowerCase),
        ),
      ],
    );
  }
}


class LocationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<dynamic>>>(
      future: getSheetData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while waiting for data.
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var locations = snapshot.data!;
          return ListView(
            children: [
              for (var location in locations)
                if (location.isNotEmpty)
                  ListTile(
                    title: Text(location[0].toString()),
                  )
            ],
          );
        }
      },
    );
  }
}

