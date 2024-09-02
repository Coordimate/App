import 'package:flutter/material.dart';

class EllipsisText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Key? textKey;
  final Key? overflowKey;
  final int maxLines;

  const EllipsisText({
    required this.text,
    super.key,
    this.textKey,
    this.style,
    this.overflowKey,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      ellipsis: '...',
    )..layout(maxWidth: 450);

    final bool isOverflowing = textPainter.didExceedMaxLines;

    return Stack(
      children: [
        Text(
          text,
          key: textKey,
          style: style,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
        if (isOverflowing && overflowKey != null)
          Positioned(
            child: Container(
              key: overflowKey,
              width: 0,
              height: 0,
              color: Colors.transparent,
            ),
          ),
      ],
    );
  }
}
