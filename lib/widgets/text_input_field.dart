import 'package:aebeze/app.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

bool validateEmail(String email) => email != null && email.isNotEmpty && email.contains("@") && hasValidDomain(email);

bool hasValidDomain(String email) {
  if (email == null) {
    return false;
  }
  if (App.isDayBreak) {
    List<String> parts = email.split("@");
    if (parts.length == 2) {
      String domain = parts[1];
      if (domain == "us.af.mil" || domain == "tengio.com" || domain == "aebeze.com") {
        return true;
      }
    }
    return false;
  }
  return true;
}

String getEmailError(String email, BuildContext context) {
  if (email == null || email.isEmpty) {
    return localize(context, "validator_email_empty");
  }
  if (!email.contains("@")) {
    return localize(context, "validator_email_not_valid");
  }
  if (!hasValidDomain(email)) {
    return localize(context, "validator_email_daybreak_domain");
  }
  return null;
}

bool validatePassword(String password) => password != null && password.length >= 6;

String getPasswordError(String password, BuildContext context) {
  if (password == null || password.isEmpty) {
    return localize(context, "validator_password_empty");
  } else if (password.length < 6) {
    return localize(context, "password_eight_characters_message");
  }
  return null;
}

class TextInputField extends StatefulWidget {
  final String hint;
  final String errorText;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final bool hasIcon;
  final FocusNode focus;
  final VoidCallback onNext;
  final TextInputAction action;
  final bool isTransparent;
  final TextStyle style;

  TextInputField({
    this.hint,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.hasIcon = false,
    this.focus,
    this.onNext,
    this.action,
    this.isTransparent = false,
    this.style,
  });

  @override
  _TextInputFieldState createState() => _TextInputFieldState();
}

class _TextInputFieldState extends SafeState<TextInputField> {
  bool shouldObscureText;

  @override
  void initState() {
    super.initState();
    shouldObscureText = widget.hasIcon;
  }

  @override
  Widget build(BuildContext context) => TextField(
        style: widget.style ?? AppTextStyles.inputField,
        keyboardType: widget.keyboardType,
        autocorrect: false,
        onChanged: widget.onChanged,
        obscureText: shouldObscureText,
        textInputAction: widget.action,
        focusNode: widget.focus,
        onSubmitted: (_) => widget.onNext(),
        decoration: InputDecoration(
          suffixIcon: widget.hasIcon
              ? IconButton(
                  padding: EdgeInsets.all(0.0),
                  alignment: Alignment.bottomCenter,
                  onPressed: () => setMountedState(() => shouldObscureText = !shouldObscureText),
                  icon: ImageIcon(
                    shouldObscureText ? AssetImage(Assets.iconEye) : AssetImage(Assets.iconNoEye),
                    size: 40.0,
                    color: AppColors.baseColor,
                  ),
                )
              : Padding(padding: EdgeInsets.zero),
          filled: true,
          contentPadding: EdgeInsets.only(bottom: 10.0, left: 0.0),
          fillColor: widget.isTransparent ? Colors.transparent : AppColors.scaffoldBackgroundColor,
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textInputFieldBorder)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: (widget.style?.color ?? AppColors.baseColor.withOpacity(0.4)),
            ),
          ),
          labelText: widget.hint,
          labelStyle: widget.style ?? AppTextStyles.inputField,
          errorText: widget.errorText,
          errorStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
}

class EmailInputField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  final String errorText;
  final TextInputAction action;
  final FocusNode focus;

  EmailInputField({
    this.onChanged,
    this.errorText,
    this.onNext,
    this.action = TextInputAction.next,
    this.focus,
  });

  @override
  Widget build(BuildContext context) => TextInputField(
        hint: localize(context, "email"),
        style: AppTextStyles.inputField,
        keyboardType: TextInputType.emailAddress,
        onChanged: onChanged,
        errorText: errorText,
        focus: focus,
        onNext: onNext,
        action: action,
        isTransparent: true,
      );
}

class PasswordInputField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String errorText;
  final FocusNode focus;
  final VoidCallback onNext;

  PasswordInputField({
    this.onChanged,
    this.errorText,
    this.focus,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) => TextInputField(
        hint: localize(context, "password"),
        style: AppTextStyles.inputField,
        hasIcon: true,
        onChanged: onChanged,
        errorText: errorText,
        focus: focus,
        onNext: onNext,
        action: TextInputAction.done,
        isTransparent: true,
      );
}
