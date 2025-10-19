import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormattedNumberTextEditingController extends TextEditingController {
  final NumberFormat formatter;
  final double initialValue;
  final int numDecimals;

  double _value;
  String _displayText;

  double get doubleValue => double.parse(_value.toStringAsFixed(numDecimals));

  FormattedNumberTextEditingController({
    required this.formatter,
    this.initialValue = 0.0,
    this.numDecimals = 2,
  }) : _value = initialValue,
       _displayText = formatter.format(initialValue) {
    text = formatter.format(_value);
    selection = TextSelection.fromPosition(TextPosition(offset: text.length));
    addListener(_listener);
  }

  @override
  void dispose() {
    removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    if (_displayText == text) {
      selection = TextSelection.fromPosition(TextPosition(offset: text.length));
      return;
    }

    // Use a digits-only string to determine the smallest currency unit
    // (e.g. cents). This avoids relying on `String.length` which is measured
    // in UTF-16 code units and breaks for multi-code-unit characters like
    // emoji. However, if the user presses backspace and only a non-digit
    // character (like an emoji or currency symbol) was removed, the digits
    // string will be unchanged — we should interpret that backspace as
    // removing the last digit.
    String textNumberString = text.replaceAll(RegExp(r'\D'), '');
    final String oldDigits = _displayText.replaceAll(RegExp(r'\D'), '');

    // If lengths of digit-strings are the same but the visible text got
    // shorter, the user most likely deleted a non-digit (emoji/currency
    // char). Treat that as deleting one digit from the end.
    if (textNumberString.length == oldDigits.length &&
        text.length < _displayText.length) {
      if (oldDigits.isNotEmpty) {
        textNumberString = oldDigits.substring(0, oldDigits.length - 1);
      } else {
        textNumberString = '';
      }
    }

    // read textNumberString as int (smallest unit, e.g. cents) and divide it by 10^numDecimals
    final textValue = int.tryParse(textNumberString) ?? 0;
    final divisor = pow(10, numDecimals);
    _value = textValue / divisor;
    // Setting the text triggers another listener call, so we have to store the
    // updated value before re-triggering that to avoid stack overflows.
    _displayText = formatter.format(_value);
    text = _displayText;
    selection = TextSelection.fromPosition(TextPosition(offset: text.length));
  }
}

class NumberInputField extends StatelessWidget {
  final Widget label;
  final double? initialValue;
  final String? helperText;
  final bool enabled;

  /// Defaults to TextInputAction.next
  final TextInputAction textInputAction;
  final void Function(double value)? onChanged;
  final String? Function(String? value)? validator;

  final NumberFormat numberFormatter;

  const NumberInputField({
    required this.label,
    required this.numberFormatter,
    this.initialValue,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.helperText,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return _InternalNumberInputField(
      label: label,
      enabled: enabled,
      initialValue: initialValue,
      textInputAction: textInputAction,
      onChanged: onChanged,
      helperText: helperText,
      validator: validator,
      numberFormatter: numberFormatter,
    );
  }
}

class _InternalNumberInputField extends StatefulWidget {
  final Widget label;
  final double? initialValue;
  final String? helperText;
  final bool enabled;

  /// Defaults to TextInputAction.next
  final TextInputAction textInputAction;
  final void Function(double value)? onChanged;
  final String? Function(String? value)? validator;
  final NumberFormat numberFormatter;

  const _InternalNumberInputField({
    required this.label,
    required this.numberFormatter,
    this.initialValue,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.helperText,
    this.enabled = true,
    this.validator,
  });

  @override
  State<_InternalNumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<_InternalNumberInputField> {
  late FormattedNumberTextEditingController _controller;

  void _listener() {
    widget.onChanged?.call(_controller.doubleValue);
  }

  @override
  void initState() {
    super.initState();
    _controller = FormattedNumberTextEditingController(
      formatter: widget.numberFormatter,
      initialValue: widget.initialValue ?? 0.0,
    );
    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        label: widget.label,
        enabled: widget.enabled,
        helperText: widget.helperText,
        hintText: widget.numberFormatter.format(0),
      ),
      controller: _controller,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
    );
  }
}
