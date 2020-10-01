import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plastic/widgets/home_widget.dart';

import 'model/motif.dart';

Future main() async {
  if (kReleaseMode) {
    await DotEnv().load('.env');
  } else {
    await DotEnv().load('.env_dev');
  }

  await Motif.getMotif();

  runApp(PlasticApp());
}

class PlasticApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'plastic',
      theme: ThemeData(
        primaryColor: Motif.activeMotif.colors.title,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        'home': (context) => HomeWidget(),
      },
      initialRoute: 'home',
    );
  }
}
