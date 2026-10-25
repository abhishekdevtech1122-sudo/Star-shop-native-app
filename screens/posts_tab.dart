Import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/shop.dart';

class PostsTab extends StatefulWidget {
  const PostsTab({
    super.key,
    required this.premium,
    required this.savedIds,
    required this.onSave,
    required this.onView,
    required this.onActions,
  });

  final bool premium;
  final Set<String> savedIds;
  final ValueChanged<FeedPost> onSave;
  final ValueChanged<FeedPost> onView;
  final ValueChanged<FeedPost> onActions;

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  final Set<String> _liked = {};
  bool _musicOn = true;

  @override
  Widget build(BuildContext context) {
    final dark = widget.premium;
    final foreground = dark ? Colors.white : const Color(0xFF17191E);
    final visiblePosts = demoPosts.where((post) {
      final shop = demoShops.firstWhere(
        (item) => item.id == post.shopId,
        orElse: () => demoShops.first,
      );
      return dark || !shop.highDiscount;
    }).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '📰 मर्चेंट फीड',
                style: TextStyle(
                  color: foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _musicOn = !_musicOn),
              icon: Icon(_musicOn ? Icons.music_note : Icons.music_off, size: 17),
              label: Text(_musicOn ? 'संगीत चालू' : 'संगीत बंद'),
              style: TextButton.styleFrom(
                foregroundColor:
                    dark ? const Color(0xFFE8C85B) : const Color(0xFF704F0D),
              ),
            ),
          ],
        ),
        Text(
          'स्थानीय डेमो पोस्ट्स • कोई मीडिया सर्विस कनेक्ट नहीं है',
          style: TextStyle(
            color: dark ? Colors.white54 : Colors.black45,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 12),
        if (visiblePosts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              'अभी कोई पोस्ट उपलब्ध नहीं है।',
              textAlign: TextAlign.center,
              style: TextStyle(color: foreground),
            ),
          ),
        ...visiblePosts.map((post) {
          final liked = _liked.contains(post.shopId);
          final saved = widget.savedIds.contains(post.shopId);
          return Card(
            color: dark ? const Color(0xFF111111) : Colors.white,
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: dark
                    ? const Color(0xFF3C3321)
                    : const Color(0xFFE8E9EC),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  dense: true,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF1CC),
                    child: Icon(Icons.storefront, color: Color(0xFF9B7017), size: 20),
                  ),
                  title: Text(
                    post.shopName,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    'स्थानीय मर्चेंट • आज',
                    style: TextStyle(
                      color: dark ? Colors.white54 : Colors.black45,
                      fontSize: 10,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => widget.onActions(post),
                    icon: Icon(Icons.more_horiz, color: foreground),
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onView(post),
                  onLongPress: () => widget.onActions(post),
                  child: AspectRatio(
                    aspectRatio: 1.08,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(post.image, fit: BoxFit.cover),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0x77000000)],
                            ),
                          ),
                        ),
                        if (post.isReel)
                          const Positioned(
                            right: 12,
                            top: 12,
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 14,
                          child: Text(
                            post.caption,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                            ),
                          ),
                        ),
                        if (!_musicOn)
                          const Positioned(
                            left: 11,
                            top: 11,
                            child: Icon(Icons.volume_off, color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 5),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'लाइक',
                        onPressed: () => setState(() {
                          if (liked) {
                            _liked.remove(post.shopId);
                          } else {
                            _liked.add(post.shopId);
                          }
                        }),
                        icon: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? Colors.red : foreground,
                        ),
                      ),
                      IconButton(
                        tooltip: 'डील सेव करें',
                        onPressed: () => widget.onSave(post),
                        icon: Icon(
                          saved ? Icons.bookmark : Icons.bookmark_border,
                          color: saved ? const Color(0xFFC59A2C) : foreground,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => widget.onView(post),
                        icon: const Icon(Icons.open_in_full, size: 15),
                        label: const Text('देखें'),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'और विकल्प',
                        onPressed: () => widget.onActions(post),
                        icon: Icon(
                          Icons.ios_share,
                          color: dark ? const Color(0xFFE8C85B) : foreground,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'अभी के लिए इतना ही ✨',
            style: TextStyle(
              color: dark ? Colors.white38 : Colors.black38,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
