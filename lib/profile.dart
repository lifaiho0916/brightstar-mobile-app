// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'model/driver.dart';
import 'partial/app_theme.dart';
import 'partial/bottom_appbar.dart';
import 'partial/drawer.dart';
import 'partial/utility.dart';
import 'package:flutter/material.dart';
import 'partial/light_colors.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final Driver driver;
  const ProfileScreen({Key? key, required this.driver}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late double screenWidth, screenHeight;
  Utility util = Utility();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  File? picture;

  @override
  void initState() {
    loadProfile();

    super.initState();
  }

  @override
  Widget build (BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    
    return WillPopScope(
      onWillPop: () => util.onWillPop(context),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: kDrawer(screen: '4', driver: widget.driver,),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                snap: false,
                floating: false,
                leading: Builder(builder: (context) => // Ensure Scaffold is in context
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.black,),
                    onPressed: () => Scaffold.of(context).openDrawer()
                  ),
                ),
                expandedHeight: 100.0,
                backgroundColor: Colors.white,
                shadowColor: Colors.white,
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: FitnessAppTheme.darkerText,
                    ),
                  ),
                ),
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50)
                  )
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.logout_outlined,
                      color: Colors.black
                    ), 
                    onPressed: () {
                      util.logout(context);
                    }
                  ),
                ],
              ),
              SliverList(delegate: SliverChildListDelegate([
                // Partner Details Start
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 16, bottom: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: const [
                        LightColors.kBlue,
                        LightColors.kBlue,
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(68.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: FitnessAppTheme.grey.withOpacity(0.6),
                            offset: Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Stack(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.6),
                                        offset: const Offset(2.0, 4.0),
                                        blurRadius: 8),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent
                                  ),
                                  child: Stack(children: [
                                    CircleAvatar(
                                      backgroundColor: 
                                      widget.driver.picture.isEmpty
                                      ? LightColors.kTealBlue
                                      : Colors.transparent,
                                      backgroundImage: 
                                      widget.driver.picture.isEmpty
                                      ? AssetImage(
                                        "assets/images/profile.png"
                                      )
                                      : null,
                                      radius: 70,
                                      child: Stack(children: [
                                        InkWell(
                                          onTap: () {
                                            widget.driver.picture.isEmpty 
                                              ? util.displaySinglePicture(context, 1, "assets/images/profile.png")
                                              : util.displaySinglePicture(context, 2, widget.driver.picture);
                                          },
                                          child: util.changeProfilePicture(widget.driver.picture)
                                        ),
                                      ],)
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: GestureDetector(
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: LightColors.kBlack.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(50)
                                          ),
                                          child: Icon(Icons.camera_alt, color: LightColors.kGrey),
                                        ),
                                        onTap: () {
                                          uploadProfilePicture();
                                        },
                                      ),
                                    )
                                  ],)
                                ),
                              ),
                            ),
                            /*
                            Align(
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: LightColors.kBlack.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(50)
                                  ),
                                  child: Icon(Icons.edit, color: Colors.white,),
                                ),
                                onTap: () {
                                },
                              ),
                            )
                            */
                          ],),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              widget.driver.name,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.normal,
                                fontSize: 20,
                                letterSpacing: 0.0,
                                color: FitnessAppTheme.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 18,
                          ),
                          Text(
                            widget.driver.username,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              letterSpacing: 0.0,
                              color: FitnessAppTheme.white,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            widget.driver.phone,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              letterSpacing: 0.0,
                              color: FitnessAppTheme.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Partner Details End
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: GridView.extent(
                      primary: false,
                      padding: EdgeInsets.all(16),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      maxCrossAxisExtent: 200.0,
                      children: <Widget>[
                        // Partner Commission Start
                        Container(
                          decoration: BoxDecoration(
                            color: FitnessAppTheme.white,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                                topRight: Radius.circular(8.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: FitnessAppTheme.grey.withOpacity(0.4),
                                  offset: const Offset(1.1, 1.1),
                                  blurRadius: 10.0),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              focusColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                              splashColor: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.2),
                              onTap: () async {
                                if (double.parse(widget.driver.commission) > 0.00) {
                                  Future<bool> confirmWithdraw = util.confirmationDialog(context, "Confirm withdraw commission ?");

                                  if (await confirmWithdraw) {
                                    String url = "${util.baseUrl()}app/withdrawCommission";

                                    http.post(Uri.parse(url), body: {
                                      "id": widget.driver.driver_id,
                                    }).then((res) {
                                      if (res.body == "success") {
                                        setState(() {
                                          widget.driver.commission = "0.00";
                                        });
                                        util.toast("Successfully withdraw commission.");
                                      } else {
                                        util.toast("Failed to withdraw commission");
                                      }
                                    }).catchError((error) {
                                      util.toast("Error occured when trying to withdraw commission: $error");
                                    });
                                  }
                                } else {
                                  util.toast("Insufficient amount to perform withdrawal.");
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                                    child: Container(
                                      child: Column(children: [
                                        Text("Commission (RM)"),
                                        SizedBox(height: 40,),
                                        Text(
                                          widget.driver.commission,
                                          style: TextStyle(
                                            fontSize: 30
                                          ),
                                        ),
                                      ]),
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Partner Commission End
                      ]
                    )
                  )
                ),
              ]))
            ],
          ),
        ),
        bottomNavigationBar: kBottomAppBar(screen: "4", driver: widget.driver,)
      )
    );
  }

  void loadProfile() {
    String url = "${util.baseUrl()}app/loadProfile";

    http.post(Uri.parse(url), body: {
        "id": widget.driver.driver_id,
      }).then((res) {
        if (util.isJson(res.body)) {
          setState(() {
            var response = json.decode(res.body)['profile']; 
            widget.driver.commission = response[0]['commission'];
          });
        } else {
          util.toast(res.body);
        }
      }).catchError((error) {
        util.toast("Error occured when trying to load profile: $error");
      });
  }
  void uploadProfilePicture() {
    setState(() {
      picture = null;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text("Update Profile Picture", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Text("Select or snap a profile picture:"),
                SizedBox(height: 5,),
                Container(
                  height: screenWidth * 0.7,
                  width: screenWidth * 0.7,
                  color: LightColors.kBiege,
                  alignment: Alignment.center,
                  child: picture == null
                    ? Text("No Picture Yet.", style: TextStyle())
                    : GestureDetector(
                        child: Image.file(picture!),
                        onTap: () {
                          util.displaySinglePicture(context, 1, picture!.path);
                        },
                      )
                ),
                SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton.icon(
                    label: Text('Camera', style: TextStyle(color: Colors.white)),
                    icon: Icon(Icons.add_a_photo, color: Colors.white, size: 18),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black45),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      )
                    ),
                    onPressed: () async {
                      XFile? pic = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                      );
                      setState((){
                        if (pic != null) {
                          picture = File(pic.path);
                        }
                      });
                    }
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    label: Text('Gallery', style: TextStyle(color: Colors.white)),
                    icon: Icon(Icons.photo, color: Colors.white, size: 18),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black45),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      )
                    ),
                    onPressed: () async {
                      XFile? pic = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      setState((){
                        if (pic != null) {
                          picture = File(pic.path);
                        }
                      });
                    }
                  ),
                ],)
              ],),
              actions: <Widget>[
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: LightColors.kTealBlue,
                    ),
                    child: Text("Update", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () async {
                    if (picture == null) {
                      util.toast("Please upload a profile picture before proceed.");
                    } else {
                      util.dialog(context, "Uploading...");

                      String pictureString = base64Encode(picture!.readAsBytesSync());
                      String url = "${util.baseUrl()}app/uploadNewProfilePicture";
                      
                      await http.post(Uri.parse(url), body: {
                        "staff_id": widget.driver.driver_id,
                        "picture_string": pictureString
                      }).then((res) {
                        print(res.body);
                        if (util.isJson(res.body)) {
                          setState(() {
                            List partner = json.decode(res.body)['picture']; 
                            widget.driver.picture = partner[0]['filename'];
                            util.changeProfilePicture(partner[0]['filename']);
                          });

                          util.toast("Successfully uploaded a new profile picture.");
                        } else {
                          util.toast("Failed to upload picture.");
                        }
                        util.pop(context);
                        util.pop(context);
                        
                        uploadProfilePicture(); // trigger update the profile picture
                      }).catchError((err) {
                        print(err);
                      });
                      util.pop(context);
                    }
                  },
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: LightColors.kTealBlue,
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )
                    ),
                  )
                )
              ],
            );
          }
        );
      }
    );
  }
}