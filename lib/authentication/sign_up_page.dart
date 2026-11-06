import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/authentication/authentication_page.dart';
import 'package:aebeze/authentication/sign_up_presenter.dart';
import 'package:aebeze/authentication/widgets/or_separator.dart';
import 'package:aebeze/authentication/widgets/page_background.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/custom_drop_down.dart';
import 'package:aebeze/widgets/page_title.dart';
import 'package:aebeze/widgets/text_input_field.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class SignUpPage extends MaterialPageRoute<Null> {
  final VoidCallback onComplete;

  SignUpPage({@required this.onComplete})
      : super(
          builder: (_) => SignUpWidget(onComplete: onComplete),
          settings: TrackingService.signUpPage,
        );
}

class SignUpWidget extends StatefulWidget {
  final VoidCallback onComplete;

  SignUpWidget({@required this.onComplete});

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

enum Gender { male, female, undisclosed }
enum AgeRange { zero, one, two, three, four }
enum Shift { day, mid, swing }
enum AirfieldBase { beale, edwards, langley, aludeid }

class _SignUpWidgetState extends BasePresenter<SignUpWidget> implements SignUpPresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode unitSquadronFocusNode = FocusNode();
  final FocusNode specialtyCodeFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  SignUpPresenter presenter;
  String email;
  String emailError;
  String password;
  String passwordError;
  String baseError;
  String unitSquadron;
  String unitSquadronError;
  String specialtyCode;
  String specialtyCodeError;
  Gender gender = Gender.male;
  AgeRange ageRange = AgeRange.zero;
  Shift shift = Shift.day;
  AirfieldBase base = AirfieldBase.beale;
  bool termsAccepted = false;
  bool validEmail = false;

  _SignUpWidgetState() {
    presenter = SignUpPresenter(this);
  }

  @override
  GlobalKey<ScaffoldState> getScaffoldKey() => _scaffoldKey;

  @override
  void onSignUpSuccess() {
    if (widget.onComplete == null) {
      pop();
      pop();
      return;
    }
    pop();
    widget.onComplete();
  }

  bool checkFieldNotEmpty(String field) => field != null && field.isNotEmpty;

  String get emptyFieldErrorMessage => localize(context, "validator_field_empty");

  bool checkAllFieldsValid() =>
      validateEmail(email) &&
      validatePassword(password) &&
      (!App.isDayBreak || (checkFieldNotEmpty(unitSquadron) && checkFieldNotEmpty(specialtyCode)));

  void createAccount() {
    emailError = getEmailError(email, context);
    passwordError = getPasswordError(password, context);
    unitSquadronError = checkFieldNotEmpty(unitSquadron) ? null : emptyFieldErrorMessage;
    specialtyCodeError = checkFieldNotEmpty(specialtyCode) ? null : emptyFieldErrorMessage;
    if (checkAllFieldsValid()) {
      presenter.signUpWithEmail(
        email,
        password,
        airforceBase: getBaseToText(base),
        airforceUnitSquadron: unitSquadron,
        airforceSpecialtyCode: specialtyCode,
        gender: getGenderToText(gender),
        ageRange: getAgeRangeToText(ageRange),
        airforceShift: getShiftToText(shift),
      );
    }
    refreshState();
  }

  void toggleDaybreakFields(String email) {
    if (validateEmail(email)) {
      setMountedState(() => validEmail = true);
    } else {
      setMountedState(() => {
            validEmail = false,
            // emailError = getEmailError(email, context),
          });
    }
  }

  Widget get facebookButton => AuthenticationButton(
        text: localize(context, 'log_in_with_facebook'),
        isDisabled: inProgress,
        onPressed: () {
          presenter.logInWithFacebook();
          refreshState();
        },
      );

