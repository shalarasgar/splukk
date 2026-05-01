// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i10;
import 'package:flutter/cupertino.dart' as _i13;
import 'package:flutter/material.dart' as _i11;
import 'package:splukk/features/auth/domain/auth_domain.dart' as _i12;
import 'package:splukk/features/chat/presentation/chat_page.dart' as _i1;
import 'package:splukk/features/farmer_dashboard/presentation/farmer_dashboard_page.dart'
    as _i3;
import 'package:splukk/features/listings/presentation/farmer_listing_form_page.dart'
    as _i4;
import 'package:splukk/features/listings/presentation/listing_detail_page.dart'
    as _i6;
import 'package:splukk/features/marketplace/presentation/marketplace_page.dart'
    as _i8;
import 'package:splukk/features/my_picks/presentation/my_picks_page.dart'
    as _i9;
import 'package:splukk/features/profile/presentation/edit_profile_page.dart'
    as _i2;
import 'package:splukk/features/profile/presentation/public_profile/farmer_public_profile_page.dart'
    as _i5;
import 'package:splukk/features/shell/presentation/main_shell_page.dart' as _i7;

/// generated route for
/// [_i1.ChatPage]
class ChatRoute extends _i10.PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    _i11.Key? key,
    required String listingId,
    String farmerName = 'Çiftçi',
    String? farmerUid,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         ChatRoute.name,
         args: ChatRouteArgs(
           key: key,
           listingId: listingId,
           farmerName: farmerName,
           farmerUid: farmerUid,
         ),
         rawPathParams: {'listingId': listingId},
         rawQueryParams: {'farmerName': farmerName, 'farmerUid': farmerUid},
         initialChildren: children,
       );

  static const String name = 'ChatRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<ChatRouteArgs>(
        orElse: () => ChatRouteArgs(
          listingId: pathParams.getString('listingId'),
          farmerName: queryParams.getString('farmerName', 'Çiftçi'),
          farmerUid: queryParams.optString('farmerUid'),
        ),
      );
      return _i1.ChatPage(
        key: args.key,
        listingId: args.listingId,
        farmerName: args.farmerName,
        farmerUid: args.farmerUid,
      );
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({
    this.key,
    required this.listingId,
    this.farmerName = 'Çiftçi',
    this.farmerUid,
  });

  final _i11.Key? key;

  final String listingId;

  final String farmerName;

  final String? farmerUid;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, listingId: $listingId, farmerName: $farmerName, farmerUid: $farmerUid}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key &&
        listingId == other.listingId &&
        farmerName == other.farmerName &&
        farmerUid == other.farmerUid;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      listingId.hashCode ^
      farmerName.hashCode ^
      farmerUid.hashCode;
}

/// generated route for
/// [_i2.EditProfilePage]
class EditProfileRoute extends _i10.PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    _i11.Key? key,
    required _i12.UserProfile profile,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         EditProfileRoute.name,
         args: EditProfileRouteArgs(key: key, profile: profile),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return _i2.EditProfilePage(key: args.key, profile: args.profile);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.profile});

  final _i11.Key? key;

  final _i12.UserProfile profile;

  @override
  String toString() {
    return 'EditProfileRouteArgs{key: $key, profile: $profile}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditProfileRouteArgs) return false;
    return key == other.key && profile == other.profile;
  }

  @override
  int get hashCode => key.hashCode ^ profile.hashCode;
}

/// generated route for
/// [_i3.FarmerDashboardPage]
class FarmerDashboardRoute extends _i10.PageRouteInfo<void> {
  const FarmerDashboardRoute({List<_i10.PageRouteInfo>? children})
    : super(FarmerDashboardRoute.name, initialChildren: children);

  static const String name = 'FarmerDashboardRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i3.FarmerDashboardPage();
    },
  );
}

/// generated route for
/// [_i4.FarmerListingFormPage]
class FarmerListingFormRoute
    extends _i10.PageRouteInfo<FarmerListingFormRouteArgs> {
  FarmerListingFormRoute({
    _i11.Key? key,
    String? listingId,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         FarmerListingFormRoute.name,
         args: FarmerListingFormRouteArgs(key: key, listingId: listingId),
         initialChildren: children,
       );

  static const String name = 'FarmerListingFormRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FarmerListingFormRouteArgs>(
        orElse: () => const FarmerListingFormRouteArgs(),
      );
      return _i4.FarmerListingFormPage(
        key: args.key,
        listingId: args.listingId,
      );
    },
  );
}

