import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tamasya/util/underscore.dart';

/// use ScrollablePositionedList if you want to scroll to index feature,
/// beside that, just use default listview
class ListViewScroll extends StatefulWidget {
  final int minOffsetBottom;
  final int initScrollToOfset;
  final EdgeInsets padding;
  final List<Widget> children;
  final Function(ScrollNotification) onScrollNotif;
  final String useInRouteName;
  final String currentRouteName;
  final int itemCount;
  final Future<void> Function() onRefresh;
  final int maxItemToTriggerArrowSticky;

  /// use this only with scrollable_positioned_list
  final Function(BuildContext context, int i) itemBuilder;
  final Function() onScrollBottom;
  final Function(double offset) onScroll;

  ListViewScroll(
      {Key key,
      this.minOffsetBottom = 30,
      this.children,
      this.onScrollNotif,
      this.padding,
      this.initScrollToOfset,
      this.useInRouteName,
      this.currentRouteName,
      this.itemCount,
      this.itemBuilder,
      this.onScrollBottom,
      this.onScroll,
      this.maxItemToTriggerArrowSticky,
      this.onRefresh})
      : super(key: key);

  @override
  _ListViewScrollState createState() => _ListViewScrollState();
}

class _ListViewScrollState extends State<ListViewScroll> {
  ScrollController scrollController = ScrollController();
  ItemScrollController itemScrollController;
  ItemPositionsListener itemPositionsListener;
  List<ItemPosition> scrollBefore;

  bool get useScrollablePosition =>
      widget.itemCount != null &&
      widget.itemBuilder != null &&
      widget.children == null;

  @override
  void initState() {
    super.initState();

    if (useScrollablePosition) {
      itemScrollController = ItemScrollController();
      itemPositionsListener = ItemPositionsListener.create();

      /// event listener invoked not by user, but by list value
      /// so if the content count height < screen height
      /// the float button arrow up will remain visible
      itemPositionsListener.itemPositions.addListener(() {
        List<ItemPosition> positions =
            itemPositionsListener.itemPositions.value.toList();
        scrollBefore = positions;

        int idxLast = -1;
        int idx = -1;
        bool isBottomScroll =
            positions.fold(false, (bool accu, ItemPosition element) {
          idx++;

          if (element.index == (widget.itemCount - 1)) {
            accu = true;
            idxLast = idx;
          }

          return accu;
        });

        if (idxLast > -1 && isBottomScroll) {
          var position = positions.elementAt(idxLast);
          isBottomScroll = position.itemTrailingEdge >= 0.75;
        }

        if (isBottomScroll && widget.onScrollBottom != null) {
          debounce(400, widget.onScrollBottom, null);
        }
      });
    } else {
      scrollController = ScrollController();
      scrollController.addListener(onScrollListener);
    }
  }

  @override
  void didUpdateWidget(ListViewScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initScrollToOfset != widget.initScrollToOfset) {
      if (useScrollablePosition) {
        itemScrollController.jumpTo(index: widget.initScrollToOfset);
      } else {
        scrollController.animateTo(widget?.initScrollToOfset?.toDouble() ?? 0,
            duration: Duration(milliseconds: 100), curve: Curves.easeIn);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void onScrollListener() {
    if (widget.onScroll != null) {
      debounce(400, widget.onScroll, [scrollController.offset]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (useScrollablePosition) {
      Widget mainScrollableList = ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          physics:
              widget.onRefresh != null ? AlwaysScrollableScrollPhysics() : null,
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder);

      if (widget.onRefresh != null) {
        mainScrollableList = RefreshIndicator(
            child: mainScrollableList, onRefresh: widget.onRefresh);
      }

      return mainScrollableList;
    }

    Widget mainList = ListView(
      padding: widget.padding,
      controller: scrollController,
      children: widget.children,
      physics:
          widget.onRefresh != null ? AlwaysScrollableScrollPhysics() : null,
    );

    if (widget.onRefresh != null) {
      mainList = RefreshIndicator(child: mainList, onRefresh: widget.onRefresh);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollNotification) {
        if (widget.onScrollNotif != null) {
          widget.onScrollNotif(scrollNotification);
        }

        return true;
      },
      child: mainList,
    );
  }
}
