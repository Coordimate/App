import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class DraggableBottomSheet extends StatefulWidget {
  final Widget child;
  final double initialChildSize;

  const DraggableBottomSheet({
    super.key,
    required this.child,
    required this.initialChildSize,
  });

  @override
  State<DraggableBottomSheet> createState() => DraggableBottomSheetState();
}

class DraggableBottomSheetState extends State<DraggableBottomSheet> {
  final sheet = GlobalKey();
  final controller = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    controller.addListener(onChanged);
  }

  void collapse() => animateSheet(getSheet.snapSizes!.first);
  void expand() => animateSheet(getSheet.maxChildSize);
  void anchor() => animateSheet(getSheet.snapSizes!.last);
  void hide() => animateSheet(getSheet.minChildSize);

  void animateSheet(double value) {
    controller.animateTo(
      value,
      duration: const Duration(microseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  DraggableScrollableSheet get getSheet =>
      sheet.currentWidget as DraggableScrollableSheet;

  void onChanged() {
    final currentSize = controller.size;
    if (currentSize <= 0.25) collapse();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builder, constraints) {
      return DraggableScrollableSheet(
          key: sheet,
          initialChildSize: widget.initialChildSize,
          maxChildSize: 0.985,
          minChildSize: widget.initialChildSize,
          expand: true,
          snap: true,
          snapSizes: [
            widget.initialChildSize,
            0.985,
          ],
          builder: (BuildContext context, ScrollController scrollController) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: darkBlue,
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  topButtonIndicator(),
                  SliverToBoxAdapter(
                    child: widget.child,
                  ),
                ],
              ),
            );
          });
    });
  }

  SliverToBoxAdapter topButtonIndicator() {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Wrap(
              children: [
                Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 5,
                  decoration: BoxDecoration(
                    color: darkBlue,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}