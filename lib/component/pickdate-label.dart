import 'package:flutter/material.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/underscore.dart';

class PickdateLabel extends StatelessWidget {
  const PickdateLabel(
      {Key key,
      this.isRequired = false,
      this.endDate,
      @required this.startDate,
      @required this.iconData,
      @required this.onTap,
      this.placeholder})
      : super(key: key);
  final DateTime startDate;
  final DateTime endDate;
  final bool isRequired;
  final IconData iconData;
  final Function onTap;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    bool hasData = startDate != null;
    String label = placeholder ?? 'Pick date';
    String labelDay = "";

    if (hasData) {
      label = formatDate(date: startDate);
      labelDay = formatDate(date: startDate, format: Constant.DATE_DAY);

      if (endDate != null && !isSameDates([endDate, startDate])) {
        label += " - ${formatDate(date: endDate)}";
        labelDay +=
            " - ${formatDate(date: endDate, format: Constant.DATE_DAY)}";
      }
    }

    Widget info = Text(label, style: TextStyle(fontWeight: FontWeight.w500));

    if (isRequired) {
      info = Row(children: [
        Text("* ", style: Style.labelStyleSection(color: Style.danger)),
        info
      ]);
    }

    if (hasData) {
      info = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          info,
          Text(labelDay, style: TextStyle(color: Style.greyDark, fontSize: 12))
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: Style.borderRadius(param: 24),
                  color: Style.backgroundGreyLight),
              padding: const EdgeInsets.all(8),
              child: Icon(iconData, size: 24)),
          SizedBox(width: 12),
          info
        ],
      ),
    );
  }
}
