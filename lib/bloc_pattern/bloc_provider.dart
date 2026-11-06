import 'package:aebeze/bloc_pattern/bloc.dart';
import 'package:flutter/widgets.dart';

/// See https://www.raywenderlich.com/4074597-getting-started-with-the-bloc-pattern
class BlocProvider<T extends Bloc> extends StatefulWidget {
  final Widget child;
  final T bloc;

  const BlocProvider({Key key, @required this.bloc, @required this.child}) : super(key: key);

  static T of<T extends Bloc>(BuildContext context) => context.findAncestorWidgetOfExactType<BlocProvider<T>>()?.bloc;

  @override
  _BlocProviderState createState() => _BlocProviderState();
}

class _BlocProviderState extends State<BlocProvider> {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}
