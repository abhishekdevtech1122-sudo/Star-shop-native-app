import 'package:flutter/material.dart';
import 'data/demo_data.dart';
import 'models/shop.dart';
import 'screens/alerts_tab.dart';
import 'screens/app_dialogs.dart';
import 'screens/home_tab.dart';
import 'screens/posts_tab.dart';
import 'screens/profile_tab.dart';

void main() => runApp(const StarShopApp());

class StarShopApp extends StatelessWidget {
  const StarShopApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Star Shops', debugShowCheckedModeBanner: false, theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4AF37), brightness: Brightness.light), scaffoldBackgroundColor: const Color(0xFFF8F9FA), fontFamily: 'Roboto'), home: const AppShell());
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  bool _premium = false;
  String _location = 'नई दिल्ली';
  String _category = 'ALL';
  String _search = '';
  String _name = 'Star Shopper';
  String _avatar = '👤';
  int _footprints = 645;
  final Map<String, int> _claimCounts = {};
  final List<ClaimRecord> _claims = [];
  final Set<String> _savedIds = {};
  int _refreshCount = 0;
  int _unreadAlerts = demoAlerts.where((alert) => !alert.highDiscount).length;

  List<FeedPost> get _savedPosts => demoPosts.where((post) => _savedIds.contains(post.shopId)).toList();

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    setState(() => _refreshCount++);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('डेमो स्क्रीन रीफ़्रेश हुई • #$_refreshCount'), duration: const Duration(milliseconds: 900)));
  }

  void _selectTab(int index) {
    setState(() {
      _tab = index;
      if (index == 2) _unreadAlerts = 0;
    });
  }

  void _addDemoSteps() {
    final wasUnlocked = _premium;
    setState(() {
      _footprints = (_footprints + 250).clamp(0, 2000).toInt();
      if (_footprints >= 2000) {
        _premium = true;
        if (!wasUnlocked) {
          _unreadAlerts = _tab == 2
              ? 0
              : demoAlerts.where((alert) => alert.highDiscount).length;
        }
      }
    });
    if (!wasUnlocked && _premium) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF101010),
          title: const Text('★ PREMIUM ZONE UNLOCKED', style: TextStyle(color: Color(0xFFFFE7A3), fontWeight: FontWeight.w900)),
          content: const Text('2,000 कदम पूरे हुए। अब गोल्ड हाई-डिस्काउंट UI खुल गया है।', style: TextStyle(color: Colors.white70)),
          actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('देखें'))],
        ),
      );
    }
  }

  Future<void> _openLocation() async => AppDialogs.showLocation(context, _location, (value) { setState(() => _location = value); }, premium: _premium);

  Future<void> _openDetails(Shop shop) => AppDialogs.showShopDetails(context, shop, _premium, onOpenPost: _viewPost);

  Future<void> _claim(Shop shop) async {
    if ((_claimCounts[shop.id] ?? 0) >= 2) return;
    final verified = await AppDialogs.showClaimPin(context, shop, _premium);
    if (!verified || !mounted) return;
    setState(() {
      _claimCounts[shop.id] = (_claimCounts[shop.id] ?? 0) + 1;
      _claims.add(ClaimRecord(shopName: shop.name, offer: shop.offer, date: DateTime.now()));
    });
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _premium ? const Color(0xFF101010) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37)),
        ),
        title: Text(
          '🎉 सफलता!',
          style: TextStyle(
            color: _premium ? const Color(0xFFFFE7A3) : const Color(0xFF17191E),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          '${shop.offer}\n\nऑफर इस UI demo में क्लेम हुआ। कोई merchant/server verification नहीं हुआ।',
          style: TextStyle(color: _premium ? Colors.white70 : Colors.black54),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('ठीक है (OK)'),
          ),
        ],
      ),
    );
  }

  Future<void> _showHistory() => AppDialogs.showHistory(context, _claims, _premium);
  Future<void> _showSaved() => AppDialogs.showSaved(context, _savedPosts, _premium, (post) => _viewPost(post));

  Future<void> _editProfile() async {
    final result = await AppDialogs.showAuth(context, _name, _premium);
    if (result != null && mounted) setState(() => _name = result);
  }

  Future<void> _editAvatar() async {
    final result = await AppDialogs.showAvatar(context, _avatar, _premium);
    if (result != null && mounted) setState(() => _avatar = result);
  }

  void _savePost(FeedPost post) {
    setState(() { if (!_savedIds.add(post.shopId)) _savedIds.remove(post.shopId); });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_savedIds.contains(post.shopId) ? '⭐ डील सेव की गई' : 'सेव्ड डील हटाई गई'), duration: const Duration(seconds: 1)));
  }

  Future<void> _viewPost(FeedPost post) => showDialog<void>(context: context, builder: (context) => Dialog(backgroundColor: Colors.black, insetPadding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [Align(alignment: Alignment.centerRight, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white))), ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(post.image, fit: BoxFit.contain)), Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('📝 ${post.shopName}', style: const TextStyle(color: Color(0xFFFFE7A3), fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(post.caption, style: const TextStyle(color: Colors.white, fontSize: 13)), const SizedBox(height: 8), Row(children: [const Icon(Icons.music_note, color: Color(0xFFFFE7A3), size: 17), const SizedBox(width: 5), const Text('संगीत टॉगल UI • कोई ऑडियो प्लेबैक नहीं', style: TextStyle(color: Colors.white70, fontSize: 10))])]))])));

  Future<void> _postActions(FeedPost post) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: _premium ? const Color(0xFF101010) : Colors.white,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
            brightness: _premium ? Brightness.dark : Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD4AF37),
              brightness: _premium ? Brightness.dark : Brightness.light,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '⚡ रील क्विक एक्शंस',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: _premium ? const Color(0xFFFFE7A3) : const Color(0xFF17191E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.favorite_border, color: Colors.red),
                    title: const Text('❤️ लाइक करें'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('डेमो लाइक जोड़ा गया')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark_border, color: Color(0xFFB38728)),
                    title: const Text('⭐ डील / रील सेव करें'),
                    onTap: () {
                      Navigator.pop(context);
                      _savePost(post);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text('↗ शेयर करें'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('शेयर UI demo — कोई बाहरी शेयर सर्विस नहीं')),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('रद्द करें'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final dark = _premium;
    final bg = dark ? const Color(0xFF050505) : const Color(0xFFF8F9FA);
    final header = dark ? const Color(0xFF121212) : Colors.white;
    final fg = dark ? const Color(0xFFFFE7A3) : const Color(0xFF181A1F);
    final screens = <Widget>[
      HomeTab(shops: demoShops, premium: _premium, category: _category, onCategory: (value) => setState(() => _category = value), search: _search, onSearch: (value) => setState(() => _search = value), claimCounts: _claimCounts, onDetails: _openDetails, onClaim: _claim),
      PostsTab(premium: _premium, savedIds: _savedIds, onSave: _savePost, onView: _viewPost, onActions: _postActions),
      AlertsTab(premium: _premium, onOpenShop: _openDetails),
      ProfileTab(premium: _premium, name: _name, avatar: _avatar, footprints: _footprints, claims: _claims, onName: _editProfile, onHistory: _showHistory, onSaved: _showSaved, onPhoto: _editAvatar, onAuth: _editProfile, onSteps: _addDemoSteps),
    ];
    return Scaffold(backgroundColor: bg, body: SafeArea(child: Column(children: [
      Container(padding: const EdgeInsets.fromLTRB(16, 11, 14, 11), decoration: BoxDecoration(color: header, border: Border(bottom: BorderSide(color: dark ? Colors.white12 : const Color(0xFFE5E7EB)))), child: Row(children: [RichText(text: TextSpan(style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2), children: const [TextSpan(text: '★ ', style: TextStyle(color: Color(0xFFD4AF37))), TextSpan(text: 'STAR SHOPS')])), const Spacer(), InkWell(onTap: _openLocation, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: dark ? const Color(0xFF211C0D) : const Color(0xFFFFF8E6), border: Border.all(color: dark ? const Color(0xFF705921) : const Color(0xFFF0D98F)), borderRadius: BorderRadius.circular(22)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on, size: 15, color: Color(0xFFB38728)), const SizedBox(width: 4), ConstrainedBox(constraints: const BoxConstraints(maxWidth: 145), child: Text(_location, overflow: TextOverflow.ellipsis, style: TextStyle(color: dark ? const Color(0xFFFFE7A3) : const Color(0xFF815E13), fontSize: 11, fontWeight: FontWeight.w800))), const Icon(Icons.expand_more, size: 16, color: Color(0xFFB38728))])))])),
      Expanded(child: RefreshIndicator(color: const Color(0xFFB38728), onRefresh: _refresh, child: IndexedStack(index: _tab, children: screens))),
    ])), bottomNavigationBar: Container(decoration: BoxDecoration(color: header, border: Border(top: BorderSide(color: dark ? Colors.white24 : const Color(0xFFE3E5E8))), boxShadow: [BoxShadow(color: Colors.black.withOpacity(dark ? 0.22 : 0.05), blurRadius: 14, offset: const Offset(0, -3))]), child: SafeArea(top: false, child: NavigationBar(height: 65, backgroundColor: header, surfaceTintColor: Colors.transparent, selectedIndex: _tab, onDestinationSelected: _selectTab, indicatorColor: dark ? const Color(0xFF4A3B18) : const Color(0xFFFFF1C8), destinations: [const NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'दुकानें'), const NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'पोस्ट्स'), NavigationDestination(icon: _AlertIcon(count: _unreadAlerts), selectedIcon: _AlertIcon(count: _unreadAlerts, active: true), label: 'अलर्ट्स'), const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'प्रोफ़ाइल')]))));
  }
}

class _AlertIcon extends StatelessWidget {
  const _AlertIcon({required this.count, this.active = false});
  final int count;
  final bool active;
  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [Icon(active ? Icons.notifications : Icons.notifications_none), if (count > 0) Positioned(right: -9, top: -7, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: const BoxDecoration(color: Color(0xFFB38728), shape: BoxShape.circle), child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900))))]);
}
