import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/pages/civil/civil_account_page/taksi_history_page.dart';
import 'package:taksi/pages/civil/civil_page.dart';
import 'package:taksi/pages/civil/near_cars/near_cars.dart';
import 'package:taksi/pages/civil/near_truck/near_truck.dart';
import 'package:taksi/pages/civil/taksi_create_order/taksi_page.dart';
// import 'package:taksi/pages/civil/yandex_maps/yandex_map_page.dart';
import 'package:taksi/pages/drivers_taxi/4Account/account_detail_info/account_detail_info_taksi.dart';
import 'package:taksi/pages/drivers_taxi/4Account/get_balance/balance_page.dart';
import 'package:taksi/pages/drivers_taxi/4Account/get_balance/balance_verify_page.dart';
import 'package:taksi/pages/drivers_taxi/4Account/get_tarifs/tarifs_page.dart';
import 'package:taksi/pages/drivers_taxi/4Account/payment_history/payment_history.dart';
import 'package:taksi/pages/drivers_taxi/4Account/settings/app_info.dart';
import 'package:taksi/pages/drivers_taxi/4Account/settings/taxiDriverSettings.dart';
import 'package:taksi/pages/drivers_taxi/chat_page/chat_page.dart';
import 'package:taksi/pages/drivers_taxi/driver_taxi_home.dart';
import 'package:taksi/pages/drivers_truck/driver_truck_home.dart';
import 'package:taksi/pages/home_screen.dart';
import 'package:taksi/pages/new_user/enter_detail_info.dart';
import 'package:taksi/pages/new_user/get_permissions/get_permissions.dart';
import 'package:taksi/pages/new_user/get_permissions/permission_done.dart';
import 'package:taksi/pages/new_user/role_select.dart';
import 'package:taksi/pages/sign/login_screen.dart';
import 'package:taksi/pages/sign/smsverify.dart';
import 'package:taksi/pages/sign/signup_screen.dart';
import 'package:taksi/services/db/cache.dart';
import '../pages/civil/civil_account_page/civil_account.dart';

abstract class Routes {
  static const permissionPage = '/permissionPage';
  static const donePage = '/donePage';

//////////////////////////////////////////////////////////
  static const passCodePage = '/passCodePage';
  static const initialPassCodePage = '/initialPassCodePage';
  static const homeScreen = '/homeScreen';
///////////////////////////////////////////////////////
  static const loginScreen = '/loginScreen';
  static const verfySMS = '/verfySMS';
  static const register = '/register';
///////////////////////////////////////////////////////

  static const civilPage = '/civilPage';
  static const taxiPage = '/taxiPage';
  static const taxiDeliveryPage = '/taxiDeliveryPage';
  static const civilAccountPage = '/civilAccountPage';
  static const civilTaksiHistoryPage = '/civilTaksiHistoryPage';
  static const nearCars = '/nearCars';
  static const nearTrucks = '/nearTrucks';

///////////////////////////////////////////////////////
  static const roleSelect = '/roleSelect';
  static const enterDetailInfo = '/enterDetailInfo';
///////////////////////////////////////////////////////
  static const taxiDriverPage = '/taxiDriverPage';

  static const taxiBalancePage = '/taxiBalancePage';
  static const paymentStatus = '/paymentStatus';
  static const paymentHistory = '/paymentHistory';
  static const accountDetailInfoPage = '/accountDetailInfoPage';
  static const tarifsPage = '/tarifsPage';
  static const settingsPage = '/settingsPage';
  static const chatPageTaxi = '/chatPageTaxi';

  ///////////////////////////////////////////////////////

  static const truckDriverPage = '/truckDriverPage';

  static const testPage = '/testPage';
  static const yandex_map_truck = '/yandex_map_truck';

  static const appInfo = '/appInfo';
}

String _initialLocation() {
  // return Routes.permissionPage;

  final permission = cache.getBool("permission");
  final userToken = cache.getString("user_token");

  if (userToken != null) {
    return Routes.homeScreen;
  } else {
    if (permission == false || permission == null) {
      return Routes.permissionPage;
    }
    return Routes.loginScreen;
  }
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
    // GoRoute(
    //   path: Routes.testPage,
    //   builder: (context, state) => TelegramStyleVideoRecorder(),
    // ),
    // GoRoute(
    //   path: Routes.yandex_map_truck,
    //   builder: (context, state) => const MapkitFlutterApp(),
    // ),
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
      path: Routes.paymentStatus,
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
      builder: (context, state) => TaxiPage(),
    ),
  
    GoRoute(
      path: Routes.accountDetailInfoPage,
      builder: (context, state) => const AccountDetailInfoTaksi(),
    ),
    GoRoute(
      path: Routes.civilAccountPage,
      builder: (context, state) => const CivilAccount(),
    ),
    GoRoute(
      path: Routes.civilTaksiHistoryPage,
      builder: (context, state) => const CivilTaksiHistoryPage(),
    ),
    // GoRoute(
    //   path: Routes.passCodePage,
    //   builder: (context, state) => const PasscodeScreen(),
    // ),
    // GoRoute(
    //   path: Routes.initialPassCodePage,
    //   builder: (context, state) => const InitialPasscode(),
    // ),

    GoRoute(
      path: Routes.settingsPage,
      builder: (context, state) => const Taxidriversettings(),
    ),
    GoRoute(
      path: Routes.nearCars,
      builder: (context, state) => const CivilNearCars(),
    ),
    GoRoute(
      path: Routes.nearTrucks,
      builder: (context, state) => const CivilNearTruck(),
    ),
    GoRoute(
      path: Routes.chatPageTaxi,
      builder: (context, state) {
        final chatRoomIdFromCache = cache.getString('chat_room_id');
        final chatRoomId = state.extra as String?;
        return ChatScreen(
          chatRoomId: chatRoomIdFromCache ?? chatRoomId ?? '',
        );
      },
    ),
    GoRoute(
      path: Routes.permissionPage,
      builder: (context, state) => const PermissionScreen(),
    ),
    GoRoute(
      path: Routes.donePage,
      builder: (context, state) => const DonePage(),
    ),
    GoRoute(
      path: Routes.appInfo,
      builder: (context, state) => AppInfo(),
    ),
  ],
);
