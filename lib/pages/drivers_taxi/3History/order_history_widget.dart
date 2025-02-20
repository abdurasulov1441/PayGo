import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

class OrderHistoryWidget extends StatefulWidget {
  final int orderNumber;
  final String status;
  final String customer;
  final String fromLocation;
  final String toLocation;
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
    required this.toLocation,
    this.peopleCount,
    this.cargoName,
    this.rating,
    this.onRatingUpdated,
  });

  @override
  State<OrderHistoryWidget> createState() => _OrderHistoryWidgetState();
}

class _OrderHistoryWidgetState extends State<OrderHistoryWidget> {
  double selectedRating = 0.0;
  TextEditingController commentController = TextEditingController();

  Future<void> _updateRating(int orderId, double rating) async {
    try {
      final response = await requestHelper.postWithAuth(
        '/services/zyber/api/orders/add-rating',
        {
          'order_id': orderId,
          'rate': rating,
          "comment": commentController.text
        },
        log: false,
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

  void _showRatingBottomSheet(BuildContext context) {
    setState(() {
      selectedRating = 0.0;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Safarni baholang',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // ⭐ Звезды рейтинга
                  RatingBar.builder(
                    initialRating: selectedRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color:
                          index < selectedRating ? Colors.amber : Colors.grey,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        selectedRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  // 📝 Поле ввода комментария
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Izoh',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 😊 Иконки доп.оценок

                  // 🟠 Динамическая кнопка
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBottomButton(
                        selectedRating > 0 ? 'Saqlash' : 'Bekor qilish',
                        selectedRating > 0 ? Colors.teal : Colors.orange,
                        Colors.white,
                        () {
                          if (selectedRating > 0) {
                            _updateRating(widget.orderNumber, selectedRating);
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
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

  Widget _buildBottomButton(
      String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
      ),
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
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '# ${widget.orderNumber}',
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grade1,
                ),
              ),
              _buildTag(widget.status, Colors.green),
            ],
          ),
          const Divider(thickness: 1, height: 20),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(widget.toLocation),
                    SvgPicture.asset('assets/icons/fromto.svg',
                        width: 30, height: 120),
                    Text(widget.fromLocation),
                  ],
                ),
                Expanded(
                    child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Buyurtmachi: ',
                          style: AppStyle.fontStyle
                              .copyWith(color: AppColors.uiText),
                        ),
                        Text(
                          ' ${widget.customer}',
                          style: AppStyle.fontStyle
                              .copyWith(fontSize: 16, color: AppColors.grade1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (widget.peopleCount != '0')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Odam soni:',
                            style: AppStyle.fontStyle.copyWith(
                                fontSize: 14, color: AppColors.uiText),
                          ),
                          Text(
                            ' ${widget.peopleCount}',
                            style: AppStyle.fontStyle.copyWith(
                                fontSize: 14, color: AppColors.grade1),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Yuk nomi:',
                            style: AppStyle.fontStyle
                                .copyWith(color: AppColors.uiText),
                          ),
                          Text(
                            ' ${widget.cargoName}',
                            style: AppStyle.fontStyle
                                .copyWith(color: AppColors.grade1),
                          ),
                        ],
                      ),
                    const SizedBox(height: 15),
                    widget.rating != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Qo‘yilgan baho:',
                                style: AppStyle.fontStyle
                                    .copyWith(color: AppColors.uiText),
                              ),
                              Text(
                                '${widget.rating}',
                                style: AppStyle.fontStyle
                                    .copyWith(color: AppColors.grade1),
                              ),
                            ],
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                              onPressed: () => _showRatingBottomSheet(context),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: AppColors.grade1),
                              child: Text('Baholash',
                                  style: AppStyle.fontStyle
                                      .copyWith(color: Colors.white)),
                            ),
                          ),
                  ],
                ))
              ])
        ]));
  }
}
