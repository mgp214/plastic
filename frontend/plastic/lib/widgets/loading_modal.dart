import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';

class LoadingModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Motif.title),
        ),
      );
}
