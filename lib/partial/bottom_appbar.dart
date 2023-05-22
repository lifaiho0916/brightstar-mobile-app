// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, must_be_immutable, camel_case_types

import 'package:brightstar_delivery/commission_history.dart';
import 'package:brightstar_delivery/commission_history_detail.dart';
import 'package:brightstar_delivery/job_detail.dart';
import 'package:brightstar_delivery/job_history.dart';
import 'package:brightstar_delivery/model/driver.dart';
import 'package:brightstar_delivery/partial/light_colors.dart';
import 'package:brightstar_delivery/main.dart';
import 'package:brightstar_delivery/profile.dart';
import 'package:flutter/material.dart';


class kBottomAppBar extends StatelessWidget implements PreferredSizeWidget {
  late String screen;  // 1-Home, 2-History, 3-Announcement, 4-Profile
  late Driver driver;
  kBottomAppBar({Key? key, required this.screen, required this.driver}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  late double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    double size = 30;
    double height = screenHeight * 0.07;
    Color normalColor = LightColors.kBlack;
    Color activeColor = LightColors.kPalePink;

    /*
    List items = [
      {
        "screen": "1",
        "normalIcon": Icons.dashboard_outlined,
        "activeIcon": Icons.dashboard,
        "route": MainScreen(partner: partner)
      },
    ];
    */

    return BottomAppBar(
      color: LightColors.kBrightWhite,
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /*
          ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                child: Container(
                  height: height,
                  padding: EdgeInsets.all(5),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(
                      screen == items[i]["screen"] ? items[i]["activeIcon"] : items[i]["normalIcon"],
                      size: size,
                      color: screen == items[i]["screen"] ? activeColor : normalColor,
                    ),
                  ]),
                ),
                onTap: () {
                  if (screen == items[i]["screen"]) {
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => items[i]['route']));
                  }
                },
              );
            }),
          */
          GestureDetector( // Job List
            child: Container(
              height: height,
              padding: EdgeInsets.all(5),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  screen == "1" ? Icons.list_alt : Icons.list_alt_outlined,
                  size: size,
                  color: screen == "1" ? activeColor : normalColor,
                ),
              ]),
            ),
            onTap: () {
              screen == "1" ? "" : Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen(driver: driver,)));
            },
          ),
          GestureDetector( // History
            child: Container(
              height: height,
              padding: EdgeInsets.all(5), 
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(screen == "2" ?  Icons.history : Icons.history_outlined, size: size , color: screen == "2" ? activeColor : normalColor,),
              ]),
            ),
            onTap: () {
              screen == "2" ? "" : Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => JobHistoryScreen(driver: driver)));
            },
          ),
          GestureDetector( // Commission History
            child: Container(
              height: height,
              padding: EdgeInsets.all(5),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(screen == "3" ?  Icons.payments : Icons.payments_outlined, size: size , color: screen == "3" ? activeColor : normalColor,),
              ]),
            ),
            onTap: () {
              screen == "3" ? "" : Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CommissionHistoryScreen(driver: driver)));
            },
          ),
          GestureDetector( // Profile
            child: Container(
              height: height,
              padding: EdgeInsets.all(5),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(screen == "4" ?  Icons.person : Icons.person_outline, size: size , color: screen == "4" ? activeColor : normalColor,),
              ]),
            ),
            onTap: () {
              screen == "4" ? "" : Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProfileScreen(driver: driver)));
            },
          ),
          GestureDetector( // Announcements
            child: Container(
              height: height,
              padding: EdgeInsets.all(5),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(screen == "5" ?  Icons.settings : Icons.settings_outlined, size: size , color: screen == "5" ? activeColor : normalColor,),
              ]),
            ),
            onTap: () {
              //screen == "5" ? "" : Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CommissionHistoryScreen(driver: driver)));
            },
          ),
        ],
      ),
    );
  }
}