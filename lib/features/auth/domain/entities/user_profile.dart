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
  final DateTime createdAt;

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
        createdAt,
      ];
}
