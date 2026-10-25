Import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/shop.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({
    super.key,
    required this.premium,
    required this.onOpenShop,
  });

  final bool premium;
  final ValueChanged<Shop> onOpenShop;

  @override
  Widget build(BuildContext context) {
    final foreground = premium ? Colors.white : const Color(0xFF17191E);
    final alerts = demoAlerts.where((alert) => premium || !alert.highDiscount).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      children: [
        Text(
          '⚡ लाइव मर्चेंट अलर्ट्स & ऑफर्स',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: foreground,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'आपके आसपास की डील्स • डेमो नोटिफिकेशन',
          style: TextStyle(
            fontSize: 10,
            color: premium ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 15),
        if (alerts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Text('कोई नया अलर्ट नहीं है।', textAlign: TextAlign.center),
          ),
        ...alerts.asMap().entries.map((entry) {
          final alert = entry.value;
          final shop = demoShops.firstWhere(
            (item) => item.id == alert.shopId,
            orElse: () => demoShops.first,
          );
          return Card(
            color: premium ? const Color(0xFF111111) : Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: premium
                    ? const Color(0xFF3E3420)
                    : const Color(0xFFE7E9EC),
              ),
            ),
            child: InkWell(
              onTap: () => onOpenShop(shop),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1CE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        entry.key == 2
                            ? Icons.video_library_outlined
                            : Icons.local_offer_outlined,
                        color: const Color(0xFF967018),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.message,
                            style: TextStyle(
                              fontSize: 12,
                              color: foreground,
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            alert.highDiscount
                                ? 'अभी • प्रीमियम ऑफर'
                                : 'आज • स्थानीय अपडेट',
                            style: TextStyle(
                              fontSize: 10,
                              color: premium ? Colors.white45 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFFB38728)),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: premium ? const Color(0xFF17140D) : const Color(0xFFFFF8E6),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFDFC36C)),
          ),
          child: const Row(
            children: [
              Icon(Icons.notifications_active_outlined, color: Color(0xFF9A751E)),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'यहाँ दिखाए गए अलर्ट केवल नमूना UI हैं; कोई पुश नोटिफिकेशन सेवा चालू नहीं है।',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.4,
                    color: Color(0xFF806117),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
