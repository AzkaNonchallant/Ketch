class ApiConstants {
  ApiConstants._();

  static const String identifyAnimalFunction = 'identify-animal';
  static const String getSpeciesDetailFunction = 'get-species-detail';
  static const String unlockAchievementFunction = 'unlock-achievement';
  static const String calculateStreakFunction = 'calculate-streak';
  static const String confirmIdentificationFunction = 'confirm-identification';
  static const String generateShareCardFunction = 'generate-share-card';

  static const String animalPhotosBucket = 'animal-photos';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}