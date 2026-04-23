import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/app_messages.dart';
import '../../../core/constants/availability_presets.dart';
import '../../../core/constants/products.dart';
import '../../../core/router/app_router.gr.dart';
import '../../../core/utils/nok_money.dart';
import '../../auth/domain/auth_domain.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../domain/listings_domain.dart';
import 'widgets/listing_card.dart';

@RoutePage()
class FarmerListingFormPage extends StatefulWidget {
  const FarmerListingFormPage({super.key, this.listingId});

  final String? listingId;

  @override
  State<FarmerListingFormPage> createState() => _FarmerListingFormPageState();
}

class _ProductLineDraft {
  _ProductLineDraft({
    required this.categoryId,
    required this.productId,
    required this.priceController,
    required this.unit,
  });

  String categoryId;
  String productId;
  final TextEditingController priceController;
  ListingPriceUnit unit;
}

class _ScheduleDraft {
  _ScheduleDraft({
    required this.weekday,
    required this.start,
    required this.end,
    required this.capacityController,
    this.calendarAnchor,
  });

  int weekday;

  /// Takvimden seçilen tarih (yalnızca form gösterimi; kayıtta yine haftanın günü kullanılır).
  DateTime? calendarAnchor;
  TimeOfDay start;
  TimeOfDay end;
  final TextEditingController capacityController;
}

class _FarmerListingFormPageState extends State<FarmerListingFormPage> {
  final _farmName = TextEditingController();
  final _city = TextEditingController();
  final _description = TextEditingController();

  final _productRows = <_ProductLineDraft>[];
  final _scheduleRows = <_ScheduleDraft>[];
  final _localImagePaths = <String>[];
  final _existingImageUrls = <String>[];

  double _availability = 75;
  int? _messageIndexInBand;
  PickingType _picking = PickingType.selfPicking;
  bool _manualClosed = false;
  bool _loading = false;
  bool _saving = false;
  FarmListing? _existing;

