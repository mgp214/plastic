import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/widgets/home_widget.dart';

import 'model/motif_data.dart';

Future main() async {
  if (kReleaseMode) {
    await DotEnv().load('.env');
  } else {
    await DotEnv().load('.env_dev');
  }

  await MotifData.getMotif();

  runApp(PlasticApp());
}

class PlasticApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'plastic',
      theme: ThemeData(
        primaryColor: Motif.title,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        'home': (context) => HomeWidget(),
      },
      initialRoute: 'home',
    );
  }
}
