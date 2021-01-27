import 'package:flutter/material.dart';
import 'package:tamasya/style/string-util.dart';
import 'package:tamasya/style/style.dart';

class SelectOption extends StatelessWidget {
  final List<String> options;
  final List<String> values;
  final String value;
  final Function(String param) onChange;
  final Widget Function(String item, bool same) renderChild;
  final Function(List<String> param) onChangeValues;
  const SelectOption(
      {Key key,
      @required this.options,
      this.value,
      this.onChange,
      this.values,
      this.onChangeValues,
      this.renderChild})
      : super(key: key);

  bool get useMultiValues => values != null && onChangeValues != null;

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 12,
        direction: Axis.horizontal,
        children: this.options.map((item) {
          bool same = false;

          if (useMultiValues) {
            same = values.contains(item);
          } else {
            same = item == value;
          }

          Widget childText;
          if (renderChild != null) {
            childText = renderChild(item, same);
          } else {
            childText = Text(startCase(item),
                style: TextStyle(color: same ? Colors.white : Style.textColor));
          }

          return InkWell(
            onTap: () {
              if (!same && !useMultiValues) {
                onChange(item);
              } else if (useMultiValues) {
                if (same) {
                  onChangeValues(
                      values.where((element) => element != item).toList());
                } else {
                  onChangeValues([...values, item]);
                }
              }
            },
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                  boxShadow: Style.commonBoxShadows,
                  borderRadius: Style.borderRadius(param: 24),
                  color: same ? Style.accent : Colors.white),
              child: childText,
            ),
          );
        }).toList());
  }
}
