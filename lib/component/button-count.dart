import 'package:flutter/material.dart';
import 'package:tamasya/style/style.dart';

class ButtonCount extends StatelessWidget {
  final int value;
  final int maxValue;
  final int minValue;
  final Function(int param) onChange;
  const ButtonCount(
      {Key key,
      @required this.value,
      @required this.onChange,
      this.maxValue,
      this.minValue})
      : super(key: key);

  Widget renderButton({bool isSubstraction = false}) {
    return InkWell(
      onTap: () {
        if ((value != 0 || !isSubstraction) &&
            (value != maxValue || isSubstraction) &&
            (value != minValue || !isSubstraction)) {
          onChange(isSubstraction ? value - 1 : value + 1);
        }
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: Style.borderRadius(param: 2500),
          color: isSubstraction ? Style.danger : Style.primary,
        ),
        child: Icon(isSubstraction ? Icons.remove : Icons.add,
            color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        renderButton(),
        SizedBox(width: 16),
        Container(
          alignment: Alignment.center,
          width: 28,
          child: Text(value.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        ),
        SizedBox(width: 16),
        renderButton(isSubstraction: true),
      ],
    );
  }
}
