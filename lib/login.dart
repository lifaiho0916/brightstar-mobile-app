// ignore_for_file: prefer_const_constructors, avoid_print, curly_braces_in_flow_control_structures, prefer_typing_uninitialized_variables, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'main.dart';
import 'model/driver.dart';
import 'partial/light_colors.dart';
import 'partial/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// void main() => runApp(
//     new MediaQuery(
//         data: new MediaQueryData.fromWindow(ui.window),
//         child: new Directionality(
//             textDirection: TextDirection.rtl,
//             child: new LoginScreen())));
void main() => runApp(MaterialApp(
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: LoginScreen())
);
bool rememberMe = false;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late double screenHeight, screenWidth;
  Utility util = Utility();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController controller;
  final emailNode = FocusNode();
  final passwordNode = FocusNode();
  var _scaffoldKey;
  bool hidePass = true;
  String appID = "";

  @override
  void initState() {
    _idController.text = "driver123";
    _passwordController.text = "driver123";
    loadData();
    
    controller = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: Stack(alignment: Alignment(0, -0.5), children: <Widget>[
          /*
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.fill
              )
            ),
          ),
          */
          Container(
            height: screenHeight,
            width: screenWidth,
            decoration: const BoxDecoration(
              color: LightColors.kTealBlue
            ), 
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(children: [
              Container(
                color: LightColors.kTealBlue,
                alignment: Alignment(0, 1),
                child: Column(children: [
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    height: screenHeight * 0.14,
                    width: screenWidth * 0.60,
                    decoration: BoxDecoration(
                      //color: Colors.white.withOpacity(0.4),
                      //borderRadius: BorderRadius.circular(200),
                      image: DecorationImage(
                        opacity: 1,
                        image: AssetImage("assets/images/logo.png"), 
                      )
                    ),
                  ),
                ],)
              ),
              Container(
                child: Text(
                  "DRIVER APP",
                  style: TextStyle(
                    fontSize: screenWidth * 0.09,
                    color: Colors.white
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.14,),
              Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                Align(
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(40),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: LightColors.kGrey,
                            border: Border.all(
                              width: 3,
                              color: LightColors.kMildGrey
                            ),
                          ),
                          child: TextField(
                            controller: _idController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: "USER ID",
                              hintStyle: TextStyle(
                                fontSize: screenWidth * 0.08,
                                color: LightColors.kMildGrey,
                                fontFamily: 'Poppins'
                              ),
                              enabledBorder: InputBorder.none, 
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: LightColors.kGrey,
                            border: Border.all(
                              width: 3,
                              color: LightColors.kMildGrey
                            ),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: _passwordController,
                                textInputAction: TextInputAction.done,
                                textAlign: TextAlign.center,
                                obscureText: hidePass,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: "PASSWORD",
                                  hintStyle: TextStyle(
                                    fontSize: screenWidth * 0.08,
                                    color: LightColors.kMildGrey,
                                    fontFamily: 'Poppins'
                                  ),
                                  enabledBorder: InputBorder.none, 
                                  focusedBorder: InputBorder.none,
                                  border: InputBorder.none
                                ),
                              )
                            ),
                          ]),
                        ),
                        /*
                        SizedBox(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                          Row(children: [
                            Container(
                              width: 23,
                              height: 23,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                border: Border.all(width: 1, color: Colors.white.withOpacity(0.7)),
                                borderRadius: BorderRadius.circular(3)
                              ),
                              child: Transform.scale(
                                scale: 1.15,
                                child: Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: Colors.white.withOpacity(0.7),
                                  ),
                                  child: Checkbox(
                                    value: rememberMe,
                                    activeColor: Colors.white.withOpacity(0.7),
                                    checkColor: Colors.black,                    
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value!;
                                      });
                                    },
                                  ),
                                )
                              )
                            ),
                            SizedBox(width: 10),
                            Text("Remember me", style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, fontFamily: 'Poppins', color: Colors.black)),
                          ],),
                        ]),
                        SizedBox(height: 20),
                        */
                        Row(children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _loginUser();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                primary: LightColors.kLightYellow,
                                side: BorderSide(
                                  width: 3,
                                  color: LightColors.kMildGrey
                                ),
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                              ),
                              child: Text(
                                'LOGIN',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.08),   
                              ),
                            )
                          ),
                        ],),
                        SizedBox(height: screenHeight * 0.05,),
                        Container(
                          child: Text(
                            "APP ID : $appID",
                            style: TextStyle(
                              fontSize: screenWidth * 0.09,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ]),
                    ),
                  )
                ),
              ])
            ])
          )
        ])
      )
    );
  }

  Future<void> loadData() async {
    setState(() {
      appID = "";
    });

    String data = await util.loadData("appID");
    
    if (data == "") {
      appIDDialog("Insert an App ID to proceed");
    } else {
      setState(() {
        appID = data;
      });
    }
  }

   Future<void> appIDDialog(message) async {
    TextEditingController appIDController = TextEditingController();

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: LightColors.kGrey,
        contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        actionsPadding: EdgeInsets.fromLTRB(5, 0, 5, 20),
        title: Text(message),
        content: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
            color: LightColors.kGrey,
            border: Border.all(
              width: 3,
              color: LightColors.kMildGrey
            ),
          ),
          child: TextField( 
            controller: appIDController, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black
            ),
            decoration: InputDecoration(
              hintText: "APP ID",
              hintStyle: TextStyle(
                fontSize: 24,
                color: LightColors.kMildGrey,
                fontFamily: 'Poppins'
              ),
              enabledBorder: InputBorder.none, 
              focusedBorder: InputBorder.none,
              border: InputBorder.none
            ), 
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (appIDController.text != "") {
                      util.saveData("appID", appIDController.text);
                      setState(() {
                        appID = appIDController.text;
                      });
                      util.toast("App ID saved.");
                      util.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    primary: LightColors.kLightYellow,
                    side: BorderSide(
                      width: 3,
                      color: LightColors.kMildGrey
                    ),
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  ),
                  child: Text(
                    'CONFIRM',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 24),   
                  ),
                )
              ),
            ],),
          )
          
        ],
      );
    });
  }

  void _loginUser() {
    String _id = _idController.text;
    String _password = _passwordController.text;
    String loginUrl = "${util.baseUrl()}app/login";
      
    if (_id.isEmpty || _password.isEmpty){
      util.toast("User ID and Password cannot be empty!");
    } else {
      util.dialog(context, "Logging in ...");

      http.post(Uri.parse(loginUrl), body: {
        "operation": "login",
        "id": _id,
        "password": _password,
      }).then((res) {
        print(res.body);

        util.pop(context);

        if (util.isJson(res.body)) {
          List driver = json.decode(res.body)['driver'];

          Driver _driver = Driver(
            driver_id: driver[0]['id'] ?? "",
            username: driver[0]['username'] ?? "",
            name: driver[0]['name'] ?? "",
            phone: driver[0]['phone'] ?? "",
            commission: driver[0]['commission'] ?? "",
            picture: driver[0]['picture'].substring(driver[0]['picture'].length - 1) == "/" ? "" : driver[0]['picture'],
            created_at: driver[0]['created_at'],
          );
          
          savePreference(rememberMe);
          util.toast("Hello " + _driver.name + " !");
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen(driver: _driver)));
        } else {
          util.toast(res.body);
        }
      }).catchError((error) {
        util.pop(context);
        print("Error occured when trying to login: " + error.toString());
        util.toast("Error occured when trying to login: " + error.toString());
      });
    }    
  }

  void savePreference(bool save) async {
    String userID = _idController.text;
    String password = _passwordController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(save == true){//save preference
      await prefs.setString("userID", "");
      await prefs.setString('userID', userID);
      await prefs.setString("password", "");
      await prefs.setString('password', password);
    } else {
      await prefs.setString("userID", "");
      await prefs.setString("password", "");
    }
  }
}