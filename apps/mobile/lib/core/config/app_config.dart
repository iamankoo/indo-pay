class AppConfig {
  const AppConfig._();

  static const appFlavor = String.fromEnvironment(
    "INDO_PAY_APP_FLAVOR",
    defaultValue: "staging",
  );

  static const stagingApiBaseUrl = String.fromEnvironment(
    "INDO_PAY_STAGING_API_BASE_URL",
    defaultValue: "https://staging-api.indo-pay.invalid/api/v1",
  );

  static const productionApiBaseUrl = String.fromEnvironment(
    "INDO_PAY_PRODUCTION_API_BASE_URL",
    defaultValue: "https://api.indo-pay.invalid/api/v1",
  );

  static const isProduction = appFlavor == "production";

  static const _defaultApiBaseUrl =
      isProduction ? productionApiBaseUrl : stagingApiBaseUrl;

  static const apiBaseUrl = String.fromEnvironment(
    "INDO_PAY_API_BASE_URL",
    defaultValue: _defaultApiBaseUrl,
  );

  static const defaultUserId = String.fromEnvironment(
    "INDO_PAY_USER_ID",
    defaultValue: "usr_demo_001",
  );

  static const merchantDemoId = String.fromEnvironment(
    "INDO_PAY_MERCHANT_ID",
    defaultValue: "mrc_demo_001",
  );

  static bool get usesHostedBackend => !apiBaseUrl.contains(".invalid");
}
