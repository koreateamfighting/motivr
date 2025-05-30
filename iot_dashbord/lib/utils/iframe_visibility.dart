import 'dart:html' as html;

void hideIframes() {
//  print("🎬 실제 iframe을 직접 탐색하여 숨기기");

  final iframes = html.document.querySelectorAll('iframe');
  for (final iframe in iframes) {
    final src = iframe.getAttribute('src');
    if (src != null && src.contains('hls_player.html')) {
      iframe.style.display = 'none';
      iframe.style.visibility = 'hidden';
      iframe.style.pointerEvents = 'none';
      //print('✅ iframe [$src] 숨김');
    }
  }

  final unity = html.document.getElementById('unity-webgl-iframe');
  if (unity != null) {
    unity.style.display = 'none';
    unity.style.visibility = 'hidden';
    unity.style.pointerEvents = 'none';
  }
}

void showIframes() {
 // print("🎬 실제 iframe을 직접 탐색하여 다시 표시");

  final iframes = html.document.querySelectorAll('iframe');
  for (final iframe in iframes) {
    final src = iframe.getAttribute('src');
    if (src != null && src.contains('hls_player.html')) {
      iframe.style.display = 'block';
      iframe.style.visibility = 'visible';
      iframe.style.pointerEvents = 'auto';
      //print('✅ iframe [$src] 복원');
    }
  }

  final unity = html.document.getElementById('unity-webgl-iframe');
  if (unity != null) {
    unity.style.display = 'block';
    unity.style.visibility = 'visible';
    unity.style.pointerEvents = 'auto';
  }
}
