import 'package:flutter/widgets.dart';
import 'package:mobynote/init_bloc.dart';
import 'package:mobynote/note_bloc.dart';

class NoteBlocProvider extends StatefulWidget {
  final Widget child;
  final NoteBloc bloc;

  const NoteBlocProvider({Key key, this.bloc, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NoteBlocProviderState();

  static NoteBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_NoteBlocProvider)
            as _NoteBlocProvider)
        .bloc;
  }
}

class _NoteBlocProviderState extends State<NoteBlocProvider> {
  @override
  Widget build(BuildContext context) {
    return _NoteBlocProvider(bloc: widget.bloc, child: widget.child);
  }

  @override
  void dispose() {
    widget.bloc.close();
    super.dispose();
  }

}

class _NoteBlocProvider extends InheritedWidget {
  final NoteBloc bloc;

  _NoteBlocProvider({
    Key key,
    @required this.bloc,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_NoteBlocProvider old) => bloc != old.bloc;


}
