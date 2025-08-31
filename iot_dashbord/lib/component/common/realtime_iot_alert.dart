import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:iot_dashboard/component/common/iot_alarm_dialog.dart';

class RealtimeIotAlert extends StatefulWidget {
  /// 필요 시 명시 (예: ws://host:3030/ws). 미지정 시 현재 호스트로 추정.
  final String? wsUrl;

  /// 페이지 로드 이전 알림 무시할 때 허용 오차(ms)
  final int allowedSkewMs;

  /// 페이지 로드 이전 알림을 무시할지 여부
  final bool ignorePastOnStartup;

  const RealtimeIotAlert({
    super.key,
    this.wsUrl,
    this.allowedSkewMs = 3000,
    this.ignorePastOnStartup = true,
  });

  @override
  State<RealtimeIotAlert> createState() => _RealtimeIotAlertState();
}

class _RealtimeIotAlertState extends State<RealtimeIotAlert> {
  html.WebSocket? _ws;

  // 시작시각 (과거 알림 차단 기준)
  late final int _startupEpochMs;

  // 이미 표시한 uid 집합 (localStorage에 영속)
  static const _kLS = 'iotAlert.processedUids';
  final Set<String> _processed = {};

  // 재연결
  int _reconnectAttempt = 0;
  bool _manuallyClosed = false;

  @override
  void initState() {
    super.initState();
    _startupEpochMs = DateTime.now().millisecondsSinceEpoch;
    _loadProcessed();
    _connect();
  }

  @override
  void dispose() {
    _manuallyClosed = true;
    _ws?.close();
    super.dispose();
  }

  // -------------------- storage --------------------
  void _loadProcessed() {
    try {
      final raw = html.window.localStorage[_kLS];
      if (raw != null) {
        final list = (jsonDecode(raw) as List).map((e) => '$e');
        _processed.addAll(list);
      }
    } catch (_) {}
  }

  void _saveProcessed() {
    try {
      html.window.localStorage[_kLS] = jsonEncode(_processed.toList());
    } catch (_) {}
  }

  // -------------------- websocket --------------------
  String _inferWsUrl() {
    final isHttps = html.window.location.protocol == 'https:';
    final scheme = isHttps ? 'wss://' : 'ws://';
    final host = html.window.location.host; // example.com:3030
    // 서버 업그레이드가 루트에 붙어 있으면 이대로 OK. 전용 경로면 '/ws'로 바꾸세요.
    return '$scheme$host';
  }