  static DateTime _nextOccurrenceOfWeekday(int weekday, DateTime from) {
    var d = DateTime(from.year, from.month, from.day);
    for (var i = 0; i < 8; i++) {
      if (d.weekday == weekday) return d;
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final id = widget.listingId;
    if (id != null) {
      await _loadListing(id);
    } else {
      _prefillFromAuthProfile();
    }
  }

  void _prefillFromAuthProfile() {
    final profile = context.read<AuthBloc>().state.profile;
    if (profile == null || profile.role != UserRole.farmer) return;
    _farmName.text = profile.farmName ?? '';
    _city.text = profile.farmCity ?? '';
    if (_productRows.isEmpty && products.isNotEmpty) {
      final firstCat = products.keys.first;
      final firstProd = products[firstCat]!.keys.first;
      _productRows.add(
        _ProductLineDraft(
          categoryId: firstCat,
          productId: firstProd,
          priceController: TextEditingController(),
          unit: ListingPriceUnit.kg,
        ),
      );
    }
    if (_scheduleRows.isEmpty) {
      final mon = _nextOccurrenceOfWeekday(DateTime.monday, DateTime.now());
      _scheduleRows.add(
        _ScheduleDraft(
          weekday: DateTime.monday,
          calendarAnchor: mon,
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 18, minute: 0),
          capacityController: TextEditingController(text: '10'),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _loadListing(String id) async {
    setState(() => _loading = true);
    final repo = Get.find<ListingRepository>();
    final listing = await repo.getListing(id);
    if (!mounted) return;
    if (listing == null) {
      setState(() => _loading = false);
      showAppSnackBar(context, 'İlan bulunamadı', isError: true);
      return;
    }
    _existing = listing;
    _farmName.text = listing.farmName;
    _city.text = listing.city;
    _description.text = listing.description ?? '';
    for (final p in _productRows) {
      p.priceController.dispose();
    }
    _productRows.clear();
    for (final s in _scheduleRows) {
      s.capacityController.dispose();
    }
    _scheduleRows.clear();
    _availability = listing.availabilityPercent.toDouble();
    _messageIndexInBand = listing.availabilityMessageIndex;
    _picking = listing.pickingType;
    _manualClosed = listing.manualClosed;
    _existingImageUrls
      ..clear()
      ..addAll(listing.imageUrls);
    if (listing.products.isNotEmpty) {
      final p = listing.products.first;
      _productRows.add(
        _ProductLineDraft(
          categoryId: p.categoryId,
          productId: p.productId,
          priceController: TextEditingController(
            text: formatOreAsNokKr(p.priceOre),
          ),
          unit: p.unit,
        ),
      );
    } else if (products.isNotEmpty) {
      final firstCat = products.keys.first;
      final firstProd = products[firstCat]!.keys.first;
      _productRows.add(
        _ProductLineDraft(
          categoryId: firstCat,
          productId: firstProd,
          priceController: TextEditingController(),
          unit: ListingPriceUnit.kg,
        ),
      );
    }
    for (final s in listing.schedule) {
      _scheduleRows.add(
        _ScheduleDraft(
          weekday: s.weekday,
          start: TimeOfDay(
            hour: s.startMinutes ~/ 60,
            minute: s.startMinutes % 60,
          ),
          end: TimeOfDay(hour: s.endMinutes ~/ 60, minute: s.endMinutes % 60),
          calendarAnchor: s.specificDate,
          capacityController: TextEditingController(
            text: s.maxPeople.toString(),
          ),
        ),
      );
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _farmName.dispose();
    _city.dispose();
    _description.dispose();
    for (final p in _productRows) {
      p.priceController.dispose();
    }
    for (final s in _scheduleRows) {
      s.capacityController.dispose();
    }
    super.dispose();
  }

  int get _bandIndex => availabilityBandIndexForPercent(_availability.round());

  List<String> get _currentBandSuggestions =>
      availabilityBands[_bandIndex].suggestions;

  void _onAvailabilityChanged(double v) {
    final oldBand = availabilityBandIndexForPercent(_availability.round());
    final newBand = availabilityBandIndexForPercent(v.round());
    setState(() {
      _availability = v;
      if (oldBand != newBand) {
        _messageIndexInBand = 0;
      }
    });
  }

  void _addScheduleRow() {
    setState(() {
      _scheduleRows.add(
        _ScheduleDraft(
          weekday: DateTime.monday,
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 18, minute: 0),
          capacityController: TextEditingController(text: '10'),
        ),
      );
    });
  }

  Future<void> _confirmRemoveScheduleRow(BuildContext context, int i) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çalışma aralığını sil'),
        content: const Text(
          'Bu çalışma aralığını silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _scheduleRows.removeAt(i).capacityController.dispose();
    });
  }

  Future<void> _pickImages() async {
    final files = await ImagePicker().pickMultiImage();
    if (files.isEmpty) return;
    setState(() {
      for (final f in files) {
        _localImagePaths.add(f.path);
      }
    });
  }

  void _removeLocalImage(int i) {
    setState(() => _localImagePaths.removeAt(i));
  }

  void _removeExistingImage(int i) {
    setState(() => _existingImageUrls.removeAt(i));
  }

  Future<void> _save() async {
    final uid = context.read<AuthBloc>().state.profile?.uid;
    if (uid == null) {
      showAppSnackBar(context, 'Oturum gerekli', isError: true);
      return;
    }
    if (_farmName.text.trim().isEmpty || _city.text.trim().isEmpty) {
      showAppSnackBar(context, 'Çiftlik adı ve şehir zorunlu', isError: true);
      return;
    }
    double? lat;
    double? lng;
    if (widget.listingId == null) {
      final profile = context.read<AuthBloc>().state.profile;
      lat = profile?.farmLatitude;
      lng = profile?.farmLongitude;
      if (lat == null || lng == null) {
        if (!mounted) return;
        final go = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Çiftlik konumu gerekli'),
            content: const Text(
              'Yeni ilan için profilinizde çiftlik konumu tanımlı olmalı. '
              'Profil sekmesinden hesabınızı açıp bilgilerinizi kontrol edebilirsiniz.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('İptal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Profil sekmesi'),
              ),
            ],
          ),
        );
        if (go == true && mounted) {
          context.router.replaceAll([MainShellRoute(initialTabIndex: 2)]);
        }
        return;
      }
    } else {
      final ex = _existing;
      if (ex == null) {
        showAppSnackBar(context, 'İlan yüklenemedi', isError: true);
        return;
      }
      lat = ex.latitude;
      lng = ex.longitude;
    }
    if (_productRows.isEmpty) {
      showAppSnackBar(context, 'En az bir ürün ekleyin', isError: true);
      return;
    }
    final lines = <ListingProductLine>[];
    for (final row in _productRows) {
      final ore = parseNokToOre(row.priceController.text);
      if (ore == null || ore <= 0) {
        showAppSnackBar(
          context,
          'Tüm ürünler için geçerli fiyat girin (NOK)',
          isError: true,
        );
        return;
      }
      lines.add(
        ListingProductLine(
          categoryId: row.categoryId,
          productId: row.productId,
          priceOre: ore,
          unit: row.unit,
        ),
      );
    }
    if (_scheduleRows.isEmpty) {
      showAppSnackBar(
        context,
        'En az bir zaman aralığı ekleyin',
        isError: true,
      );
      return;
    }
    final slots = <DayTimeSlot>[];
    for (final row in _scheduleRows) {
      final cap = int.tryParse(row.capacityController.text.trim());
      if (cap == null || cap < 1) {
        showAppSnackBar(context, 'Kapasite en az 1 olmalı', isError: true);
        return;
      }
      final sm = row.start.hour * 60 + row.start.minute;
      final em = row.end.hour * 60 + row.end.minute;
      if (em <= sm) {
        showAppSnackBar(
          context,
          'Bitiş saati başlangıçtan sonra olmalı',
          isError: true,
        );
        return;
      }
      slots.add(
        DayTimeSlot(
          weekday: row.weekday,
          startMinutes: sm,
          endMinutes: em,
          maxPeople: cap,
        ),
      );
    }
    final pct = _availability.round().clamp(0, 100);
    final band = availabilityBands[availabilityBandIndexForPercent(pct)];
    final rawMsg = _messageIndexInBand ?? 0;
    final msgIdx = rawMsg.clamp(0, band.suggestions.length - 1);

