class ProfileModel{
  final String id;
  final String userName;
  final String? avatarUrl;
  final String bio;
  final String timeZone;
  final DateTime createdAt; 
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.userName,
    required this.bio,
    required this.avatarUrl,
    required this.timeZone,
    required this.createdAt,
    required this.updatedAt
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(id: json['id'] as String, userName: json['username'] as String, bio: json['bio'] as String, avatarUrl: json['avatar_url'] as String?, timeZone: json['timezone'] as String, createdAt: DateTime.parse(
        json['created_at'] as String,
      ), updatedAt: DateTime.parse(json['updated_at']));
  }

  Map<String, dynamic> toJson() => {
  
    'id': id,
    'username': userName,
    'avatar_url': avatarUrl,
    'bio': bio,
    'timezone': timeZone,
    'created_at': createdAt,
    'updated_at': updatedAt
  };

}

