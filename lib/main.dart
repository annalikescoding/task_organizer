import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const TaskFace());

// THEME CONSTANTS
class AppColors {
  static const Color background = Color(0xFF0F0E17);
  static const Color neonOrange = Color(0xFFFF8906);
  static const Color synthPink = Color(0xFFE53170);
  static const Color surface = Color(0xFF2E2F3E);
  static const Color textPrimary = Color(0xFFFFFFFE);
  static const Color textMuted = Color(0xFFA7A9BE);
}

// MODELS
class Task {
  String id;
  String title;
  int duration;
  String energy;
  bool completed;
  Task({required this.id, required this.title, required this.duration, required this.energy, this.completed = false});
}

enum ItemCategory { aura, eyewear, headwear }

class ShopItem {
  final String id;
  final String name;
  final String emoji;
  final int price;
  final ItemCategory category;
  bool unlocked;
  ShopItem({required this.id, required this.name, required this.emoji, required this.price, required this.category, this.unlocked = false});
}

// ROOT APP
class TaskFace extends StatelessWidget {
  const TaskFace({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TASKFACE',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(primary: AppColors.neonOrange, secondary: AppColors.synthPink, surface: AppColors.surface),
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [
    Task(id: 't1', title: 'Read Bible', duration: 15, energy: 'Low'),
    Task(id: 't2', title: 'Morning Cardio Session', duration: 45, energy: 'High'),
    Task(id: 't3', title: 'Clean Workspace', duration: 30, energy: 'Medium'),
    Task(id: 't4', title: 'Deep Work: Flutter Project', duration: 90, energy: 'High'),
    Task(id: 't5', title: 'Meditate', duration: 10, energy: 'Low'),
    Task(id: 't6', title: 'Grocery Run', duration: 60, energy: 'Medium'),
    Task(id: 't7', title: 'Stretch Routine', duration: 5, energy: 'Low'),
    Task(id: 't8', title: 'Study Session', duration: 60, energy: 'High'),
  ];
  double _timePool = 30;
  String _selectedEnergy = 'Medium';
  final TextEditingController _titleController = TextEditingController();
  String _newTaskEnergy = 'Low';
  int _newTaskDuration = 5;
  final List<int> _durationMilestones = [5, 15, 30, 45, 60, 90, 120];
  final List<String> _energyLevels = ['Low', 'Medium', 'High'];
  int _points = 100;
  int _streak = 0;
  double get _multiplier => _streak >= 5 ? 2.0 : (_streak >= 3 ? 1.5 : 1.0);
  String _avatarGender = 'Female';
  String? _equippedAura;
  String? _equippedEyewear;
  String? _equippedHeadwear;

  final List<ShopItem> _shopItems = [
    ShopItem(id: 'a1', name: 'Neon Aura', emoji: '🔥', price: 20, category: ItemCategory.aura),
    ShopItem(id: 'a2', name: 'Lightning Field', emoji: '⚡', price: 35, category: ItemCategory.aura),
    ShopItem(id: 'a3', name: 'Frost Halo', emoji: '❄️', price: 30, category: ItemCategory.aura),
    ShopItem(id: 'e1', name: 'Cyber Shades', emoji: '🕶️', price: 15, category: ItemCategory.eyewear),
    ShopItem(id: 'e2', name: 'Disguise Mask', emoji: '🥸', price: 25, category: ItemCategory.eyewear),
    ShopItem(id: 'h1', name: 'Royal Crown', emoji: '👑', price: 50, category: ItemCategory.headwear),
    ShopItem(id: 'h2', name: 'Cowboy Hat', emoji: '🤠', price: 20, category: ItemCategory.headwear),
    ShopItem(id: 'h3', name: 'Party Hat', emoji: '🎉', price: 10, category: ItemCategory.headwear),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // ---------- LOGIC ----------
  void _resetStreakChain() => setState(() => _streak = 0);

  void _handleCheckTap(Task task) {
    final int earned = (10 * _multiplier).round();
    setState(() { _points += earned; _streak += 1; task.completed = true; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.surface,
      duration: const Duration(milliseconds: 900),
      content: Text('✅ ${task.title} complete! +$earned pts', style: const TextStyle(color: AppColors.neonOrange, fontWeight: FontWeight.bold)),
    ));
  }

  void _handleDeleteTap(String id) => setState(() => _tasks.removeWhere((t) => t.id == id));

  void _addCustomTask() {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: AppColors.synthPink, content: Text('Enter a task title first!')));
      return;
    }
    setState(() {
      _tasks.add(Task(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title, duration: _newTaskDuration, energy: _newTaskEnergy));
      _titleController.clear();
      _newTaskEnergy = 'Low';
      _newTaskDuration = 5;
    });
    FocusScope.of(context).unfocus();
  }

