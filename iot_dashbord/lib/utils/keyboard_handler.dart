import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// 엔터키를 눌렀을 때 지정한 callback을 실행
void handleEnterKey(RawKeyEvent event, VoidCallback onEnter) {
  if (event is RawKeyDownEvent &&
      event.logicalKey == LogicalKeyboardKey.enter) {
    onEnter();
  }
}

/// 엔터키를 눌렀을 때 지정한 callback을 실행
void handleEnterKey2(RawKeyEvent event,  BuildContext context) {
  if (event is RawKeyDownEvent &&
      event.logicalKey == LogicalKeyboardKey.enter) {
    Navigator.of(context).pop();
  }
}

/// ESC 키를 눌렀을 때 현재 context에서 pop
void handleEscapeKey(RawKeyEvent event, BuildContext context) {
  if (event is RawKeyDownEvent &&
      event.logicalKey == LogicalKeyboardKey.escape) {
    Navigator.of(context).pop();
  }
}

/// ✅ F11 키를 눌렀을 때 현재 context에서 pop
void handleF11Key(RawKeyEvent event, BuildContext context) {
  if (event is RawKeyDownEvent &&
      event.logicalKey == LogicalKeyboardKey.f11) {
    Navigator.of(context).pop();
  }
}
