import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taksi/pages/drivers_taxi/chat_page/provider/chat_provider.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';

class MyChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isSender;
  final String senderName;
  final String type; // "text", "image", "audio"
  final String? id;

  const MyChatBubble({
    Key? key,
    required this.text,
    required this.time,
    required this.isSender,
    required this.senderName,
    this.id,
    this.type = "text",
  }) : super(key: key);
// delete message from server
  Future<void> deleteMessage(String smsId) async {
    try {
      final response = await requestHelper
          .deleteWithAuth("/services/zyber/api/chat/delete-message/$smsId");
      print(response);
    } catch (e) {
      print(e);
    }
  }

  // edit message from server

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 10,
        ),

        /// **Foydalanuvchi avatari faqat boshqa odamlar uchun**
        if (!isSender) _buildAvatar(),

        Flexible(
          child: IntrinsicWidth(
            child: GestureDetector(
              onLongPressStart: (details) =>
                  _showMessageOptions(context, details.globalPosition, id),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isSender ? Color(0xFFD9FDD3) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: isSender ? Radius.circular(16) : Radius.zero,
                    bottomRight: isSender ? Radius.zero : Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// **Asosiy xabar + vaqt yonida chiqishi**
                    _buildMessageWithTime(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showMessageOptions(
      BuildContext context, Offset tapPosition, String? id) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    double screenWidth = overlay.size.width;

    double left = isSender
        ? tapPosition.dx - 100 // O‘ng tomonda bo‘lsa, menyuni chapga suramiz
        : tapPosition.dx + 20; // Chap tomonda bo‘lsa, menyuni o‘ngga suramiz

    double right = screenWidth - left - 150; // Menyu kengligi 150px

    List<PopupMenuEntry> menuItems = [];

    // **FAQAT O'Z XABARLARINGIZNI TAHRIRLASH VA O'CHIRISH MUMKIN**
    if (isSender) {
      menuItems.addAll([
        _buildMenuItem(context, 'assets/icons/pen.svg', "Taxrirlash", false),
        _buildMenuItem(
            context, 'assets/icons/trash.svg', "O‘chirish", true, Colors.red),
      ]);
    }

    if (menuItems.isNotEmpty) {
      showMenu(
        color: AppColors.backgroundColor,
        context: context,
        position: RelativeRect.fromLTRB(
            left, tapPosition.dy, right, overlay.size.height - tapPosition.dy),
        items: menuItems,
      );
    }
  }

  /// **Menyu elementini yaratish**
  PopupMenuItem _buildMenuItem(
      BuildContext context, String icon, String labelText, bool? isDelete,
      [Color? color]) {
    return PopupMenuItem(
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 18,
            height: 18,
          ),
          SizedBox(width: 10),
          Text(labelText,
              style: TextStyle(fontSize: 14, color: color ?? Colors.black)),
        ],
      ),
      onTap: () {
        if (isDelete!) {
          // after on tap, pop the menu and after 3 seconds delete message delay 3 seconds

          Future.delayed(Duration(milliseconds: 500), () {
            deleteMessage(id!);
            Provider.of<ChatProvider>(context, listen: false)
                .deleteMessageGroup(id!);
          });
          //
        } else {
          // edit message
          // after on tap, pop the menu and after 3 seconds edit message delay 3 seconds
          Future.delayed(Duration(milliseconds: 500), () {
            Provider.of<ChatProvider>(context, listen: false).setEditingMessage(
                id!, text); // Xabarni `TextField` ga chiqarish
          });
        }
      },
    );
  }

  Widget _buildMessageWithTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Ismni chapga tekislash
      mainAxisSize: MainAxisSize.min,
      children: [
        /// **Foydalanuvchi ismi (Faqat boshqa odamlar uchun)**
        if (!isSender)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              senderName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),

        /// **Xabar + vaqtni bir qatorda chiqarish**
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            /// **Xabar matni**
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),

            /// **Vaqtni matndan keyin chiqarish**
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                time,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),

            /// **Jo‘natuvchi uchun ✔✔ (Seen) belgisi**
            if (isSender)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Icon(
                  Icons.done_all,
                  size: 14,
                  color: Colors.blue,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// **Foydalanuvchi ismining birinchi harfini ko‘rsatish**
  Widget _buildAvatar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(right: 8),
        child: CircleAvatar(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          radius: 16,
          child: Text(
            senderName.isNotEmpty
                ? senderName.substring(0, 1).toUpperCase()
                : "?",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
