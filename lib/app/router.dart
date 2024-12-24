import 'package:go_router/go_router.dart';
import 'package:taksi/pages/civil/civil_page.dart';
import 'package:taksi/pages/civil/test_page.dart';
import 'package:taksi/pages/home_screen.dart';
import 'package:taksi/pages/new_user/role_select.dart';
import 'package:taksi/pages/sign/login_screen.dart';
import 'package:taksi/pages/sign/sign_up_verify.dart';
import 'package:taksi/pages/sign/signup_screen.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/language/language_select_page.dart';

abstract class Routes {
  static const selsctLanguagePage = '/selsctLanguagePage';

  static const homeScreen = '/homeScreen';

  static const loginScreen = '/loginScreen';
  static const verfySMS = '/verfySMS';
  static const register = '/register';

  static const roleSelect = '/roleSelect';
  static const civilPage = '/civilPage';

  static const testPage = '/testPage';
}

String _initialLocation() {
  return Routes.testPage;

  final userToken = cache.getString("user_token");

  if (userToken != null) {
    return Routes.homeScreen;
  }
  return Routes.selsctLanguagePage;
}

Object? _initialExtra() {
  return {};
}

final router = GoRouter(
  initialLocation: _initialLocation(),
  initialExtra: _initialExtra(),
  routes: [
    GoRoute(
      path: Routes.homeScreen,
      builder: (context, state) => const LanguageSelectionPage(),
    ),
    GoRoute(
      path: Routes.homeScreen,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.loginScreen,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.roleSelect,
      builder: (context, state) => const RoleSelectionPage(),
    ),
    GoRoute(
      path: Routes.register,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: Routes.verfySMS,
      builder: (context, state) {
        final phoneNumber = state.extra as String;
        return VerificationScreen(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: Routes.civilPage,
      builder: (context, state) => const MainCivilPage(),
    ),
    GoRoute(
      path: Routes.testPage,
      builder: (context, state) => const TestPage(),
    ),
  ],
);
