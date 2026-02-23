import '../../_shared/constants/network_config.dart';

class FamilyMemberUrls {
  static String getFamilyMembersUrl() {
    return '${NetworkConfig.baseUrl}/patient/family-members';
  }

  static String deleteFamilyMemberUrl(String familyMemberId) {
    return '${NetworkConfig.baseUrl}/patient/family-members/$familyMemberId';
  }
}


