import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubCategoryHeader extends StatelessWidget {
  final String title;
  final double padding;

  const SubCategoryHeader({
    @required this.title,
    this.padding = 0,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: TextScaled(
                title ?? "",
                style: AppTextStyles.subCategory,
              ),
            ),
            ColumnSeparator.tinyPlus,
            const SeparatorLine(),
          ],
        ),
      );
}
