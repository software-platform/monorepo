import 'package:flutter/material.dart';

/// Signature for the function that builds an offset using the [childSize].
typedef OffsetBuilder = Offset Function(Size childSize);

/// Signature for the function that builds a trigger widget
/// using the [openPopup] and the [closePopup] callbacks.
typedef TriggerBuilder = Widget Function(
  BuildContext context,
  VoidCallback openPopup,
  VoidCallback closePopup,
  bool isPopupOpened,
);

/// A widget that displays the trigger widget built by the [triggerBuilder]
/// that opens the given [popup] when the trigger widget is activated.
class BasePopup extends StatefulWidget {
  /// A [RouteObserver] to subscribe to the route callbacks.
  final RouteObserver routeObserver;

  /// An additional constraints to apply to the [popup].
  final BoxConstraints popupConstraints;

  /// A callback that is called to build the [popup] offset from
  /// the trigger widget.
  final OffsetBuilder offsetBuilder;

  /// A callback that is called to build the trigger widget.
  final TriggerBuilder triggerBuilder;

  /// A widget to display when the trigger widget is triggered.
  final Widget popup;

  /// Indicates whether the [popup] should prevent other [MouseRegion]s
  /// visually behind it from detecting the pointer.
  final bool isPopupOpaque;

  /// Defines if the [popup] should close itself when user taps on space
  /// outside the visible container of the [popup].
  final bool closePopupWhenTapOutside;

  /// Creates a new instance of the base popup.
  ///
  /// If the [popupConstraints] is null, an empty instance of
  /// the [BoxConstraints] is used.
  ///
  /// The [isPopupOpaque] defaults value is `true`.
  /// The [closePopupWhenTapOutside] defaults value is `true`.
  ///
  /// All the required parameters must not be null.
  const BasePopup({
    Key key,
    BoxConstraints popupConstraints,
    @required this.offsetBuilder,
    @required this.triggerBuilder,
    @required this.popup,
    this.isPopupOpaque = true,
    this.closePopupWhenTapOutside = true,
    this.routeObserver,
  })  : popupConstraints = popupConstraints ?? const BoxConstraints(),
        assert(offsetBuilder != null),
        assert(triggerBuilder != null),
        assert(popup != null),
        super(key: key);

  @override
  _BasePopupState createState() => _BasePopupState();
}

class _BasePopupState extends State<BasePopup> with RouteAware {
  /// A [OverlayEntry] where used to display a [BasePopup.popup].
  OverlayEntry _overlayEntry;

  /// The [LayerLink] that allows a [BasePopup.popup] to follow the trigger.
  final _layerLink = LayerLink();

  /// Indicates whether the [widget.popup] is opened.
  bool get _isPopupOpened => _overlayEntry != null;

  @override
  void didChangeDependencies() {
    widget.routeObserver?.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.triggerBuilder(
        context,
        _openPopup,
        _closePopup,
        _isPopupOpened,
      ),
    );
  }

  /// Opens a [BasePopup.popup].
  void _openPopup() {
    final childBox = context.findRenderObject() as RenderBox;
    final childSize = childBox.size;
    final offset = widget.offsetBuilder(childSize);

    final _widget = Stack(
      children: <Widget>[
        if (widget.closePopupWhenTapOutside)
          GestureDetector(
            onTap: _closePopup,
          ),
        CompositedTransformFollower(
          showWhenUnlinked: false,
          link: _layerLink,
          offset: offset,
          child: MouseRegion(
            opaque: widget.isPopupOpaque,
            child: ConstrainedBox(
              constraints: widget.popupConstraints,
              child: widget.popup,
            ),
          ),
        ),
      ],
    );

    setState(() {
      _overlayEntry = OverlayEntry(builder: (context) => _widget);
    });

    Overlay.of(context).insert(_overlayEntry);
  }

  @override
  void didPushNext() {
    _closePopup();
    super.didPushNext();
  }

  /// Closes a [BasePopup.popup].
  void _closePopup() {
    if (_overlayEntry != null) {
      _overlayEntry.remove();

      setState(() {
        _overlayEntry = null;
      });
    }
  }

  @override
  void dispose() {
    widget.routeObserver?.unsubscribe(this);
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }
}
