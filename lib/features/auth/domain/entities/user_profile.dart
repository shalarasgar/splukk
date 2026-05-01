import 'package:equatable/equatable.dart';

enum UserRole { consumer, farmer }

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.documentId,
    required this.role,
    required this.phone,
    this.fullName,
    this.farmName,
    this.farmAddress,
    this.farmCountry,
    this.farmState,
    this.farmCity,
    this.farmPostalCode,
    this.farmStreet,
    this.farmStreetNumber,
    this.farmLatitude,
    this.farmLongitude,
    this.logoUrl,
    this.bio,
    this.alternativePhone,
    this.socialInstagram,
    this.socialFacebook,
    this.bankIban,
    required this.createdAt,
  });

  final String uid;
  /// Firestore `users` koleksiyonundaki belge kimliği (`users/{documentId}`).
  final String documentId;
  final UserRole role;
  final String phone;
  final String? fullName;
  final String? farmName;
  final String? farmAddress;
  final String? farmCountry;
  final String? farmState;
  final String? farmCity;
  final String? farmPostalCode;
  final String? farmStreet;
  final String? farmStreetNumber;
  final double? farmLatitude;
  final double? farmLongitude;
  final String? logoUrl;
  final String? bio;
  final String? alternativePhone;
  final String? socialInstagram;
  final String? socialFacebook;
  final String? bankIban;
  final DateTime createdAt;

  UserProfile copyWith({
    String? fullName,
    String? farmName,
    String? farmAddress,
    String? farmCountry,
    String? farmState,
    String? farmCity,
    String? farmPostalCode,
    String? farmStreet,
    String? farmStreetNumber,
    double? farmLatitude,
    double? farmLongitude,
    String? logoUrl,
    String? bio,
    String? alternativePhone,
    String? socialInstagram,
    String? socialFacebook,
    String? bankIban,
  }) {
    return UserProfile(
      uid: uid,
      documentId: documentId,
      role: role,
      phone: phone,
      fullName: fullName ?? this.fullName,
      farmName: farmName ?? this.farmName,
      farmAddress: farmAddress ?? this.farmAddress,
      farmCountry: farmCountry ?? this.farmCountry,
      farmState: farmState ?? this.farmState,
      farmCity: farmCity ?? this.farmCity,
      farmPostalCode: farmPostalCode ?? this.farmPostalCode,
      farmStreet: farmStreet ?? this.farmStreet,
      farmStreetNumber: farmStreetNumber ?? this.farmStreetNumber,
      farmLatitude: farmLatitude ?? this.farmLatitude,
      farmLongitude: farmLongitude ?? this.farmLongitude,
      logoUrl: logoUrl ?? this.logoUrl,
      bio: bio ?? this.bio,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      socialInstagram: socialInstagram ?? this.socialInstagram,
      socialFacebook: socialFacebook ?? this.socialFacebook,
      bankIban: bankIban ?? this.bankIban,
      createdAt: createdAt,
    );
  }

  /// Tek satırda gösterim: yapılandırılmış alanlar veya eski `farmAddress`.
  String? get farmLocationSummary {
    final line = _streetLine;
    final pc = farmPostalCode?.trim();
    final ci = farmCity?.trim();
    final st = farmState?.trim();
    final co = farmCountry?.trim();
    final hasStructured = line != null ||
        [pc, ci, st, co].any((e) => e != null && e.isNotEmpty);
    if (hasStructured) {
      return [
        if (line != null && line.isNotEmpty) line,
        if (pc != null && pc.isNotEmpty) pc,
        if (ci != null && ci.isNotEmpty) ci,
        if (st != null && st.isNotEmpty) st,
        if (co != null && co.isNotEmpty) co,
      ].join(', ');
    }
    final fa = farmAddress?.trim();
    return fa != null && fa.isNotEmpty ? fa : null;
  }

  String? get _streetLine {
    final s = farmStreet?.trim();
    final n = farmStreetNumber?.trim();
    if (s == null || s.isEmpty) return null;
    if (n == null || n.isEmpty) return s;
    return '$s $n';
  }

  String get displayLabel {
    switch (role) {
      case UserRole.consumer:
        return fullName?.trim().isNotEmpty == true ? fullName!.trim() : phone;
      case UserRole.farmer:
        return farmName?.trim().isNotEmpty == true ? farmName!.trim() : phone;
    }
  }

  @override
  List<Object?> get props => [
        uid,
        documentId,
        role,
        phone,
        fullName,
        farmName,
        farmAddress,
        farmCountry,
        farmState,
        farmCity,
        farmPostalCode,
        farmStreet,
        farmStreetNumber,
        farmLatitude,
        farmLongitude,
        logoUrl,
        bio,
        alternativePhone,
        socialInstagram,
        socialFacebook,
        bankIban,
        createdAt,
      ];
}
