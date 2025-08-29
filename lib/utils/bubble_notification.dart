import 'package:flutter/material.dart';

class BubbleNotification {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context, {
    required String message,
    BubbleType type = BubbleType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    // Remover notificación anterior si existe
    _currentOverlay?.remove();
    
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _BubbleWidget(
        message: message,
        type: type,
        onTap: onTap,
        onDismiss: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
      ),
    );
    
    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);
    
    // Auto-dismiss después del tiempo especificado
    Future.delayed(duration, () {
      if (_currentOverlay == overlayEntry) {
        overlayEntry.remove();
        _currentOverlay = null;
      }
    });
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

enum BubbleType {
  success,
  error,
  warning,
  info,
}

class _BubbleWidget extends StatefulWidget {
  final String message;
  final BubbleType type;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _BubbleWidget({
    required this.message,
    required this.type,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<_BubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case BubbleType.success:
        return Colors.green.shade600;
      case BubbleType.error:
        return Colors.red.shade600;
      case BubbleType.warning:
        return Colors.orange.shade600;
      case BubbleType.info:
        return Colors.blue.shade600;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case BubbleType.success:
        return Icons.check_circle;
      case BubbleType.error:
        return Icons.error;
      case BubbleType.warning:
        return Icons.warning;
      case BubbleType.info:
        return Icons.info;
    }
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap ?? _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIcon(),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extensión para facilitar el uso
extension BubbleNotificationExtension on BuildContext {
  void showBubble(
    String message, {
    BubbleType type = BubbleType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    BubbleNotification.show(
      this,
      message: message,
      type: type,
      duration: duration,
      onTap: onTap,
    );
  }

  void showSuccessBubble(String message) {
    showBubble(message, type: BubbleType.success);
  }

  void showErrorBubble(String message) {
    showBubble(message, type: BubbleType.error);
  }

  void showWarningBubble(String message) {
    showBubble(message, type: BubbleType.warning);
  }

  void showInfoBubble(String message) {
    showBubble(message, type: BubbleType.info);
  }
}