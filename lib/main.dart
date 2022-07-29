import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yask/custom_theme.dart';
import 'package:yask/pages/main_page.dart';
import 'package:yask/pages/match_page.dart';
import 'package:yask/pages/new_match_page.dart';
import 'package:flutter/services.dart';
import 'package:yask/pages/new_round_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yask!',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('pt', ''),
      ],
      theme: CustomTheme.darkTheme,
      initialRoute: mainPageRoute,
      routes: {
        mainPageRoute: (context) => const MainPage(),
        newMatchPageRoute: (context) => const NewMatchPage(),
        matchPageRoute: (context) => const MatchPage(),
        newRoundPageRoute: (context) => const NewRoundPage(),
      },
    );
  }
}
