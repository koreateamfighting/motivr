import 'dart:html' as html;

void hideIframes() {
  // HLS iframe 숨기기
  final iframes = html.document.querySelectorAll('iframe');
  for (final iframe in iframes) {
    final src = iframe.getAttribute('src');
    if (src != null && src.contains('hls_player.html')) {
      iframe.style.display = 'none';
      iframe.style.visibility = 'hidden';
      iframe.style.pointerEvents = 'none';
    }
  }

  // Unity iframe 숨기기
  final unity = html.document.getElementById('unity-webgl-iframe');
  if (unity != null) {
    unity.style.display = 'none';
    unity.style.visibility = 'hidden';
    unity.style.pointerEvents = 'none';
  }

  // Opencv 이미지 (cam1, cam2) 숨기기
  final images = html.document.querySelectorAll('img');
  for (final img in images) {
    final src = img.getAttribute('src');
    if (src != null && src.contains('/stream/')) {
      img.style.display = 'none';
      img.style.visibility = 'hidden';
      img.style.pointerEvents = 'none';
    }
  }
}

void showIframes() {
  // HLS iframe 복원
  final iframes = html.document.querySelectorAll('iframe');
  for (final iframe in iframes) {
    final src = iframe.getAttribute('src');
    if (src != null && src.contains('hls_player.html')) {
      iframe.style.display = 'block';
      iframe.style.visibility = 'visible';
      iframe.style.pointerEvents = 'auto';
    }
  }

  // Unity iframe 복원
  final unity = html.document.getElementById('unity-webgl-iframe');
  if (unity != null) {
    unity.style.display = 'block';
    unity.style.visibility = 'visible';
    unity.style.pointerEvents = 'auto';
  }

  // Opencv 이미지 복원
  final images = html.document.querySelectorAll('img');
  for (final img in images) {
    final src = img.getAttribute('src');
    if (src != null && src.contains('/stream/')) {
      img.style.display = 'block';
      img.style.visibility = 'visible';
      img.style.pointerEvents = 'auto';
    }
  }
}
