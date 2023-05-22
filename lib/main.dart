// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:brightstar_delivery/job_detail.dart';
import 'package:brightstar_delivery/model/job.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'model/driver.dart';
import 'partial/app_theme.dart';
import 'partial/bottom_appbar.dart';
import 'partial/drawer.dart';
import 'partial/light_colors.dart';
import 'package:http/http.dart' as http;

import 'partial/utility.dart';

class MainScreen extends StatefulWidget {
  final Driver driver;
  const MainScreen({Key? key, required this.driver}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late double screenWidth, screenHeight;
  Utility util = Utility();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DateTime currentBackPressTime;
  List<Job> jobs = [];

  @override
  void initState() {
    loadShipments();
    super.initState();
  }
  
  @override
  Widget build (BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: WillPopScope(
        onWillPop: () => util.onWillPop(context),
        child: Scaffold(
          key: _scaffoldKey,
          drawer: kDrawer(screen: '1', driver: widget.driver,),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  snap: false,
                  floating: false,
                  leading: Builder(builder: (context) => // Ensure Scaffold is in context
                    IconButton(
                      icon: Icon(Icons.menu, color: Colors.white,),
                      onPressed: () => Scaffold.of(context).openDrawer()
                    ),
                  ),
                  expandedHeight: 100.0,
                  backgroundColor: LightColors.kBlue,
                  shadowColor: Colors.white,
                  flexibleSpace: const FlexibleSpaceBar(
                    title: Text(
                      'Job List',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.only(
                      //bottomLeft: Radius.circular(50),
                      //bottomRight: Radius.circular(50)
                    )
                  ),
                  actions: [
                    IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.white
                    ), 
                    onPressed: () {
                      setState(() {
                        setState(() {
                          jobs = [];
                        });

                        util.dialog(context, "Refreshing, please wait...");
                        loadShipments();
                        Future.delayed(Duration(milliseconds: 500), () {
                          util.pop(context);
                        });
                      });
                    }
                  ),
                  ],
                ),
                
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      padding: EdgeInsets.all(3),
                      alignment: Alignment.center,
                      child: Text(
                        "JALAN KLANG / SHAH ALAM",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 16
                        ),
                      ),
                    ),
                    /*
                    GestureDetector(
                      onTap: () {
                        //showOrderDetails(context, order[i]);
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => JobDetailScreen(driver: widget.driver, job: Job())));
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 0, right: 0, bottom: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      LightColors.kBlue,
                                      LightColors.kBlue,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(2.0),
                                    bottomLeft: Radius.circular(2.0),
                                    topLeft: Radius.circular(2.0),
                                    topRight: Radius.circular(2.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 0, right: 0, bottom: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Table(
                                        columnWidths: {
                                          0: FlexColumnWidth(5),
                                          1: FlexColumnWidth(2),
                                        },     
                                        children: [
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: Colors.yellow,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "BS",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                    Text(
                                                      "11/10/2023",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    )
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "PICKUP",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16,
                                                        color: Colors.white
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ]),
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kGrey,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Shuvah Logistic (M) Sdn. Bhd.",
                                                      style: TextStyle(
                                                        overflow: TextOverflow.ellipsis,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.green,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "DONE",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ])
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        //showOrderDetails(context, order[i]);
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => JobDetailScreen(driver: widget.driver, job: Job())));
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 0, right: 0, bottom: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      LightColors.kBlue,
                                      LightColors.kBlue,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(2.0),
                                    bottomLeft: Radius.circular(2.0),
                                    topLeft: Radius.circular(2.0),
                                    topRight: Radius.circular(2.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 0, right: 0, bottom: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Table(
                                        columnWidths: {
                                          0: FlexColumnWidth(5),
                                          1: FlexColumnWidth(2),
                                        },     
                                        children: [
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kPink,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "BS/SE",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                    Text(
                                                      "11/10/2023",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    )
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "PICKUP",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16,
                                                        color: Colors.white
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ]),
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kGrey,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "MASTERWHEEL",
                                                      style: TextStyle(
                                                        overflow: TextOverflow.ellipsis,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kLightYellow,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "PENDING",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ])
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        //showOrderDetails(context, order[i]);
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => JobDetailScreen(driver: widget.driver, job: Job())));
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 0, right: 0, bottom: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      LightColors.kBlue,
                                      LightColors.kBlue,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(2.0),
                                    bottomLeft: Radius.circular(2.0),
                                    topLeft: Radius.circular(2.0),
                                    topRight: Radius.circular(2.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 0, right: 0, bottom: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Table(
                                        columnWidths: {
                                          0: FlexColumnWidth(5),
                                          1: FlexColumnWidth(2),
                                        },     
                                        children: [
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: Colors.yellow,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "BS",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                    Text(
                                                      "11/10/2023",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    )
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kRubyRed,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "DROP",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16,
                                                        color: Colors.white
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ]),
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kGrey,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "NEW PJ KLANG",
                                                      style: TextStyle(
                                                        overflow: TextOverflow.ellipsis,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kLightYellow,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "PENDING",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ])
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        //showOrderDetails(context, order[i]);
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => JobDetailScreen(driver: widget.driver, job: Job())));
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 0, right: 0, bottom: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      LightColors.kBlue,
                                      LightColors.kBlue,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(2.0),
                                    bottomLeft: Radius.circular(2.0),
                                    topLeft: Radius.circular(2.0),
                                    topRight: Radius.circular(2.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 0, right: 0, bottom: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Table(
                                        columnWidths: {
                                          0: FlexColumnWidth(5),
                                          1: FlexColumnWidth(2),
                                        },     
                                        children: [
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: Colors.lightBlue,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "SE",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                    Text(
                                                      "11/10/2023",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    )
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "PICKUP",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16,
                                                        color: Colors.white
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ]),
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kGrey,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "ENG HUAT FORKLIFT",
                                                      style: TextStyle(
                                                        overflow: TextOverflow.ellipsis,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kLightYellow,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "PENDING",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ])
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        //showOrderDetails(context, order[i]);
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => JobDetailScreen(driver: widget.driver, job: Job())));
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 0, right: 0, bottom: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      LightColors.kBlue,
                                      LightColors.kBlue,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(2.0),
                                    bottomLeft: Radius.circular(2.0),
                                    topLeft: Radius.circular(2.0),
                                    topRight: Radius.circular(2.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 0, right: 0, bottom: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Table(
                                        columnWidths: {
                                          0: FlexColumnWidth(5),
                                          1: FlexColumnWidth(2),
                                        },     
                                        children: [
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: Colors.yellow,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "BS",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                    Text(
                                                      "11/10/2023",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    )
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "PICKUP",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16,
                                                        color: Colors.white
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ]),
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kGrey,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Company ABC",
                                                      style: TextStyle(
                                                        overflow: TextOverflow.ellipsis,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kLightYellow,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "PENDING",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ])
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        //showOrderDetails(context, order[i]);
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => JobDetailScreen(driver: widget.driver, job: Job())));
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 0, right: 0, bottom: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      LightColors.kBlue,
                                      LightColors.kBlue,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(2.0),
                                    bottomLeft: Radius.circular(2.0),
                                    topLeft: Radius.circular(2.0),
                                    topRight: Radius.circular(2.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 0, right: 0, bottom: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Table(
                                        columnWidths: {
                                          0: FlexColumnWidth(5),
                                          1: FlexColumnWidth(2),
                                        },     
                                        children: [
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kPink,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "BS/SE",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                    Text(
                                                      "11/10/2023",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    )
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "PICKUP",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16,
                                                        color: Colors.white
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ]),
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kGrey,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Company DEFH",
                                                      style: TextStyle(
                                                        overflow: TextOverflow.ellipsis,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kLightYellow,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "PENDING",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ])
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    */
                  ]),
                ),

                SliverList(delegate: SliverChildBuilderDelegate(
                  childCount: jobs.length,
                  (context, i) {
                    Utility util = Utility();
                    
                    String shipment_status = "";
                    String is_done = "";
                    Color shipment_status_color = Colors.black;
                    Color is_done_color = Colors.black;

                    switch(jobs[i].shipment_status) {
                      case "1":
                        shipment_status = "PICKUP";
                        is_done = "PENDING";
                        shipment_status_color = LightColors.kBlue;
                        is_done_color = LightColors.kLightYellow;
                        break;
                      case "2":
                        shipment_status = "PICKUP";
                        is_done = "DONE";
                        shipment_status_color = LightColors.kBlue;
                        is_done_color = Colors.green;
                        break;
                      case "3":
                        shipment_status = "DROP";
                        is_done = "PENDING";
                        shipment_status_color = LightColors.kRubyRed;
                        is_done_color = LightColors.kLightYellow;
                        break;
                      case "4":
                        shipment_status = "DROP";
                        is_done = "DONE";
                        shipment_status_color = LightColors.kRubyRed;
                        is_done_color = LightColors.kLightYellow;
                        break;
                    }

                    return jobs.isEmpty
                    ? GestureDetector(
                        child: Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: util.empty(screenHeight),
                        ),
                      )
                    : GestureDetector(
                      onTap: () {
                        //showOrderDetails(context, order[i]);
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => JobDetailScreen(driver: widget.driver, job_id: jobs[i].job_id)));
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 0, right: 0, bottom: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      shipment_status_color,
                                      shipment_status_color
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(2.0),
                                    bottomLeft: Radius.circular(2.0),
                                    topLeft: Radius.circular(2.0),
                                    topRight: Radius.circular(2.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 0, right: 0, bottom: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Table(
                                        columnWidths: {
                                          0: FlexColumnWidth(5),
                                          1: FlexColumnWidth(2),
                                        },     
                                        children: [
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kPink,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "BS/SE",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                    Text(
                                                      "${jobs[i].created_at}",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    )
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      shipment_status,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16,
                                                        color: Colors.white
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ]),
                                          TableRow(children: [
                                            TableCell(
                                              child: Container(
                                                color: LightColors.kGrey,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "${jobs[i].receiver_name}",
                                                      style: TextStyle(
                                                        overflow: TextOverflow.ellipsis,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: is_done_color,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      is_done,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                  ]
                                                ),
                                              )
                                            ),
                                          ])
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                )),
              ],
            ),
          ),
          bottomNavigationBar: kBottomAppBar(screen: "1", driver: widget.driver,)
        )
      )
    );
  }

  void loadShipments() {
    String loginUrl = "${util.baseUrl()}app/loadAllShipment";

    http.post(Uri.parse(loginUrl), body: {
        "id": widget.driver.driver_id,
      }).then((res) {
        if (util.isJson(res.body)) {
          List data = json.decode(res.body)['shipment'];

          for (int i = 0; i < data.length; i++) {
            setState(() {
              jobs.add(Job(
                job_id: data[i]['shipment_id'] ?? "",
                reference_id: data[i]['reference_id'] ?? "",
                service_level: data[i]['service_level'] ?? "",
                shipment_no: data[i]['shipment_no'] ?? "",
                driver: data[i]['driver'] ?? "",
                delivery_partner: data[i]['delivery_partner'] ?? "",
                status: data[i]['status'] ?? "",
                shipment_status: data[i]['shipment_status'] ?? "",
                origin: data[i]['origin'] ?? "",
                destination: data[i]['destination'] ?? "",
                location: data[i]['location'] ?? "",
                weight: data[i]['weight'] ?? "",
                quantity: data[i]['quantity'] ?? "",

                receiver_name: data[i]['receiver_name'] ?? "",
                receiver_phone: data[i]['receiver_phone'] ?? "",
                receiver_address: data[i]['receiver_address'] ?? "",
                receiver_city: data[i]['receiver_city'] ?? "",
                receiver_state: data[i]['receiver_state'] ?? "",
                receiver_country: data[i]['receiver_country'] ?? "",
                receiver_postcode: data[i]['receiver_postcode'] ?? "",

                sender_name: data[i]['sender_name'] ?? "",
                sender_phone: data[i]['sender_phone'] ?? "",
                sender_address_line1: data[i]['sender_address_line1'] ?? "",
                sender_address_line2: data[i]['sender_address_line2'] ?? "",
                sender_state: data[i]['sender_state'] ?? "",
                sender_city: data[i]['sender_city'] ?? "",
                sender_country: data[i]['sender_country'] ?? "",
                sender_postcode: data[i]['sender_postcode'] ?? "",

                created_at: data[i]['created_at'] ?? "",
              )); 
            });
          }
        } else {
          util.toast(res.body);
        }
      }).catchError((error) {
        util.toast("Error occured when trying to load available stock: $error");
      });
  }
}