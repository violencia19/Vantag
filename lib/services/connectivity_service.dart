import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _controller.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Servis başlat ve bağlantı durumunu dinlemeye başla
  Future<void> initialize() async {
    // Mevcut durumu kontrol et
    await checkConnectivity();

    // Değişiklikleri dinle
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectivity(results);
    });
  }

  /// Mevcut bağlantı durumunu kontrol et
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectivity(results);
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      _controller.add(false);
      return false;
    }
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;

    // none dışında herhangi bir bağlantı varsa connected
    _isConnected = results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);

    // Sadece değişiklik olduğunda bildir
    if (wasConnected != _isConnected) {
      _controller.add(_isConnected);
    }
  }

  /// Gerçek internet erişimini test et (opsiyonel, daha yavaş)
  Future<bool> hasRealInternetAccess() async {
    try {
      // Basit bir HTTP isteği yaparak gerçek erişimi test et
      // Bu opsiyonel, connectivity_plus sadece ağ bağlantısını kontrol eder
      return _isConnected;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