class FarmerListingFormRouteArgs {
  const FarmerListingFormRouteArgs({this.key, this.listingId});

  final _i11.Key? key;

  final String? listingId;

  @override
  String toString() {
    return 'FarmerListingFormRouteArgs{key: $key, listingId: $listingId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FarmerListingFormRouteArgs) return false;
    return key == other.key && listingId == other.listingId;
  }

  @override
  int get hashCode => key.hashCode ^ listingId.hashCode;
}

/// generated route for
/// [_i5.FarmerPublicProfilePage]
class FarmerPublicProfileRoute
    extends _i10.PageRouteInfo<FarmerPublicProfileRouteArgs> {
  FarmerPublicProfileRoute({
    _i11.Key? key,
    required String farmerUid,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         FarmerPublicProfileRoute.name,
         args: FarmerPublicProfileRouteArgs(key: key, farmerUid: farmerUid),
         initialChildren: children,
       );

  static const String name = 'FarmerPublicProfileRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FarmerPublicProfileRouteArgs>();
      return _i5.FarmerPublicProfilePage(
        key: args.key,
        farmerUid: args.farmerUid,
      );
    },
  );
}

class FarmerPublicProfileRouteArgs {
  const FarmerPublicProfileRouteArgs({this.key, required this.farmerUid});

  final _i11.Key? key;

  final String farmerUid;

  @override
  String toString() {
    return 'FarmerPublicProfileRouteArgs{key: $key, farmerUid: $farmerUid}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FarmerPublicProfileRouteArgs) return false;
    return key == other.key && farmerUid == other.farmerUid;
  }

  @override
  int get hashCode => key.hashCode ^ farmerUid.hashCode;
}

/// generated route for
/// [_i6.ListingDetailPage]
class ListingDetailRoute extends _i10.PageRouteInfo<ListingDetailRouteArgs> {
  ListingDetailRoute({
    _i13.Key? key,
    required String listingId,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         ListingDetailRoute.name,
         args: ListingDetailRouteArgs(key: key, listingId: listingId),
         initialChildren: children,
       );

  static const String name = 'ListingDetailRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ListingDetailRouteArgs>();
      return _i6.ListingDetailPage(key: args.key, listingId: args.listingId);
    },
  );
}

class ListingDetailRouteArgs {
  const ListingDetailRouteArgs({this.key, required this.listingId});

  final _i13.Key? key;

  final String listingId;

  @override
  String toString() {
    return 'ListingDetailRouteArgs{key: $key, listingId: $listingId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ListingDetailRouteArgs) return false;
    return key == other.key && listingId == other.listingId;
  }

  @override
  int get hashCode => key.hashCode ^ listingId.hashCode;
}

/// generated route for
/// [_i7.MainShellPage]
class MainShellRoute extends _i10.PageRouteInfo<MainShellRouteArgs> {
  MainShellRoute({
    _i11.Key? key,
    int initialTabIndex = 0,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         MainShellRoute.name,
         args: MainShellRouteArgs(key: key, initialTabIndex: initialTabIndex),
         initialChildren: children,
       );

  static const String name = 'MainShellRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MainShellRouteArgs>(
        orElse: () => const MainShellRouteArgs(),
      );
      return _i7.MainShellPage(
        key: args.key,
        initialTabIndex: args.initialTabIndex,
      );
    },
  );
}

class MainShellRouteArgs {
  const MainShellRouteArgs({this.key, this.initialTabIndex = 0});

  final _i11.Key? key;

  final int initialTabIndex;

  @override
  String toString() {
    return 'MainShellRouteArgs{key: $key, initialTabIndex: $initialTabIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MainShellRouteArgs) return false;
    return key == other.key && initialTabIndex == other.initialTabIndex;
  }

  @override
  int get hashCode => key.hashCode ^ initialTabIndex.hashCode;
}

/// generated route for
/// [_i8.MarketplacePage]
class MarketplaceRoute extends _i10.PageRouteInfo<void> {
  const MarketplaceRoute({List<_i10.PageRouteInfo>? children})
    : super(MarketplaceRoute.name, initialChildren: children);

  static const String name = 'MarketplaceRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i8.MarketplacePage();
    },
  );
}

/// generated route for
/// [_i9.MyPicksPage]
class MyPicksRoute extends _i10.PageRouteInfo<void> {
  const MyPicksRoute({List<_i10.PageRouteInfo>? children})
    : super(MyPicksRoute.name, initialChildren: children);

  static const String name = 'MyPicksRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i9.MyPicksPage();
    },
  );
}
