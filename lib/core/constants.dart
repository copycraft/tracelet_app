// lib/core/constants.dart
import 'package:flutter/material.dart';

class Constants {
  static const appName = "Tracelet";
}

Color statusColor(String status) {
  switch (status) {
    case "delivered":
      return Colors.green;
    case "exception":
    case "failed_delivery":
      return Colors.red;
    case "in_transit":
    case "out_for_delivery":
      return Colors.blue;
    case "customs":
      return Colors.orange;
    case "picked_up":
      return Colors.teal;
    default:
      return Colors.grey;
  }
}

String prettyStatus(String status) {
  return status.replaceAll('_', ' ').toUpperCase();
}
