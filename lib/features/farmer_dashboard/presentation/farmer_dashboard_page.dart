import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependencies.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:splukk/core/l10n/locale_keys.dart';

import '../../../core/app_messages.dart';
import '../../../core/router/app_router.gr.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../listings/domain/listings_domain.dart';

@RoutePage()
class FarmerDashboardPage extends StatelessWidget {
  const FarmerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthBloc>().state.profile?.uid;
    final repo = sl<ListingRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.farmer_dashboard_title.tr(context: context)),
        actions: [
          IconButton(
            tooltip: LocaleKeys.farmer_listing_form_new_title.tr(context: context),
            onPressed: uid == null
                ? null
                : () {
                    context.router.push(FarmerListingFormRoute());
                  },
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
          TextButton(
            onPressed: () async {
              final bloc = context.read<AuthBloc>();
              bloc.add(const AuthSignOutRequested());
              await bloc.stream.firstWhere(
                (s) => s.status == AuthStatus.unauthenticated,
              );
              if (context.mounted) context.router.maybePop();
            },
            child: Text(LocaleKeys.farmer_dashboard_sign_out.tr(context: context)),
          ),
        ],
      ),
      body: uid == null
          ? Center(child: Text(LocaleKeys.farmer_dashboard_auth_required.tr(context: context)))
          : StreamBuilder<List<FarmListing>>(
              stream: repo.watchListingsForFarmer(uid),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('${LocaleKeys.farmer_profile_error.tr(context: context)}: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data!;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(LocaleKeys.farmer_dashboard_no_listings.tr(context: context)),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            context.router.push(FarmerListingFormRoute());
                          },
                          icon: const Icon(Icons.add),
                          label: Text(LocaleKeys.farmer_dashboard_create_listing.tr(context: context)),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final l = list[i];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      title: Text(l.farmName),
                      subtitle: Text('${l.city} · %${l.availabilityPercent}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(LocaleKeys.farmer_dashboard_delete_confirm_title.tr(context: context)),
                                  content: Text(LocaleKeys.farmer_dashboard_delete_confirm_body.tr(context: context)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: Text(LocaleKeys.common_cancel.tr(context: context)),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: Text(LocaleKeys.farmer_listing_form_delete.tr(context: context)),
                                    ),
                                  ],
                                ),
                              );
                                if (ok == true) {
                                  final result = await repo.deleteListing(l.id);
                                  result.fold(
                                    (failure) {
                                      if (context.mounted) {
                                        showAppSnackBar(context, '${LocaleKeys.farmer_profile_error.tr(context: context)}: ${failure.message}', isError: true);
                                      }
                                    },
                                    (_) {
                                      if (context.mounted) {
                                        showAppSnackBar(context, LocaleKeys.farmer_dashboard_delete_success.tr(context: context));
                                      }
                                    },
                                  );
                                }
                            },
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () {
                        context.router.push(
                          FarmerListingFormRoute(listingId: l.id),
                        );
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: uid == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                context.router.push(FarmerListingFormRoute());
              },
              icon: const Icon(Icons.add),
              label: Text(LocaleKeys.farmer_dashboard_create_listing.tr(context: context)),
            ),
    );
  }
}
