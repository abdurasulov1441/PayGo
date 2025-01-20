import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:taksi/style/app_colors.dart';

class OrderHistoryWidget extends StatelessWidget {
  final String orderNumber;
  final String status;
  final String customer;
  final String fromLocation;
  final String fromDateTime;
  final String toLocation;
  final String toDateTime;
  final String cargoWeight;
  final String cargoName;

  const OrderHistoryWidget({
    super.key,
    required this.orderNumber,
    required this.status,
    required this.customer,
    required this.fromLocation,
    required this.fromDateTime,
    required this.toLocation,
    required this.toDateTime,
    required this.cargoWeight,
    required this.cargoName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 1, color: AppColors.backgroundColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(-4, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTag('Buyurtma raqami № $orderNumber', Colors.orange),
              _buildTag(status, Colors.green),
            ],
          ),
          const Divider(thickness: 1, height: 20),
          Text(
            'Buyurtmachi: $customer',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLocation('Qayerdan', fromLocation, fromDateTime),
              const Icon(
                Icons.arrow_forward,
                color: AppColors.grade1,
                size: 30,
              ),
              _buildLocation('Qayerga', toLocation, toDateTime),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Yuk vazni: $cargoWeight',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            'Yuk nomi: $cargoName',
            style: const TextStyle(fontSize: 16),
          ),
          Center(
            child: RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(rating);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLocation(String label, String location, String dateTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Text(
          location,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          dateTime,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
