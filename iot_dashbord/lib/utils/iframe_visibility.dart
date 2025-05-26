import 'dart:html' as html;

void hideIframes() {
  html.document.getElementById('hls-player-iframe')?.style.display = 'none';
  html.document.getElementById('unity-webgl-iframe')?.style.display = 'none';
}

void showIframes() {
  html.document.getElementById('hls-player-iframe')?.style.display = 'block';
  html.document.getElementById('unity-webgl-iframe')?.style.display = 'block';
}
