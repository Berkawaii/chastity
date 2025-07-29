import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'presentation/providers/artist_provider.dart';
import 'presentation/providers/artwork_provider.dart';
import 'presentation/providers/local_provider.dart';
import 'presentation/screens/artwork_detail_screen.dart';
import 'presentation/screens/collection_detail_screen.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/screens/search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VirtualMuseumApp());
}

class VirtualMuseumApp extends StatelessWidget {
  const VirtualMuseumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ArtworkProvider()),
        ChangeNotifierProvider(create: (_) => ArtistProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CollectionProvider()),
      ],
      child: MaterialApp(
        title: 'Virtual Museum',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => const MainNavigationScreen(),
          '/artwork-detail': (_) => const ArtworkDetailScreen(),
          '/collection': (_) => const CollectionDetailScreen(),
          '/create-collection': (_) => const CollectionDetailScreen(),
          '/search': (_) => const SearchScreen(),
        },
      ),
    );
  }
}
