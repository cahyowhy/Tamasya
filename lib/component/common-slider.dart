import 'package:flutter/material.dart';
import 'package:tamasya/style/style.dart';

/// if use range, use props : valueLowest, valueHighest, onChangeRanges
class CommonSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final int divisions;
  final bool parseInt;
  final Function(double) onChanged;
  final bool useMinMaxLabel;
  final String labelMin;
  final String labelMax;
  final Widget labelWidgetMin;
  final Widget labelWidgetMax;
  final bool showReset;

  /// for range
  final double valueLowest;
  final double valueHighest;
  final RangeLabels rangeLabels;
  final Function(RangeValues) onChangeRanges;

  const CommonSlider(
      {Key key,
      @required this.min,
      @required this.max,
      this.label,
      this.divisions,
      this.onChanged,
      this.useMinMaxLabel = true,
      this.value,
      this.parseInt = true,
      this.valueLowest,
      this.valueHighest,
      this.onChangeRanges,
      this.rangeLabels,
      this.labelMin,
      this.labelMax,
      this.labelWidgetMin,
      this.labelWidgetMax,
      this.showReset = true})
      : super(key: key);

  bool get useRange {
    return valueLowest != null &&
        valueHighest != null &&
        onChangeRanges != null;
  }

  @override
  Widget build(BuildContext context) {
    Widget slider;

    if (useRange) {
      slider = RangeSlider(
        values: RangeValues(valueLowest, valueHighest),
        min: min,
        max: max,
        divisions: divisions,
        labels: rangeLabels,
        onChanged: onChangeRanges,
      );
    } else {
      slider = Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
      );
    }

    if (useMinMaxLabel || (labelWidgetMax != null && labelWidgetMin != null)) {
      Widget labelStart;
      Widget labelEnd;
      bool useMultiRow = labelWidgetMax != null && labelWidgetMin != null;

      if (labelWidgetMax != null && labelWidgetMin != null) {
        labelStart = labelWidgetMin;
        labelEnd = labelWidgetMax;
      } else {
        String labelMinFinal =
            labelMin ?? (parseInt ? (min ?? 0).toInt() : (min ?? 0)).toString();
        String labelMaxFinal =
            labelMax ?? (parseInt ? (max ?? 0).toInt() : (max ?? 0)).toString();

        useMultiRow = labelMinFinal.length > 2 || labelMaxFinal.length > 2;

        labelStart = Text(
          labelMinFinal,
          style:
              TextStyle(color: Style.primaryBlue, fontWeight: FontWeight.w500),
        );

        labelEnd = Text(
          labelMaxFinal,
          style:
              TextStyle(color: Style.primaryBlue, fontWeight: FontWeight.w500),
        );
      }

      Widget child;

      if (useMultiRow) {
        child = Column(
          children: [
            slider,
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [labelStart, labelEnd],
                )),
            SizedBox(height: 12),
          ],
        );
      } else {
        child = Row(
          children: [
            SizedBox(width: 6),
            Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: labelStart),
            Expanded(child: slider),
            Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: labelEnd),
            SizedBox(width: 6),
          ],
        );
      }

      slider = Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: Style.borderRadius(),
            color: Style.backgroundGreyLight),
        child: child,
      );
    }

    if (showReset) {
      return Row(
        children: [
          Expanded(child: slider),
          SizedBox(width: 12),
          InkWell(
            onTap: () {
              if (useRange) {
                onChangeRanges(RangeValues(0, 0));
              } else {
                onChanged(0);
              }
            },
            child: Text("Reset",
                style: TextStyle(color: Style.primaryBlue, fontSize: 12)),
          )
        ],
      );
    }

    return slider;
  }
}
