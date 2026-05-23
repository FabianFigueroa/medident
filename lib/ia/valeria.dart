import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../main_export.dart';
import '../core/widgets/app_card.dart';

class ValeriaAssistant extends StatefulWidget {
  final Map<String, Function(Map<String, dynamic>)?>? extraTools;

  const ValeriaAssistant({super.key, this.extraTools});

  @override
  State<ValeriaAssistant> createState() => _ValeriaAssistantState();
}

class _ValeriaAssistantState extends State<ValeriaAssistant>
    with TickerProviderStateMixin {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late AnimationController _expandCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _zoomCtrl;
  late Animation<double> _zoomAnim;
  ValeriaRiveExpression? _lastExpression;
  bool _isExpanded = false;
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  static const double _collapsedSize = 56;
  static const double _panelWidth = 300;
  static const double _panelHeight = 380;
  static const double _avatarSize = 100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final valeria = context.read<ValeriaProvider>();
      valeria.registerTool('navigate', (params) {
        if (params['screen'] != null) {
          debugPrint('Valeria navigate to: ${params['screen']}');
        }
      });
    });
    _expandCtrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _floatCtrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _zoomCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _zoomAnim = CurvedAnimation(parent: _zoomCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _expandCtrl.dispose();
    _floatCtrl.dispose();
    _zoomCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandCtrl.forward();
      } else {
        _expandCtrl.reverse();
      }
    });
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize();
    if (!available) return;
    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) => _textCtrl.text = result.recognizedWords,
      onSoundLevelChange: (_) {},
      localeId: 'es_ES',
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    if (_textCtrl.text.trim().isNotEmpty) _sendMessage();
  }

  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();

    final valeria = context.read<ValeriaProvider>();
    await valeria.sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ValeriaProvider>(
      builder: (context, valeria, _) {
        if (!valeria.isVisible) return const SizedBox.shrink();

        if (_lastExpression != valeria.expression && _isExpanded) {
          _lastExpression = valeria.expression;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _zoomCtrl.forward(from: 0);
          });
        } else if (_lastExpression == null) {
          _lastExpression = valeria.expression;
        }

        return AnimatedBuilder(
          animation: _expandCtrl,
          builder: (context, _) {
            final t = _expandCtrl.value;
            final width = _collapsedSize + (_panelWidth - _collapsedSize) * t;
            final height = _collapsedSize + (_panelHeight - _collapsedSize) * t;
            final showPanel = t > 0.5;
            final panelOpacity = ((t - 0.5) / 0.5).clamp(0.0, 1.0);
            final btnOpacity = (1.0 - t / 0.5).clamp(0.0, 1.0);

            return GestureDetector(
              onTap: _isExpanded ? null : _toggleExpand,
              child: Container(
                width: width,
                height: height,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    _collapsedSize / 2 + (12 - _collapsedSize / 2) * t,
                  ),
                ),
                child: Stack(
                  children: [
                    if (showPanel)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        width: _panelWidth,
                        height: _panelHeight,
                        child: Opacity(
                          opacity: panelOpacity,
                          child: _buildPanel(valeria),
                        ),
                      ),
                    if (!showPanel)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        width: _collapsedSize,
                        height: _collapsedSize,
                        child: Opacity(
                          opacity: btnOpacity,
                          child: _buildCollapsed(valeria),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCollapsed(ValeriaProvider valeria) {
    final pulse = valeria.expression == ValeriaRiveExpression.thinking;
    return GestureDetector(
      onTap: _toggleExpand,
      child: Stack(
        children: [
          if (pulse)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 1.2),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, _) {
                return Container(
                  width: _collapsedSize,
                  height: _collapsedSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                );
              },
            ),
          Container(
            width: _collapsedSize,
            height: _collapsedSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowDark,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ValeriaRiveAvatar(
              size: _collapsedSize,
              expression: valeria.expression,
              isTyping: valeria.isTyping,
              cropToTopHalf: true,
            ),
          ),
          if (valeria.unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${valeria.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPanel(ValeriaProvider valeria) {
    final lastResponse = valeria.messages.isNotEmpty && !valeria.messages.last.isUser
        ? valeria.messages.last.text
        : null;
    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      borderRadius: 12,
      elevation: 6,
      color: AppColors.white,
      shadowColor: AppColors.shadowDark,
      child: Column(
        children: [
          _buildHeader(valeria),
          _buildAvatarArea(valeria),
          if (valeria.isTyping)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Pensando...',
                style: TextStyle(color: AppColors.grey500, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            )
          else if (lastResponse != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                lastResponse,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.grey700,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ),
          const Spacer(),
          _buildInputArea(valeria),
        ],
      ),
    );
  }

  Widget _buildHeader(ValeriaProvider valeria) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Valeria AI',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (valeria.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.grey500, size: 16),
              onPressed: () => valeria.clearMessages(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: 'Limpiar',
            ),
          IconButton(
            icon: const Icon(Icons.visibility_off_outlined, color: AppColors.grey500, size: 16),
            onPressed: () => valeria.toggleVisibility(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: 'Ocultar',
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.grey700, size: 18),
            onPressed: _toggleExpand,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarArea(ValeriaProvider valeria) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _zoomCtrl]),
      builder: (context, _) {
        final floatY = math.sin(_floatCtrl.value * math.pi * 2) * 6;
        final zoom = 1.0 + (_zoomAnim.value * 0.35);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Transform.translate(
              offset: Offset(0, floatY),
              child: Transform.scale(
                scale: zoom,
                child: ClipOval(
                  child: ValeriaRiveAvatar(
                    size: _avatarSize,
                    expression: valeria.expression,
                    isTyping: valeria.isTyping,
                    cropToTopHalf: true,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea(ValeriaProvider valeria) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Escribe algo...',
                hintStyle: TextStyle(color: AppColors.grey400, fontSize: 12),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
            ),
          ),
          GestureDetector(
            onTap: _isListening ? _stopListening : () => _startListening(),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _isListening ? AppColors.error : AppColors.grey200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.white : AppColors.grey600,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: valeria.isTyping ? null : _sendMessage,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: valeria.isTyping
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
