import 'package:alh_pdf_view/lib.dart';
import 'package:alh_pdf_view/view/alh_pdf_view.dart';
import 'package:flutter/services.dart';

/// Calling native methods that can change the current settings of the PDF.
class AlhPdfViewController {
  final RenderCallback? onRender;
  final PageChangedCallback? onPageChanged;
  final ErrorCallback? onError;
  final PageErrorCallback? onPageError;
  final ZoomChangedCallback? onZoomChanged;

  late final MethodChannel _channel;

  AlhPdfViewController({
    required int id,
    required this.onRender,
    required this.onPageChanged,
    required this.onError,
    required this.onPageError,
    required this.onZoomChanged,
  }) {
    _channel = MethodChannel('alh_pdf_view_$id');
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onRender':
        if (onRender != null) {
          onRender!(call.arguments['pages']);
        }
        break;
      case 'onPageChanged':
        if (onPageChanged != null) {
          onPageChanged!(
            call.arguments['page'],
            call.arguments['total'],
          );
        }
        break;
      case 'onError':
        if (onError != null) {
          onError!(call.arguments['error']);
        }
        break;
      case 'onPageError':
        if (onPageError != null) {
          onPageError!(
            call.arguments['page'],
            call.arguments['error'],
          );
        }
        break;
      case 'onZoomChanged':
        if (onZoomChanged != null) {
          onZoomChanged!(call.arguments['zoom']);
        }
        break;
      default:
        throw MissingPluginException(
          '${call.method} was invoked but has no handler',
        );
    }
  }

  /// Returns the number of pages  for the PDF.
  Future<int> getPageCount() async {
    final int pageCount = await _channel.invokeMethod('pageCount');
    return pageCount;
  }

  /// Returns the current page that is shown.
  ///
  /// The page index begins at 0.
  Future<int> getCurrentPage() async {
    final int currentPage = await _channel.invokeMethod('currentPage');
    return currentPage;
  }

  /// Jumping to the given [page].
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  Future<bool> setPage({required int page, bool withAnimation = true}) async {
    return await _channel.invokeMethod('setPage', <String, dynamic>{
      'page': page,
      'withAnimation': withAnimation,
    });
  }

  /// Goes to the next page.
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  Future<bool> goToNextPage({bool withAnimation = true}) async {
    return await _channel.invokeMethod(
      'nextPage',
      {'withAnimation': withAnimation},
    );
  }

  /// Goes to the next page.
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  Future<bool> goToPreviousPage({bool withAnimation = true}) async {
    return await _channel.invokeMethod(
      'previousPage',
      {'withAnimation': withAnimation},
    );
  }

  /// Setting the scale factor to the default zoom factor.
  Future<void> resetZoom() async {
    await _channel.invokeMethod('resetZoom');
  }

  /// Zooming to the given [zoom].
  ///
  /// By default, the zoom animation duration is 400 ms.
  Future<void> setZoom({required double zoom}) async {
    await _channel.invokeMethod('setZoom', <String, dynamic>{
      'newZoom': zoom,
    });
  }

  /// Returns the current zoom value.
  Future<double> getZoom() async {
    final double zoom = await _channel.invokeMethod('currentZoom');
    return zoom;
  }

  /// Returns the size of the given [page] index.
  ///
  /// Only working for iOS.
  Future<Size> getPageSize({required int page}) async {
    final sizeMap = await _channel.invokeMethod('pageSize', {'page': page});
    return Size(sizeMap["width"], sizeMap["height"]);
  }
}
