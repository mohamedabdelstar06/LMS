import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../log_helper/helper.dart';
import '../model.dart';

// ─── Sky Palette (same as screen) ─────────────────────────────────────────────
class _Sky {
  static const bg         = Color(0xFFF0F7FF);
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF5F9FF);
  static const border     = Color(0xFFD4E6F9);

  static const blue1 = Color(0xFF2980D9);
  static const blue2 = Color(0xFF4AA8F2);
  static const blue3 = Color(0xFF82C5F8);
  static const blue4 = Color(0xFFBEDEFB);
  static const blue5 = Color(0xFFDCEEFD);

  static const textPrimary   = Color(0xFF0D2B4E);
  static const textSecondary = Color(0xFF4A7098);
  static const textMuted     = Color(0xFF8AAEC8);

  static const green  = Color(0xFF10B981);
  static const purple = Color(0xFF7C3AED);
  static const amber  = Color(0xFFF59E0B);
  static const pink   = Color(0xFFEC4899);
  static const red    = Color(0xFFEF4444);
}
// ───────────────────────────────────────────────────────────────────────────────

class LogCard extends StatefulWidget {
  final ActivityLog log;
  final int index;

  const LogCard({super.key, required this.log, required this.index});

  @override
  State<LogCard> createState() => _LogCardState();
}

class _LogCardState extends State<LogCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index % 10) * 30),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.index % 10 * 40), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final log            = widget.log;
    final componentColor = LogHelpers.componentColor(log.component);
    final originIcon     = LogHelpers.originIcon(log.origin);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit:  (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _hovered ? _Sky.blue5 : _Sky.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? componentColor.withOpacity(0.45)
                    : _Sky.border,
                width: 1.2,
              ),
              boxShadow: _hovered
                  ? [
                BoxShadow(
                  color: componentColor.withOpacity(0.13),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: _Sky.blue3.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : [
                BoxShadow(
                  color: _Sky.blue4.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildComponentBadge(log, componentColor),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMainContent(log, componentColor)),
                  const SizedBox(width: 16),
                  _buildMetaColumn(log, originIcon),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComponentBadge(ActivityLog log, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: color.withOpacity(0.28)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              log.component.substring(
                  0, log.component.length > 2 ? 2 : log.component.length),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: _Sky.surfaceAlt,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _Sky.border),
          ),
          child: Text(
            '#${log.id}',
            style: const TextStyle(
              color: _Sky.textMuted,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(ActivityLog log, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                log.eventName,
                style: const TextStyle(
                  color: _Sky.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _EventTag(eventName: log.eventName, color: color),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _Sky.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _Sky.border),
          ),
          child: Text(
            log.description,
            style: const TextStyle(
              color: _Sky.textSecondary,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.person_outline,
                size: 13, color: _Sky.textMuted),
            const SizedBox(width: 4),
            Text(
              log.userFullName,
              style: const TextStyle(
                  color: _Sky.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(width: 14),
            const Icon(Icons.info_outline,
                size: 13, color: _Sky.textMuted),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                log.eventContext,
                style: const TextStyle(
                    color: _Sky.textMuted, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaColumn(ActivityLog log, IconData originIcon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          LogHelpers.formatTime(log.time),
          style: const TextStyle(
            color: _Sky.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          LogHelpers.formatDate(log.time),
          style: const TextStyle(color: _Sky.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 10),
        _IpChip(ip: log.ipAddress),
        const SizedBox(height: 8),
        _OriginBadge(origin: log.origin, icon: originIcon),
      ],
    );
  }
}

// ─── Event Tag ─────────────────────────────────────────────────────────────────
class _EventTag extends StatelessWidget {
  final String eventName;
  final Color color;

  const _EventTag({required this.eventName, required this.color});

  @override
  Widget build(BuildContext context) {
    final isCreate = eventName.toLowerCase().contains('creat');
    final isLogin  = eventName.toLowerCase().contains('log');
    final isGet    = eventName.toLowerCase().contains('get');

    final tagColor = isCreate
        ? _Sky.green
        : isLogin
        ? _Sky.blue1
        : isGet
        ? _Sky.purple
        : color;

    final label = isCreate
        ? 'CREATE'
        : isLogin
        ? 'AUTH'
        : isGet
        ? 'READ'
        : 'EVENT';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tagColor.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tagColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── IP Chip ───────────────────────────────────────────────────────────────────
class _IpChip extends StatefulWidget {
  final String ip;
  const _IpChip({required this.ip});

  @override
  State<_IpChip> createState() => _IpChipState();
}

class _IpChipState extends State<_IpChip> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.ip));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copy,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: _copied
                ? _Sky.green.withOpacity(0.10)
                : _Sky.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _copied
                  ? _Sky.green.withOpacity(0.45)
                  : _Sky.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _copied ? Icons.check_rounded : Icons.wifi_outlined,
                size: 11,
                color: _copied ? _Sky.green : _Sky.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                widget.ip.length > 15
                    ? '${widget.ip.substring(0, 15)}...'
                    : widget.ip,
                style: TextStyle(
                  color: _copied ? _Sky.green : _Sky.textSecondary,
                  fontSize: 10.5,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Origin Badge ──────────────────────────────────────────────────────────────
class _OriginBadge extends StatelessWidget {
  final String origin;
  final IconData icon;

  const _OriginBadge({required this.origin, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isWeb  = origin == 'web';
    final color  = isWeb ? _Sky.blue1 : _Sky.amber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            origin.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Card ────────────────────────────────────────────────────────────────
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Sky.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Sky.border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: _Sky.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                      color: _Sky.textMuted, fontSize: 11.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Chip ───────────────────────────────────────────────────────────────
class FilterChipWidget extends StatefulWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  State<FilterChipWidget> createState() => _FilterChipWidgetState();
}

class _FilterChipWidgetState extends State<FilterChipWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.color.withOpacity(0.12)
                : _hovered
                ? widget.color.withOpacity(0.06)
                : _Sky.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.selected
                  ? widget.color.withOpacity(0.55)
                  : _hovered
                  ? widget.color.withOpacity(0.3)
                  : _Sky.border,
              width: widget.selected ? 1.4 : 1.0,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.selected
                  ? widget.color
                  : _hovered
                  ? widget.color.withOpacity(0.75)
                  : _Sky.textSecondary,
              fontSize: 12.5,
              fontWeight: widget.selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}