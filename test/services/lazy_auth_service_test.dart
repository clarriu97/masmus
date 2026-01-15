import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/services/auth/lazy_auth_service.dart';

void main() {
  group('LazyAuthService', () {
    late LazyAuthService authService;

    setUp(() {
      authService = LazyAuthService();
    });

    test('starts as guest by default', () {
      expect(authService.isGuest, true);
      expect(authService.isAuthenticated, false);
    });

    test('loginAsGuest sets guest mode', () {
      authService.loginAsGuest();

      expect(authService.isGuest, true);
      expect(authService.isAuthenticated, false);
    });

    test('requiresAuth returns true for protected actions', () {
      expect(authService.requiresAuth('create_private_match'), true);
      expect(authService.requiresAuth('join_tournament'), true);
      expect(authService.requiresAuth('purchase_items'), true);
      expect(authService.requiresAuth('send_friend_request'), true);
    });

    test('requiresAuth returns false for public actions', () {
      expect(authService.requiresAuth('view_home'), false);
      expect(authService.requiresAuth('play_quick_match'), false);
      expect(authService.requiresAuth('unknown_action'), false);
    });

    test('login changes authentication state', () async {
      final bool result = await authService.login('test@test.com', 'password');

      expect(result, true);
      expect(authService.isAuthenticated, true);
      expect(authService.isGuest, false);
    });

    test('logout resets to guest state', () async {
      await authService.login('test@test.com', 'password');
      authService.logout();

      expect(authService.isAuthenticated, false);
      expect(authService.isGuest, true);
    });

    test('singleton pattern returns same instance', () {
      final LazyAuthService instance1 = LazyAuthService();
      final LazyAuthService instance2 = LazyAuthService();

      expect(identical(instance1, instance2), true);
    });
  });
}
