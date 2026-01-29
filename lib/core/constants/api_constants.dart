/// API constants and configuration
class ApiConstants {
  ApiConstants._();

  // Gemini - FREE tier model (Verified from official docs Jan 2026)
  // Model: gemini-2.5-flash - Supports text + images, 1M input tokens
  // Free tier: 15 requests/min, 1500 requests/day
  static const String geminiModel = 'gemini-2.5-flash';
  // Cloudinary
  static const String cloudinaryCloudName = 'dbialkq5t';
  static const String cloudinaryUploadPreset = 'lens_of_blessings';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String blessingsCollection = 'blessings';
}
