import 'dart:async';

StreamController<String> recentsStreamController =
    StreamController<String>.broadcast();

void reloadRecents() async {
  recentsStreamController.add("");
}
