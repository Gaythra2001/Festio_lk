// Web implementation - prevents right-click context menu
import 'dart:html' as html;

void disableContextMenu() {
  html.document.onContextMenu.listen((event) {
    event.preventDefault();
  });
}
