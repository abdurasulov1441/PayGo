import 'package:flutter/material.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:taksi/pages/drivers_taxi/1Order/taxi_orders_page.dart';
import 'package:taksi/pages/drivers_taxi/2Accepted/taxi_accpeted_orders_page.dart';
import 'package:taksi/pages/drivers_taxi/3History/taxi_orders_history_page.dart';
import 'package:taksi/pages/drivers_taxi/4Account/taxi_account.dart';
import 'package:taksi/style/app_colors.dart';

class DriverTaxiHome extends StatefulWidget {
  const DriverTaxiHome({super.key});

  @override
  State createState() => _FluidNavBarDemoState();
}

class _FluidNavBarDemoState extends State<DriverTaxiHome> {
  Widget _child = TaxiOrdersPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.grade1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
        onPressed: () {},
        child: SvgPicture.asset(
          'assets/images/message.svg',
          color: AppColors.backgroundColor,
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(microseconds: 10),
        child: _child,
      ),
      bottomNavigationBar: FluidNavBar(
        icons: [
          FluidNavBarIcon(
            svgPath: "assets/images/orders.svg",
            backgroundColor: AppColors.grade1,
            extras: {"label": "Home"},
          ),
          FluidNavBarIcon(
            svgPath: "assets/images/accepted_orders.svg",
            backgroundColor: AppColors.grade1,
            extras: {"label": "Orders"},
          ),
          FluidNavBarIcon(
            svgPath: "assets/images/orders_history.svg",
            backgroundColor: AppColors.grade1,
            extras: {"label": "History"},
          ),
          FluidNavBarIcon(
            svgPath: "assets/images/account.svg",
            backgroundColor: AppColors.grade1,
            extras: {"label": "Account"},
          ),
        ],
        onChange: _handleNavigationChange,
        style: FluidNavBarStyle(
          barBackgroundColor: AppColors.grade1,
          iconUnselectedForegroundColor: AppColors.backgroundColor,
          iconSelectedForegroundColor: AppColors.backgroundColor,
        ),
        scaleFactor: 1.5,
        defaultIndex: 0,
      ),
    );
  }

  void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          _child = TaxiOrdersPage();
          break;
        case 1:
          _child = TaxiAcceptedOrdersPage();
          break;
        case 2:
          _child = TaxiOrdersHistoryPage();
          break;
        case 3:
          _child = TaxiAccountPage();
          break;
      }
    });
  }
}
