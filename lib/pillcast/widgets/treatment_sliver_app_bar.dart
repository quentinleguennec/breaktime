import 'package:aebeze/app.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/page_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TreatmentSliverAppBar extends StatelessWidget {
  static const double sliverAppBarHeight = 220;

  final PillcastAudioTreatment treatment;

  const TreatmentSliverAppBar(this.treatment);

  Widget buildImage() => Image(
        height: 250,
        color: App.isDayBreak ? null : Colors.white,
        image: AssetImage(
          Assets.ingredientImage(treatment.activeIngredient),
        ),
      );

  @override
  Widget build(BuildContext context) => SliverAppBar(
        automaticallyImplyLeading: false,
        floating: false,
        pinned: false,
        snap: false,
        expandedHeight: sliverAppBarHeight - MediaQuery.of(context).padding.top,
        backgroundColor: Colors.transparent,

        /// This allows to set the minimum height of the bar.
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: Container(),
        ),
        flexibleSpace: Container(
          height: sliverAppBarHeight,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: NavigationAppBarOverlay(
                    withInvertedColor: !App.isDayBreak,
                    isCancel: false,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      top: MediaQuery.of(context).padding.top,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: buildImage(),
                      ),
                    ),
                    Positioned.fill(
                      top: MediaQuery.of(context).padding.top,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: PageTitle(text: capitalizeWord(treatment.type)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
