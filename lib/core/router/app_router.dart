import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: MainShellRoute.page, initial: true),
        AutoRoute(page: FarmerDashboardRoute.page),
        AutoRoute(page: FarmerListingFormRoute.page),
        AutoRoute(page: ListingDetailRoute.page),
      ];
}
