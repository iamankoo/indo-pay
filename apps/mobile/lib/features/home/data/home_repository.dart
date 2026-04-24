import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/config/app_config.dart";
import "../../../core/network/api_client.dart";
import "../../../core/storage/session_store.dart";
import "../domain/home_dashboard.dart";

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(apiClientProvider));
});

final homeDashboardProvider = FutureProvider<HomeDashboard>((ref) async {
  return ref.watch(homeRepositoryProvider).fetchDashboard();
});

final homeIdentityProvider = StateNotifierProvider<HomeIdentityNotifier, HomeIdentity?>((ref) {
  return HomeIdentityNotifier()..loadUser();
});

class HomeIdentityNotifier extends StateNotifier<HomeIdentity?> {
  HomeIdentityNotifier() : super(null);

  Future<void> loadUser() async {
    final sessionStore = SessionStore();
    final name = await sessionStore.readUserName();
    if (name != null && name.isNotEmpty) {
      final firstName = name.split(" ").first;
      state = HomeIdentity(
        firstName: firstName,
        fullName: name,
        upiId: "$firstName@indopay".toLowerCase(),
        phoneNumber: "",
        avatarUrl: "https://i.pravatar.cc/160?img=12",
        kycStatus: "Verified",
        linkedBankAccounts: 1,
        savedBeneficiaries: 4,
      );
    } else {
      state = null;
    }
  }

  void setUser(String fullName, String mobileNumber, String email) {
    final firstName = fullName.split(" ").first;
    state = HomeIdentity(
      firstName: firstName,
      fullName: fullName,
      upiId: "$firstName@indopay".toLowerCase(),
      phoneNumber: mobileNumber,
      avatarUrl: "https://i.pravatar.cc/160?img=12",
      kycStatus: "Verified",
      linkedBankAccounts: 1,
      savedBeneficiaries: 4,
    );
    final sessionStore = SessionStore();
    sessionStore.saveUserName(fullName: fullName, mobileNumber: mobileNumber, email: email);
  }
}


final unreadNotificationCountProvider = StateProvider<int>((ref) => 3);
final bankLinkFeatureFlagProvider = Provider<bool>((ref) => false);

class HomeRepository {
  HomeRepository(this._dio);

  final Dio _dio;

  Future<HomeDashboard> fetchDashboard() async {
    final walletResponse = await _dio.get<Map<String, dynamic>>(
      "/wallet/${AppConfig.defaultUserId}",
    );
    final passbookResponse = await _dio.get<Map<String, dynamic>>(
      "/passbook",
      queryParameters: {
        "userId": AppConfig.defaultUserId,
        "limit": 3,
      },
    );

    final wallet = walletResponse.data ?? const <String, dynamic>{};
    final passbook = passbookResponse.data ?? const <String, dynamic>{};
    final previewItems = (passbook["items"] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>();

    return HomeDashboard(
      userId: wallet["userId"]?.toString() ?? AppConfig.defaultUserId,
      walletBalance: wallet["promoWalletBalance"] as int? ?? 0,
      cashbackEarnedThisMonth: wallet["monthlyRedeemed"] as int? ?? 0,
      expiringRewards: wallet["expiringIn7Days"] as int? ?? 0,
      passbookPreview: previewItems
          .map(
            (item) => HomeFeedItem(
              id: item["id"]?.toString() ?? "item",
              type: item["type"]?.toString() ?? "transaction",
              amount: item["amount"] as int? ?? 0,
              status: item["status"]?.toString() ?? "SUCCESS",
              createdAt: DateTime.tryParse(
                    item["createdAt"]?.toString() ?? "",
                  ) ??
                  DateTime.now(),
            ),
          )
          .toList(),
    );
  }
}

class HomeIdentity {
  const HomeIdentity({
    required this.firstName,
    required this.fullName,
    required this.upiId,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.kycStatus,
    required this.linkedBankAccounts,
    required this.savedBeneficiaries,
  });

  final String firstName;
  final String fullName;
  final String upiId;
  final String phoneNumber;
  final String avatarUrl;
  final String kycStatus;
  final int linkedBankAccounts;
  final int savedBeneficiaries;
}
