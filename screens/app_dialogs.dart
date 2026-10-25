Import 'dart:async';
import 'package:flutter/material.dart';
import '../data/demo_data.dart';
import '../models/shop.dart';

class AppDialogs {
  static Future<void> showLocation(
    BuildContext context,
    String current,
    ValueChanged<String> onSelect, {
    required bool premium,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationSheet(
        current: current,
        onSelect: onSelect,
        premium: premium,
      ),
    );
  }

  static Future<bool> showClaimPin(BuildContext context, Shop shop, bool premium) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(context: context, builder: (context) => AlertDialog(backgroundColor: premium ? const Color(0xFF111111) : Colors.white, title: Text('डिस्काउंट क्लेम करें', style: TextStyle(color: premium ? Colors.white : const Color(0xFF17191E), fontWeight: FontWeight.w900)), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(shop.name, style: const TextStyle(color: Color(0xFFB38728), fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text('काउंटर पर उपलब्ध 4-अंकों का पिन दर्ज करें।\nडेमो में कोई भी 4 अंक स्वीकार होंगे।', style: TextStyle(color: premium ? Colors.white70 : Colors.black54, fontSize: 12, height: 1.4)), const SizedBox(height: 12), TextField(controller: controller, keyboardType: TextInputType.number, maxLength: 4, obscureText: true, autofocus: true, decoration: const InputDecoration(labelText: '4-अंकों का पिन', counterText: '', border: OutlineInputBorder()))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('रद्द करें')), FilledButton(onPressed: () { if (controller.text.length == 4) Navigator.pop(context, true); }, child: const Text('वेरीफ़ाई करें'))]));
    controller.dispose();
    return result ?? false;
  }

  static Future<void> showShopDetails(
    BuildContext context,
    Shop shop,
    bool premium, {
    ValueChanged<FeedPost>? onOpenPost,
  }) async {
    final posts = demoPosts.where((post) => post.shopId == shop.id).toList();
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: premium ? const Color(0xFF101010) : Colors.white,
        insetPadding: const EdgeInsets.all(22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '🏪 मर्चेंट स्टोर विवरण',
                      style: TextStyle(
                        color: premium ? Colors.white : const Color(0xFF17191E),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: premium ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  shop.image,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                shop.name,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: premium ? Colors.white : const Color(0xFF17191E),
                ),
              ),
              Text(
                '📂 ${shop.category}  •  ${shop.openToday ? 'आज खुला है' : 'आज बंद है'}',
                style: const TextStyle(
                  color: Color(0xFF168260),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _infoBox('📍 लोकेशन / पता', shop.address),
              const SizedBox(height: 8),
              _infoBox('💬 ऑफ़र', '${shop.offer}\n${shop.description}'),
              const SizedBox(height: 14),
              Text(
                '🎬 मर्चेंट पोस्ट्स / रील्स',
                style: TextStyle(
                  color: premium ? const Color(0xFFFFE7A3) : const Color(0xFF17191E),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.isEmpty ? 1 : posts.length.clamp(0, 3).toInt(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 7,
                  mainAxisSpacing: 7,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, index) {
                  final post = posts.isEmpty ? null : posts[index];
                  final openPost = onOpenPost;
                  return InkWell(
                    onTap: post == null || openPost == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            openPost(post);
                          },
                    borderRadius: BorderRadius.circular(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(post?.image ?? shop.image, fit: BoxFit.cover),
                          if (post?.isReel ?? false)
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('समझ आ गया (OK)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _infoBox(String title, String text) => Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF7F7F5), borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xFFE7E5DF))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFF17191E), fontWeight: FontWeight.w800, fontSize: 11)), const SizedBox(height: 5), Text(text, style: const TextStyle(color: Color(0xFF4D5157), fontSize: 12, height: 1.45))]));

  static ThemeData _sheetTheme(BuildContext context, bool premium) {
    final brightness = premium ? Brightness.dark : Brightness.light;
    final foreground = premium ? Colors.white : const Color(0xFF17191E);
    return Theme.of(context).copyWith(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD4AF37),
        brightness: brightness,
      ),
      listTileTheme: ListTileThemeData(
        textColor: foreground,
        iconColor: premium ? const Color(0xFFFFE7A3) : const Color(0xFF17191E),
      ),
    );
  }

  static Future<void> showHistory(
    BuildContext context,
    List<ClaimRecord> records,
    bool premium,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: premium ? const Color(0xFF101010) : Colors.white,
      builder: (context) => Theme(
        data: _sheetTheme(context, premium),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '📅 पूरी क्लेम हिस्ट्री',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: premium ? Colors.white : const Color(0xFF17191E),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8F1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    'कुल ${records.length} सफल डेमो क्लेम',
                    style: const TextStyle(
                      color: Color(0xFF168260),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: records.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(25),
                          child: Text(
                            'अभी कोई क्लेम नहीं है। किसी दुकान पर डेमो क्लेम करें।',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: records.reversed
                              .map(
                                (record) => ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFFFF1CE),
                                    child: Icon(Icons.check, color: Color(0xFF9B7010)),
                                  ),
                                  title: Text(record.shopName),
                                  subtitle: Text(
                                    '${record.offer}\n${record.date.toLocal().toString().substring(0, 16)}',
                                  ),
                                  isThreeLine: true,
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showSaved(
    BuildContext context,
    List<FeedPost> saved,
    bool premium,
    ValueChanged<FeedPost> onOpen,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: premium ? const Color(0xFF101010) : Colors.white,
      builder: (context) => Theme(
        data: _sheetTheme(context, premium),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '⭐ सेव्ड डील्स & लोकेशन',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: premium ? Colors.white : const Color(0xFF17191E),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Text(
                  '⚠️ सेव की गई डील्स केवल इस डेमो सेशन में रहती हैं।',
                  style: TextStyle(color: Color(0xFF94701D), fontSize: 11),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: saved.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'आपकी सेव्ड डील्स यहाँ दिखाई देंगी। पोस्ट में bookmark दबाएँ।',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: saved
                              .map(
                                (post) => ListTile(
                                  onTap: () {
                                    Navigator.pop(context);
                                    onOpen(post);
                                  },
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      post.image,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(post.shopName),
                                  subtitle: Text(
                                    post.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<String?> showAuth(BuildContext context, String currentName, bool premium) async {
    final name = TextEditingController(text: currentName);
    final result = await showDialog<String>(context: context, builder: (context) => AlertDialog(backgroundColor: premium ? const Color(0xFF101010) : Colors.white, title: Text('⭐ वेलकम तू Star Shops', style: TextStyle(color: premium ? Colors.white : const Color(0xFF17191E))), content: Column(mainAxisSize: MainAxisSize.min, children: [Text('नाम और मोबाइल जानकारी इस डेमो में केवल आपके डिवाइस की UI स्थिति है। कोई अकाउंट/सर्वर कनेक्शन नहीं।', style: TextStyle(fontSize: 12, color: premium ? Colors.white70 : Colors.black54)), const SizedBox(height: 12), TextField(controller: name, decoration: const InputDecoration(labelText: 'आपका नाम', border: OutlineInputBorder())), const SizedBox(height: 10), const TextField(keyboardType: TextInputType.phone, maxLength: 10, decoration: InputDecoration(labelText: 'मोबाइल नंबर (डेमो)', counterText: '', border: OutlineInputBorder()))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')), FilledButton(onPressed: () => Navigator.pop(context, name.text.trim().isEmpty ? currentName : name.text.trim()), child: const Text('सेव करें'))]));
    name.dispose();
    return result;
  }

  static Future<String?> showAvatar(BuildContext context, String current, bool premium) {
    final avatars = ['👤', '🙂', '😎', '🌟', '🧑‍🎨', '🛍️'];
    String selected = current;
    double zoom = 1;
    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: premium ? const Color(0xFF101010) : Colors.white,
          title: Text('📸 प्रोफाइल फोटो सेट करें', style: TextStyle(color: premium ? Colors.white : const Color(0xFF17191E), fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('फ्रेम में फोटो का डेमो चुनें और ज़ूम एडजस्ट करें।', style: TextStyle(color: premium ? Colors.white60 : Colors.black54, fontSize: 11)),
              const SizedBox(height: 14),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4AF37), width: 3), color: const Color(0xFFFFF2D0)),
                child: Center(child: Transform.scale(scale: zoom, child: Text(selected, style: const TextStyle(fontSize: 62)))),
              ),
              Slider(value: zoom, min: 0.5, max: 3, onChanged: (value) => setState(() => zoom = value)),
              Wrap(
                spacing: 10,
                children: avatars.map((avatar) {
                  return InkWell(
                    onTap: () => setState(() => selected = avatar),
                    child: CircleAvatar(
                      backgroundColor: selected == avatar ? const Color(0xFFFFE6A1) : const Color(0xFFF0F0F0),
                      child: Text(avatar, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
            FilledButton(onPressed: () => Navigator.pop(context, selected), child: const Text('✅ सेव करें')),
          ],
        ),
      ),
    );
  }

}

class _LocationSheet extends StatefulWidget {
  const _LocationSheet({
    required this.current,
    required this.onSelect,
    required this.premium,
  });

  final String current;
  final ValueChanged<String> onSelect;
  final bool premium;

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  final _controller = TextEditingController();
  Timer? _searchTimer;
  Timer? _dismissTimer;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _searchTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted) return;
      setState(() => _notFound = true);
      _dismissTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) Navigator.of(context).pop();
      });
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _select(String area) {
    widget.onSelect(area);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.premium;
    final foreground = dark ? Colors.white : const Color(0xFF17191E);
    final subtext = dark ? Colors.white60 : const Color(0xFF667085);
    final surface = dark ? const Color(0xFF101010) : Colors.white;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Material(
          color: surface,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFB38728)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'लोकेशन खोजें या बदलें',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: foreground,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: subtext),
                    ),
                  ],
                ),
                Text(
                  'वर्तमान क्षेत्र: ${widget.current}',
                  style: TextStyle(fontSize: 11, color: subtext),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  style: TextStyle(color: foreground),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) _select(value.trim());
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: dark ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA),
                    hintText: 'एरिया / लोकेशन लिखें',
                    hintStyle: TextStyle(color: subtext),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFB38728)),
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) {
                          _select(_controller.text.trim());
                        }
                      },
                      icon: const Icon(Icons.arrow_forward, color: Color(0xFFB38728)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: dark ? const Color(0xFF514221) : const Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (!_notFound)
                  Row(
                    children: [
                      const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFB38728),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'लोकेशन खोजी जा रही है… कृपया 7–8 सेकंड प्रतीक्षा करें।',
                          style: TextStyle(fontSize: 11, color: subtext),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF241D0E) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE1C46A)),
                    ),
                    child: const Text(
                      '8 सेकंड कोशिश के बाद भी लोकेशन नहीं मिली। यह सूचना 5 सेकंड में अपने आप बंद हो जाएगी।',
                      style: TextStyle(
                        color: Color(0xFF9B6410),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                Text(
                  'मैन्युअल एरिया चुनें',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: foreground),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: ['Connaught Place', 'Karol Bagh', 'Saket', 'Dwarka']
                      .map(
                        (area) => ActionChip(
                          label: Text(area),
                          onPressed: () => _select(area),
                          backgroundColor: dark ? const Color(0xFF211C0D) : const Color(0xFFFFF8E6),
                          side: const BorderSide(color: Color(0xFFE1C46A)),
                          labelStyle: const TextStyle(color: Color(0xFF8C6817), fontWeight: FontWeight.w700),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 7),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        _select(_controller.text.trim());
                      }
                    },
                    child: const Text('दर्ज किया गया एरिया लागू करें'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
