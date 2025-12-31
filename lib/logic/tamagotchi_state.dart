import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TamagotchiStage { baby, child, teen, adult }
enum TamagotchiType { unknown, dog, cat, dino }

class TamagotchiStats {
  final double hunger; // 0.0 (starving) to 100.0 (full)
  final double hygiene; // 0.0 (dirty) to 100.0 (clean)
  final double fun; // 0.0 (bored) to 100.0 (happy)
  final double energy; // 0.0 (tired) to 100.0 (rested)
  final DateTime lastUpdated;
  final DateTime birthDate;
  final TamagotchiStage stage;
  final TamagotchiType type;

  const TamagotchiStats({
    this.hunger = 80.0,
    this.hygiene = 80.0,
    this.fun = 80.0,
    this.energy = 80.0,
    required this.lastUpdated,
    required this.birthDate,
    this.stage = TamagotchiStage.baby,
    this.type = TamagotchiType.unknown,
  });

  TamagotchiStats copyWith({
    double? hunger,
    double? hygiene,
    double? fun,
    double? energy,
    DateTime? lastUpdated,
    DateTime? birthDate,
    TamagotchiStage? stage,
    TamagotchiType? type,
  }) {
    return TamagotchiStats(
      hunger: hunger ?? this.hunger,
      hygiene: hygiene ?? this.hygiene,
      fun: fun ?? this.fun,
      energy: energy ?? this.energy,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      birthDate: birthDate ?? this.birthDate,
      stage: stage ?? this.stage,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hunger': hunger,
      'hygiene': hygiene,
      'fun': fun,
      'energy': energy,
      'lastUpdated': lastUpdated.toIso8601String(),
      'birthDate': birthDate.toIso8601String(),
      'stage': stage.index,
      'type': type.index,
    };
  }

  factory TamagotchiStats.fromMap(Map<String, dynamic> map) {
    return TamagotchiStats(
      hunger: map['hunger'] ?? 80.0,
      hygiene: map['hygiene'] ?? 80.0,
      fun: map['fun'] ?? 80.0,
      energy: map['energy'] ?? 80.0,
      lastUpdated: DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
      birthDate: DateTime.tryParse(map['birthDate'] ?? '') ?? DateTime.now(),
      stage: TamagotchiStage.values[map['stage'] ?? 0],
      type: TamagotchiType.values[map['type'] ?? 0],
    );
  }
  
  Duration get age => DateTime.now().difference(birthDate);
}

final tamagotchiProvider = StateNotifierProvider<TamagotchiNotifier, TamagotchiStats>((ref) {
  return TamagotchiNotifier();
});

class TamagotchiNotifier extends StateNotifier<TamagotchiStats> {
  Timer? _timer;
  
  TamagotchiNotifier() : super(TamagotchiStats(lastUpdated: DateTime.now(), birthDate: DateTime.now())) {
    loadState();
  }

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('tamagotchi_stats');
    if (jsonString != null) {
      state = TamagotchiStats.fromMap(json.decode(jsonString));
      _applyTimePassed(); // Calculate decay for offline time
      _checkEvolution();
    }
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _decayStats();
      _checkEvolution();
    });
  }

  void _decayStats() {
    state = state.copyWith(
      hunger: (state.hunger - 0.5).clamp(0.0, 100.0),
      hygiene: (state.hygiene - 0.5).clamp(0.0, 100.0),
      fun: (state.fun - 0.5).clamp(0.0, 100.0),
      energy: (state.energy - 0.2).clamp(0.0, 100.0),
      lastUpdated: DateTime.now(),
    );
    _saveState();
  }
  
  void _applyTimePassed() {
    final now = DateTime.now();
    final difference = now.difference(state.lastUpdated);
    final seconds = difference.inSeconds;
    
    // Example: decay 1 point per 20 seconds of offline time
    final decayAmount = seconds / 20.0;
    
    state = state.copyWith(
      hunger: (state.hunger - decayAmount).clamp(0.0, 100.0),
      hygiene: (state.hygiene - decayAmount).clamp(0.0, 100.0),
      fun: (state.fun - decayAmount).clamp(0.0, 100.0),
      energy: (state.energy - (decayAmount / 2)).clamp(0.0, 100.0),
      lastUpdated: now,
    );
  }
  
  void _checkEvolution() {
    // Evolution logic:
    // Baby -> Child: 1 minute (for demo)
    // Child -> Teen: 3 minutes
    // Teen -> Adult: 5 minutes
    // In real app these would be days
    
    final age = state.age;
    TamagotchiStage newStage = state.stage;
    
    if (age.inMinutes > 5 && state.stage.index < TamagotchiStage.adult.index) {
      newStage = TamagotchiStage.adult;
    } else if (age.inMinutes > 3 && state.stage.index < TamagotchiStage.teen.index) {
      newStage = TamagotchiStage.teen;
    } else if (age.inMinutes > 1 && state.stage.index < TamagotchiStage.child.index) {
      newStage = TamagotchiStage.child;
    }
    
    if (newStage != state.stage) {
      state = state.copyWith(stage: newStage);
      _saveState();
      // Here we could trigger a notification or event
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tamagotchi_stats', json.encode(state.toMap()));
  }

  // --- Actions ---

  void feed() {
    state = state.copyWith(
      hunger: (state.hunger + 20.0).clamp(0.0, 100.0),
      energy: (state.energy + 5.0).clamp(0.0, 100.0),
    );
    _saveState();
  }

  void clean() {
    state = state.copyWith(
      hygiene: 100.0,
      fun: (state.fun + 5.0).clamp(0.0, 100.0),
    );
    _saveState();
  }

  void play() {
    state = state.copyWith(
      fun: (state.fun + 20.0).clamp(0.0, 100.0),
      energy: (state.energy - 10.0).clamp(0.0, 100.0),
      hunger: (state.hunger - 5.0).clamp(0.0, 100.0),
    );
    _saveState();
  }

  void sleep() {
    state = state.copyWith(
      energy: 100.0,
    );
    _saveState();
  }
  
  // Debug helper to reset or force evolve
  void reset() {
    state = TamagotchiStats(lastUpdated: DateTime.now(), birthDate: DateTime.now());
    _saveState();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
