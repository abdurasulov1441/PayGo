import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';

class OrderHistoryWidget extends StatefulWidget {
  final int orderNumber;
  final String status;
  final String customer;
  final String fromLocation;
  final String fromDateTime;
  final String toLocation;
  final String toDateTime;
  final String? peopleCount;
  final String? cargoName;
  final double? rating;
  final Function(int orderId, double rating)? onRatingUpdated;

  const OrderHistoryWidget({
    super.key,
    required this.orderNumber,
    required this.status,
    required this.customer,
    required this.fromLocation,
    required this.fromDateTime,
    required this.toLocation,
    required this.toDateTime,
    this.peopleCount,
    this.cargoName,
    this.rating,
    this.onRatingUpdated,
  });

  @override
  State<OrderHistoryWidget> createState() => _OrderHistoryWidgetState();
}

class _OrderHistoryWidgetState extends State<OrderHistoryWidget> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _updateRating(String orderId, double rating) async {
    try {
      final response = await requestHelper.postWithAuth(
        '/services/zyber/api/orders/add-rating',
        {'order_id': orderId, 'rate': rating, "comment_id": 2},
        log: true,
      );
      setState(() {});
      if (widget.onRatingUpdated != null) {
        widget.onRatingUpdated!(widget.orderNumber, rating);
      }
      print(response);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showRatingDialog(context) async {
    double selectedRating = 0.0;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buyurtmani baholash'),
          content: RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              selectedRating = rating;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateRating(widget.orderNumber.toString(), selectedRating);
                Navigator.of(context).pop();
                print(selectedRating);
              },
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
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
              _buildTag(
                  'Buyurtma raqami № ${widget.orderNumber}', Colors.orange),
              _buildTag(widget.status, Colors.green),
            ],
          ),
          const Divider(thickness: 1, height: 20),
          Text(
            'Buyurtmachi: ${widget.customer}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLocation('Qayerdan', widget.fromLocation),
              const Icon(
                Icons.arrow_forward,
                color: AppColors.grade1,
                size: 30,
              ),
              _buildLocation('Qayerga', widget.toLocation),
            ],
          ),
          const SizedBox(height: 15),
          if (widget.peopleCount != '0')
            Text(
              'Odam soni: ${widget.peopleCount}',
              style: const TextStyle(fontSize: 16),
            )
          else
            Text(
              'Yuk nomi: ${widget.cargoName}',
              style: const TextStyle(fontSize: 16),
            ),
          if (widget.rating != null)
            Text(
              'Qo\'yilgan baho: ${widget.rating}'.toString(),
              style: const TextStyle(fontSize: 16),
            )
          else
            ElevatedButton(
                onPressed: () {
                  _showRatingDialog(context);
                },
                child: Text('Buyurtmani baholash')),
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

  Widget _buildLocation(String label, String location) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            location,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
