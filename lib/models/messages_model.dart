import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;

  final String sender;

  // left, right, center
  final String senderType;

  // message, system, image...
  final String type;

  final String text;

  final Timestamp? createdAt;

  MessageModel({
    required this.messageId,
    required this.sender,
    required this.senderType,
    required this.type,
    required this.text,
    this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      messageId: docId,
      sender: map["sender"] ?? "",
      senderType: map["senderType"] ?? "left",
      type: map["type"] ?? "message",
      text: map["text"] ?? "",
      createdAt: map["createdAt"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "senderType": senderType,
      "type": type,
      "text": text,
      "createdAt": createdAt,
    };
  }
}
