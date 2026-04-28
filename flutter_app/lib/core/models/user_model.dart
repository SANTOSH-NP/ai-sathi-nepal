class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String authProvider;
  final String subscriptionType;
  final DateTime? subscriptionExpiry;
  final String preferredLanguage;
  final int todayAiUsage;
  final int monthCvUsage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.authProvider,
    required this.subscriptionType,
    this.subscriptionExpiry,
    this.preferredLanguage = 'en',
    this.todayAiUsage = 0,
    this.monthCvUsage = 0,
  });

  bool get isPremium =>
      (subscriptionType == 'premium_monthly' ||
          subscriptionType == 'premium_yearly') &&
      subscriptionExpiry != null &&
      subscriptionExpiry!.isAfter(DateTime.now());

  bool get isGuest => authProvider == 'guest';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      authProvider: json['authProvider'] ?? 'email',
      subscriptionType: json['subscriptionType'] ?? 'free',
      subscriptionExpiry: json['subscriptionExpiry'] != null
          ? DateTime.tryParse(json['subscriptionExpiry'].toString())
          : null,
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      todayAiUsage: json['todayAiUsage'] ?? 0,
      monthCvUsage: json['monthCvUsage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'authProvider': authProvider,
        'subscriptionType': subscriptionType,
        'preferredLanguage': preferredLanguage,
      };
}
