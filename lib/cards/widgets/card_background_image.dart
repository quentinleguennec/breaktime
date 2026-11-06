import 'package:aebeze/services/model.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/widgets/reveal_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardBackgroundImage extends StatelessWidget {
  final Background background;
  final VoidCallback onImageLoaded;

  CardBackgroundImage(this.background, {this.onImageLoaded});

  @override
  Widget build(BuildContext context) => RevealNetworkImage(
        imageUrl: background.image,
        backgroundColor: backgroundColor(background),
        onImageLoaded: onImageLoaded,
      );
}
