import 'package:flutter/material.dart';
import 'package:tamasya/style/string-util.dart';

class MoneyField extends StatefulWidget {
  final double value;
  final Function(double text) onNumberValueChange;
  final InputDecoration inputDecoration;
  final int precision;
  final String symbol;

  MoneyField(
      {Key key,
      this.value,
      this.onNumberValueChange,
      this.inputDecoration,
      this.precision = 0,
      this.symbol})
      : super(key: key);

  @override
  _MoneyFieldState createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  TextEditingController textEditingController;
  FocusNode focusNode;
  bool hasFocus = false;

  @override
  void initState() {
    super.initState();
    textEditingController =
        TextEditingController(text: this.numValueText(widget.value));
    focusNode = FocusNode();

    focusNode.addListener(onFocusChange);
  }

  onFocusChange() {
    setState(() {
      hasFocus = focusNode.hasFocus;

      if (hasFocus) {
        this.textEditingController.text = this.numValueText(this.numberValue);
      } else {
        onBlur();
      }
    });
  }

  String numValueText(double numValue) {
    if ((numValue ?? 0) > 0) {
      return numValue.toStringAsFixed(widget.precision);
    }

    return '';
  }

  onBlur() {
    String masked = this.applyMask(this.numberValue ?? 0);

    if (masked != this.textEditingController.text) {
      this.textEditingController.text = masked;
    }
  }

  String applyMask(double value) {
    List<String> textRepresentation = value
        .toStringAsFixed(widget.precision)
        .replaceAll('.', '')
        .split('')
        .reversed
        .toList(growable: true);

    return formatCurrency(int.parse(textRepresentation.reversed.join('')),
        symbol: widget.symbol ?? '', useDecimal: widget.precision > 0);
  }

  String getOnlyNumbers(String text) {
    String cleanedText = text;

    var onlyNumbersRegex = new RegExp(r'[^\d]');

    cleanedText = cleanedText.replaceAll(onlyNumbersRegex, '');

    return cleanedText;
  }

  double get numberValue {
    List<String> parts = getOnlyNumbers(this.textEditingController.text)
        .split('')
        .toList(growable: true);

    int idxAt = parts.length - widget.precision;

    if (idxAt >= 0 && parts.length > 0) {
      parts.insert(parts.length - widget.precision, '.');
    }

    double numberValue = 0;

    if (parts.join().length > 0) {
      numberValue = double.parse(parts.join());
    }

    return numberValue;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      onChanged: (_) => widget.onNumberValueChange(this.numberValue),
      keyboardType: TextInputType.number,
      controller: textEditingController,
      decoration: widget.inputDecoration,
    );
  }
}
