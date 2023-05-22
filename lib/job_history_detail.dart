// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:brightstar_delivery/job_history.dart';
import 'package:brightstar_delivery/model/job.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:brightstar_delivery/model/driver.dart';
import 'package:brightstar_delivery/partial/app_theme.dart';
import 'package:brightstar_delivery/partial/bottom_appbar.dart';
import 'package:brightstar_delivery/partial/drawer.dart';
import 'package:brightstar_delivery/partial/utility.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'main.dart';
import 'partial/light_colors.dart';
import 'package:http/http.dart' as http;

class JobHistoryDetailScreen extends StatefulWidget {
  final Driver driver;
  String job_id;
  JobHistoryDetailScreen({Key? key, required this.driver, required this.job_id}) : super(key: key);

  @override
  _JobHistoryDetailScreenState createState() => _JobHistoryDetailScreenState();
}

class _JobHistoryDetailScreenState extends State<JobHistoryDetailScreen> {
  late double screenWidth, screenHeight;
  Utility util = Utility();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Job job = Job();
  List drivers = [];
  late DateTime currentBackPressTime;

  late List picture_list = [];
  List pickup_pictures = [];
  List drop_pictures = [];
  File? picture;
  
  @override
  void initState() {
    loadSingleShipment();

    super.initState();
  }

