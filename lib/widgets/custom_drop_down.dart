import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomDropDown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final String hint;
  final T startValue;
  final ValueChanged<T> onChanged;

  const CustomDropDown({
    @required this.items,
    @required this.onChanged,
    this.hint,
    this.startValue,
  });

  @override
  _CustomDropDownState<T> createState() => _CustomDropDownState<T>();
}

class _CustomDropDownState<T> extends SafeState<CustomDropDown<T>> {
  String get hint => widget.hint;

  List<DropdownMenuItem<T>> get items => widget.items;

  T get startValue => widget.startValue;

  ValueChanged<T> get onChanged => widget.onChanged;

  T value;

  @override
  void initState() {
    value = startValue;
    super.initState();
  }

  Widget get underline => Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.baseColor.withOpacity(0.4),
              width: 1,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (hint != null) ...[
            Text(
              hint,
              textScaleFactor: 0.75,
              style: AppTextStyles.inputField,
            ),
            Padding(padding: const EdgeInsets.only(bottom: 1)),
          ],
          DropdownButton<T>(
            value: value,
            isDense: true,
            isExpanded: true,
            elevation: 0,
            style: AppTextStyles.inputField,
            underline: Container(
              height: 0,
              color: AppColors.baseColor.withOpacity(0.4),
            ),
            onChanged: (newValue) {
              setMountedState(() => value = newValue);
              if (onChanged != null) onChanged(newValue);
            },
            items: items,
          ),
          ColumnSeparator.small,
          underline,
        ],
      );
}
