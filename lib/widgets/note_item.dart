import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobynote/NoteModel.dart';
import 'package:mobynote/const.dart';
import 'package:mobynote/generated/i18n.dart';
import 'package:mobynote/keys.dart';
import 'package:mobynote/utils/datetime.dart';
import 'package:mobynote/utils/my_custom_icons_icons.dart';


class NoteItem extends StatelessWidget {
  final DismissDirectionCallback onDismissed;
  final ConfirmDismissCallback callback;
  final GestureTapCallback onTap;
  final Note note;

  const NoteItem({
    @required this.onDismissed,
    @required this.callback,
    @required this.onTap,
    @required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ObjectKey(EisKeys.noteItem(note.id.toString())),
      background: Container(color: note.attrs.recycledFlag ? Colors.green : Colors.red),
//      secondaryBackground: Container(color: Colors.red),
      onDismissed: onDismissed,
      confirmDismiss: callback,
      child: _makeCard(context, note),
    );
  }

  ListTile _makeListTile(BuildContext ctx, Note note) {
    return note.attrs.title != null && note.attrs.title.isNotEmpty
        ? _makeListTileWithTitle(ctx, note)
        : _makeListTileNoTitle(ctx, note);

  }

  ListTile _makeListTileWithTitle(BuildContext ctx, Note note) {
    final title = note.attrs.title;
    final text = note.noteText;
    return ListTile(
      leading: note.attrs.recycledFlag
//          ?  Icon(MyCustomIcons.godot_icon, color: Colors.red,)
          ?  Icon(Icons.delete_outline, color: Colors.red,)
          : null,
      //leading: note.attrs.recycledFlag ?  Icon(Icons.delete, color: Colors.red,) : null,
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
      subtitle: Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  ListTile _makeListTileNoTitle(BuildContext ctx, Note note) {
    final text = note.noteText;
    return ListTile(
      leading: note.attrs.recycledFlag
          ? Icon(Icons.delete_outline, color: Colors.red,)
//          ? Icon(MyCustomIcons.godot_icon, color: Colors.red,)
          : null,
//      leading: note.attrs.recycledFlag ?  Icon(Icons.delete, color: Colors.red,) : null,
      onTap: onTap,
      title: Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Card _makeCard(BuildContext ctx, Note note) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _makeListTile(ctx, note),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  child: Text(
                      "${S.of(ctx).created}: ${toDate(note.iidTimeStamp, S.of(ctx).date_format)}"),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  child: Text(
                      "${S.of(ctx).edited}: ${toDate(note.verTimeStamp, S.of(ctx).date_format)} (v: ${note.verOrd})"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
