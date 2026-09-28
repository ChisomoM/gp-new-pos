import 'dart:async';

import 'package:app_links/app_links.dart';

/// {@template deep_link_service}
/// Service for handling deep links and app links.
/// Listens for incoming links and emits navigation events.
/// {@endtemplate}
class DeepLinkService {
  /// {@macro deep_link_service}
  DeepLinkService();

  final _appLinks = AppLinks();
  final _linkController = StreamController<String?>.broadcast();
  StreamSubscription<Uri>? _linkSubscription;

  /// Stream of incoming deep links.
  Stream<String?> get linkStream => _linkController.stream;

  /// Initialize the service.
  Future<void> init() async {
    // Handle initial link if app was launched from a link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _linkController.add(initialLink.toString());
      }
    } catch (e) {
      // Handle error
    }

    // Listen for links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _linkController.add(uri.toString());
      },
      onError: (Object err) {
        // Handle error
      },
    );
  }

  /// Dispose the service.
  void dispose() {
    _linkSubscription?.cancel();
    _linkController.close();
  }
}
