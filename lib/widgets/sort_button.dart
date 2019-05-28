// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:mobynote/app_session.dart';
import 'package:mobynote/app_session_provider.dart';
import 'package:mobynote/generated/i18n.dart';
import 'package:mobynote/keys.dart';
import 'package:mobynote/managers/home_screen_manager.dart';
import 'package:mobynote/managers/note_manager.dart';
import 'package:mobynote/note_bloc.dart';
import 'package:mobynote/service_locator.dart';

class SortButton extends StatelessWidget {
  final PopupMenuItemSelected<VisualMappingOptions> onSelected;
  final VisualMappingOptions activeSort;
  final bool isActive;

  SortButton({this.onSelected, this.activeSort, this.isActive, Key key})
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
      activeSort: activeSort,
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
    @required this.activeSort,
    @required this.activeStyle,
    @required this.defaultStyle,
  }) : super(key: key);

  final PopupMenuItemSelected<VisualMappingOptions> onSelected;
  final VisualMappingOptions activeSort;
  final TextStyle activeStyle;
  final TextStyle defaultStyle;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VisualMappingOptions>(
      key: EisKeys.sortButton,
      tooltip: S.of(context).filter_notes,
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        final _activeSort = sl<NoteManager>().switchVisualMappingOptionsCmd.lastResult;
        print('Mobynote._Button.build: active=$_activeSort');
        return <PopupMenuItem<VisualMappingOptions>>[
          PopupMenuItem<VisualMappingOptions>(
            key: EisKeys.defaultSort,
            value: VisualMappingOptions.mk(),
            child: Text(
              S.of(context).default_sort,
//              style: _activeSort.sortType == SortType.ASC
//                  ? activeStyle
//                  : defaultStyle,
            ),
          ),
          PopupMenuItem<VisualMappingOptions>(
            key: EisKeys.customSort,
            value: VisualMappingOptions.mk(sortType: SortType.DESC),
            child: Text(
              S.of(context).custom_sort,
//              style: _activeSort.sortType == SortType.DESC
//                  ? activeStyle
//                  : defaultStyle,
            ),
          ),
          PopupMenuItem<VisualMappingOptions>(
            key: EisKeys.sortPrefScreen,
            value: VisualMappingOptions.mk(sortType: SortType.SET),
            child: Text(
              S.of(context).sort_screen,
//              style: _activeSort.sortType == SortType.SET
//                  ? activeStyle
//                  : defaultStyle,
            ),
          ),
        ];
      },
      icon: Icon(Icons.sort),
    );
  }
}
