import 'package:flutter/material.dart';

enum ChatType {
  private,
  group,
}

enum MessageType {
  text,
  image,
  file,
  system,
}

enum ChatRequestStatus {
  pending,
  approved,
  rejected,
}

class ChatRoom {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final ChatType type;
  final List<String> memberIds;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final Map<String, dynamic> settings;
  final bool isPrivate;

  ChatRoom({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.type,
    required this.memberIds,
    this.createdBy,
    required this.createdAt,
    this.lastMessageAt,
    this.settings = const {},
    this.isPrivate = false,
  });

  ChatRoom copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    ChatType? type,
    List<String>? memberIds,
    String? createdBy,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    Map<String, dynamic>? settings,
    bool? isPrivate,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      memberIds: memberIds ?? this.memberIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      settings: settings ?? this.settings,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'type': type.name,
        'memberIds': memberIds,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'lastMessageAt': lastMessageAt?.toIso8601String(),
        'settings': settings,
        'isPrivate': isPrivate,
      };

  factory ChatRoom.fromMap(Map<String, dynamic> map) => ChatRoom(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        imageUrl: map['imageUrl'] as String?,
        type: ChatType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => ChatType.private,
        ),
        memberIds: List<String>.from(map['memberIds'] ?? []),
        createdBy: map['createdBy'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        lastMessageAt: map['lastMessageAt'] != null 
            ? DateTime.parse(map['lastMessageAt'] as String) 
            : null,
        settings: Map<String, dynamic>.from(map['settings'] ?? {}),
        isPrivate: map['isPrivate'] as bool? ?? false,
      );
}

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isEdited;
  final Map<String, List<String>> reactions; // emoji -> list of user IDs
  final String? replyToMessageId;
  final Map<String, dynamic> metadata;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.type,
    required this.createdAt,
    this.editedAt,
    this.isEdited = false,
    this.reactions = const {},
    this.replyToMessageId,
    this.metadata = const {},
  });

  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    DateTime? editedAt,
    bool? isEdited,
    Map<String, List<String>>? reactions,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      isEdited: isEdited ?? this.isEdited,
      reactions: reactions ?? this.reactions,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'chatRoomId': chatRoomId,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'content': content,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'editedAt': editedAt?.toIso8601String(),
        'isEdited': isEdited,
        'reactions': reactions,
        'replyToMessageId': replyToMessageId,
        'metadata': metadata,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as String,
        chatRoomId: map['chatRoomId'] as String,
        senderId: map['senderId'] as String,
        senderName: map['senderName'] as String,
        senderAvatar: map['senderAvatar'] as String?,
        content: map['content'] as String,
        type: MessageType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => MessageType.text,
        ),
        createdAt: DateTime.parse(map['createdAt'] as String),
        editedAt: map['editedAt'] != null 
            ? DateTime.parse(map['editedAt'] as String) 
            : null,
        isEdited: map['isEdited'] as bool? ?? false,
        reactions: Map<String, List<String>>.from(
          (map['reactions'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), List<String>.from(value)),
          ) ?? {},
        ),
        replyToMessageId: map['replyToMessageId'] as String?,
        metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      );
}

class ChatRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final String? requesterAvatar;
  final String targetUserId;
  final String? message;
  final ChatRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? responseMessage;

  ChatRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    this.requesterAvatar,
    required this.targetUserId,
    this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.responseMessage,
  });

  ChatRequest copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? requesterAvatar,
    String? targetUserId,
    String? message,
    ChatRequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? responseMessage,
  }) {
    return ChatRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterAvatar: requesterAvatar ?? this.requesterAvatar,
      targetUserId: targetUserId ?? this.targetUserId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      responseMessage: responseMessage ?? this.responseMessage,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'requesterId': requesterId,
        'requesterName': requesterName,
        'requesterAvatar': requesterAvatar,
        'targetUserId': targetUserId,
        'message': message,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'respondedAt': respondedAt?.toIso8601String(),
        'responseMessage': responseMessage,
      };

  factory ChatRequest.fromMap(Map<String, dynamic> map) => ChatRequest(
        id: map['id'] as String,
        requesterId: map['requesterId'] as String,
        requesterName: map['requesterName'] as String,
        requesterAvatar: map['requesterAvatar'] as String?,
        targetUserId: map['targetUserId'] as String,
        message: map['message'] as String?,
        status: ChatRequestStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => ChatRequestStatus.pending,
        ),
        createdAt: DateTime.parse(map['createdAt'] as String),
        respondedAt: map['respondedAt'] != null 
            ? DateTime.parse(map['respondedAt'] as String) 
            : null,
        responseMessage: map['responseMessage'] as String?,
      );
}

class PrivateChatRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  final String status; // 'pending', 'accepted', 'rejected'

  PrivateChatRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory PrivateChatRequest.fromMap(Map<String, dynamic> map) =>
      PrivateChatRequest(
        id: map['id'] as String,
        senderId: map['senderId'] as String,
        receiverId: map['receiverId'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        status: map['status'] as String? ?? 'pending',
      );
}
