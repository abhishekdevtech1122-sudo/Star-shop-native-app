Import 'package:flutter/material.dart';
import '../models/shop.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.premium, required this.name, required this.avatar, required this.footprints, required this.claims, required this.onName, required this.onHistory, required this.onSaved, required this.onPhoto, required this.onAuth, required this.onSteps});
  final bool premium;
  final String name;
  final String avatar;
  final int footprints;
  final List<ClaimRecord> claims;
  final VoidCallback onName;
  final VoidCallback onHistory;
  final VoidCallback onSaved;
  final VoidCallback onPhoto;
  final VoidCallback onAuth;
  final VoidCallback onSteps;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _display = '0';
  String _expression = '';

  void _tap(String key) {
    setState(() {
      if (key == 'C') {
        _display = '0';
        _expression = '';
      } else if (key == '⌫') {
        if (_display != '0' && _display != 'Error') {
          _display = _display.length > 1
              ? _display.substring(0, _display.length - 1)
              : '0';
        } else if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _display = '0';
        } else {
          _display = '0';
        }
      } else if (key == '%') {
        final value = double.tryParse(_display);
        if (value != null) _display = _formatNumber(value / 100);
      } else if (key == '=') {
        _calculate();
      } else if ('+-×÷'.contains(key)) {
        if (_expression.isEmpty) {
          _expression = '$_display$key';
        } else if ('+-×÷'.contains(_expression[_expression.length - 1])) {
          _expression = '${_expression.substring(0, _expression.length - 1)}$key';
        } else {
          _expression = '$_expression$_display$key';
        }
        _display = '0';
      } else if (key == '.') {
        if (!_display.contains('.')) {
          _display = _display == 'Error' ? '0.' : '$_display.';
        }
      } else {
        if (_display == 'Error') {
          _display = key;
        } else {
          _display = _display == '0' ? key : '$_display$key';
        }
      }
    });
  }

  void _calculate() {
    final source = '$_expression$_display'.replaceAll('×', '*').replaceAll('÷', '/');
    var index = 0;

    void skipSpaces() {
      while (index < source.length && source[index].trim().isEmpty) {
        index++;
      }
    }

    double parseFactor() {
      skipSpaces();
      if (index < source.length && (source[index] == '+' || source[index] == '-')) {
        final sign = source[index++];
        final value = parseFactor();
        return sign == '-' ? -value : value;
      }
      final start = index;
      while (index < source.length &&
          (RegExp(r'[0-9.]').hasMatch(source[index]))) {
        index++;
      }
      if (start == index) throw const FormatException('Number expected');
      return double.parse(source.substring(start, index));
    }

    double parseTerm() {
      var value = parseFactor();
      while (true) {
        skipSpaces();
        if (index >= source.length || (source[index] != '*' && source[index] != '/')) {
          return value;
        }
        final operator = source[index++];
        final next = parseFactor();
        if (operator == '/' && next == 0) throw const FormatException('Division by zero');
        value = operator == '*' ? value * next : value / next;
      }
    }

    double parseExpression() {
      var value = parseTerm();
      while (true) {
        skipSpaces();
        if (index >= source.length || (source[index] != '+' && source[index] != '-')) {
          return value;
        }
        final operator = source[index++];
        final next = parseTerm();
        value = operator == '+' ? value + next : value - next;
      }
    }

    try {
      final result = parseExpression();
      skipSpaces();
      if (index != source.length || !result.isFinite) {
        throw const FormatException('Invalid expression');
      }
      _display = _formatNumber(result);
      _expression = '';
    } catch (_) {
      _display = 'Error';
      _expression = '';
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.premium;
    final card = dark ? const Color(0xFF101010) : Colors.white;
    final fg = dark ? Colors.white : const Color(0xFF17191E);
    final double progress = (widget.footprints / 2000).clamp(0.0, 1.0).toDouble();
    return ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(14, 14, 14, 24), children: [
      Card(color: card, elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: dark ? const Color(0xFF42371C) : const Color(0xFFE7E9EC))), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Align(alignment: Alignment.topRight, child: IconButton(onPressed: widget.onSaved, tooltip: 'सेव्ड डील्स', icon: Icon(Icons.menu_rounded, color: fg))),
        InkWell(onTap: widget.onPhoto, borderRadius: BorderRadius.circular(60), child: Stack(children: [CircleAvatar(radius: 39, backgroundColor: const Color(0xFFFFF1CE), child: Text(widget.avatar, style: const TextStyle(fontSize: 32))), Positioned(right: 0, bottom: 0, child: CircleAvatar(radius: 13, backgroundColor: const Color(0xFFC59A2C), child: const Icon(Icons.photo_camera, size: 14, color: Colors.white)))])),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [Flexible(child: Text(widget.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: fg), overflow: TextOverflow.ellipsis)), IconButton(onPressed: widget.onName, icon: const Icon(Icons.edit, size: 17, color: Color(0xFFB38728)))]),
        Text('STAR SHOPS MEMBER  •  LOCAL DEMO', style: TextStyle(color: dark ? const Color(0xFFE0C361) : const Color(0xFF987219), fontSize: 9, letterSpacing: 0.7, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Row(children: [Expanded(child: _walletBox('🏆  ${widget.claims.length} कार्ड्स', 'सफल क्लेम कार्ड्स', const Color(0xFF14815C), card, fg, widget.onHistory)), const SizedBox(width: 10), Expanded(child: _walletBox('👣  ${widget.footprints}', 'टोटल फुटप्रिंट', const Color(0xFFB38728), card, fg, widget.onSteps))]),
        const SizedBox(height: 15),
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: dark ? const Color(0xFF17140D) : const Color(0xFFFFF8E6), borderRadius: BorderRadius.circular(12), border: Border.all(color: dark ? const Color(0xFF5A4720) : const Color(0xFFF0D992))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.directions_walk, color: Color(0xFFB38728), size: 18), const SizedBox(width: 6), Expanded(child: Text('स्टेप फुटप्रिंट • 2,000 कदम लक्ष्य', style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800))), Text('${(progress * 100).round()}%', style: const TextStyle(color: Color(0xFF9A7117), fontSize: 11, fontWeight: FontWeight.w900))]), const SizedBox(height: 9), LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: dark ? Colors.white12 : Colors.black12, color: const Color(0xFFD4AF37)), const SizedBox(height: 9), Text('${widget.footprints} / 2,000 कदम • अधिक कदम से हाई-डिस्काउंट UI अनलॉक करें', style: TextStyle(color: dark ? Colors.white60 : Colors.black54, fontSize: 10)), Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: widget.onSteps, icon: const Icon(Icons.add, size: 15), label: const Text('डेमो कदम जोड़ें')))])),
      ]))),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: Text('स्मार्ट बचत कैलकुलेटर', style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w900))), const Icon(Icons.calculate_outlined, color: Color(0xFFB38728))]),
      const SizedBox(height: 9),
      Card(color: dark ? const Color(0xFF101010) : const Color(0xFF20232A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), decoration: BoxDecoration(color: dark ? const Color(0xFF171717) : const Color(0xFF313640), borderRadius: BorderRadius.circular(11)), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_expression, style: const TextStyle(color: Colors.white54, fontSize: 12)), Text(_display, style: const TextStyle(color: Color(0xFFFFE7A3), fontSize: 27, fontWeight: FontWeight.w800))])), const SizedBox(height: 9), GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 4, mainAxisSpacing: 7, crossAxisSpacing: 7, childAspectRatio: 1.55, children: ['C','⌫','%','÷','7','8','9','×','4','5','6','-','1','2','3','+','0','00','.','='].map((key) => _calcButton(key)).toList())]))),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: widget.onAuth, icon: const Icon(Icons.person_outline), label: const Text('नाम / प्रोफ़ाइल जानकारी अपडेट करें'), style: OutlinedButton.styleFrom(foregroundColor: dark ? const Color(0xFFE8C85B) : const Color(0xFF30343A), side: BorderSide(color: dark ? const Color(0xFF5B4821) : const Color(0xFFD9DCE1)), padding: const EdgeInsets.symmetric(vertical: 12))),
      const SizedBox(height: 7),
      Center(child: Text('STAR SHOPS • UI-ONLY DEMO', style: TextStyle(color: dark ? Colors.white30 : Colors.black38, fontSize: 9, letterSpacing: 1))),
    ]);
  }

  Widget _walletBox(String title, String subtitle, Color accent, Color bg, Color fg, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(13), child: Container(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13), border: Border.all(color: accent.withOpacity(0.25))), child: Column(children: [Text(title, style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w900), textAlign: TextAlign.center), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: fg.withOpacity(0.65), fontSize: 9), textAlign: TextAlign.center)])));

  Widget _calcButton(String key) { final operator = '+-×÷%'.contains(key) || key == '=' || key == 'C' || key == '⌫'; final color = key == '=' ? const Color(0xFFD4AF37) : key == 'C' ? const Color(0xFF8C5527) : operator ? const Color(0xFF414650) : const Color(0xFF30343C); return Material(color: color, borderRadius: BorderRadius.circular(10), child: InkWell(onTap: () => _tap(key), borderRadius: BorderRadius.circular(10), child: Center(child: Text(key, style: TextStyle(color: key == '=' ? Colors.black : Colors.white, fontWeight: FontWeight.w800, fontSize: 16))))); }
}