  void _connect() {
    final url = widget.wsUrl ?? _inferWsUrl();
    try {
      _ws = html.WebSocket(url);

      _ws!.onOpen.listen((_) {
        _reconnectAttempt = 0; // reset
      });

      _ws!.onMessage.listen((evt) {
        if (evt.data is String) {
          _handleMessage(evt.data as String);
        }
      });

      _ws!.onClose.listen((_) => _scheduleReconnect());
      _ws!.onError.listen((_) => _scheduleReconnect());
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_manuallyClosed) return;
    // 지수 백오프 (최대 30초)
    _reconnectAttempt = (_reconnectAttempt + 1).clamp(1, 30);
    final delayMs = (1000 * (1 << (_reconnectAttempt - 1))).clamp(1000, 30000);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!_manuallyClosed) _connect();
    });
  }

  // -------------------- message handling --------------------
  void _handleMessage(String raw) {
    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final type = msg['type'];
    if (type == 'iot-alert') {
      _handleIotAlert(msg['data'] as Map<String, dynamic>?);
    } else if (type == 'iotSensorUpdate') {
      _handleIotSensorUpdate(msg['data'] as Map<String, dynamic>?);
    }
  }

  // 서버가 alarmhistory.js 혹은 sensor 라우터에서 쏘는 표준 알람
  void _handleIotAlert(Map<String, dynamic>? d) {
    if (d == null) return;
    final data = d;

    final type = '${data['Type'] ?? ''}';
    if (type != 'iot') return;

    final rawEvent = '${data['Event'] ?? ''}'.trim();
    final normalized = rawEvent.replaceAll(RegExp(r'\s+'), ''); // '점검 필요'→'점검필요'
    if (!_isAlertEvent(normalized)) return;

    final uid = (data['uid']?.toString().isNotEmpty ?? false)
        ? data['uid'].toString()
        : '${data['DeviceID'] ?? ''}|${data['Timestamp'] ?? ''}';

    // 과거 알림 차단 (페이지 로드 이후만)
    final tsMs = _parseMillis(data['Timestamp']);
    if (widget.ignorePastOnStartup &&
        tsMs != null &&
        tsMs < (_startupEpochMs - widget.allowedSkewMs)) {
      return;
    }

    if (_processed.contains(uid)) return;
    _processed.add(uid);
    _saveProcessed();

    final rid = '${data['DeviceID'] ?? ''}';
    final label = '${data['Label'] ?? 'unknown'}';
    final when = _parseDateTime(data['Timestamp']) ?? DateTime.now();

    _showDialog(
      severity: rawEvent,
      rid: rid,
      label: label,
      occurredAt: when,
    );
  }

  // 센서 스트림만 오는 환경 대비 (EventType 기반 매핑)
  void _handleIotSensorUpdate(Map<String, dynamic>? d) {
    if (d == null) return;

    final eventType = int.tryParse('${d['EventType'] ?? ''}');
    final mapped = _mapEventType(eventType);
    if (mapped == null) return; // 정상/기타는 무시

    final rawEvent = mapped; // '주의' | '경고' | '점검필요'
    final normalized = rawEvent.replaceAll(RegExp(r'\s+'), '');

    if (!_isAlertEvent(normalized)) return;

    final rid = '${d['RID'] ?? d['DeviceID'] ?? ''}';
    final label = '${d['Label'] ?? 'unknown'}';

    final ts = d['CreateAt'] ?? d['Timestamp'];
    final tsMs = _parseMillis(ts);
    if (widget.ignorePastOnStartup &&
        tsMs != null &&
        tsMs < (_startupEpochMs - widget.allowedSkewMs)) {
      return;
    }

    final uid = (d['IndexKey']?.toString().isNotEmpty ?? false)
        ? d['IndexKey'].toString()
        : '$rid|${ts ?? ''}';

    if (_processed.contains(uid)) return;
    _processed.add(uid);
    _saveProcessed();

    final when = _parseDateTime(ts) ?? DateTime.now();

    _showDialog(
      severity: rawEvent,
      rid: rid,
      label: label,
      occurredAt: when,
    );
  }

  bool _isAlertEvent(String normalized) {
    // 요구사항: '경고' | '위험' | '점검필요' | (필요하면 '주의'도 허용)
    return normalized == '경고' ||
        normalized == '위험' ||
        normalized == '점검필요' ||
        normalized == '주의';
  }

  String? _mapEventType(int? eventType) {
    if (eventType == null) return null;
    switch (eventType) {
      case 68:
        return '경고';
      case 67:
        return '주의';
    // 필요 시 추가 매핑. “점검필요”는 센서 이벤트로 직접 오진 않지만,
    // 연결/지연 감지로 서버가 브로드캐스트하면 위 _handleIotAlert 에서 처리됩니다.
      default:
        return null; // 정상/기타는 무시
    }
  }

  int? _parseMillis(dynamic ts) {
    try {
      if (ts == null) return null;
      if (ts is num) return ts.toInt();
      final dt = DateTime.tryParse('$ts');
      return dt?.millisecondsSinceEpoch;
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDateTime(dynamic ts) {
    try {
      if (ts == null) return null;
      if (ts is num) return DateTime.fromMillisecondsSinceEpoch(ts.toInt());
      return DateTime.tryParse('$ts')?.toLocal();
    } catch (_) {
      return null;
    }
  }

  // -------------------- UI --------------------
  void _showDialog({
    required String severity,
    required String rid,
    required String label,
    required DateTime occurredAt,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => IotAlarmDialog(
        severity: severity, // '경고' | '위험' | '점검 필요' | '주의'
        rid: rid,
        label: label,
        occurredAt: occurredAt,
        btnText: '확인',
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
