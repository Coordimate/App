import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';
import 'package:coordimate/widget_keys.dart';

class EditableTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int? maxLines;
  final Function(String) onSubmit;
  final double fontSize;
  final double padding;
  final int? maxLength;
  final double iconSize;
  final double horizontalPadding;
  final TextAlign textAlign;
  final int? minChars;
  final String? errorMessage;
  final Color textColor;
  final Color borderColor;
  final String? placeHolderText; // New optional field

  const EditableTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    this.fontSize = kDefaultFontSize,
    this.padding = 24.0,
    this.maxLines,
    this.maxLength,
    this.iconSize = 24.0,
    this.horizontalPadding = 0.0,
    this.textAlign = TextAlign.center,
    this.minChars,
    this.errorMessage,
    this.textColor = darkBlue,
    this.borderColor = darkBlue,
    this.placeHolderText, // Define placeHolderText as an optional argument
  });

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  bool isEditing = false;
  String? errorText;
  String lastValidValue = '';

  @override
  void initState() {
    super.initState();
    if (widget.minChars != null &&
        widget.maxLength != null &&
        widget.minChars! > widget.maxLength!) {
      throw ArgumentError('minChars cannot be greater than maxLength');
    }
    lastValidValue = widget.controller.text;
    widget.controller.addListener(_enforceMaxLength);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_enforceMaxLength);
    super.dispose();
  }

  void _enforceMaxLength() {
    if (widget.maxLength != null &&
        widget.controller.text.length > widget.maxLength!) {
      widget.controller.text =
          widget.controller.text.substring(0, widget.maxLength!);
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller.text.length),
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _validateAndSubmit() {
    final str = widget.controller.text.trim();
    if (widget.minChars != null &&
        str.length < widget.minChars!) {
      setState(() {
        errorText = widget.errorMessage ??
            'Minimum ${widget.minChars} characters required';
        widget.controller.text = lastValidValue;
      });
      _showErrorDialog(
          context, 'Minimum ${widget.minChars} characters required');
    } else {
      setState(() {
        errorText = null;
        lastValidValue = str;
        isEditing = false;
      });
      widget.onSubmit(str);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSubmitEnabled = widget.minChars == null ||
        widget.controller.text.trim().length >= widget.minChars!;
    String displayedText = widget.controller.text.isNotEmpty
        ? widget.controller.text
        : widget.placeHolderText ?? '';

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            child: TextField(
              controller: widget.controller,
              textAlign: widget.textAlign,
              readOnly: !isEditing,
              focusNode: widget.focusNode,
              maxLines: widget.maxLines,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: widget.textColor,
              ),
              onChanged: (value) {
                setState(() {
                  if (widget.minChars != null &&
                      value.trim().length < widget.minChars!) {
                    errorText = widget.errorMessage ??
                        'Minimum ${widget.minChars} characters required';
                  } else {
                    errorText = null;
                  }
                });
              },
              onSubmitted: (value) {
                _validateAndSubmit();
              },
              decoration: InputDecoration(
                hintText: displayedText, // Use displayedText as placeholder
                enabledBorder: InputBorder.none,
                focusedBorder: isEditing
                    ? UnderlineInputBorder(
                        borderSide: BorderSide(color: widget.borderColor))
                    : InputBorder.none,
                errorText: errorText,
                errorMaxLines: 2,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: widget.padding),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: IconButton(
            key: editTextFieldButtonKey,
            onPressed: isSubmitEnabled
                ? () {
                    if (isEditing) {
                      _validateAndSubmit();
                    } else {
                      setState(() {
                        isEditing = true;
                        lastValidValue = widget.controller.text;
                      });
                      widget.focusNode.requestFocus();
                    }
                  }
                : null,
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: isSubmitEnabled ? darkBlue : Colors.grey,
              size: widget.iconSize,
            ),
          ),
        ),
      ],
    );
  }
}