  void _onEnergySelected(String v) {
    if (v == _selectedEnergy) return;
    setState(() { _selectedEnergy = v; _resetStreakChain(); });
  }

  void _onSliderChanged(double v) => setState(() { _timePool = v; _resetStreakChain(); });

  void _buyOrToggleItem(ShopItem item) {
    setState(() {
      if (!item.unlocked) {
        if (_points >= item.price) { _points -= item.price; item.unlocked = true; _equip(item); }
        else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: AppColors.synthPink, content: Text('Not enough points! 💸'))); }
      } else { _toggleEquip(item); }
    });
  }

  void _equip(ShopItem item) {
    if (item.category == ItemCategory.aura) _equippedAura = item.id;
    if (item.category == ItemCategory.eyewear) _equippedEyewear = item.id;
    if (item.category == ItemCategory.headwear) _equippedHeadwear = item.id;
  }

  void _toggleEquip(ShopItem item) {
    if (item.category == ItemCategory.aura) _equippedAura = (_equippedAura == item.id) ? null : item.id;
    if (item.category == ItemCategory.eyewear) _equippedEyewear = (_equippedEyewear == item.id) ? null : item.id;
    if (item.category == ItemCategory.headwear) _equippedHeadwear = (_equippedHeadwear == item.id) ? null : item.id;
  }

  bool _isEquipped(ShopItem item) {
    if (item.category == ItemCategory.aura) return _equippedAura == item.id;
    if (item.category == ItemCategory.eyewear) return _equippedEyewear == item.id;
    if (item.category == ItemCategory.headwear) return _equippedHeadwear == item.id;
    return false;
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    final List<Task> filtered = _tasks.where((t) => !t.completed && t.duration <= _timePool && t.energy == _selectedEnergy).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildAvatarSection()),
          SliverToBoxAdapter(child: _buildFilterControls()),
          SliverToBoxAdapter(child: _buildSectionTitle('🎯 MATCHED TASKS', filtered.length)),
          filtered.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => _buildTaskCard(filtered[i]), childCount: filtered.length)),
          SliverToBoxAdapter(child: _buildCustomTaskGenerator()),
          SliverToBoxAdapter(child: _buildShopSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ]),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TASKFACE', style: TextStyle(color: AppColors.neonOrange, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        Text('Energy-Synced Productivity', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ]),
      Row(children: [_buildStreakBadge(), const SizedBox(width: 10), _buildCoinBank()]),
    ]),
  );

  Widget _buildStreakBadge() {
    final bool isHot = _multiplier > 1.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isHot ? AppColors.synthPink : AppColors.textMuted.withValues(alpha: 0.3), width: 1.5),
        boxShadow: isHot ? [BoxShadow(color: AppColors.synthPink.withValues(alpha: 0.55), blurRadius: 14, spreadRadius: 1)] : [],
      ),
      child: Row(children: [
        Text(isHot ? '🔥' : '➖', style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text('${_multiplier.toStringAsFixed(1)}x', style: TextStyle(color: isHot ? AppColors.synthPink : AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }

  Widget _buildCoinBank() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.neonOrange.withValues(alpha: 0.5), width: 1.5)),
    child: Row(children: [
      const Text('🪙', style: TextStyle(fontSize: 14)),
      const SizedBox(width: 4),
      Text('$_points', style: const TextStyle(color: AppColors.neonOrange, fontWeight: FontWeight.bold, fontSize: 14)),
    ]),
  );

  Widget _buildAvatarSection() => Container(
    margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.neonOrange.withValues(alpha: 0.25))),
    child: Column(children: [
      CustomPaint(size: const Size(190, 190), painter: AvatarPainter(gender: _avatarGender, auraId: _equippedAura, eyewearId: _equippedEyewear, headwearId: _equippedHeadwear)),
      const SizedBox(height: 10),
      const Text('YOUR AVATAR', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2)),
      const SizedBox(height: 14),
      Row(children: ['Female', 'Male'].map((g) {
        final bool sel = _avatarGender == g;
        return Expanded(child: GestureDetector(
          onTap: () { if (_avatarGender != g) setState(() => _avatarGender = g); },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: sel ? AppColors.neonOrange : AppColors.background,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: sel ? AppColors.neonOrange : AppColors.textMuted.withValues(alpha: 0.3)),
            ),
            child: Text(g == 'Female' ? '👩 Female' : '👨 Male', textAlign: TextAlign.center,
              style: TextStyle(color: sel ? Colors.black : AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ));
      }).toList()),
    ]),
  );

  Widget _buildFilterControls() => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('⏱ AVAILABLE TIME POOL', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
        Text('${_timePool.round()} min', style: const TextStyle(color: AppColors.neonOrange, fontWeight: FontWeight.bold, fontSize: 15)),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: AppColors.neonOrange, inactiveTrackColor: AppColors.background, thumbColor: AppColors.neonOrange,
          overlayColor: AppColors.neonOrange.withValues(alpha: 0.2), valueIndicatorColor: AppColors.neonOrange,
        ),
        child: Slider(min: 5, max: 120, divisions: 23, value: _timePool, label: '${_timePool.round()} min', onChanged: _onSliderChanged),
      ),
      const SizedBox(height: 8),
      const Text('⚡ ENERGY STATE', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
      const SizedBox(height: 10),
      Row(children: _energyLevels.map((level) {
        final bool sel = _selectedEnergy == level;
        return Expanded(child: GestureDetector(
          onTap: () => _onEnergySelected(level),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: sel ? AppColors.synthPink : AppColors.background,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: sel ? AppColors.synthPink : AppColors.textMuted.withValues(alpha: 0.3)),
              boxShadow: sel ? [BoxShadow(color: AppColors.synthPink.withValues(alpha: 0.45), blurRadius: 10, spreadRadius: 0.5)] : [],
            ),
            child: Text(level, textAlign: TextAlign.center, style: TextStyle(color: sel ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ));
      }).toList()),
    ]),
  );

  Widget _buildSectionTitle(String title, int count) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.neonOrange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Text('$count', style: const TextStyle(color: AppColors.neonOrange, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    ]),
  );

  Widget _buildEmptyState() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16)),
    child: const Center(child: Text('No tasks match your current vibe.\nAdjust your energy or time pool 🔍', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
  );

  Widget _buildTaskCard(Task task) {
    final Color ec = task.energy == 'Low' ? Colors.greenAccent : (task.energy == 'Medium' ? AppColors.neonOrange : AppColors.synthPink);
    return Container(
      key: ValueKey(task.id),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: ec.withValues(alpha: 0.35))),
      child: Row(children: [
        GestureDetector(
          onTap: () => _handleCheckTap(task),
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.neonOrange, width: 2)),
            child: const Icon(Icons.check, size: 16, color: AppColors.neonOrange),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Row(children: [_buildTag('${task.duration} min', AppColors.textMuted), const SizedBox(width: 6), _buildTag(task.energy, ec)]),
        ])),
        GestureDetector(onTap: () => _handleDeleteTap(task.id), child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.delete_outline, color: AppColors.synthPink, size: 22))),
      ]),
    );
  }

  Widget _buildTag(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );

  Widget _buildCustomTaskGenerator() => Container(
    margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.synthPink.withValues(alpha: 0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('✨ CREATE NEW TASK', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
      const SizedBox(height: 12),
      TextField(
        controller: _titleController,
        style: const TextStyle(color: AppColors.textPrimary),
        cursorColor: AppColors.neonOrange,
        decoration: InputDecoration(
          hintText: 'e.g. Write journal entry', hintStyle: const TextStyle(color: AppColors.textMuted),
          filled: true, fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: _buildEnergyDropdown()), const SizedBox(width: 10), Expanded(child: _buildDurationDropdown())]),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, child: GestureDetector(
        onTap: _addCustomTask,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.neonOrange, borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.neonOrange.withValues(alpha: 0.35), blurRadius: 12, spreadRadius: 0.5)],
          ),
          child: const Center(child: Text('+ INJECT TASK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black))),
        ),
      )),
    ]),
  );

  Widget _buildEnergyDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: _newTaskEnergy, isExpanded: true, dropdownColor: AppColors.surface, iconEnabledColor: AppColors.neonOrange,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      items: _energyLevels.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
      onChanged: (v) { if (v != null) setState(() => _newTaskEnergy = v); },
    )),
  );

  Widget _buildDurationDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
    child: DropdownButtonHideUnderline(child: DropdownButton<int>(
      value: _newTaskDuration, isExpanded: true, dropdownColor: AppColors.surface, iconEnabledColor: AppColors.neonOrange,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      items: _durationMilestones.map((d) => DropdownMenuItem<int>(value: d, child: Text('$d min'))).toList(),
      onChanged: (v) { if (v != null) setState(() => _newTaskDuration = v); },
    )),
  );

  Widget _buildShopSection() => Container(
    margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('🛒 MARKET TERMINAL', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
      const SizedBox(height: 4),
      const Text('Unlock cosmetics with your points', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      const SizedBox(height: 12),
      _shopLabel('AURA'),
      ..._shopItems.where((i) => i.category == ItemCategory.aura).map(_shopRow),
      const SizedBox(height: 8),
      _shopLabel('EYEWEAR'),
      ..._shopItems.where((i) => i.category == ItemCategory.eyewear).map(_shopRow),
      const SizedBox(height: 8),
      _shopLabel('HEADWEAR'),
      ..._shopItems.where((i) => i.category == ItemCategory.headwear).map(_shopRow),
    ]),
  );

  Widget _shopLabel(String t) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 6),
    child: Text(t, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
  );

  Widget _shopRow(ShopItem item) {
    final bool equipped = _isEquipped(item);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: equipped ? AppColors.neonOrange : Colors.transparent, width: 1.5),
        boxShadow: equipped ? [BoxShadow(color: AppColors.neonOrange.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 0.5)] : [],
      ),
      child: Row(children: [
        Text(item.emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          if (!item.unlocked) Text('🪙 ${item.price} pts', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ])),
        GestureDetector(
          onTap: () => _buyOrToggleItem(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: !item.unlocked ? AppColors.neonOrange : (equipped ? AppColors.synthPink : AppColors.surface), borderRadius: BorderRadius.circular(10)),
            child: Text(!item.unlocked ? 'BUY' : (equipped ? 'UNEQUIP' : 'EQUIP'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: !item.unlocked ? Colors.black : Colors.white)),
          ),
        ),
      ]),
    );
  }
}

