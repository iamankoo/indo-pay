import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/config/app_config.dart";
import "../../../core/network/api_client.dart";
import "../../../core/storage/session_store.dart";
import "../domain/home_dashboard.dart";
import "profile_photo_repository.dart";

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(apiClientProvider));
});

final homeDashboardProvider = FutureProvider<HomeDashboard>((ref) async {
  return ref.watch(homeRepositoryProvider).fetchDashboard();
});

final homeIdentityProvider = StateNotifierProvider<HomeIdentityNotifier, HomeIdentity?>((ref) {
  return HomeIdentityNotifier(ref)..loadUser();
});

class HomeIdentityNotifier extends StateNotifier<HomeIdentity?> {
  HomeIdentityNotifier(this._ref) : super(null);

  final Ref _ref;
  final SessionStore _sessionStore = SessionStore();

  Future<void> loadUser() async {
    final profile = await _sessionStore.readUserProfile();
    if (profile == null) {
      state = null;
      return;
    }

    state = _identityFromProfile(profile);
  }

  Future<void> setUser({
    required String fullName,
    required String mobileNumber,
    required String email,
    String? profilePhotoPath,
  }) async {
    final identity = HomeIdentity.fromStoredProfile(
      fullName: fullName,
      phoneNumber: mobileNumber,
      email: email,
      profilePhotoPath: profilePhotoPath,
      kycStatus: "Verified",
      linkedBankAccounts: 1,
      savedBeneficiaries: 4,
    );
    state = identity;
    await _sessionStore.saveUserProfile(
      fullName: fullName,
      mobileNumber: mobileNumber,
      email: email,
      profilePhotoPath: profilePhotoPath,
    );
  }

  Future<void> updateProfilePhoto() async {
    final currentIdentity = state;
    if (currentIdentity == null) {
      return;
    }

    final repository = _ref.read(profilePhotoRepositoryProvider);
    final pickedPath = await repository.pickProfilePhotoPath();
    if (pickedPath == null || pickedPath.isEmpty) {
      return;
    }

    final persistedPath = await repository.persistProfilePhoto(
      pickedPath,
      previousPath: currentIdentity.profilePhotoPath,
    );
    final updatedIdentity = currentIdentity.copyWith(
      profilePhotoPath: persistedPath,
    );
    state = updatedIdentity;
    await _sessionStore.saveUserProfile(
      fullName: updatedIdentity.fullName,
      mobileNumber: updatedIdentity.phoneNumber,
      email: updatedIdentity.email,
      profilePhotoPath: updatedIdentity.profilePhotoPath,
    );
  }

  HomeIdentity _identityFromProfile(StoredUserProfile profile) {
    return HomeIdentity.fromStoredProfile(
      fullName: profile.fullName,
      phoneNumber: profile.mobileNumber,
      email: profile.email,
      profilePhotoPath: profile.profilePhotoPath,
      kycStatus: "Verified",
      linkedBankAccounts: 1,
      savedBeneficiaries: 4,
    );
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
    required this.email,
    this.profilePhotoPath,
    required this.kycStatus,
    required this.linkedBankAccounts,
    required this.savedBeneficiaries,
  });

  factory HomeIdentity.fromStoredProfile({
    required String fullName,
    required String phoneNumber,
    required String email,
    String? profilePhotoPath,
    required String kycStatus,
    required int linkedBankAccounts,
    required int savedBeneficiaries,
  }) {
    final parts = fullName
        .trim()
        .split(RegExp(r"\s+"))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    final firstName = parts.isEmpty ? "User" : parts.first;
    final normalizedHandle = firstName.toLowerCase();
    return HomeIdentity(
      firstName: firstName,
      fullName: fullName,
      upiId: "$normalizedHandle@indopay",
      phoneNumber: phoneNumber,
      email: email,
      profilePhotoPath: profilePhotoPath,
      kycStatus: kycStatus,
      linkedBankAccounts: linkedBankAccounts,
      savedBeneficiaries: savedBeneficiaries,
    );
  }

  final String firstName;
  final String fullName;
  final String upiId;
  final String phoneNumber;
  final String email;
  final String? profilePhotoPath;
  final String kycStatus;
  final int linkedBankAccounts;
  final int savedBeneficiaries;

  HomeIdentity copyWith({
    String? profilePhotoPath,
  }) {
    return HomeIdentity(
      firstName: firstName,
      fullName: fullName,
      upiId: upiId,
      phoneNumber: phoneNumber,
      email: email,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      kycStatus: kycStatus,
      linkedBankAccounts: linkedBankAccounts,
      savedBeneficiaries: savedBeneficiaries,
    );
  }
}
