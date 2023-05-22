// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, must_be_immutable, camel_case_types

import 'package:brightstar_delivery/commission_history.dart';
import 'package:brightstar_delivery/job_history.dart';
import 'package:brightstar_delivery/login.dart';
import 'package:brightstar_delivery/model/driver.dart';
import 'package:brightstar_delivery/partial/light_colors.dart';
import 'package:brightstar_delivery/main.dart';
import 'package:brightstar_delivery/partial/utility.dart';
import 'package:brightstar_delivery/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class kDrawer extends StatelessWidget {
  String screen;  // 1-Home, 2-History, 3-Announcement, 4-Profile
  Driver driver;
  Utility util = Utility();
  kDrawer({Key? key, required this.screen, required this.driver}) : super(key: key);

  @override

  @override
  Widget build(BuildContext context) {
    Color normalColor = LightColors.kBlack;
    Color activeColor = LightColors.kPalePink;

    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: LightColors.kBrightWhite,
              image: DecorationImage(image: AssetImage("assets/images/logo.png"), fit: BoxFit.fitWidth)
            ),
            accountEmail: Text(''), // keep blank text because email is required
            accountName: Row(
              children: <Widget>[
              ],
            ),
          ),
          ListTile( // Job List
            dense: true,
            leading: Icon(screen == "1" ? Icons.list_alt : Icons.list_alt_outlined, color: screen == "1" ? activeColor : normalColor,),
            title: Text("Job List", style: TextStyle(fontSize: 18, color: screen == "1" ? activeColor : normalColor,)),
            trailing: Icon(Icons.keyboard_arrow_right, color: screen == "1" ? activeColor : normalColor,),
            onTap: () {
              screen == "1" ? "" : Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen(driver: driver,)));
            }
          ),
          Divider(),
          ListTile( // Record
            dense: true,
            leading: Icon(screen == "2" ? Icons.history : Icons.history_outlined, color: screen == "2" ? activeColor : normalColor,),
            title: Text("Record", style: TextStyle(fontSize: 18, color: screen == "2" ? activeColor : normalColor,)),
            trailing: Icon(Icons.keyboard_arrow_right, color: screen == "2" ? activeColor : normalColor,),
            onTap: () {
              screen == "2" ? "" : Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => JobHistoryScreen(driver: driver)));
            }
          ),
          Divider(),
          ListTile( // Commission History
            dense: true,
            leading: Icon(screen == "3" ? Icons.payments : Icons.payments_outlined, color: screen == "3" ? activeColor : normalColor,),
            title: Text("Commission", style: TextStyle(fontSize: 18, color: screen == "3" ? activeColor : normalColor,)),
            trailing: Icon(Icons.keyboard_arrow_right, color: screen == "3" ? activeColor : normalColor,),
            onTap: () {
              screen == "3" ? "" : Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CommissionHistoryScreen(driver: driver)));
            }
          ),
          Divider(),
          ListTile( // Profile
            dense: true,
            leading: Icon(screen == "4" ? Icons.person : Icons.person_outline, color: screen == "4" ? activeColor : normalColor,),
            title: Text("Profile", style: TextStyle(fontSize: 18, color: screen == "4" ? activeColor : normalColor,)),
            trailing: Icon(Icons.keyboard_arrow_right, color: screen == "4" ? activeColor : normalColor,),
            onTap: () {
              screen == "4" ? "" : Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProfileScreen(driver: driver,)));
            }
          ),
          Divider(),
          ListTile( // Settings
            dense: true,
            leading: Icon(screen == "5" ? Icons.settings : Icons.settings_outlined, color: screen == "5" ? activeColor : normalColor,),
            title: Text("Settings", style: TextStyle(fontSize: 18, color: screen == "5" ? activeColor : normalColor,)),
            trailing: Icon(Icons.keyboard_arrow_right, color: screen == "5" ? activeColor : normalColor,),
            onTap: () {
              //screen == "5" ? "" : Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AnnouncementScreen(partner: partner)));
            }
          ),
          Divider(),
          ListTile(
            dense: true,
            leading: Icon(Icons.logout_outlined, color: LightColors.kBlack),
            title: Text("Logout", style: TextStyle(fontSize: 18, color: LightColors.kBlack)),
            trailing: Icon(Icons.keyboard_arrow_right, color: LightColors.kBlack),
            onTap: () {
              logout(context);
            }
          ),
          Divider(),
        ],
      ),
    );
  }

  void clearSharedPrefs () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void logout(context) { // go to login screen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to Logout?", style: TextStyle(fontSize: 16, fontFamily: 'Poppins')),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove("userID");
                prefs.remove("password");
                Navigator.of(context).pop();
                Navigator.push(context, 
                  MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
                  util.toast("Log out success.");
              },
              style: TextButton.styleFrom(
                elevation: 5,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: LightColors.kPink,   
              ),
              child: Text("Yes", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                elevation: 5,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: LightColors.kBlack,
              ),
              child: Text("No", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins')),
            ),
          ],
        );
      }
    );
  }
}