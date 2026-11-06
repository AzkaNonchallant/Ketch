class AppConstants {
  AppConstants._();

  static const String appName = 'Ketch';
  static const String appVersion = '1.0.0';

  //bagian ini ya apasi namanya...shared prefferences
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserTheme = 'user_theme';
  static const String keyIsFirstTime = 'is_first_time';
  static const String keyUserLanguage = 'user_language';

  //ini bagian pagination 
  static const int defaultPageSize = 20;
  static const int maxImageUploadSizeMb = 10;

  //ini policy sementara gini aja aman kali ya
  static const String privacyPolicyUrl = 'https://AzkaNonchallant.github.io/animal-discovery/privacy';
  static const String termsOfServiceUrl = 'https://AzkaNonchallant.github.io/animal-discovery/terms';
  static const String supportEmail = 'azkaaydirrafifsyah@gmail.com';
}