  @override
  Widget build (BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    //List orderProducts = widget.job.order_product;

    String shipment_status = "";
    String is_done = "";
    Color shipment_status_color = Colors.black;
    Color is_done_color = Colors.black;
    String address = "";
    String phone = "";

    switch(job.shipment_status) {
      case "1":
        shipment_status = "PICKUP";
        is_done = "PENDING";
        shipment_status_color = LightColors.kBlue;
        is_done_color = LightColors.kLightYellow;
        address = "${job.sender_address_line1} ${job.sender_address_line2}, ${job.sender_city}, ${job.sender_postcode} ${job.sender_country}";
        phone = job.sender_phone;
        break;
      case "2":
        shipment_status = "PICKUP";
        is_done = "DONE";
        shipment_status_color = LightColors.kBlue;
        is_done_color = Colors.green;
        address = "${job.sender_address_line1} ${job.sender_address_line2}, ${job.sender_city}, ${job.sender_postcode} ${job.sender_country}";
        phone = job.sender_phone;
        break;
      case "3":
        shipment_status = "DROP";
        is_done = "PENDING";
        shipment_status_color = LightColors.kRubyRed;
        is_done_color = LightColors.kLightYellow;
        address = "${job.receiver_address}, ${job.receiver_city}, ${job.receiver_postcode} ${job.receiver_country}";
        phone = job.receiver_phone;
        break;
      case "4":
        shipment_status = "DROP";
        is_done = "DONE";
        shipment_status_color = LightColors.kRubyRed;
        is_done_color = LightColors.kLightYellow;
        address = "${job.receiver_address}, ${job.receiver_city}, ${job.receiver_postcode} ${job.receiver_country}";
        phone = job.receiver_phone;
        break;
    }

    return WillPopScope(
      onWillPop: () => util.onWillPop(context),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: kDrawer(screen: '0', driver: widget.driver,),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                snap: false,
                floating: false,
                leading: Builder(builder: (context) => // Ensure Scaffold is in context
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white,),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => JobHistoryScreen(driver: widget.driver)))
                  ),
                ),
                expandedHeight: 100.0,
                backgroundColor: LightColors.kBlue,
                shadowColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "JOB ID - ${job.job_id}",
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w700,
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
                  job.delivery_partner == widget.driver.driver_id 
                  ? Container()
                  : IconButton(
                    icon: Icon(
                      Icons.person_add,
                      color: Colors.white
                    ), 
                    onPressed: () {
                      addDeliveryPartner();
                    }
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.white
                    ), 
                    onPressed: () {
                      setState(() {
                        job = Job();
                        pickup_pictures = [];
                        drop_pictures = [];

                        util.dialog(context, "Refreshing, please wait...");
                        loadSingleShipment();
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
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text(
                      "${job.receiver_name}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 16
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 0, right: 0, bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              /*
                              gradient: LinearGradient(
                                colors: <Color>[
                                  LightColors.kBlue,
                                  LightColors.kBlue,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              */
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(2.0),
                                bottomLeft: Radius.circular(2.0),
                                topLeft: Radius.circular(2.0),
                                topRight: Radius.circular(2.0),
                              ),
                            ),
                            child: Column(children: [
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(children: [
                                        Container(
                                          width: screenWidth * 0.6,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: LightColors.kPink,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            )
                                          ),
                                          child: Text(
                                            "BS/SE",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FitnessAppTheme.fontName,
                                              fontSize: 16
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: shipment_status_color,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          )
                                        ),
                                        child: Text(
                                          shipment_status,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FitnessAppTheme.fontName,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(children: [
                                        Container(
                                          width: screenWidth * 0.6,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: LightColors.kGrey,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            )
                                          ),
                                          child: Text(
                                            "$address\nContact Person: $phone",
                                            style: TextStyle(
                                              fontFamily: FitnessAppTheme.fontName,
                                              height: 1.3,
                                              fontSize: 16
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: is_done_color,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          )
                                        ),
                                        child: Text(
                                          is_done,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FitnessAppTheme.fontName,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey.withOpacity(0.5),
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            )
                                          )
                                        ),
                                        child: Text(
                                          "Carton (Ctn)",
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            height: 1.3,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey.withOpacity(0.5),
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            )
                                          )
                                        ),
                                        child: Text(
                                          "Date & Time",
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            height: 1.3,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey.withOpacity(0.5),
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            bottom: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                          )
                                        ),
                                        child: Text(
                                          job.quantity,
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            height: 1.3,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        padding: EdgeInsets.all(10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey.withOpacity(0.5),
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            bottom: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                          )
                                        ),
                                        child: Text(
                                          job.created_at,
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            height: 1.3,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey.withOpacity(0.5),
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                          )
                                        ),
                                        child: Text(
                                          "Commission",
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            height: 1.3,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey.withOpacity(0.5),
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            bottom: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                          )
                                        ),
                                        child: Text(
                                          "RM ${job.delivery_partner == widget.driver.driver_id
                                            ? job.delivery_partner_commission : job.driver_commission}",
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            height: 1.3,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              job.delivery_partner != ""
                               ? IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey,
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            )
                                          )
                                        ),
                                        child: Text(
                                          "Delivery Partner",
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            height: 1.3,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ) : Container(),
                              job.delivery_partner != ""
                              ? IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey,
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            bottom: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                          )
                                        ),
                                        child: Text(
                                          job.delivery_partner == widget.driver.driver_id
                                            ? "${job.driver_name} assigned you as delivery partner."
                                            : job.delivery_partner_name,
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            height: 1.3,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ) : Container(),
                              
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey,
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            )
                                          )
                                        ),
                                        child: Text(
                                          "Acknowledgement",
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            height: 1.3,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),


                              job.shipment_status == "0" || job.shipment_status == "1"
                              ? Container()
                              : IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey,
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            )
                                          )
                                        ),
                                        child: Text(
                                          "Pickup Images:",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            height: 1.3,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              job.shipment_status == "0" || job.shipment_status == "1"
                              ? Container()
                              : Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: LightColors.kGrey,
                                  border: Border(
                                    left: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    right: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    )
                                  )
                                ),
                                child: GridView.count(  
                                  crossAxisCount: 3,  
                                  crossAxisSpacing: 4.0,  
                                  mainAxisSpacing: 8.0,  
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: List.generate(
                                    pickup_pictures.length, (index) {  
                                      return GestureDetector(
                                        child: Center(  
                                          child: Image.network(util.baseUrl() + util.shipmentPicUrl() + pickup_pictures[index]),
                                        ),
                                        onTap: () {
                                          util.displaySinglePicture(context, 2, util.baseUrl() + util.shipmentPicUrl() + pickup_pictures[index]);
                                        },
                                      );  
                                    }  
                                  )  
                                ),
                              ),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey,
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            )
                                          )
                                        ),
                                        child: Column(children: [
                                          job.shipment_status == "0" || job.shipment_status == "1"
                                          ? job.delivery_partner == widget.driver.driver_id
                                            ? Container()
                                            : Container(
                                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                              child: GestureDetector(
                                                onTap: () {
                                                  submitImage("pickup");
                                                },
                                                child: Container(
                                                  width: screenWidth,
                                                  height: 55,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: LightColors.kBlue
                                                  ),
                                                  child: Text(
                                                    "CONFIRM PICKUP",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w900
                                                    )
                                                  ),
                                                ),
                                              )
                                            )
                                          : Container(
                                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                            child: GestureDetector(
                                              onTap: () {
                                                
                                              },
                                              child: Container(
                                                width: screenWidth,
                                                height: 55,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: LightColors.kMildGrey
                                                ),
                                                child: Text(
                                                  "PICKEDUP\n${job.pickup_date}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900
                                                  )
                                                ),
                                              ),
                                            )
                                          ),
                                        ],)
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              job.shipment_status == "0" || job.shipment_status == "1" || job.shipment_status == "3"
                              ? Container()
                              : IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey,
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            )
                                          )
                                        ),
                                        child: Text(
                                          "Dropoff Images:",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            height: 1.3,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              job.shipment_status == "0" || job.shipment_status == "1" || job.shipment_status == "3"
                              ? Container()
                              : Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: LightColors.kGrey,
                                  border: Border(
                                    left: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    right: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    )
                                  )
                                ),
                                child: GridView.count(  
                                  crossAxisCount: 3,  
                                  crossAxisSpacing: 4.0,  
                                  mainAxisSpacing: 8.0,  
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: List.generate(
                                    drop_pictures.length, (index) {  
                                      return GestureDetector(
                                        child: Center(  
                                          child: Image.network(util.baseUrl() + util.shipmentPicUrl() + drop_pictures[index]),
                                        ),
                                        onTap: () {
                                          util.displaySinglePicture(context, 2, util.baseUrl() + util.shipmentPicUrl() + drop_pictures[index]);
                                        },
                                      );  
                                    }  
                                  )  
                                ),
                              ),
                              job.shipment_status == "0" || job.shipment_status == "1"
                              ? Container()
                              : IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: screenWidth * 0.6,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                          color: LightColors.kGrey,
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            )
                                          )
                                        ),
                                        child: Column(children: [
                                          job.shipment_status == "0" || job.shipment_status == "1" || job.shipment_status == "3"
                                          ? job.delivery_partner == widget.driver.driver_id
                                            ? Container()
                                            : Container(
                                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                              child: GestureDetector(
                                                onTap: () {
                                                  submitImage("drop");
                                                },
                                                child: Container(
                                                  width: screenWidth,
                                                  height: 55,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: LightColors.kBlue
                                                  ),
                                                  child: Text(
                                                    "CONFIRM DROPOFF",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w900
                                                    )
                                                  ),
                                                ),
                                              )
                                            )
                                          : Container(
                                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                            child: GestureDetector(
                                              onTap: () {
                                                
                                              },
                                              child: Container(
                                                width: screenWidth,
                                                height: 55,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: LightColors.kMildGrey
                                                ),
                                                child: Text(
                                                  "DROPPED OFF\n${job.drop_date}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900
                                                  )
                                                ),
                                              ),
                                            )
                                          ),
                                        ],)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],)
                          ),
                        ),
                      ],
                    ),
                  ),
                ])
              )
            ],
          ),
        ),
        bottomNavigationBar: kBottomAppBar(screen: "0", driver: widget.driver,)
      )
    );
  }

  void loadSingleShipment() {
    String loginUrl = "${util.baseUrl()}app/loadSingleShipment";

    setState(() {
      job = Job();
      pickup_pictures = [];
      drop_pictures = [];
    });

    http.post(Uri.parse(loginUrl), body: {
        "operation": "load single shipment",
        "id": widget.job_id,
        "staff_id": widget.driver.driver_id
      }).then((res) {
        if (util.isJson(res.body)) {
          print(res.body);
          List data = json.decode(res.body)['shipment'];
          
          setState(() {
            drivers = json.decode(res.body)['driver'];
          });

          for (int i = 0; i < data.length; i++) {
            setState(() {
              job = Job(
                job_id: data[i]['shipment_id'] ?? "",
                reference_id: data[i]['reference_id'] ?? "",
                service_level: data[i]['service_level'] ?? "",
                shipment_no: data[i]['shipment_no'] ?? "",
                driver: data[i]['driver'] ?? "",
                driver_name: data[i]['driver_name'] ?? "",
                delivery_partner: data[i]['delivery_partner'] ?? "",
                delivery_partner_name: data[i]['delivery_partner_name'] ?? "",
                driver_commission: data[i]['driver_commission'] ?? "0.00",
                delivery_partner_commission: data[i]['delivery_partner_commission'] ?? "0.00",
                status: data[i]['status'] ?? "",
                shipment_status: data[i]['shipment_status'] ?? "",
                pickup_picture: data[i]['pickup_picture'],
                drop_picture: data[i]['drop_picture'],
                pickup_date: data[i]['pickup_date'],
                drop_date: data[i]['drop_date'],
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
              ); 
            });
          }

          if (job.pickup_picture.isNotEmpty) {
            List str = job.pickup_picture.split(",");

            for (int i = 0; i < str.length; i++) {
              setState(() {
                pickup_pictures.add(str[i]);
              });
            }
          }

          if (job.drop_picture.isNotEmpty) {
            List str = job.drop_picture.split(",");

            for (int i = 0; i < str.length; i++) {
              setState(() {
                drop_pictures.add(str[i]);
              });
            }
          }
        } else {
          util.toast(res.body);
        }
      }).catchError((error) {
        util.toast("Error occured when trying to load data: $error");
      });
  }

  void submitImage(String type) {
    String type_string = "";
    TextEditingController quantityController = TextEditingController();
    
    switch (type) {
      case "pickup":
        type_string = "Confirm Pickup ?";
        break;
      case "drop":
        type_string = "Confirm Drop-off ?";
        break;
    }

    setState(() {
      picture = null;
    });

    List<File> pictures = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: LightColors.kGrey,
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text(
                type == "pickup" ? "Picked Up ?" : "Dropped-off ?", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Text("Quantity:"),
                SizedBox(height: 5,),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all()
                  ),
                  child: TextField( 
                    controller: quantityController, 
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18
                    ),
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none, 
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Text(type == "pickup" ? "Submit pickup pictures:" : "Submit drop-off pictures:"),
                SizedBox(height: 5,),
                Expanded(
                  child: Container(
                    height: screenWidth * 0.7,
                    width: screenWidth * 0.7,
                    color: LightColors.kGrey,
                    alignment: Alignment.center,
                    child: pictures == null
                      ? Text("No Picture Yet.", style: TextStyle())
                      : GridView.builder(
                        itemCount: pictures.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            child: Container(
                              padding: EdgeInsets.all(3),
                              child: Image.file(File(pictures[index].path), fit: BoxFit.cover),
                            ),
                            onTap: () {
                              util.displaySinglePicture(context, 1, pictures[index].path);
                            },
                            onLongPress: () async {
                              bool remove = await removeSinglePicture(pictures[index].path);
                              if (remove) {
                                setState(() {
                                  pictures.removeAt(index);
                                });
                              }
                            },
                          );
                        }
                      ),
                    )
                ),
                SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton.icon(
                    label: Text('Camera', style: TextStyle(color: Colors.white)),
                    icon: Icon(Icons.add_a_photo, color: Colors.white, size: 18),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(LightColors.kBlack),
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
                          pictures.add(File(pic.path));
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
                      backgroundColor: MaterialStateProperty.all<Color>(LightColors.kBlack),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      )
                    ),
                    onPressed: () async {
                      final List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
                      setState((){
                        if (selectedImages != null) {
                          for (int i = 0; i < selectedImages.length; i++) {
                            pictures.add(File(selectedImages[i].path));
                          }
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
                      color: LightColors.kPink,
                    ),
                    child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () async {
                    if (pictures.isEmpty || quantityController.text.isEmpty) {
                      util.toast(type == "pickup" ? "Please upload a pickup picture & specify quantity before proceed." : "Please upload a drop-off picture & specify quantity before proceed.");
                    } else {
                      util.dialog(context, "Uploading...");

                      List pictureStringArr = [];
                      for (int i = 0; i < pictures.length; i++) {
                        String pictureString = base64Encode(pictures[i].readAsBytesSync());
                        pictureStringArr.add(pictureString);
                      }

                      String url = "${util.baseUrl()}app/submitPicture";
                      await http.post(Uri.parse(url), body: {
                        "operation": "submit picture",
                        "type": type,
                        "id": widget.job_id,
                        "driver_id": widget.driver.driver_id,
                        "delivery_partner_id": job.delivery_partner,
                        "picture_string_arr": json.encode(pictureStringArr),
                        "quantity": quantityController.text
                      }).then((res) {
                        print(res.body);
                        
                        if (res.body == "success") {
                          if (type == "drop") {
                            util.toast("Upload success, shipment status updated. Shipment completed.");
                          } else if (type == "pickup") {
                            util.toast("Upload success, shipment status updated.");
                          }
                          
                          loadSingleShipment();
                          util.pop(context);
                          util.pop(context);
                        } else {
                          util.toast("Failed to upload the pictures.");
                        }
                      }).catchError((err) {
                        print(err);
                      });                      
                    }
                  },
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: LightColors.kPink,
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

  Future<bool> removeSinglePicture(pic) async {
    bool remove = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: LightColors.kGrey,
        title: Text("Remove this picture from the list?"),
        content: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Container(
              color: LightColors.kGrey,
              padding: EdgeInsets.all(3),
              child: Image.file(File(pic)),
            )
          )
        ],),
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
        actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Yes"),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(LightColors.kPink),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  )
                )
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text("No"),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(LightColors.kPink),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  )
                )
              ),
            ),
          ],
      );
    }) ?? false;

    return remove;
  }

  void addDeliveryPartner() {
    String driver_id = "0";
    List<DropdownMenuItem<String>>? driver_names = [];
    
    driver_names.add(
      DropdownMenuItem<String>( 
        value: "0", 
        enabled: false,
        child: Text("-- Select --"),
      )
    );

    for (int i = 0; i < drivers.length; i++) {
      driver_names.add(
        DropdownMenuItem<String>( 
          value: drivers[i]!['driver_id'], 
          child: Text(drivers[i]!['name']),
        )
      );
    }

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
            backgroundColor: LightColors.kGrey,
            contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            actionsPadding: EdgeInsets.fromLTRB(5, 0, 5, 20),
            title: Text("Add A Delivery Partner:"),
            content: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                color: LightColors.kGrey,
                border: Border.all(
                  width: 3,
                  color: LightColors.kMildGrey
                ),
              ),
              child: DropdownButton(
                value: driver_id,
                isExpanded: true,
                items: driver_names,
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    driver_id = value!.toString();
                    print(driver_id);
                  });
                },
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 30, left: 15, right: 15),
                child: Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (driver_id != "0") {
                          assignDeliveryPartner(driver_id);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: LightColors.kBlue,
                        side: BorderSide(
                          width: 3,
                          color: LightColors.kMildGrey
                        ),
                        padding: EdgeInsets.all(15),
                      ),
                      child: Icon(Icons.check)
                    )
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        util.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: LightColors.kRubyRed,
                        side: BorderSide(
                          width: 3,
                          color: LightColors.kMildGrey
                        ),
                        padding: EdgeInsets.all(15),
                      ),
                      child: Icon(Icons.close)
                    )
                  ),
                ],),
              )
            ],
          );
        });
    });
  }

  void assignDeliveryPartner(String driver_id) {
    String loginUrl = "${util.baseUrl()}app/assignDeliveryPartner";

    http.post(Uri.parse(loginUrl), body: {
        "operation": "assign delivery partner",
        "id": widget.job_id,
        "staff_id": driver_id
      }).then((res) {
        if (res.body == "success") {
          util.toast("Successfully assigned a delivery partner.");
          loadSingleShipment();
          util.pop(context);
        } else {
          util.toast(res.body);
        }
      }).catchError((error) {
        util.toast("Error occured when trying to load data: $error");
      });
  }
}