import 'package:flutter/material.dart';

import '../models/shop.dart';
import '../widgets/store_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.shops,
    required this.premium,
    required this.category,
    required this.onCategory,
    required this.search,
    required this.onSearch,
    required this.claimCounts,
    required this.onDetails,
    required this.onClaim,
  });

  final List<Shop> shops;
  final bool premium;
  final String category;
  final ValueChanged<String> onCategory;
  final String search;
  final ValueChanged<String> onSearch;
  final Map<String, int> claimCounts;
  final ValueChanged<Shop> onDetails;
  final ValueChanged<Shop> onClaim;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final TextEditingController _searchController;
  static const _baseCategories = ['ALL', 'OPEN TODAY', 'SALON', 'PARLOR'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.search);
  }

  @override
  void didUpdateWidget(covariant HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.search != _searchController.text) {
      _searchController.value = TextEditingValue(
        text: widget.search,
        selection: TextSelection.collapsed(offset: widget.search.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.search.toLowerCase().trim();
    final categories = widget.premium
        ? [..._baseCategories.take(2), 'HIGH DISCOUNT', ..._baseCategories.skip(2)]
        : _baseCategories;

    final filtered = widget.shops.where((shop) {
      final claimCount = widget.claimCounts[shop.id] ?? 0;
      final isClaimed = claimCount > 0;
      final matchesCategory = widget.category == 'ALL' ||
          (widget.category == 'OPEN TODAY' && shop.openToday) ||
          (widget.category == 'HIGH DISCOUNT' && shop.highDiscount) ||
          shop.category == widget.category;
      final matchesSearch = query.isEmpty ||
          '${shop.name} ${shop.address} ${shop.phone} ${shop.category} ${shop.offer} '
                  '${shop.highDiscount ? 'high' : ''} ${isClaimed ? 'claimed' : ''}'
              .toLowerCase()
              .contains(query);
      final unlocked = widget.premium || !shop.highDiscount;
      return matchesCategory && matchesSearch && unlocked;
    }).toList();

    final background = widget.premium
        ? const Color(0xFF101010)
        : const Color(0xFFF8F9FA);
    final textColor = widget.premium ? Colors.white : const Color(0xFF1A1D23);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        TextField(
          controller: _searchController,
          onChanged: widget.onSearch,
          decoration: InputDecoration(
            hintText: "दुकान, एरिया, फोन, 'high' या 'claimed' खोजें...",
            hintStyle: TextStyle(
              fontSize: 12,
              color: widget.premium ? Colors.white54 : Colors.black45,
            ),
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: widget.premium ? const Color(0xFF171717) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: widget.premium
                    ? const Color(0xFF514221)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: widget.premium
                    ? const Color(0xFF514221)
                    : const Color(0xFFE5E7EB),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final label = categories[index];
              final selected = widget.category == label;
              final isHigh = label == 'HIGH DISCOUNT';
              final isOpen = label == 'OPEN TODAY';
              final selectedTextColor = isHigh && selected
                  ? Colors.black
                  : (widget.premium && selected ? Colors.black : Colors.white);
              final unselectedTextColor = widget.premium
                  ? const Color(0xFFE2C870)
                  : isOpen
                      ? const Color(0xFF087451)
                      : isHigh
                          ? const Color(0xFF9B6410)
                          : const Color(0xFF475467);

              return ChoiceChip(
                label: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 9.5,
                    color: selected ? selectedTextColor : unselectedTextColor,
                  ),
                ),
                selected: selected,
                onSelected: (_) => widget.onCategory(label),
                showCheckmark: false,
                backgroundColor: widget.premium
                    ? const Color(0xFF171717)
                    : isOpen
                        ? const Color(0xFFEAF8F1)
                        : isHigh
                            ? const Color(0xFFFFF3D6)
                            : Colors.white,
                selectedColor: isHigh
                    ? const Color(0xFFB88726)
                    : isOpen
                        ? const Color(0xFF168260)
                        : widget.premium
                            ? const Color(0xFFE8C85B)
                            : const Color(0xFF17191E),
                side: BorderSide(
                  color: selected
                      ? Colors.transparent
                      : widget.premium
                          ? const Color(0xFF574824)
                          : const Color(0xFFE5E7EB),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        if (widget.category == 'HIGH DISCOUNT' && widget.premium)
          Container(
            padding: const EdgeInsets.all(13),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF231C0B), Color(0xFF101010)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFB88726)),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, color: Color(0xFFFFE7A3)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'PREMIUM DEALS  •  गोल्ड में चुनी हुई बड़ी बचत',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              'इस खोज में कोई दुकान नहीं मिली।',
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
          ),
        ...filtered.map(
          (shop) => StoreCard(
            shop: shop,
            premium: widget.premium,
            claimCount: widget.claimCounts[shop.id] ?? 0,
            onDetails: () => widget.onDetails(shop),
            onClaim: () => widget.onClaim(shop),
          ),
        ),
        const SizedBox(height: 4),
        if (filtered.isNotEmpty)
          Text(
            'डेमो कंटेंट • ${filtered.length} दुकानें',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: widget.premium ? Colors.white38 : Colors.black38,
            ),
          ),
        Container(height: 1, color: background.withOpacity(0)),
      ],
    );
  }
}