// =============================================================
// AVATAR PAINTER
// Every feature, hair style, and accessory is drawn in the same
// 190x190 coordinate space, so hats/glasses always align perfectly.
// =============================================================
class AvatarPainter extends CustomPainter {
  final String gender;
  final String? auraId;
  final String? eyewearId;
  final String? headwearId;

  const AvatarPainter({required this.gender, this.auraId, this.eyewearId, this.headwearId});

  static const double cx = 95;
  static const double eyeY = 95;
  static const double leftEyeX = 73;
  static const double rightEyeX = 117;
  static const double headTop = 52;
  static const double headL = 44;
  static const double headR = 146;
  static const double headB = 152;

  @override
  void paint(Canvas canvas, Size size) {
    _drawAura(canvas);
    _drawHairBack(canvas);
    _drawHead(canvas);
    _drawEars(canvas);
    _drawHairFront(canvas);
    _drawCheeks(canvas);
    _drawEyebrows(canvas);
    _drawEyes(canvas);
    _drawNose(canvas);
    _drawMouth(canvas);
    _drawEyewear(canvas);
    _drawHeadwear(canvas);
  }

  void _drawAura(Canvas canvas) {
    if (auraId == null) return;
    const Offset c = Offset(cx, 100);
    if (auraId == 'a1') {
      canvas.drawCircle(c, 93, Paint()..shader = RadialGradient(colors: [AppColors.neonOrange.withValues(alpha: 0.5), AppColors.neonOrange.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: c, radius: 93)));
      final Paint fl = Paint()..color = AppColors.synthPink.withValues(alpha: 0.38);
      for (int i = 0; i < 7; i++) {
        final double a = i / 7 * 2 * math.pi;
        canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * 80, 13, fl);
      }
    } else if (auraId == 'a2') {
      canvas.drawCircle(c, 93, Paint()..shader = RadialGradient(colors: [Colors.cyanAccent.withValues(alpha: 0.38), Colors.cyanAccent.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: c, radius: 93)));
      final Paint bolt = Paint()..color = Colors.yellowAccent.withValues(alpha: 0.9)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
      for (int i = 0; i < 4; i++) {
        final double a = i / 4 * 2 * math.pi + 0.4;
        final Offset b = c + Offset(math.cos(a), math.sin(a)) * 58;
        final Offset t = c + Offset(math.cos(a), math.sin(a)) * 92;
        final Offset m = Offset((b.dx + t.dx) / 2 + 9, (b.dy + t.dy) / 2 - 7);
        canvas.drawPath(Path()..moveTo(b.dx, b.dy)..lineTo(m.dx, m.dy)..lineTo(t.dx, t.dy), bolt);
      }
    } else if (auraId == 'a3') {
      canvas.drawCircle(c, 93, Paint()..shader = RadialGradient(colors: [Colors.lightBlueAccent.withValues(alpha: 0.38), Colors.lightBlueAccent.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: c, radius: 93)));
      final Paint flake = Paint()..color = Colors.white.withValues(alpha: 0.85)..strokeWidth = 2.2..strokeCap = StrokeCap.round;
      for (int i = 0; i < 8; i++) {
        final double a = i / 8 * 2 * math.pi;
        final Offset p = c + Offset(math.cos(a), math.sin(a)) * 83;
        canvas.drawLine(p + const Offset(-5, 0), p + const Offset(5, 0), flake);
        canvas.drawLine(p + const Offset(0, -5), p + const Offset(0, 5), flake);
        canvas.drawLine(p + const Offset(-3.5, -3.5), p + const Offset(3.5, 3.5), flake);
        canvas.drawLine(p + const Offset(3.5, -3.5), p + const Offset(-3.5, 3.5), flake);
      }
    }
  }

  void _drawHairBack(Canvas canvas) {
    final Paint hp = Paint()..color = gender == 'Female' ? AppColors.synthPink : const Color(0xFF3FD3C6);
    if (gender == 'Female') {
      canvas.drawRRect(
        RRect.fromRectAndCorners(const Rect.fromLTRB(28, 30, 162, 155), topLeft: const Radius.circular(52), topRight: const Radius.circular(52), bottomLeft: const Radius.circular(20), bottomRight: const Radius.circular(20)),
        hp,
      );
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(34, 34, 156, 100), const Radius.circular(40)), hp);
    }
  }

  void _drawHead(Canvas canvas) => canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTRB(headL, headTop, headR, headB), const Radius.circular(28)),
    Paint()..color = const Color(0xFFD4A574),
  );

  void _drawEars(Canvas canvas) {
    final Paint skin = Paint()..color = const Color(0xFFD4A574);
    canvas.drawCircle(Offset(headL - 3, 104), 9, skin);
    canvas.drawCircle(Offset(headR + 3, 104), 9, skin);
  }

  void _drawHairFront(Canvas canvas) {
    final Paint hp = Paint()..color = gender == 'Female' ? AppColors.synthPink : const Color(0xFF3FD3C6);
    if (gender == 'Female') {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(44, 44, 118, 68), const Radius.circular(24)), hp);
      canvas.drawOval(const Rect.fromLTWH(118, 50, 22, 28), hp);
    } else {
      for (int i = 0; i < 5; i++) {
        final double x = 58 + i * 16.0;
        canvas.drawPath(Path()..moveTo(x, 42)..lineTo(x + 7, 24)..lineTo(x + 14, 42)..close(), hp);
      }
    }
  }

  void _drawCheeks(Canvas canvas) {
    final Paint blush = Paint()..color = AppColors.synthPink.withValues(alpha: 0.2);
    canvas.drawCircle(const Offset(66, 112), 9, blush);
    canvas.drawCircle(const Offset(124, 112), 9, blush);
  }

  void _drawEyebrows(Canvas canvas) {
    final Paint brow = Paint()..color = const Color(0xFF5C3D1E)..style = PaintingStyle.stroke..strokeWidth = gender == 'Female' ? 2.2 : 3.2..strokeCap = StrokeCap.round;
    if (gender == 'Female') {
      canvas.drawPath(Path()..moveTo(60, 74)..quadraticBezierTo(72, 68, 84, 72), brow);
      canvas.drawPath(Path()..moveTo(106, 72)..quadraticBezierTo(118, 68, 130, 74), brow);
    } else {
      canvas.drawLine(const Offset(60, 74), const Offset(86, 72), brow);
      canvas.drawLine(const Offset(104, 72), const Offset(130, 74), brow);
    }
  }

  void _drawEyes(Canvas canvas) {
    final Paint white = Paint()..color = const Color(0xFFFFFFFE);
    final Paint pupil = Paint()..color = const Color(0xFF2B2A3D);
    final Paint iris = Paint()..color = gender == 'Female' ? AppColors.synthPink.withValues(alpha: 0.8) : Colors.cyanAccent.withValues(alpha: 0.8);
    final Paint shine = Paint()..color = Colors.white;

    for (final double x in [leftEyeX, rightEyeX]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, eyeY), width: 26, height: 22), white);
      canvas.drawCircle(Offset(x, eyeY + 1), 7, iris);
      canvas.drawCircle(Offset(x, eyeY + 1), 5, pupil);
      canvas.drawCircle(Offset(x - 2, eyeY - 2), 1.8, shine);
    }

    if (gender == 'Female') {
      final Paint lash = Paint()..color = const Color(0xFF2B2A3D)..strokeWidth = 2..strokeCap = StrokeCap.round;
      for (final double x in [leftEyeX, rightEyeX]) {
        canvas.drawLine(Offset(x - 9, eyeY - 8), Offset(x - 11, eyeY - 13), lash);
        canvas.drawLine(Offset(x - 4, eyeY - 10), Offset(x - 4, eyeY - 15), lash);
        canvas.drawLine(Offset(x + 1, eyeY - 10), Offset(x + 2, eyeY - 15), lash);
        canvas.drawLine(Offset(x + 6, eyeY - 9), Offset(x + 8, eyeY - 14), lash);
        canvas.drawLine(Offset(x + 10, eyeY - 7), Offset(x + 13, eyeY - 11), lash);
      }
    }
  }

  void _drawNose(Canvas canvas) => canvas.drawPath(
    Path()..moveTo(cx - 5, 104)..lineTo(cx + 5, 104)..lineTo(cx, 112)..close(),
    Paint()..color = const Color(0xFFC08060),
  );

  void _drawMouth(Canvas canvas) {
    canvas.drawPath(
      Path()..moveTo(cx - 14, 122)..quadraticBezierTo(cx, gender == 'Female' ? 134 : 130, cx + 14, 122),
      Paint()..color = const Color(0xFF8B3A3A)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round,
    );
    if (gender == 'Female') {
      canvas.drawPath(
        Path()..moveTo(cx - 9, 122)..quadraticBezierTo(cx, 130, cx + 9, 122),
        Paint()..color = AppColors.synthPink.withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawEyewear(Canvas canvas) {
    if (eyewearId == null) return;
    if (eyewearId == 'e1') {
      final Paint lens = Paint()..color = Colors.black87;
      final Paint rim = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.7)..style = PaintingStyle.stroke..strokeWidth = 1.8;
      final Paint arm = Paint()..color = Colors.black87..strokeWidth = 2.4..strokeCap = StrokeCap.round;
      for (final double x in [leftEyeX, rightEyeX]) {
        final RRect r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, eyeY), width: 34, height: 22), const Radius.circular(6));
        canvas.drawRRect(r, lens);
        canvas.drawRRect(r, rim);
      }
      canvas.drawLine(Offset(leftEyeX + 17, eyeY), Offset(rightEyeX - 17, eyeY), arm);
      canvas.drawLine(Offset(leftEyeX - 17, eyeY), Offset(headL - 3, 104), arm);
      canvas.drawLine(Offset(rightEyeX + 17, eyeY), Offset(headR + 3, 104), arm);
    } else if (eyewearId == 'e2') {
      final Path band = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTRB(headL + 4, eyeY - 16, headR - 4, eyeY + 16), const Radius.circular(14)));
      final Path holes = Path()
        ..addOval(Rect.fromCenter(center: Offset(leftEyeX, eyeY), width: 26, height: 22))
        ..addOval(Rect.fromCenter(center: Offset(rightEyeX, eyeY), width: 26, height: 22));
      canvas.drawPath(Path.combine(PathOperation.difference, band, holes), Paint()..color = Colors.black.withValues(alpha: 0.88));
    }
  }

  void _drawHeadwear(Canvas canvas) {
    if (headwearId == null) return;
    if (headwearId == 'h1') {
      final Paint gold = Paint()..color = const Color(0xFFFFD700);
      final Paint gStroke = Paint()..color = const Color(0xFFB8860B)..style = PaintingStyle.stroke..strokeWidth = 2;
      final Path crown = Path()
        ..moveTo(55, 42)..lineTo(55, 22)..lineTo(70, 36)..lineTo(82, 10)..lineTo(cx, 28)..lineTo(108, 10)..lineTo(120, 36)..lineTo(135, 22)..lineTo(135, 42)..close();
      canvas.drawPath(crown, gold);
      canvas.drawPath(crown, gStroke);
      canvas.drawCircle(const Offset(82, 16), 4, Paint()..color = AppColors.synthPink);
      canvas.drawCircle(const Offset(cx, 30), 4, Paint()..color = Colors.cyanAccent);
      canvas.drawCircle(const Offset(108, 16), 4, Paint()..color = AppColors.synthPink);
    } else if (headwearId == 'h2') {
      final Paint brown = Paint()..color = const Color(0xFFAD6A3D);
      final Paint dBrown = Paint()..color = const Color(0xFF7A4020);
      canvas.drawOval(const Rect.fromLTWH(35, 30, 120, 20), brown);
      canvas.drawRRect(
        RRect.fromRectAndCorners(const Rect.fromLTRB(66, 8, 124, 40), topLeft: const Radius.circular(18), topRight: const Radius.circular(18)),
        brown,
      );
      canvas.drawRect(const Rect.fromLTRB(66, 30, 124, 37), dBrown);
    } else if (headwearId == 'h3') {
      final Paint pink = Paint()..color = AppColors.synthPink;
      canvas.drawPath(Path()..moveTo(cx, 2)..lineTo(68, 44)..lineTo(122, 44)..close(), pink);
      final Paint dot = Paint()..color = Colors.white.withValues(alpha: 0.88);
      canvas.drawCircle(const Offset(88, 32), 2.6, dot);
      canvas.drawCircle(const Offset(102, 22), 2.6, dot);
      canvas.drawCircle(const Offset(cx, 12), 2.6, dot);
      canvas.drawCircle(const Offset(cx, 2), 7, Paint()..color = Colors.cyanAccent);
    }
  }

  @override
  bool shouldRepaint(covariant AvatarPainter old) =>
      old.gender != gender || old.auraId != auraId || old.eyewearId != eyewearId || old.headwearId != headwearId;
}