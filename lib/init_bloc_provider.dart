import 'package:flutter/widgets.dart';
import 'package:mobynote/init_bloc.dart';

class InitBlocProvider extends StatefulWidget {
  final Widget child;
  final InitBloc bloc;

  const InitBlocProvider({Key key, this.bloc, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InitBlocProviderState();

  static InitBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InitBlocProvider)
            as _InitBlocProvider)
        .bloc;
  }
}

class _InitBlocProviderState extends State<InitBlocProvider> {
  @override
  Widget build(BuildContext context) {
    return _InitBlocProvider(bloc: widget.bloc, child: widget.child);
  }
}

class _InitBlocProvider extends InheritedWidget {
  final InitBloc bloc;

  _InitBlocProvider({
    Key key,
    @required this.bloc,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InitBlocProvider old) => bloc != old.bloc;
}
