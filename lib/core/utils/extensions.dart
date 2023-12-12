import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

extension AnimatedWidgetExtension on Widget {
  fadeInList(int index, bool isVertical) {
    double offset = 50.0;
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 900),
      child: SlideAnimation(
        horizontalOffset: isVertical ? 0.0 : offset,
        verticalOffset: !isVertical ? 0.0 : offset,
        child: FadeInAnimation(
          child: this,
        ),
      ),
    );
  }
}

extension StringExtensions on String {
  String capitalize() {
    return split(' ')
        .map((word) => word.isEmpty
            ? word
            : "${word[0].toUpperCase()}${word.substring(1)}")
        .join(' ');
  }

  String removeAccentsAndToLowercase() {
    const String accents = 'áéíóúÁÉÍÓÚ';
    const String withoutAccents = 'aeiouAEIOU';

    String modifiedText = this;
    for (int i = 0; i < accents.length; i++) {
      modifiedText = modifiedText.replaceAll(accents[i], withoutAccents[i]);
    }

    return modifiedText.toLowerCase();
  }
}
