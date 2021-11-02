import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/widgets/components/input/border_button.dart';

class DateFieldWidget extends StatelessWidget {
  final DateTime date;
  final Function(DateTime) onChanged;

  const DateFieldWidget({Key key, this.date, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) => BorderButton(
      color: Motif.lightBackground,
      content:
          date == null ? 'unset' : DateFormat('MMMM d, \'\'yy').format(date),
      onPressed: () {
        showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime.tryParse('1950-01-01T00:00:00.000Z'),
                lastDate: DateTime.tryParse('2050-01-01T00:00:00.000Z'))
            .then((value) => onChanged(value));
      });
}
