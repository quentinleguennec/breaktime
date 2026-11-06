import 'package:aebeze/widgets/reveal_container.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RevealNetworkImage extends StatefulWidget {
  final Color backgroundColor;
  final String imageUrl;
  final BoxFit fit;
  final VoidCallback onImageLoaded;
  final VoidCallback onError;

  RevealNetworkImage({
    @required this.imageUrl,
    this.backgroundColor = Colors.white,
    this.fit = BoxFit.cover,
    this.onImageLoaded,
    this.onError,
  });

  @override
  _State createState() => _State();
}

class _State extends SafeState<RevealNetworkImage> with SingleTickerProviderStateMixin {
  ImageStream imageStream;
  ImageStreamListener loadingListener;
  bool isLoading = true;
  Image image;
  AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    loadingListener = ImageStreamListener((_, __) => onImageLoaded());
    image = Image.network(widget.imageUrl, fit: widget.fit);
    try {
      imageStream = image.image.resolve(ImageConfiguration())..addListener(loadingListener);
    } catch (HandshakeException) {
      try {
        imageStream = image.image.resolve(ImageConfiguration())..addListener(loadingListener);
      } catch (HandshakeException) {
        if (widget.onError != null) widget.onError();
        setMountedState(() => isLoading = false);
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    imageStream.removeListener(loadingListener);
    controller?.dispose();
    super.dispose();
  }

  void onImageLoaded() {
    controller.forward();
    if (widget.onImageLoaded != null) widget.onImageLoaded();
    setMountedState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Container(
        color: widget.backgroundColor,
        child: RevealContainer(controller, child: image),
      );
}
