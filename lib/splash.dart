// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_const_constructors
import 'dart:convert';
//import 'package:wwp/login.dart';
//import 'package:wwp/object/staff.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'login.dart';
import 'model/driver.dart';
import 'partial/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'partial/light_colors.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(
    MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: Colors.black,
      ),
      home: SplashScreen()
    )
  ));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
  with TickerProviderStateMixin {
  
  late double screenHeight, screenWidth;
  Utility util = Utility();

  void iniState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Stack(children: [
            Container(
              height: screenHeight,
              width: screenWidth,
              decoration: const BoxDecoration(
                color: LightColors.kTealBlue
              ), 
            ),
            Center(
              child: FadeInImage(
                width: screenWidth * 0.6,
                height: screenHeight * 0.6,
                placeholder: AssetImage("assets/images/transparent.png"),
                image: AssetImage("assets/images/logo.png"),
              ),
            ),
            ProgressIndicator()
          ],)
        )
      );
  }
}

class ProgressIndicator extends StatefulWidget {
  const ProgressIndicator({Key? key}) : super(key: key);

  @override
  ProgressIndicatorState createState() => ProgressIndicatorState();
}

class ProgressIndicatorState extends State <ProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  late bool haveSharedPrefs;   // to indicate if user have requested to save email & password before
  late String userID, password; // to save email & password
  bool loaded = false;       // to stop the progress indicator
  Utility util = Utility();

  @override
  void initState() {
    super.initState();

    autoLogin();
    controller = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    animation = Tween(begin: 0.0, end: 1.00).animate(controller)..addListener(() {
      setState(() {
        if (animation.value > 0.99 && loaded == false) {  // if loading reach 99%, perform login request
          loaded = true;
          /*
          if (haveSharedPrefs == true) {  // if there are shared preference record, directly login 
            String loginUrl = "${util.baseUrl()}app/login";
            try {
              http.post(Uri.parse(loginUrl), body: {
                "email": email,
                "password": password,
              }).then((res) {
                if (!util.isJson(res.body)) {
                  clearSharedPrefs();
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()));
                } else {
                  print(res.body);
                  List partner = json.decode(res.body)['partner']; 

                  Partner _partner = Partner(
                    partner_id: partner[0]['id'] ?? "",
                    name: partner[0]['name'] ?? "",
                    email: partner[0]['email'] ?? "",
                    contact_no: partner[0]['contact_no'] ?? "",
                    commission: partner[0]['commission'] ?? "",
                    balance_stock: partner[0]['balance_stock'] ?? "",
                    battery_to_collect: partner[0]['battery_to_collect'] ?? "",
                    warning: partner[0]['warning'] ?? "",
                    picture: partner[0]['picture'].substring(partner[0]['picture'].length - 1) == "/" ? "" : partner[0]['picture'],
                    pic_name: partner[0]['pic_name'],
                    pic_phone: partner[0]['pic_phone'],
                    created_at: '',
                  );

                  util.toast("Hello ${_partner.name} !");
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen(partner: _partner)));
                }
              }).catchError((error) {
                util.toast("Error occured:" + error.toString());
              });
            } on Exception catch (error) {
              util.toast("Error occured:" + error.toString());
            }
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
          }
          */
          //
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
          //
        }
      });
    });
    controller.repeat();
  }

  /* This method is to check if there are any shared preference record saved. */
  void autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = (prefs.getString("userID"))??"";
    password = (prefs.getString("password"))??"";
    haveSharedPrefs = false;

    if (userID.isNotEmpty) {
      haveSharedPrefs = true;
    }
  }

  void clearSharedPrefs () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void dialog(msg) {
    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (context) => AlertDialog(
        title: Row(children: [
          CircularProgressIndicator(
            color: LightColors.kPurple,
          ),
          SizedBox(width: 20,),
          Text(
            msg,
            style: TextStyle(
              fontSize: 16
            ),
          ),
        ],)
      ),
    );
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.6),
      child: CircularProgressIndicator(
        value: animation.value,
        strokeWidth: 8,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
      )
    );
  }
  
}