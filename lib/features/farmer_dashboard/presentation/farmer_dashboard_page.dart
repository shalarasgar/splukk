import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependencies.dart';

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
        title: const Text('Çiftçi paneli'),
        actions: [
          IconButton(
            tooltip: 'Yeni ilan',
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
            child: const Text('Çıkış'),
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Oturum gerekli'))
          : StreamBuilder<List<FarmListing>>(
              stream: repo.watchListingsForFarmer(uid),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Hata: ${snap.error}'));
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
                        const Text('Henüz ilanınız yok'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            context.router.push(FarmerListingFormRoute());
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('İlan oluştur'),
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
                                  title: const Text('İlanı Sil'),
                                  content: const Text('Bu ilanı silmek istediğinize emin misiniz?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('İptal'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('Sil'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                try {
                                  await repo.deleteListing(l.id);
                                  if (context.mounted) {
                                    showAppSnackBar(context, 'İlan başarıyla silindi');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    showAppSnackBar(context, 'Hata: $e', isError: true);
                                  }
                                }
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
              label: const Text('İlan'),
            ),
    );
  }
}
