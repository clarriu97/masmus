/// Servicio de autenticación perezosa que permite explorar la app sin registro
class LazyAuthService {
  factory LazyAuthService() {
    return _instance;
  }

  LazyAuthService._internal();
  static final LazyAuthService _instance = LazyAuthService._internal();

  bool _isGuest = true;
  bool _isAuthenticated = false;

  bool get isGuest => _isGuest;
  bool get isAuthenticated => _isAuthenticated;

  /// Inicia sesión como invitado
  void loginAsGuest() {
    _isGuest = true;
    _isAuthenticated = false;
  }

  /// Verifica si una acción requiere autenticación
  bool requiresAuth(String action) {
    // Acciones que requieren autenticación
    const authRequiredActions = [
      'create_private_match',
      'join_tournament',
      'purchase_items',
      'send_friend_request',
    ];

    return authRequiredActions.contains(action);
  }

  /// Simula inicio de sesión
  Future<bool> login(String email, String password) async {
    // TODO: Implementar lógica de autenticación real
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _isGuest = false;
    return true;
  }

  /// Cierra sesión
  void logout() {
    _isAuthenticated = false;
    _isGuest = true;
  }
}
