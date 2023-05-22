import 'dart:ui';

import 'package:brightstar_delivery/partial/light_colors.dart';

class Job {
  Job({
    this.job_id = '',
    this.reference_id = '',
    this.service_level = '',
    this.shipment_no = '',
    this.driver = '',
    this.driver_name = '',
    this.delivery_partner = '',
    this.delivery_partner_name = '',
    this.driver_commission = '',
    this.delivery_partner_commission = '',
    this.status = '',
    this.shipment_status = '',
    this.pickup_picture = '',
    this.drop_picture = '',
    this.pickup_date = '',
    this.drop_date = '',
    this.origin = '',
    this.destination = '',
    this.location = '',
    this.weight = '',
    this.quantity = '',

    this.receiver_name = '',
    this.receiver_phone = '',
    this.receiver_address = '',
    this.receiver_city = '',
    this.receiver_state = '',
    this.receiver_country = '',
    this.receiver_postcode = '',

    this.sender_name = '',
    this.sender_phone = '',
    this.sender_address_line1 = '',
    this.sender_address_line2 = '',
    this.sender_state = '',
    this.sender_city = '',
    this.sender_country = '',
    this.sender_postcode = '',

    this.created_at = ''
  });

    String job_id;
    String reference_id;
    String service_level;
    String shipment_no;
    String driver;
    String driver_name;
    String delivery_partner;
    String driver_commission;
    String delivery_partner_commission;
    String delivery_partner_name;
    String status;
    String shipment_status;
    String pickup_picture;
    String drop_picture;
    String pickup_date;
    String drop_date;
    String origin;
    String destination;
    String location;
    String weight;
    String quantity;

    String receiver_name;
    String receiver_phone;
    String receiver_address;
    String receiver_city;
    String receiver_state;
    String receiver_country;
    String receiver_postcode;

    String sender_name;
    String sender_phone;
    String sender_address_line1;
    String sender_address_line2;
    String sender_state;
    String sender_city;
    String sender_country;
    String sender_postcode;

    String created_at;
}
