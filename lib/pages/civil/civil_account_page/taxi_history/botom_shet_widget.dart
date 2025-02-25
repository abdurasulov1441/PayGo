import 'package:flutter/material.dart';
import 'package:taksi/services/style/app_colors.dart';
 void showRideDetailsBottomSheet(
      BuildContext context, Map<String, dynamic> orderData) {
    showModalBottomSheet(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              _buildLocationInfo(orderData),
              SizedBox(height: 16),
              _buildDetailsSection(orderData),
              SizedBox(height: 16),
              _buildFeedbackSection(orderData),
              SizedBox(height: 20),
              _buildReorderButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReorderButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.grade1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {},
        child: Text("Re-order Ride",
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Widget _buildLocationInfo(Map<String, dynamic> orderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _locationItem(orderData['from_location'] ?? "Неизвестно",
            "Chiqish joyi", "#${orderData['id'] ?? "N/A"} "),
        SizedBox(height: 16),
        _locationItem(orderData['to_location'] ?? "Неизвестно",
            "Yetib borish joyi", "${orderData['date'] ?? "00:00"}"),
      ],
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> orderData) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.ui,
                radius: 25,
                child: Image.asset(
                  "assets/images/car_for_widget.png",
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(orderData['driver_name'] ?? "Неизвестный водитель",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      "${orderData['car_model'] ?? "Неизвестная машина"}"),
                 
                ],
              ),
            ],
          ),
          Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detailItem("Rating", "${orderData['rating'] ?? "⭐️⭐️⭐️⭐️⭐️"}"),
              _detailItem("Payment Method",
                  orderData['payment_method'] ?? "Не указано"),
              _detailItem("Travel Duration",
                  "${orderData['travel_time'] ?? "N/A"} мин."),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detailItem("Ride Fare", "\$${orderData['ride_fare'] ?? "0.00"}"),
              _detailItem("Discount", orderData['discount'] ?? "--"),
              _detailItem(
                  "Total fare", "\$${orderData['total_fare'] ?? "0.00"}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(Map<String, dynamic> orderData) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        orderData['feedback'] ?? "No feedback provided.",
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _locationItem(String address, String label, String trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_pin, size: 18, color: Colors.teal),
                SizedBox(width: 5),
                Text(address, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Text(label, style: TextStyle(color: Colors.grey)),
          ],
        ),
        Text(trailing,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
      ],
    );
  }

  Widget _detailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }