import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/util/type-def.dart';

class Style {
  static const Color primary = Color(0xff009888);

  static const Color primaryLight = Color(0xff52c9b8);

  static const Color primaryDark = Color(0xff00695b);

  static const Color accent = Color(0xffff7865);

  static const Color accentLight = Color(0xffffaa93);

  static const Color accentDark = Color(0xffc7473a);

  static const Color primaryBlue = Color(0xff2196f3);

  static const Color primaryBlueLight = Color(0xff6ec6ff);

  static const Color primaryBlueDark = Color(0xff0069c0);

  static const Color primaryPink = Color(0xffe91e63);

  static const Color primaryPinkLight = Color(0xffff6090);

  static const Color primaryPinkDark = Color(0xffb0003a);

  static const Color primaryPurple = Color(0xff9c27b0);

  static const Color primaryPurpleLight = Color(0xffd05ce3);

  static const Color primaryPurpleDark = Color(0xff6a0080);

  static const Color primaryDeepOrange = Color(0xfff4511e);

  static const Color primaryDeepOrangeLight = Color(0xffff844c);

  static const Color primaryDeepOrangeDark = Color(0xffb91400);

  static const Color background = Color(0xfffefefe);

  static const Color backgroundGreyLight = Color(0xffebeff2);

  static const Color greyLight = Color(0xffc3c3c3);

  static const Color greyDark = Color(0xffa0a0a0);

  static const Color textColor = Color(0xff273228);

  static const Color danger = Color(0xffe54d42);

  static const Color dangerDark = Color(0xffb82f24);

  static const double dotSize = 18;

