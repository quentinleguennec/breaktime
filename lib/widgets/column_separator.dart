import 'package:flutter/widgets.dart';

enum SeparatorSize { veryTiny, tiny, tinyPlus, small, medium, big, veryBig, huge, veryHuge }

class ColumnSeparator extends StatelessWidget {
  final SeparatorSize size;

  const ColumnSeparator._internal(this.size);

  static const veryTiny = const ColumnSeparator._internal(SeparatorSize.veryTiny);
  static const tiny = const ColumnSeparator._internal(SeparatorSize.tiny);
  static const tinyPlus = const ColumnSeparator._internal(SeparatorSize.tinyPlus);
  static const small = const ColumnSeparator._internal(SeparatorSize.small);
  static const medium = const ColumnSeparator._internal(SeparatorSize.medium);
  static const big = const ColumnSeparator._internal(SeparatorSize.big);
  static const veryBig = const ColumnSeparator._internal(SeparatorSize.veryBig);
  static const huge = const ColumnSeparator._internal(SeparatorSize.huge);
  static const veryHuge = const ColumnSeparator._internal(SeparatorSize.veryHuge);

  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.only(bottom: separatorSize));

  double get separatorSize {
    switch (size) {
      case SeparatorSize.veryTiny:
        return 4;
      case SeparatorSize.tiny:
        return 6;
      case SeparatorSize.tinyPlus:
        return 8;
      case SeparatorSize.small:
        return 12;
      case SeparatorSize.big:
        return 24;
      case SeparatorSize.veryBig:
        return 36;
      case SeparatorSize.huge:
        return 48;
      case SeparatorSize.veryHuge:
        return 64;
      case SeparatorSize.medium:
      default:
        return 16;
    }
  }
}
