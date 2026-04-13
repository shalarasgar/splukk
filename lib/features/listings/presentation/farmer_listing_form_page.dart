import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/app_messages.dart';
import '../../../core/router/app_router.gr.dart';
import '../../../core/constants/availability_presets.dart';
import '../../../core/constants/products.dart';
import '../../../core/utils/nok_money.dart';
import '../../auth/domain/auth_domain.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../domain/listings_domain.dart';

@RoutePage()
class FarmerListingFormPage extends StatefulWidget {
  const FarmerListingFormPage({
    super.key,
    this.listingId,
  });

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
      _scheduleRows.add(
        _ScheduleDraft(
          weekday: DateTime.monday,
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
          priceController:
              TextEditingController(text: formatOreAsNokKr(p.priceOre)),
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
          end: TimeOfDay(
            hour: s.endMinutes ~/ 60,
            minute: s.endMinutes % 60,
          ),
          capacityController:
              TextEditingController(text: s.maxPeople.toString()),
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

  int get _bandIndex =>
      availabilityBandIndexForPercent(_availability.round());

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
      showAppSnackBar(context, 'En az bir zaman aralığı ekleyin', isError: true);
      return;
    }
    final slots = <DayTimeSlot>[];
    for (final row in _scheduleRows) {
      final cap = int.tryParse(row.capacityController.text.trim());
      if (cap == null || cap < 1) {
        showAppSnackBar(
          context,
          'Kapasite en az 1 olmalı',
          isError: true,
        );
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
    final msgIdx =
        rawMsg.clamp(0, band.suggestions.length - 1);

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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bandSuggestions = _currentBandSuggestions;
    final selectedMsgIdx = (_messageIndexInBand ?? 0)
        .clamp(0, bandSuggestions.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listingId == null ? 'Yeni ilan' : 'İlanı düzenle'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kaydet'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Görseller (isteğe bağlı)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
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
                label: const Text('Ekle'),
                onPressed: _pickImages,
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _farmName,
            readOnly: true,
            enableInteractiveSelection: false,
            decoration: const InputDecoration(
              labelText: 'Çiftlik adı',
              helperText: 'Buradan değiştirilemez',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _city,
            readOnly: true,
            enableInteractiveSelection: false,
            decoration: const InputDecoration(
              labelText: 'Şehir',
              helperText: 'Buradan değiştirilemez',
            ),
          ),
          const SizedBox(height: 24),
          Text('Ürün', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (var i = 0; i < _productRows.length; i++) ...[
            _ProductRowEditor(
              row: _productRows[i],
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 24),
          Text('Toplama tipi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<PickingType>(
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
          const SizedBox(height: 24),
          Text(
            'Kalan ürün (%) — ${_availability.round()}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _availability,
            min: 0,
            max: 100,
            divisions: 100,
            label: '${_availability.round()}%',
            onChanged: _onAvailabilityChanged,
          ),
          Text(
            'Müsaitlik mesajı (${availabilityBands[_bandIndex].minInclusive}–${availabilityBands[_bandIndex].maxInclusive}%)',
            style: Theme.of(context).textTheme.labelLarge,
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
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _messageIndexInBand = v),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Önerilen metin',
            ),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Manuel kapalı'),
            subtitle: const Text('Açık saatlerde bile ilanı kapalı göster'),
            value: _manualClosed,
            onChanged: (v) => setState(() => _manualClosed = v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _description,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Açıklama (isteğe bağlı)',
              hintText: 'İptal / no-show kuralları vb.',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          Text('Çalışma aralıkları',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
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
            label: const Text('Zaman aralığı ekle'),
          ),
          const SizedBox(height: 32),
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
  const _ProductRowEditor({
    required this.row,
    required this.onChanged,
  });

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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
    var initial = row.calendarAnchor ??
        _nextOccurrenceOfWeekday(row.weekday, now);
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
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
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
                    child: Text(
                      'Başlangıç ${_fmt(row.start)}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(context, false),
                    child: Text(
                      'Bitiş ${_fmt(row.end)}',
                    ),
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
