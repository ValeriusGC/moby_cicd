// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:mobynote/generated/i18n.dart';
import 'package:mobynote/keys.dart';
import 'package:mobynote/model/vmo.dart';
import 'package:mobynote/note_bloc.dart';

class FilterButton extends StatelessWidget {
  final PopupMenuItemSelected<ShowRecycled> onSelected;
  final ShowRecycled activeFilter;
  final bool isActive;

  FilterButton({this.onSelected, this.activeFilter, this.isActive, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.body1;
    final activeStyle = theme.textTheme.body1.copyWith(
      color: theme.accentColor,
    );
    final button = _Button(
      onSelected: onSelected,
      activeFilter: activeFilter,
      activeStyle: activeStyle,
      defaultStyle: defaultStyle,
    );

    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.0,
      duration: Duration(milliseconds: 150),
      child: isActive ? button : IgnorePointer(child: button),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    Key key,
    @required this.onSelected,
    @required this.activeFilter,
    @required this.activeStyle,
    @required this.defaultStyle,
  }) : super(key: key);

  final PopupMenuItemSelected<ShowRecycled> onSelected;
  final ShowRecycled activeFilter;
  final TextStyle activeStyle;
  final TextStyle defaultStyle;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ShowRecycled>(
      key: EisKeys.filterButton,
      tooltip: S.of(context).filter_notes,
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<ShowRecycled>>[
          PopupMenuItem<ShowRecycled>(
            key: EisKeys.allFilter,
            value: ShowRecycled.BOTH,
            child: Text(
              S.of(context).show_all,
              style: activeFilter == ShowRecycled.BOTH
                  ? activeStyle
                  : defaultStyle,
            ),
          ),
          PopupMenuItem<ShowRecycled>(
            key: EisKeys.activeFilter,
            value: ShowRecycled.ONLY_LIVE,
            child: Text(
              S.of(context).show_active,
              style: activeFilter == ShowRecycled.ONLY_LIVE
                  ? activeStyle
                  : defaultStyle,
            ),
          ),
          PopupMenuItem<ShowRecycled>(
            key: EisKeys.deletedFilter,
            value: ShowRecycled.ONLY_RECYCLED,
            child: Text(
              S.of(context).show_recycle,
              style: activeFilter == ShowRecycled.ONLY_RECYCLED
                  ? activeStyle
                  : defaultStyle,
            ),
          ),
        ];
      },
      icon: Icon(Icons.filter_list),
    );
  }
}
