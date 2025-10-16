import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    final normalizedQuery = query.toLowerCase().trim();
    final normalizedText = text.toLowerCase();
    final List<TextSpan> spans = [];

    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight = normalizedText.indexOf(
          normalizedQuery,
          start,
        )) !=
        -1) {
      if (indexOfHighlight > start) {
        spans.add(
          TextSpan(text: text.substring(start, indexOfHighlight), style: style),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(
            indexOfHighlight,
            indexOfHighlight + normalizedQuery.length,
          ),
          style:
              highlightStyle ??
              TextStyle(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      );

      start = indexOfHighlight + normalizedQuery.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: style ?? DefaultTextStyle.of(context).style,
        children: spans,
      ),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
    );
  }
}
