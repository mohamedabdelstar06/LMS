import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CommentSuperEngine {
  CommentSuperEngine._();

  static final CommentSuperEngine instance = CommentSuperEngine._();

  final Map<int, _CommentNode> _nodes = {};
  Timer? _timer;

  void register(int id, VoidCallback rebuild, BuildContext context) {
    _nodes[id] = _CommentNode(rebuild, context);
    _start();
  }

  void unregister(int id) {
    _nodes.remove(id);
  }

  void _start() {
    if (_timer != null) return;

    _timer = Timer.periodic(
      const Duration(seconds: 20),
          (_) => _updateVisibleNodes(),
    );
  }

  void _updateVisibleNodes() {
    final nodes = Map<int, _CommentNode>.from(_nodes);

    for (final entry in nodes.entries) {
      final node = entry.value;

      if (!_isWidgetVisible(node.context)) continue;

      if (node.context.mounted) {
        node.rebuild();
      }
    }
  }

  bool _isWidgetVisible(BuildContext context) {
    final renderObject = context.findRenderObject();

    if (renderObject is RenderBox && renderObject.attached) {
      final vp = RenderAbstractViewport.of(renderObject);
      if (vp == null) return false;

      final offset = vp.getOffsetToReveal(renderObject, 0.0).offset;

      return offset >= 0;
    }

    return false;
  }
}

class _CommentNode {
  final VoidCallback rebuild;
  final BuildContext context;

  _CommentNode(this.rebuild, this.context);
}