    setState(() => _saving = true);
    try {
      final repo = Get.find<ListingRepository>();
      final desc = _description.text.trim();
      if (widget.listingId == null) {
        await repo.createListing(
          farmerUid: uid,
          farmName: _farmName.text.trim(),
          city: _city.text.trim(),
          newImageLocalPaths: List<String>.from(_localImagePaths),
          pickingType: _picking,
          availabilityPercent: pct,
          availabilityMessageIndex: msgIdx,
          manualClosed: _manualClosed,
          description: desc.isEmpty ? null : desc,
          latitude: lat,
          longitude: lng,
          products: lines,
          schedule: slots,
        );
      } else {
        final ex = _existing!;
        final updated = FarmListing(
          id: ex.id,
          farmerUid: ex.farmerUid,
          farmName: _farmName.text.trim(),
          city: _city.text.trim(),
          imageUrls: List<String>.from(_existingImageUrls),
          pickingType: _picking,
          availabilityPercent: pct,
          availabilityMessageIndex: msgIdx,
          manualClosed: _manualClosed,
          description: desc.isEmpty ? null : desc,
          latitude: lat,
          longitude: lng,
          products: lines,
          schedule: slots,
          createdAt: ex.createdAt,
          updatedAt: ex.updatedAt,
          expiresAt: ex.expiresAt,
        );
        await repo.updateListing(
          listing: updated,
          newImageLocalPaths: List<String>.from(_localImagePaths),
        );
      }
      if (!mounted) return;
      showAppSnackBar(context, 'Kaydedildi');
      context.router.maybePop();
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Kayıt başarısız: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  FarmListing _buildMockListing() {
    final pct = _availability.round().clamp(0, 100);
    final band = availabilityBands[availabilityBandIndexForPercent(pct)];
    final msgIdx = (_messageIndexInBand ?? 0).clamp(
      0,
      band.suggestions.length - 1,
    );
    return FarmListing(
      id: widget.listingId ?? 'mock',
      farmerUid: 'mock_farmer',
      farmName: _farmName.text.isNotEmpty ? _farmName.text : 'Çiftlik Adı',
      city: _city.text.isNotEmpty ? _city.text : 'Şehir',
      imageUrls: _existingImageUrls,
      pickingType: _picking,
      availabilityPercent: pct,
      availabilityMessageIndex: msgIdx,
      manualClosed: _manualClosed,
      description: _description.text,
      latitude: _existing?.latitude ?? 0,
      longitude: _existing?.longitude ?? 0,
      products: _productRows.map((r) {
        final ore = parseNokToOre(r.priceController.text) ?? 0;
        return ListingProductLine(
          categoryId: r.categoryId,
          productId: r.productId,
          priceOre: ore,
          unit: r.unit,
        );
      }).toList(),
      schedule: _scheduleRows.map((s) {
        final cap = int.tryParse(s.capacityController.text.trim()) ?? 10;
        return DayTimeSlot(
          weekday: s.weekday,
          startMinutes: s.start.hour * 60 + s.start.minute,
          endMinutes: s.end.hour * 60 + s.end.minute,
          maxPeople: cap,
          specificDate: s.calendarAnchor,
        );
      }).toList(),
      createdAt: _existing?.createdAt ?? DateTime.now(),
      updatedAt: _existing?.updatedAt ?? DateTime.now(),
      expiresAt: _existing?.expiresAt ?? DateTime.now(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label, {
    String? hintText,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      helperText: helperText,
      labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
      helperStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2B8C5F), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBFBFB),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2B8C5F)),
        ),
      );
    }

    final bandSuggestions = _currentBandSuggestions;
    final selectedMsgIdx = (_messageIndexInBand ?? 0).clamp(
      0,
      bandSuggestions.length - 1,
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenWidth * 0.6;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: headerHeight,
            collapsedHeight: kToolbarHeight + 20,
            toolbarHeight: kToolbarHeight + 20,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF2B8C5F),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2B8C5F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF2B8C5F),
                          ),
                        )
                      : Text(
                          'Kaydet',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/4.png', fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Text(
                      widget.listingId == null ? 'Yeni ilan' : 'İlanı düzenle',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                Text(
                  'Canlı Önizleme',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2B8C5F),
                  ),
                ),
                Text(
                  'İlanınız müşterilere bu şekilde görünecek',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                ///////////////////////////// Card
                const SizedBox(height: 12),
                ListingCard(listing: _buildMockListing()),

                _buildSectionHeader('Görseller (isteğe bağlı)'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _existingImageUrls.length; i++)
                      _NetworkThumb(
                        url: _existingImageUrls[i],
                        onRemove: () => _removeExistingImage(i),
                      ),
                    for (var i = 0; i < _localImagePaths.length; i++)
                      _LocalThumb(
                        path: _localImagePaths[i],
                        onRemove: () => _removeLocalImage(i),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text('Ekle', style: GoogleFonts.inter()),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onPressed: _pickImages,
                    ),
                  ],
                ),

                _buildSectionHeader('Çiftlik Bilgileri'),
                TextField(
                  controller: _farmName,
                  readOnly: true,
                  enableInteractiveSelection: false,
                  decoration: _buildInputDecoration(
                    'Çiftlik adı',
                    helperText: 'Buradan değiştirilemez',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _city,
                  readOnly: true,
                  enableInteractiveSelection: false,
                  decoration: _buildInputDecoration(
                    'Şehir',
                    helperText: 'Buradan değiştirilemez',
                  ),
                ),

                _buildSectionHeader('Ürün'),
                for (var i = 0; i < _productRows.length; i++) ...[
                  _ProductRowEditor(
                    row: _productRows[i],
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                ],

                _buildSectionHeader('Toplama tipi'),
                SegmentedButton<PickingType>(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: PickingType.selfPicking,
                      label: Text('Kendi toplama'),
                    ),
                    ButtonSegment(
                      value: PickingType.prePicked,
                      label: Text('Toplanmış'),
                    ),
                  ],
                  selected: {_picking},
                  onSelectionChanged: (s) => setState(() => _picking = s.first),
                ),

                _buildSectionHeader(
                  'Kalan ürün (%) — ${_availability.round()}',
                ),
                Slider(
                  value: _availability,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: const Color(0xFF2B8C5F),
                  label: '${_availability.round()}%',
                  onChanged: _onAvailabilityChanged,
                ),
                Text(
                  'Müsaitlik mesajı (${availabilityBands[_bandIndex].minInclusive}–${availabilityBands[_bandIndex].maxInclusive}%)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedMsgIdx,
                  items: [
                    for (var i = 0; i < bandSuggestions.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(
                          bandSuggestions[i],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(),
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _messageIndexInBand = v),
                  decoration: _buildInputDecoration('Önerilen metin'),
                ),

                _buildSectionHeader('Görünürlük'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      'Manuel kapalı',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Açık saatlerde bile ilanı kapalı göster',
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                    activeColor: const Color(0xFF2B8C5F),
                    value: _manualClosed,
                    onChanged: (v) => setState(() => _manualClosed = v),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 6,
                  decoration: _buildInputDecoration(
                    'Açıklama (isteğe bağlı)',
                    hintText: 'İptal / no-show kuralları vb.',
                  ),
                ),

                _buildSectionHeader('Çalışma aralıkları'),
                for (var i = 0; i < _scheduleRows.length; i++) ...[
                  _ScheduleRowEditor(
                    row: _scheduleRows[i],
                    onRemove: () => _confirmRemoveScheduleRow(context, i),
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: _addScheduleRow,
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    'Zaman aralığı ekle',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2B8C5F),
                    side: const BorderSide(color: Color(0xFF2B8C5F)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkThumb extends StatelessWidget {
  const _NetworkThumb({required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return _ThumbFrame(
      onRemove: onRemove,
      child: Image.network(url, fit: BoxFit.cover),
    );
  }
}

class _LocalThumb extends StatelessWidget {
  const _LocalThumb({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return _ThumbFrame(
      onRemove: onRemove,
      child: FutureBuilder(
        future: XFile(path).readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        },
      ),
    );
  }
}

class _ThumbFrame extends StatelessWidget {
  const _ThumbFrame({required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(width: 88, height: 88, child: child),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductRowEditor extends StatelessWidget {
  const _ProductRowEditor({required this.row, required this.onChanged});

  final _ProductLineDraft row;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final catItems = products.keys
        .map(
          (k) => DropdownMenuItem<String>(
            value: k,
            child: Text(k, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList();
    final plist = products[row.categoryId];
    if (plist == null || plist.isEmpty) {
      return const SizedBox.shrink();
    }
    var pid = row.productId;
    if (!plist.containsKey(pid)) {
      pid = plist.keys.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        row.productId = pid;
        onChanged();
      });
    }
    final prodItems = plist.entries
        .map(
          (e) => DropdownMenuItem<String>(
            value: e.key,
            child: Text(e.value, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: row.categoryId,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: catItems,
              onChanged: (v) {
                if (v == null) return;
                row.categoryId = v;
                row.productId = products[v]!.keys.first;
                onChanged();
              },
            ),
            DropdownButtonFormField<String>(
              value: pid,
              decoration: const InputDecoration(labelText: 'Ürün'),
              items: prodItems,
              onChanged: (v) {
                if (v == null) return;
                row.productId = v;
                onChanged();
              },
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: row.priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Fiyat (NOK)',
                      hintText: 'Örn: 39,90',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<ListingPriceUnit>(
                    value: row.unit,
                    decoration: const InputDecoration(labelText: 'Birim'),
                    items: const [
                      DropdownMenuItem(
                        value: ListingPriceUnit.kg,
                        child: Text('1 kg'),
                      ),
                      DropdownMenuItem(
                        value: ListingPriceUnit.package,
                        child: Text('1 paket'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      row.unit = v;
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRowEditor extends StatelessWidget {
  const _ScheduleRowEditor({
    required this.row,
    required this.onRemove,
    required this.onChanged,
  });

  final _ScheduleDraft row;
  final Future<void> Function() onRemove;
  final VoidCallback onChanged;

  static DateTime _nextOccurrenceOfWeekday(int weekday, DateTime from) {
    var d = DateTime(from.year, from.month, from.day);
    for (var i = 0; i < 8; i++) {
      if (d.weekday == weekday) return d;
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  Future<void> _pickWeekdayFromCalendar(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = today.add(const Duration(days: 365 * 3));
    var initial =
        row.calendarAnchor ?? _nextOccurrenceOfWeekday(row.weekday, now);
    initial = DateTime(initial.year, initial.month, initial.day);
    if (initial.isBefore(today)) {
      initial = _nextOccurrenceOfWeekday(row.weekday, now);
    }
    if (initial.isAfter(lastDate)) {
      initial = lastDate;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: lastDate,
      helpText: 'Çalışma günü seçin',
    );
    if (picked == null || !context.mounted) return;
    final day = DateTime(picked.year, picked.month, picked.day);
    row.weekday = picked.weekday;
    row.calendarAnchor = day;
    onChanged();
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final initial = isStart ? row.start : row.end;
    final t = await showTimePicker(context: context, initialTime: initial);
    if (t == null) return;
    if (isStart) {
      row.start = t;
    } else {
      row.end = t;
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final anchor = row.calendarAnchor;
    final dayLabel = anchor != null
        ? '${_fmtPaddedDate(anchor)} · ${_weekdayTr(row.weekday)}'
        : _weekdayTr(row.weekday);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Gün',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    child: InkWell(
                      onTap: () => _pickWeekdayFromCalendar(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dayLabel,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              'Takvim',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onRemove(),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(context, true),
                    child: Text('Başlangıç ${_fmt(row.start)}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(context, false),
                    child: Text('Bitiş ${_fmt(row.end)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: row.capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bu aralıkta max. kişi',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static String _fmtPaddedDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  static String _weekdayTr(int w) {
    switch (w) {
      case DateTime.monday:
        return 'Pazartesi';
      case DateTime.tuesday:
        return 'Salı';
      case DateTime.wednesday:
        return 'Çarşamba';
      case DateTime.thursday:
        return 'Perşembe';
      case DateTime.friday:
        return 'Cuma';
      case DateTime.saturday:
        return 'Cumartesi';
      case DateTime.sunday:
        return 'Pazar';
      default:
        return '';
    }
  }
}
