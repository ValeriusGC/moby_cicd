import 'package:flutter/widgets.dart';

class EisKeys {

  /// Notes
  static final noteItem = (String id) => Key('NoteItem__${id}');

  /// HomeScreen
  static final homeScreen = const Key('__home_screen__');
  static final homeScreenListView = const Key('__home_screen_list_view__');
  static final snackbar = const Key('__snackbar__');
  static final visibleSearch = const Key('__home_screen_visible_search__');
  static final invisibleSearch = const Key('__home_screen_invisible_search__');
  static final homeScreenLoadingSpinner = const Key('__home_screen_loading_spinner__');
  static final homeScreenLoaderPlaceholder = const Key('__home_screen_loader_placeholder__');
  static final homeScreenLoaderError = const Key('__home_screen_loader_error__');
  static Key snackbarAction(String id) => Key('__snackbar_action_${id}__');
  static final addTodoFab = const Key('__addTodoFab__');

  /// AddScreen
  static final addScreen = const Key('__addScreen__');
  static final titleField = const Key('__titleField__');
  static final textField = const Key('__textField__');

  /// Filters
  static final filterButton = const Key('__filterButton__');
  static final allFilter = const Key('__allFilter__');
  static final activeFilter = const Key('__activeFilter__');
  static final deletedFilter = const Key('__deletedFilter__');

  /// Sorting
  static final sortButton = const Key('__sortButton__');
  static final defaultSort = const Key('__defSort__');
  static final customSort = const Key('__customSort__');
  static final sortPrefScreen = const Key('__sortPrefScreen__');

}

