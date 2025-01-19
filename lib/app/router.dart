import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/pages/civil/civil_page.dart';
import 'package:taksi/pages/civil/delivery_page.dart';
import 'package:taksi/pages/civil/taksi_page.dart';
import 'package:taksi/pages/civil/test_page.dart';
import 'package:taksi/pages/civil/yandex_maps/yandex_map_page.dart';
import 'package:taksi/pages/drivers_taxi/4Account/get_balance/balance_page.dart';
import 'package:taksi/pages/drivers_taxi/4Account/get_balance/balance_verify_page.dart';
import 'package:taksi/pages/drivers_taxi/4Account/get_tarifs/tarifs_page.dart';
import 'package:taksi/pages/drivers_taxi/4Account/payment_history/payment_history.dart';
import 'package:taksi/pages/drivers_taxi/driver_taxi_home.dart';
import 'package:taksi/pages/drivers_truck/driver_truck_home.dart';
import 'package:taksi/pages/home_screen.dart';
import 'package:taksi/pages/new_user/enter_detail_info.dart';
import 'package:taksi/pages/new_user/role_select.dart';
import 'package:taksi/pages/sign/login_screen.dart';
import 'package:taksi/pages/sign/sign_up_verify.dart';
import 'package:taksi/pages/sign/signup_screen.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/language/language_select_page.dart';

abstract class Routes {
  static const selsctLanguagePage = '/selsctLanguagePage';

  static const homeScreen = '/homeScreen';
///////////////////////////////////////////////////////
  static const loginScreen = '/loginScreen';
  static const verfySMS = '/verfySMS';
  static const register = '/register';
///////////////////////////////////////////////////////

  static const civilPage = '/civilPage';
  static const taxiPage = '/taxiPage';
  static const taxiDeliveryPage = '/taxiDeliveryPage';

///////////////////////////////////////////////////////
  static const roleSelect = '/roleSelect';
  static const enterDetailInfo = '/enterDetailInfo';
///////////////////////////////////////////////////////
  static const taxiDriverPage = '/taxiDriverPage';

  static const taxiBalancePage = '/taxiBalancePage';
  static const paymentStatus = '/paymentStatus';
  static const paymentHistory = '/paymentHistory';

  static const tarifsPage = '/tarifsPage';

  ///////////////////////////////////////////////////////

  static const truckDriverPage = '/truckDriverPage';

  static const testPage = '/testPage';
  static const yandex_map_truck = '/yandex_map_truck';
}

String _initialLocation() {
  // return Routes.selsctLanguagePage;

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
      path: Routes.selsctLanguagePage,
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
    GoRoute(
      path: Routes.yandex_map_truck,
      builder: (context, state) => const MapkitFlutterApp(),
    ),
    GoRoute(
      path: Routes.truckDriverPage,
      builder: (context, state) => const DriverTruckHome(),
    ),
    GoRoute(
      path: Routes.taxiDriverPage,
      builder: (context, state) => const DriverTaxiHome(),
    ),
    GoRoute(
      path: Routes.enterDetailInfo,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;

        if (args == null || args['roleId'] == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Ошибка: Аргументы отсутствуют.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          );
        }

        final int roleId = args['roleId'];
        return EnterDetailInfo(roleId: roleId);
      },
    ),
    GoRoute(
      path: Routes.taxiBalancePage,
      builder: (context, state) => const BalancePage(),
    ),
    GoRoute(
      path: '/paymentStatus',
      builder: (context, state) {
        final invoiceId = state.extra as String;
        return PaymentStatusPage(invoiceId: invoiceId);
      },
    ),
    GoRoute(
      path: Routes.paymentHistory,
      builder: (context, state) => const PaymentHistoryPage(),
    ),
    GoRoute(
      path: Routes.tarifsPage,
      builder: (context, state) => const TariffsPage(),
    ),
    GoRoute(
      path: Routes.taxiPage,
      builder: (context, state) => const TaxiPage(),
    ),
    GoRoute(
      path: Routes.taxiDeliveryPage,
      builder: (context, state) => const DeliveryPage(),
    ),
  ],
);
