import 'package:flutter/material.dart';

typedef AnimatedGridBuilder<T> = Widget Function(BuildContext, T item, AnimatedGridDetails details);

/// Based on https://gist.github.com/lukepighetti/df460db180b9f6cb3410e3cc91ed74e6
class AnimatedGrid<T> extends StatelessWidget {
  const AnimatedGrid({
    Key? key,
    required this.itemHeight,
    required this.items,
    required this.keyBuilder,
    required this.builder,
    this.padding = 8,
    this.columns = 2,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.elasticOut,
  }) : super(key: key);

  final List<T> items;
  final Key Function(T item) keyBuilder;
  final AnimatedGridBuilder<T> builder;
  final int columns;
  final double itemHeight;
  final double padding;
  final Duration duration;
  final Curve curve;

  static int _rows(int columns, int count) => (count / columns).ceil();

  @visibleForTesting
  static List<int> gridIndices(int index, int columns, int count) {
    final rows = _rows(columns, count);
    final maxItemsForGridSize = columns * rows;
    final yIndex = (index / maxItemsForGridSize * rows).floor();
    final xIndex = index % columns;
    return [xIndex, yIndex];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        assert(constraints.hasBoundedWidth);
        final width = constraints.maxWidth;

        final count = items.length;
        final itemWidth = (width / columns) - padding / columns;
        final rows = _rows(columns, count);
        final gridHeight = rows * itemHeight + (padding * rows);

        return SizedBox(
          height: gridHeight,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              for (var i = 0; i < items.length; i++)
                Builder(
                  key: keyBuilder(items[i]),
                  builder: (context) {
                    final item = items[i];
                    final indices = gridIndices(i, columns, count);

                    final xIndex = indices.first;
                    final yIndex = indices.last;
                    final offset = Offset(
                      xIndex * itemWidth + xIndex * padding,
                      yIndex * itemHeight + yIndex * padding,
                    );

                    return TweenAnimationBuilder<Offset>(
                      tween: Tween<Offset>(end: offset),
                      duration: duration,
                      curve: curve,
                      builder: (context, offset, child) {
                        return Transform.translate(
                          offset: offset,
                          child: child,
                        );
                      },
                      child: SizedBox(
                        height: itemHeight,
                        width: itemWidth,
                        child: builder(
                          context,
                          item,
                          AnimatedGridDetails(
                            index: i,
                            columnIndex: xIndex,
                            rowIndex: yIndex,
                            columns: columns,
                            rows: rows,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedGridDetails {
  const AnimatedGridDetails({
    required this.index,
    required this.columnIndex,
    required this.rowIndex,
    required this.columns,
    required this.rows,
  });

  final int index;
  final int columnIndex;
  final int rowIndex;
  final int columns;
  final int rows;
}

extension IterableX<T> on Iterable<T> {
  int get lastIndex => isEmpty ? throw RangeError('Cannot find the last index of an empty iterable') : length - 1;
}
