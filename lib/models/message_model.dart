import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? messageId;
  String? senderId;
  String? receiverId;
  String? jobId; // The job associated with the chat
  String? message;
  DateTime? timestamp;

  MessageModel({
    this.messageId,
    this.senderId,
    this.receiverId,
    this.jobId,
    this.message,
    this.timestamp,
  });

  // Factory method to create a MessageModel from Firestore snapshot
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      jobId: map['jobId'],
      message: map['message'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  // Method to convert MessageModel to a Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'jobId': jobId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}