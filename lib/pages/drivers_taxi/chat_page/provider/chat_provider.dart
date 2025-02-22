import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:taksi/services/request_helper.dart';

class ChatProvider with ChangeNotifier {
    int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _totalPages = 1; 

  int get currentPage => _currentPage; // ✅ Добавлен геттер
  int get totalPages => _totalPages; // ✅ Добавлен геттер

  IO.Socket? _socket;
  List<Map<String, dynamic>> groupedMessages = [];

  String? editingMessageId;
  String? editingMessageText;

  void setEditingMessage(String messageId, String messageText) {
    editingMessageId = messageId;
    editingMessageText = messageText;
    notifyListeners();
  }

  ChatProvider() {
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      _socket = IO.io(
        "https://paygo.app-center.uz",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setReconnectionAttempts(3)
            .build(),
      );

      _socket!.onConnect((_) {
        print("✅ Подключено к WebSocket!");
      });

      _socket!.onDisconnect((_) {
        print("⚠️ WebSocket отключен, переподключаем...");
        _reconnectWebSocket();
      });

      _socket!.onError((data) {
        print("❌ Ошибка WebSocket: $data");
        _reconnectWebSocket();
      });

      _socket!.on("new_message", (data) {
        print("📩 Новое сообщение: $data");

        if (data is List) {
          for (var group in data) {
            if (group is Map<String, dynamic>) {
              _addMessageGroup(group);
            }
          }
        }
      });

      _socket!.connect();
    } catch (e) {
      print("❌ Ошибка подключения к WebSocket: $e");
      _reconnectWebSocket();
    }
  }
  
  void turnOffWebSocket() {
    _socket?.disconnect();
  }


  void _addMessageGroup(Map<String, dynamic> newGroup) {
    String date = newGroup["date"];
    List<dynamic> messages = newGroup["messages"];

    int dateIndex =
        groupedMessages.indexWhere((group) => group["date"] == date);

    if (dateIndex != -1) {
      groupedMessages[dateIndex]["messages"].addAll(messages);
    } else {
      groupedMessages.add({
        "date": date,
        "messages": messages,
      });
    }
    playSendSound(isme: false);
    notifyListeners();
  }


  void deleteMessageGroup(String messageId) {
    for (var group in groupedMessages) {
      group["messages"].removeWhere((message) => message["id"] == messageId);
    }
    notifyListeners();
  }


  Future<void> editMessageGroup(String messageId, String newText) async {
    try {
      final response = await requestHelper.putWithAuth(
        "/services/zyber/api/chat/edit-message",
        {
          "message_id": messageId,
          "message_text": newText,
        },
      );

      if (response != null && response["success"] == true) {
        print("✅ Xabar yangilandi!");

        for (var group in groupedMessages) {
          for (var message in group["messages"]) {
            if (message["id"] == messageId) {
              message["message_text"] = newText;
            }
          }
        }
        editingMessageId = null;
        editingMessageText = null;
        notifyListeners();
      } else {
        print("❌ Xabarni yangilashda xatolik yuz berdi");
      }
    } catch (e) {
      print("❌ Xatolik: $e");
    }
  }

  Future<void> sendMessage(String chatRoomId, String messageText) async {
    try {
      var response = await requestHelper.postWithAuth(
        "/services/zyber/api/chat/send-message",
        {
          "chat_room_id": chatRoomId,
          "message_text": messageText,
        },
        log: false,
      );
      playSendSound(isme: true);
      if (response != null && response["success"] == true) {
        print("✅ Сообщение отправлено!");
      } else {
        print("❌ Ошибка при отправке сообщения");
      }
    } catch (e) {
      print("❌ Ошибка запроса: $e");
    }
  }

  final player = AudioPlayer();
  void playSendSound({required bool isme}) async {
    if (isme) {
      await player.play(AssetSource('sounds/send.mp3'));
      return;
    } else {
      await player.play(AssetSource('sounds/send2.mp3'));
    }
  }

  Future<void> fetchMessages(String chatRoomId) async {
    try {
      final response = await requestHelper.getWithAuth(
        "/services/zyber/api/chat/get-messages?chat_room_id=$chatRoomId",
        log: true,
      );

      if (response != null && response["success"] == true) {
        groupedMessages =
            List<Map<String, dynamic>>.from(response["grouped_messages"] ?? []);
        notifyListeners();
      } else {
        print("❌ Ошибка при загрузке сообщений");
      }
    } catch (e) {
      print("❌ Ошибка загрузки чата: $e");
    }
  }



  Future<void> fetchMoreMessages(String chatRoomId) async {
    if (_isLoadingMore || !_hasMore || _currentPage > _totalPages) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await requestHelper.getWithAuth(
        "/services/zyber/api/chat/get-messages?chat_room_id=$chatRoomId&page=$_currentPage",
        log: true,
      );

      if (response != null && response["success"] == true) {
        List<Map<String, dynamic>> newMessages =
            List<Map<String, dynamic>>.from(response["grouped_messages"] ?? []);

        _totalPages = response["total_pages"] ?? 1; // Обновляем общее число страниц

        if (newMessages.isNotEmpty) {
          groupedMessages.addAll(newMessages); // Добавляем в конец списка
          _currentPage++;
        } else {
          _hasMore = false;
        }
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print("❌ Ошибка загрузки сообщений: $e");
      _hasMore = false;
    }

    _isLoadingMore = false;
    notifyListeners();
  }
 
  void _reconnectWebSocket() {
    Future.delayed(Duration(seconds: 3), () {
      _socket?.connect();
    });
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }
}
