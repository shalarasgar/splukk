import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:splukk/core/constants/products.dart';
import 'package:splukk/core/l10n/locale_keys.dart';
import '../../../domain/listings_domain.dart';
import 'farmer_form_models.dart';

class ProductRowEditor extends StatelessWidget {
  const ProductRowEditor({super.key, required this.row, required this.onChanged});

  final ProductLineDraft row;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final catItems = products.keys
        .map(
          (k) => DropdownMenuItem<String>(
            value: k,
            child: Text(
              'categories.$k'.tr(context: context),
              overflow: TextOverflow.ellipsis,
            ),
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
            child: Text(
              'products.${e.key}'.tr(context: context),
              overflow: TextOverflow.ellipsis,
            ),
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
              decoration: InputDecoration(
                labelText: LocaleKeys.marketplace_categories.tr(
                  context: context,
                ),
              ),
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
              decoration: InputDecoration(
                labelText: LocaleKeys.farmer_listing_form_product.tr(
                  context: context,
                ),
              ),
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
                    decoration: InputDecoration(
                      labelText:
                          '${LocaleKeys.farmer_listing_form_price.tr(context: context)} (NOK)',
                      hintText: LocaleKeys.farmer_listing_form_price_hint.tr(
                        context: context,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<ListingPriceUnit>(
                    value: row.unit,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.farmer_listing_form_unit.tr(
                        context: context,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: ListingPriceUnit.kg,
                        child: Text(
                          LocaleKeys.farmer_listing_form_unit_kg.tr(
                            context: context,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ListingPriceUnit.package,
                        child: Text(
                          LocaleKeys.farmer_listing_form_unit_package.tr(
                            context: context,
                          ),
                        ),
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
