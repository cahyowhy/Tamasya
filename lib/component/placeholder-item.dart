import 'package:flutter/widgets.dart';
import 'package:tamasya/style/style.dart';

class PlaceholderWidget extends StatelessWidget {
  final int repeat;
  final double paddingTop;
  final double paddingForRestItem;
  final Color color;
  const PlaceholderWidget(
      {Key key,
      this.repeat = 1,
      this.paddingForRestItem = 12,
      this.color,
      this.paddingTop = 6})
      : super(key: key);

  Widget _renderPlaceholder() {
    return Row(
      children: [
        Container(
            decoration: BoxDecoration(
                borderRadius: Style.borderRadius(),
                color: color ?? Style.backgroundGreyLight),
            width: 70,
            height: 70),
        SizedBox(width: 8),
        Expanded(
            child: Column(children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: Style.borderRadius(),
                  color: color ?? Style.backgroundGreyLight),
              height: 20),
          SizedBox(height: 4),
          Container(
              decoration: BoxDecoration(
                  borderRadius: Style.borderRadius(),
                  color: color ?? Style.backgroundGreyLight),
              height: 20),
          SizedBox(height: 4),
          Container(
              decoration: BoxDecoration(
                  borderRadius: Style.borderRadius(),
                  color: color ?? Style.backgroundGreyLight),
              height: 20),
        ]))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: this.repeat,
      itemBuilder: (BuildContext _, int index) {
        return Padding(
          child: _renderPlaceholder(),
          padding: EdgeInsets.only(
              top: index == 0 ? this.paddingTop : this.paddingForRestItem),
        );
      },
    );
  }
}
