import 'package:flutter/material.dart';
import 'package:meme_generator/pages/meme_generator_screen.dart';
import 'package:meme_generator/pages/my_collections_screen.dart';
import 'package:meme_generator/pages/select_meme_screen.dart';

/// App,s main widget.
class MyApp extends StatelessWidget {
  /// Constructor for [MyApp].
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/selectSample',
      routes: {
        '/createMeme': (ctx) => const GeneratorMemeScreen(),
        '/myCollectionsMems': (ctx) => const CollectionsMemsSrceen(),
        '/selectSample': (ctx) => const SelectSampleScreen(),
      },
    );
  }
}
