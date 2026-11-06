import 'dart:io';

import 'package:aebeze/assets.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:share/share.dart';

import '../app_constants.dart';

class SupportingSciencesPage extends PopupRoute<Null> {
  final List<SupportingScience> supportingSciences;

  SupportingSciencesPage({@required this.supportingSciences}) : super(settings: TrackingService.supportingSciencesPage);

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => false;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
          BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) =>
      SlideTransition(
        child: child,
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation),
      );

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      _SupportingSciences(supportingSciences);
}

class _SupportingSciences extends StatelessWidget {
  final List<SupportingScience> supportingSciences;

  _SupportingSciences(this.supportingSciences);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: NavigationAppBar(),
        body: buildList(context),
      );

  Widget buildList(BuildContext context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: ListView.builder(
          key: const ValueKey<String>("location-list"),
          padding: const EdgeInsets.only(top: 50),
          itemCount: supportingSciences?.length ?? 0,
          itemBuilder: buildListItem,
        ),
      );

  Widget buildListItem(BuildContext context, int index) => _SupportingScienceListItem(
        supportingSciences[index],
        noFooter: index == supportingSciences.length - 1,
      );
}

class _SupportingScienceListItem extends StatelessWidget {
  final SupportingScience supportingScience;
  final bool noFooter;

  _SupportingScienceListItem(this.supportingScience, {this.noFooter = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          children: <Widget>[
            _Header(supportingScience),
            _Tags(supportingScience),
            ColumnSeparator.medium,
            _Title(supportingScience),
            _Authors(supportingScience),
            _Doi(supportingScience),
            _Content(supportingScience),
            if (!noFooter) ...[
              ColumnSeparator.veryBig,
              _Footer(),
            ],
            ColumnSeparator.veryBig,
          ],
        ),
      );
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width - 40,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.warmGrey.withOpacity(0.5), width: 1),
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  final SupportingScience supportingScience;

  _Header(this.supportingScience);

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          buildHeaderSource(),
          buildShare(),
        ],
      );

  buildHeaderSource() => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: TextScaled(
                supportingScience.source,
                style: AppTextStyles.captionBright,
              ),
            ),
            TextScaled(supportingScience.date, style: AppTextStyles.caption),
          ],
        ),
      );

  buildShare() => GestureDetector(
        onTap: () => Share.openShareDialog(supportingScience.url),
        child: Container(
          width: defaultIconTapSize,
          height: defaultIconTapSize,
          padding: const EdgeInsets.all(12),
          color: Colors.transparent,
          child: Platform.isAndroid
              ? Icon(Icons.share, color: AppColors.baseColor)
              : Image.asset(Assets.iosShare, width: 24.0, height: 24.0, color: AppColors.baseColor),
        ),
      );
}

class _Tags extends StatelessWidget {
  final SupportingScience supportingScience;

  _Tags(this.supportingScience);

  @override
  Widget build(BuildContext context) => supportingScience.tags == null || supportingScience.tags.isEmpty
      ? Container()
      : Container(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 18.0,
            runSpacing: 8.0,
            children: supportingScience.tags.map((tag) => buildTag(tag)).toList(),
          ),
        );

  Widget buildTag(String tag) => TextScaled(
        "#" + tag,
        textAlign: TextAlign.start,
        style: AppTextStyles.caption,
      );
}

class _Title extends StatelessWidget {
  final SupportingScience supportingScience;

  _Title(this.supportingScience);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.only(top: 8.0, bottom: 14.0),
        alignment: Alignment.centerLeft,
        child: TextScaled(
          supportingScience.title,
          textAlign: TextAlign.start,
          style: AppTextStyles.h4,
        ),
      );
}

class _Authors extends StatelessWidget {
  final SupportingScience supportingScience;

  _Authors(this.supportingScience);

  @override
  Widget build(BuildContext context) => supportingScience.authors == null || supportingScience.authors.isEmpty
      ? Container()
      : Container(
          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
          alignment: Alignment.centerLeft,
          child: TextScaled(
            supportingScience.authors,
            textAlign: TextAlign.start,
            style: AppTextStyles.captionSmall,
          ));
}

class _Doi extends StatelessWidget {
  final SupportingScience supportingScience;

  _Doi(this.supportingScience);

  @override
  Widget build(BuildContext context) => supportingScience.doi == null || supportingScience.doi.isEmpty
      ? Container()
      : Container(
          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
          alignment: Alignment.centerLeft,
          child: TextScaled(
            supportingScience.doi,
            textAlign: TextAlign.start,
            style: AppTextStyles.captionSmall.copyWith(fontStyle: FontStyle.italic, color: AppColors.baseColor),
          ),
        );
}

class _Content extends StatelessWidget {
  final SupportingScience supportingScience;

  _Content(this.supportingScience);

  @override
  Widget build(BuildContext context) => supportingScience.content == null || supportingScience.content.isEmpty
      ? Container()
      : Padding(
          padding: const EdgeInsets.only(),
          child: TextScaled(
            supportingScience.content,
            style: AppTextStyles.bodyLight.copyWith(fontSize: 14.0, height: 1.4),
          ),
        );
}