  static Widget containerWrapper({Widget widget, bool isBottomSheet = false}) {
    return Container(
      child: widget,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isBottomSheet
              ? BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24))
              : null),
      padding: EdgeInsets.only(
          left: isBottomSheet ? 16 : 12,
          right: isBottomSheet ? 16 : 12,
          bottom: 12,
          top: isBottomSheet ? 16 : 12),
    );
  }

  /// assume padding hor. was 16
  static double maxWidth() {
    return Get.width - 38;
  }

  static Widget renderDot({double size, Color color, EdgeInsets padding}) {
    return Container(
        padding: padding,
        height: size ?? dotSize,
        width: size ?? dotSize,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color ?? Colors.white));
  }

  static Widget renderDotTimeline({double size, Color color}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Style.renderDot(padding: EdgeInsets.only(right: 24)),
        Style.renderDot(color: Style.textColor, size: Style.dotSize / 3)
      ],
    );
  }

  static Widget renderSwitchLabel(
      bool value, Function(bool param) onChange, String title,
      {String subtitle, double gapSubtitle = 4}) {
    Widget infoWidget = Text(title,
        style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis);

    if (subtitle != null) {
      infoWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          infoWidget,
          SizedBox(height: gapSubtitle),
          Text(subtitle, style: TextStyle(color: Style.greyDark, fontSize: 12))
        ],
      );
    }

    Widget row = Row(
      children: [
        Expanded(child: infoWidget),
        SizedBox(width: 8),
        SizedBox(
            height: Style.fieldhHeight,
            child: Switch(onChanged: onChange, value: value))
      ],
    );

    return row;
  }

  static Widget renderLabelInfo(String title, String value, {double bottom}) {
    Widget row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(value, style: TextStyle(color: Style.primaryBlue)),
      ],
    );

    if (bottom != null) {
      return Padding(padding: EdgeInsets.only(bottom: bottom), child: row);
    }

    return row;
  }

  static Widget formSection(Widget child,
      {String label,
      double pre = 16,
      double pra = 16,
      double labelHorSpace = 8,
      bool isRequired = false,
      bool useLabelStyleSection = false,
      bool isHorizontal = false}) {
    List<Widget> childrens = toList(() sync* {
      if (!isHorizontal) yield SizedBox(height: pre);

      if ((label ?? '').isNotEmpty) {
        Widget textWidget = Text(label,
            style: useLabelStyleSection
                ? labelStyleSection()
                : TextStyle(fontSize: 16));
        if (isRequired) {
          textWidget = RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
                style: useLabelStyleSection
                    ? labelStyleSection(color: danger)
                    : TextStyle(
                        fontSize: 16,
                        color: Style.danger,
                        fontFamily: 'Poppins'),
                text: "* ",
                children: [
                  TextSpan(
                      text: label,
                      style: useLabelStyleSection
                          ? labelStyleSection()
                          : TextStyle(color: Style.textColor))
                ]),
          );
        }

        yield textWidget;
        if (!isHorizontal) yield SizedBox(height: labelHorSpace);
      }

      yield child;
      if (!isHorizontal) yield SizedBox(height: pra);
    });

    if (isHorizontal) {
      return Padding(
        padding: EdgeInsets.only(top: pre, bottom: pra),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: childrens,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: childrens,
    );
  }

  static commonInputDecoration(
      {String label,
      bool skipLabelText = false,
      bool skipBorder,
      bool fieldBorder,
      TextStyle helperStyle,
      TextStyle labelStyle,
      TextStyle hintStyle,
      String hintText,
      String helper,
      EdgeInsets padding,
      double raiusBorder = 6,
      String counterText}) {
    var finalBorder = (skipBorder ?? false)
        ? OutlineInputBorder(borderSide: BorderSide.none)
        : (fieldBorder ?? false)
            ? OutlineInputBorder(
                borderRadius: Style.borderRadius(param: raiusBorder),
                borderSide: BorderSide(color: Colors.black26))
            : UnderlineInputBorder(borderSide: BorderSide(color: greyDark));

    return InputDecoration(
        hintText: hintText ?? 'Masukkan ${label ?? 'data'}',
        labelText: label,
        helperText: helper,
        helperStyle: helperStyle,
        counterText: counterText,
        labelStyle:
            labelStyle ?? TextStyle(color: Style.greyLight, fontSize: 14),
        hintStyle: hintStyle ?? TextStyle(color: Style.greyLight, fontSize: 14),
        contentPadding: padding ??
            EdgeInsets.symmetric(
                horizontal: (fieldBorder ?? false) ? 16 : 0,
                vertical: (fieldBorder ?? false) ? 12 : 0),
        border: finalBorder);
  }

  static BorderRadius borderRadius({double param = 6}) =>
      BorderRadius.all(Radius.circular(param));

  static List<BoxShadow> commonBoxShadows = [
    BoxShadow(
      blurRadius: 3,
      color: Color.fromRGBO(0, 0, 0, .12),
      offset: new Offset(0, 1),
    ),
    BoxShadow(
      blurRadius: 2,
      color: Color.fromRGBO(0, 0, 0, .24),
      offset: new Offset(0, 1),
    )
  ];

  static ThemeData theme = ThemeData(
      textTheme: TextTheme(
        bodyText2: TextStyle(color: textColor),
        bodyText1: TextStyle(color: textColor),
        subtitle1: TextStyle(color: textColor),
        subtitle2: TextStyle(color: textColor),
      ),
      primaryColor: primary,
      primaryColorLight: primaryLight,
      primaryColorDark: primaryDark,
      accentColor: accent,
      fontFamily: 'Poppins',
      accentTextTheme: TextTheme().apply(
          displayColor: Colors.white), // color text on top of material widget
      primaryTextTheme: TextTheme().apply(
          displayColor: Colors.white)); // color text on top of material widget

  static const double fieldhHeight = 42;

  static EdgeInsets paddingSection(
          {double left = 16,
          double right = 16,
          double top = 20,
          double bottom = 20}) =>
      EdgeInsets.only(left: left, right: right, bottom: bottom, top: top);

  static BoxDecoration boxDecorSection({bool markActive = false, bool skipShadow = false}) =>
      BoxDecoration(
          boxShadow: skipShadow ? null : Style.commonBoxShadows,
          color: Style.background,
          border: markActive ? Border.all(color: Style.primaryBlue, width: 2) : null,
          borderRadius: Style.borderRadius(param: 12));

  static Widget renderFormSection(Widget child, String label,
      {bool isRequired = false,
      double pra = 16,
      bool isHorizontal = true,
      bool useLabelStyleSection = false}) {
    return Style.formSection(child,
        isHorizontal: isHorizontal,
        isRequired: isRequired,
        pra: pra,
        pre: 0,
        useLabelStyleSection: useLabelStyleSection,
        label: label);
  }

  static TextStyle labelStyleSection({Color color = Style.textColor}) =>
      TextStyle(fontWeight: FontWeight.w500, color: color);

  static Widget renderCharPreview(String char, double wh,
      {double hh, bool skipBd = false}) {
    var borderRadius = skipBd ? null : BorderRadius.all(Radius.circular(6));

    return Container(
        width: wh,
        alignment: Alignment.center,
        height: hh ?? wh,
        child: Text(
          char,
          style: TextStyle(color: Colors.white, fontSize: wh >= 54 ? 26 : 18),
        ),
        decoration:
            BoxDecoration(color: Colors.black26, borderRadius: borderRadius));
  }

  static Widget renderImage(String image, String charId, double wh,
      {bool useHero = false,
      double hh,
      String heroTag,
      Border border,
      double radius = 6,
      bool skipBorderRadius = false,
      String placeholderImg}) {
    var borderRadius = (skipBorderRadius || ((radius ?? 0) == 0))
        ? null
        : BorderRadius.all(Radius.circular(radius));
    bool hasPlaceholder = (placeholderImg ?? "").isNotEmpty;
    Widget errWidget;

    if (hasPlaceholder) {
      errWidget = Container(
        width: wh,
        height: hh ?? wh,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(placeholderImg),
              fit: BoxFit.cover,
            ),
            borderRadius: borderRadius),
      );
    } else {
      bool skipBdFinal = (skipBorderRadius || ((radius ?? 0) == 0));

      errWidget = renderCharPreview(charId, wh, hh: hh, skipBd: skipBdFinal);
    }

    if ((image ?? '').isEmpty) {
      return errWidget;
    }

    Widget renderImageProvider(ImageProvider imageProvider,
        {double newHeight, double newWidth}) {
      return Container(
        width: newWidth ?? wh,
        height: newHeight ?? hh ?? wh,
        decoration: BoxDecoration(
          border: border,
          borderRadius: borderRadius,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    Widget networkImage = CachedNetworkImage(
      width: wh,
      height: hh ?? wh,
      imageUrl: image,
      imageBuilder: (_, ImageProvider imageProvider) {
        return renderImageProvider(imageProvider);
      },
      placeholder: (context, _) {
        return Container(
          width: wh,
          height: hh ?? wh,
          decoration:
              BoxDecoration(borderRadius: borderRadius, color: greyLight),
        );
      },
      errorWidget: (context, url, error) {
        return errWidget;
      },
    );

    if (useHero) {
      networkImage = SizedBox(
        width: wh,
        height: hh ?? wh,
        child: Hero(child: networkImage, tag: heroTag),
      );
    }

    return networkImage;
  }
}
