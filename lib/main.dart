import 'package:flutter/material.dart';
import 'package:smart_franchise_pos/detail_history.dart';
import 'package:smart_franchise_pos/form_menu.dart';
import 'package:smart_franchise_pos/history.dart';
import 'package:smart_franchise_pos/login.dart';
import 'package:smart_franchise_pos/manage_accounts.dart';
import 'package:smart_franchise_pos/models/order_data.dart';
import 'package:smart_franchise_pos/order.dart';
import 'package:smart_franchise_pos/home.dart';
import 'package:smart_franchise_pos/register.dart';
import 'package:smart_franchise_pos/report.dart';
import 'package:smart_franchise_pos/services/user_data.dart';
import 'package:smart_franchise_pos/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Franchise POS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(movePage: "Login"),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  final String movePage;
  final OrderData? menuDetail;

  const MainPage({Key? key, required this.movePage, this.menuDetail})
      : super(key: key);

  @override
  State<MainPage> createState() =>
      _MainPageState(movePage: movePage, menuDetail: menuDetail);
}

class _MainPageState extends State<MainPage> {
  String pageActive = "Login";
  OrderData? detailMenu;
  List<Widget> bottomMenusRole = [];

  _MainPageState({required String movePage, OrderData? menuDetail}) {
    pageActive = movePage;
    detailMenu = menuDetail;
  }

  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  void _initUserData() async {
    userData = await UserDataService.getUserData();
    setState(() {});
  }

  _pageView() {
    if (userData['authStatus'] != "logged") {
      switch (pageActive) {
        case 'Login':
          return Login();
        case 'Register':
          return Register();
        default:
          return Login();
      }
    }

    if (userData['role'] == "owner") {
      bottomMenusRole = [
        _itemMenu(
          menu: 'Menus',
          icon: Icons.rocket_sharp,
        ),
        _itemMenu(
          menu: 'Report',
          icon: Icons.file_copy,
        ),
        _itemMenu(
          menu: 'Settings',
          icon: Icons.settings,
        ),
      ];
      switch (pageActive) {
        case 'Settings':
          break;
        case 'Order':
        case 'History':
        case 'DetailHistory':
          return Checkout();
        default:
          pageActive == "Login" ? pageActive = 'Menus' : '';
      }
    } else {
      bottomMenusRole = [
        _itemMenu(
          menu: 'Order',
          icon: Icons.format_list_bulleted_rounded,
        ),
        _itemMenu(
          menu: 'History',
          icon: Icons.history_toggle_off_rounded,
        ),
        _itemMenu(
          menu: 'Settings',
          icon: Icons.settings,
        ),
      ];
      switch (pageActive) {
        case 'Settings':
          break;
        case 'Menus':
        case 'FormMenu':
        case 'Report':
        case 'ManageAccounts':
          return HomePage();
        default:
          pageActive == "Login" ? pageActive = 'Order' : '';
      }
    }

    switch (pageActive) {
      case 'Menus':
        return HomePage();
      case 'FormMenu':
        return FormMenu();
      case 'Order':
        return Checkout();
      case 'History':
        return History();
      case 'DetailHistory':
        return DetailHistory(itemMenu: detailMenu);
      case 'Report':
        return Report();
      case 'Settings':
        return Settings();
      case 'ManageAccounts':
        return ManageAccounts();
      default:
        return HomePage();
    }
  }

  _setPage(String page) {
    setState(() {
      pageActive = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1f2029),
      body: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xff17181f),
              ),
              child: _pageView(),
            ),
          ),
        ],
      ),
      floatingActionButton: pageActive == "Menus"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainPage(
                            movePage: "FormMenu",
                          )),
                );
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.deepOrange,
            )
          : null,
      bottomNavigationBar: pageActive == "Login" ||
              pageActive == "DetailHistory" ||
              pageActive == "Register" ||
              pageActive == "FormMenu" ||
              pageActive == "ManageAccounts"
          ? null
          : _bottomMenu(),
    );
  }

  Widget _bottomMenu() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      padding: const EdgeInsets.only(top: 6, right: 12, left: 12),
      width: MediaQuery.of(context).size.width,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: (1 / 1),
        physics:
            NeverScrollableScrollPhysics(), // Set physics to disable scrolling
        children: bottomMenusRole,
      ),
    );
  }

  Widget _itemMenu({required String menu, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: GestureDetector(
        onTap: () => _setPage(menu),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: pageActive == menu
                    ? Colors.deepOrangeAccent
                    : Colors.transparent,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.slowMiddle,
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    menu,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
