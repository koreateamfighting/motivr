// utils/iframe_visibility.dart
import 'dart:html' as html;

/// 숨기기 전의 인라인 스타일 백업용
class _PrevStyle {
  final String display;
  final String visibility;
  final String pointerEvents;

  _PrevStyle({
    required this.display,
    required this.visibility,
    required this.pointerEvents,
  });

  static _PrevStyle from(html.Element el) => _PrevStyle(
    display: el.style.display ?? '',
    visibility: el.style.visibility ?? '',
    pointerEvents: el.style.pointerEvents ?? '',
  );

  void restore(html.Element el) {
    el.style.display = display;
    el.style.visibility = visibility;
    el.style.pointerEvents = pointerEvents;
  }
}

/// 중첩 안전 iframe/스트림 가리개
class _IframeShield {
  static int _depth = 0; // 숨김 중첩 카운터
  static final Map<html.Element, _PrevStyle> _saved = {}; // 실제 숨겼던 요소 + 원래 스타일

  /// 하나 더 숨김(중첩 +1)
  static void hide() {
    _depth++;
    print('[IframeShield] hide() 호출 → depth: $_depth');
    _apply();
  }

  /// 하나 해제(중첩 -1)
  static void show() {
    if (_depth > 0) {
      _depth--;
      print('[IframeShield] show() 호출 → depth: $_depth');
    } else {
      print('[IframeShield] show() 호출 but depth==0 (무시)');
    }
    _apply();
  }

  /// 강제 전체 해제(비상 복구용)
  static void reset() {
    print('[IframeShield] reset() 호출 (기존 depth: $_depth) → depth: 0');
    _depth = 0;
    _apply(forceShow: true);
  }

  static void _apply({bool forceShow = false}) {
    final shouldHide = !forceShow && _depth > 0;

    if (shouldHide) {
      // 현재 DOM에서 타겟 요소 수집
      final targets = <html.Element>{}
        ..addAll(_hlsIframes())
        ..addAll(_unityIframe())
        ..addAll(_opencvImages());

      print('[IframeShield] 숨김 적용: ${targets.length}개 요소');

      for (final el in targets) {
        // 처음 숨길 때만 원래 스타일 저장
        _saved.putIfAbsent(el, () => _PrevStyle.from(el));

        // 숨김 적용
        el.style.display = 'none';
        el.style.visibility = 'hidden';
        el.style.pointerEvents = 'none';
      }
    } else {
      // depth==0 이거나 reset일 때만 복원
      if (_saved.isNotEmpty) {
        print('[IframeShield] 복원 적용: ${_saved.length}개 요소 (현재 depth: $_depth)');
        final entries = List.of(_saved.entries);
        for (final e in entries) {
          final el = e.key;
          final prev = e.value;
          // 요소가 아직 DOM에 있으면 복원
          try {
            prev.restore(el);
          } catch (_) {
            // DOM에서 제거된 요소면 무시
          }
        }
        _saved.clear();
      } else {
        // 복원할 것이 없는데 호출되는 경우도 로깅(디버깅 편의)
        print('[IframeShield] 복원 스킵: 저장된 요소 없음 (현재 depth: $_depth)');
      }
    }
  }

  // --- 타겟 셀렉터들 ---------------------------------------------------------

  /// src에 'hls_player.html'을 포함하는 iframe들
  static Iterable<html.Element> _hlsIframes() {
    return html.document
        .querySelectorAll('iframe')
        .where((e) => e.getAttribute('src')?.contains('hls_player.html') ?? false);
  }

  /// id가 'unity-webgl-iframe'인 Unity iframe
  static Iterable<html.Element> _unityIframe() {
    final u = html.document.getElementById('unity-webgl-iframe');
    return u == null ? const [] : [u];
  }

  /// src에 '/stream/'을 포함하는 OpenCV 이미지들
  static Iterable<html.Element> _opencvImages() {
    return html.document
        .querySelectorAll('img')
        .where((e) => e.getAttribute('src')?.contains('/stream/') ?? false);
  }
}

/// 외부(앱)에서 쓰는 API — 기존 함수명 유지
void hideIframes() => _IframeShield.hide();
void showIframes() => _IframeShield.show();

/// 필요하면 비상 복구
void resetIframes() => _IframeShield.reset();
