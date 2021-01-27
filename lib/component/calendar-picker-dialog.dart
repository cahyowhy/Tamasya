import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/component/form-head.dart';
import 'package:tamasya/component/date-range-picker.dart' as DateRangePicker;

class CalendarPickerDialog extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime minDate;
  final DateTime maxDate;
  final List<DateTime> restrictDates;
  final String title;
  CalendarPickerDialog(
      {Key key,
      this.firstDate,
      this.lastDate,
      this.minDate,
      this.maxDate,
      this.title = "Choose date",
      this.restrictDates})
      : super(key: key);

  @override
  _CalendarPickerDialogState createState() => _CalendarPickerDialogState();
}

class _CalendarPickerDialogState extends State<CalendarPickerDialog> {
  DateTime firstDate = DateTime.now().add(Duration(days: 14));
  DateTime lastDate = DateTime.now().add(Duration(days: 21));
  DateTime finalMinDate;
  DateTime finalMaxDate;

  @override
  void initState() {
    super.initState();

    if (widget.firstDate != null) {
      firstDate = widget.firstDate;
    }

    if (widget.lastDate != null) {
      lastDate = widget.lastDate;
    }

    finalMinDate = widget.minDate ??
        DateTime(firstDate.year, firstDate.month, firstDate.day);
    finalMaxDate = widget.maxDate ??
        DateTime(firstDate.year + 2, firstDate.month, firstDate.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 56),
        child: FormHead(title: widget.title),
      ),
      body: DateRangePicker.DatePickerDialog(
          initialFirstDate: firstDate,
          initialLastDate: lastDate,
          showAsCalendar: true,
          onCancelSelected: Get.back,
          firstDate: finalMinDate,
          onSelectedDates: (dates) {
            Get.back(result: dates);
          },
          initialDatePickerMode: DateRangePicker.DatePickerMode.day,
          restrictDates: widget.restrictDates,
          restrictInfoCalendar: widget.restrictDates != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Max. date are tomorrow',))
              : null,
          lastDate: finalMaxDate),
    );
  }
}
