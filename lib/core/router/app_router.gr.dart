// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;
import 'package:splukk/features/farmer_dashboard/presentation/farmer_dashboard_page.dart'
    as _i1;
import 'package:splukk/features/listings/presentation/farmer_listing_form_page.dart'
    as _i2;
import 'package:splukk/features/listings/presentation/listing_detail_page.dart'
    as _i3;
import 'package:splukk/features/shell/presentation/main_shell_page.dart' as _i4;

/// generated route for
/// [_i1.FarmerDashboardPage]
class FarmerDashboardRoute extends _i5.PageRouteInfo<void> {
  const FarmerDashboardRoute({List<_i5.PageRouteInfo>? children})
    : super(FarmerDashboardRoute.name, initialChildren: children);

  static const String name = 'FarmerDashboardRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.FarmerDashboardPage();
    },
  );
}

/// generated route for
/// [_i2.FarmerListingFormPage]
class FarmerListingFormRoute
    extends _i5.PageRouteInfo<FarmerListingFormRouteArgs> {
  FarmerListingFormRoute({
    _i6.Key? key,
    String? listingId,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         FarmerListingFormRoute.name,
         args: FarmerListingFormRouteArgs(key: key, listingId: listingId),
         initialChildren: children,
       );

  static const String name = 'FarmerListingFormRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FarmerListingFormRouteArgs>(
        orElse: () => const FarmerListingFormRouteArgs(),
      );
      return _i2.FarmerListingFormPage(
        key: args.key,
        listingId: args.listingId,
      );
    },
  );
}

class FarmerListingFormRouteArgs {
  const FarmerListingFormRouteArgs({this.key, this.listingId});

  final _i6.Key? key;

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
/// [_i3.ListingDetailPage]
class ListingDetailRoute extends _i5.PageRouteInfo<ListingDetailRouteArgs> {
  ListingDetailRoute({
    _i6.Key? key,
    required String listingId,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         ListingDetailRoute.name,
         args: ListingDetailRouteArgs(key: key, listingId: listingId),
         initialChildren: children,
       );

  static const String name = 'ListingDetailRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ListingDetailRouteArgs>();
      return _i3.ListingDetailPage(key: args.key, listingId: args.listingId);
    },
  );
}

class ListingDetailRouteArgs {
  const ListingDetailRouteArgs({this.key, required this.listingId});

  final _i6.Key? key;

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
/// [_i4.MainShellPage]
class MainShellRoute extends _i5.PageRouteInfo<MainShellRouteArgs> {
  MainShellRoute({
    _i6.Key? key,
    int initialTabIndex = 0,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         MainShellRoute.name,
         args: MainShellRouteArgs(key: key, initialTabIndex: initialTabIndex),
         initialChildren: children,
       );

  static const String name = 'MainShellRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MainShellRouteArgs>(
        orElse: () => const MainShellRouteArgs(),
      );
      return _i4.MainShellPage(
        key: args.key,
        initialTabIndex: args.initialTabIndex,
      );
    },
  );
}

class MainShellRouteArgs {
  const MainShellRouteArgs({this.key, this.initialTabIndex = 0});

  final _i6.Key? key;

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
