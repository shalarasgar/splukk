import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../listings/domain/listings_domain.dart';
import '../marketplace_cubit.dart';
import '../marketplace_state.dart';

class MarketplaceMapWidget extends StatefulWidget {
  const MarketplaceMapWidget({super.key});

  @override
  State<MarketplaceMapWidget> createState() => _MarketplaceMapWidgetState();
}

class _MarketplaceMapWidgetState extends State<MarketplaceMapWidget>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _isInitialized = false;
  LatLng? _userLocation;
  FarmListing? _previousSelectedListing;
  AnimationController? _animationController;

  @override
  void dispose() {
    _animationController?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    _animationController?.dispose();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.fastOutSlowIn,
    );

    _animationController!.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    _animationController!.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitBounds();
      });
    }
  }

  void _fitBounds() {
    final state = context.read<MarketplaceCubit>().state;
    final listings = state.filteredListings
        .where((l) => l.latitude.isFinite && l.longitude.isFinite)
        .toList();

    if (listings.isEmpty) return;

    if (listings.length == 1) {
      _animatedMapMove(
        LatLng(
          listings.first.latitude.isFinite ? listings.first.latitude : 0,
          listings.first.longitude.isFinite ? listings.first.longitude : 0,
        ),
        12.0,
      );
      return;
    }

    // Вычисляем bounds всех маркеров
    double minLat = listings.first.latitude;
    double maxLat = listings.first.latitude;
    double minLng = listings.first.longitude;
    double maxLng = listings.first.longitude;

    for (final listing in listings) {
      final lat = listing.latitude.isFinite ? listing.latitude : 0.0;
      final lng = listing.longitude.isFinite ? listing.longitude : 0.0;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    // Добавляем отступ
    final latPadding = (maxLat - minLat) * 0.2;
    final lngPadding = (maxLng - minLng) * 0.2;

    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

    // Вычисляем zoom на основе bounds
    final latDiff = (maxLat - minLat) + latPadding;
    final lngDiff = (maxLng - minLng) + lngPadding;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    // Приблизительный расчет zoom (180 градусов = zoom 0)
    final zoom = 10.0 - (maxDiff * 3).clamp(0.0, 8.0);

    _animatedMapMove(center, zoom);
  }

  Future<void> _locateUser() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Геолокация отключена')));
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Разрешение на геолокацию отклонено')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Разрешение на геолокацию отклонено навсегда'),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!position.latitude.isFinite || !position.longitude.isFinite) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось получить точные координаты'),
          ),
        );
        return;
      }

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });

      _animatedMapMove(_userLocation!, 14.0);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка геолокации: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarketplaceCubit, MarketplaceState>(
      listener: (context, state) {
        if (_previousSelectedListing != null && state.selectedListing == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fitBounds();
          });
        }
        _previousSelectedListing = state.selectedListing;
      },
      builder: (context, state) {
        final listings = state.filteredListings
            .where((l) => l.latitude.isFinite && l.longitude.isFinite)
            .toList();

        // Норвегия (или центр на основе первого листинга)
        final initialCenter = listings.isNotEmpty
            ? LatLng(listings.first.latitude, listings.first.longitude)
            : const LatLng(59.9139, 10.7522); // Oslo

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 10.0,
                onTap: (_, __) {
                  context.read<MarketplaceCubit>().clearSelection();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.splukk.app',
                ),
                MarkerLayer(
                  markers: [
                    // User location marker
                    if (_userLocation != null &&
                        _userLocation!.latitude.isFinite &&
                        _userLocation!.longitude.isFinite)
                      Marker(
                        point: _userLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            // color: const Color.fromARGB(255, 255, 255, 255),
                            // shape: BoxShape.circle,
                            // border: Border.all(color: Colors.white, width: 3),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black.withOpacity(0.3),
                            //     blurRadius: 8,
                            //     offset: const Offset(0, 4),
                            //   ),
                            // ],
                          ),
                          child: const Icon(
                            Icons.navigation_rounded,
                            // LucideIcons.navigation,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    // Listing markers
                    ...listings.map((listing) {
                      final isSelected =
                          state.selectedListing?.id == listing.id;
                      return Marker(
                        point: LatLng(
                          listing.latitude.isFinite ? listing.latitude : 0,
                          listing.longitude.isFinite ? listing.longitude : 0,
                        ),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () {
                            final isCurrentlySelected =
                                state.selectedListing?.id == listing.id;

                            if (isCurrentlySelected) {
                              // Если уже выбрано — сбрасываем (второе нажатие)
                              context.read<MarketplaceCubit>().clearSelection();
                            } else {
                              // Если не выбрано — выбираем и зумируем
                              context.read<MarketplaceCubit>().selectListing(
                                listing,
                              );
                              _animatedMapMove(
                                LatLng(
                                  listing.latitude.isFinite
                                      ? listing.latitude
                                      : 0,
                                  listing.longitude.isFinite
                                      ? listing.longitude
                                      : 0,
                                ),
                                13.0, // Чуть ближе для лучшего фокуса
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2B8C5F)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF2B8C5F),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              LucideIcons.mapPin,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF2B8C5F),
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: _locateUser,
                backgroundColor: Colors.white,
                child: const Icon(
                  LucideIcons.crosshair,
                  color: Color(0xFF2B8C5F),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