  Widget get privacyAndAboutRow => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Container(
              height: 35,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: TextScaled(
                localize(context, "privacy_policy"),
                style: AppTextStyles.h7,
              ),
            ),
            onTap: presenter.openTermsPage,
          ),
          TextScaled(
            " $bulletPoint ",
            style: AppTextStyles.h7,
          ),
          GestureDetector(
            child: Container(
              height: 35,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: TextScaled(
                localize(context, "about_button_login_page"),
                style: AppTextStyles.h7,
              ),
            ),
            onTap: presenter.openAboutPage,
          ),
        ],
      );

  String getGenderToText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return localize(context, "sign_up_gender_male");
      case Gender.female:
        return localize(context, "sign_up_gender_female");
      case Gender.undisclosed:
      default:
        return localize(context, "sign_up_gender_undisclosed");
    }
  }

  String getAgeRangeToText(AgeRange ageRange) {
    switch (ageRange) {
      case AgeRange.zero:
        return localize(context, "sign_up_age_range_0");
      case AgeRange.one:
        return localize(context, "sign_up_age_range_1");
      case AgeRange.two:
        return localize(context, "sign_up_age_range_2");
      case AgeRange.three:
        return localize(context, "sign_up_age_range_3");
      case AgeRange.four:
      default:
        return localize(context, "sign_up_age_range_4");
    }
  }

  String getShiftToText(Shift shift) {
    switch (shift) {
      case Shift.day:
        return localize(context, "sign_up_shift_day");
      case Shift.mid:
        return localize(context, "sign_up_shift_mid");
      case Shift.swing:
      default:
        return localize(context, "sign_up_shift_swing");
    }
  }

  String getBaseToText(AirfieldBase base) {
    switch (base) {
      case AirfieldBase.beale:
        return localize(context, "sign_up_airbase_beale");
      case AirfieldBase.edwards:
        return localize(context, "sign_up_airbase_edwards");
      case AirfieldBase.langley:
        return localize(context, "sign_up_airbase_langley");
      case AirfieldBase.aludeid:
      default:
        return localize(context, "sign_up_airbase_aludeid");
    }
  }

  Widget get baseDropDown => CustomDropDown(
        hint: localize(context, "sign_up_base"),
        startValue: base,
        onChanged: (newValue) => base = newValue,
        items: AirfieldBase.values
            .map<DropdownMenuItem<AirfieldBase>>(
              (base) => DropdownMenuItem<AirfieldBase>(
                value: base,
                child: TextScaled(getBaseToText(base)),
              ),
            )
            .toList(),
      );

  Widget get unitField => TextInputField(
        hint: localize(context, "sign_up_unit_squadron"),
        onChanged: (text) {
          unitSquadron = text;
          unitSquadronError = checkFieldNotEmpty(unitSquadron) ? null : emptyFieldErrorMessage;
          refreshState();
        },
        errorText: unitSquadronError,
        focus: unitSquadronFocusNode,
        onNext: () => FocusScope.of(context).requestFocus(specialtyCodeFocusNode),
      );

  Widget get specialtyCodeField => TextInputField(
        hint: localize(context, "sign_up_af_specialty_code"),
        onChanged: (text) {
          specialtyCode = text;
          specialtyCodeError = checkFieldNotEmpty(specialtyCode) ? null : emptyFieldErrorMessage;
          refreshState();
        },
        errorText: specialtyCodeError,
        focus: specialtyCodeFocusNode,
      );

  Widget get genderDropDown => CustomDropDown(
        hint: localize(context, "gender"),
        startValue: gender,
        onChanged: (newValue) => gender = newValue,
        items: Gender.values
            .map<DropdownMenuItem<Gender>>(
              (gender) => DropdownMenuItem<Gender>(
                value: gender,
                child: TextScaled(getGenderToText(gender)),
              ),
            )
            .toList(),
      );

  Widget get ageRangeDropDown => CustomDropDown(
        hint: localize(context, "age"),
        startValue: ageRange,
        onChanged: (newValue) => ageRange = newValue,
        items: AgeRange.values
            .map<DropdownMenuItem<AgeRange>>(
              (ageRange) => DropdownMenuItem<AgeRange>(
                value: ageRange,
                child: TextScaled(getAgeRangeToText(ageRange)),
              ),
            )
            .toList(),
      );

  Widget get shiftDropDown => CustomDropDown(
        hint: localize(context, "shift"),
        startValue: shift,
        onChanged: (newValue) => shift = newValue,
        items: Shift.values
            .map<DropdownMenuItem<Shift>>(
              (shift) => DropdownMenuItem<Shift>(
                value: shift,
                child: TextScaled(getShiftToText(shift)),
              ),
            )
            .toList(),
      );

  Widget get emailField => EmailInputField(
        onChanged: (text) {
          email = text;
          toggleDaybreakFields(email);
          if (emailError != null && getEmailError(email, context) == null) {
            emailError = null;
          }
          refreshState();
        },
        errorText: emailError,
        onNext: () => FocusScope.of(context).requestFocus(passwordFocusNode),
      );

  Widget get passwordField => PasswordInputField(
        onChanged: (text) {
          password = text;
          if (passwordError != null && getPasswordError(password, context) == null) {
            passwordError = null;
          }
          refreshState();
        },
        errorText: passwordError,
        focus: passwordFocusNode,
        onNext: createAccount,
      );

  Widget get passwordHelpText => TextScaled(
        localize(context, "password_eight_characters_message"),
        style: AppTextStyles.captionSmallZirkonRegular.copyWith(color: AppColors.baseColorVeryFaded),
      );

  Widget get termsText => TextScaled(
        localize(context, "sign_up_terms"),
        style: AppTextStyles.captionSmallZirkonRegular.copyWith(color: AppColors.baseColorVeryFaded),
      );

  Widget get createButton => AuthenticationButton(
        text: localize(context, "create_account"),
        isDisabled: inProgress || !checkAllFieldsValid(),
        onPressed: createAccount,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            AuthenticationPageBackground(),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: NavigationAppBarOverlay(isCancel: false),
                  ),
                  ColumnSeparator.veryBig,
                  PageTitle(
                    text: localize(context, "authentication_sign_up_page_title"),
                    color: AppColors.baseColorFaded,
                  ),
                  ColumnSeparator.veryBig,
                  Padding(
                    /// Horizontal padding needs to be 16 else the DropDowns display with an ugly shift.
                    padding: const EdgeInsets.symmetric(horizontal: smallPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        emailField,
                        ColumnSeparator.big,
                        passwordField,
                        ColumnSeparator.medium,
                        passwordHelpText,
                        if (App.isDayBreak && validEmail) ...[
                          ColumnSeparator.big,
                          baseDropDown,
                          ColumnSeparator.veryBig,
                          unitField,
                          ColumnSeparator.veryBig,
                          specialtyCodeField,
                          ColumnSeparator.veryBig,
                          genderDropDown,
                          ColumnSeparator.veryBig,
                          ageRangeDropDown,
                          ColumnSeparator.veryBig,
                          shiftDropDown,
                          ColumnSeparator.medium,
                        ],
                        ColumnSeparator.medium,
                        termsText,
                        ColumnSeparator.veryBig,
                        createButton,
                        ColumnSeparator.medium,
                        if (!App.isDayBreak) ...[
                          Center(child: OrSeparator()),
                          ColumnSeparator.medium,
                          facebookButton,
                          ColumnSeparator.medium,
                        ],
                        ColumnSeparator.huge,
                        privacyAndAboutRow,
                        ColumnSeparator.big,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
