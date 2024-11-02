import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return DockItem(icon: icon);
            },
          ),
        ),
      ),
    );
  }
}

class DockItem extends StatelessWidget {
  const DockItem({
    Key? key,
    required this.icon,
  }) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
      ),
      child: Center(child: Icon(icon, color: Colors.white)),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late List<T> _items = widget.items.toList();
  final Map<int, Offset> _positions = {};
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black26,
      ),
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 120,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Stack(
          children: [
            for (int i = 0; i < _items.length; i++)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: _positions.containsKey(i) ? _positions[i]!.dx : i * 60.0,
                top: _positions.containsKey(i) ? _positions[i]!.dy : 36.0,
                child: GestureDetector(
                  onPanStart: (_) {
                    setState(() => _draggingIndex = i);
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _positions[i] =
                          (_positions[i] ?? Offset(i * 60.0, 36.0)) +
                              details.delta;
                    });
                  },
                  onPanEnd: (_) {
                    setState(() {
                      final newIndex = _calculateNearestIndex(_positions[i]!);
                      _reorderItems(_draggingIndex!, newIndex);
                      _draggingIndex = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: _draggingIndex == i
                        ? (Matrix4.identity()..scale(1.2))
                        : Matrix4.identity(),
                    child: widget.builder(_items[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _calculateNearestIndex(Offset offset) {
    final iconWidth = 60.0;
    int nearestIndex = 0;
    double nearestDistance = double.infinity;

    for (int i = 0; i < _items.length; i++) {
      final targetPosition = Offset(i * iconWidth, 36.0);
      final distance = (offset - targetPosition).distance;

      if (distance < nearestDistance) {
        nearestIndex = i;
        nearestDistance = distance;
      }
    }
    return nearestIndex;
  }

  void _reorderItems(int fromIndex, int toIndex) {
    setState(() {
      final item = _items.removeAt(fromIndex);
      _items.insert(toIndex, item);

      for (int i = 0; i < _items.length; i++) {
        _positions[i] = Offset(i * 60.0, 36.0);
      }
    });
  }
}
