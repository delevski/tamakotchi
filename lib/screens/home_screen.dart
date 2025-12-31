import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../logic/tamagotchi_state.dart';
import '../logic/auth_provider.dart';
import 'package:tamakochi_app/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tamagotchiState = ref.watch(tamagotchiProvider);
    final notifier = ref.read(tamagotchiProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.reset,
            tooltip: 'Reset',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(l10n.stage, style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        _getStageName(tamagotchiState.stage, l10n),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(l10n.age, style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        '${tamagotchiState.age.inMinutes}m', // Show minutes for demo
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBadge(Icons.fastfood, tamagotchiState.hunger, Colors.orange),
                _buildStatBadge(Icons.clean_hands, tamagotchiState.hygiene, Colors.blue),
                _buildStatBadge(Icons.mood, tamagotchiState.fun, Colors.pink),
                _buildStatBadge(Icons.flash_on, tamagotchiState.energy, Colors.yellow[800]!),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Character
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -10 * _bounceController.value),
                child: child,
              );
            },
            child: _buildCharacter(tamagotchiState.stage),
          ),
          
          const Spacer(),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.restaurant,
                  label: l10n.feed,
                  onTap: notifier.feed,
                ),
                _buildActionButton(
                  icon: Icons.wash,
                  label: l10n.clean,
                  onTap: notifier.clean,
                ),
                _buildActionButton(
                  icon: Icons.sports_esports,
                  label: l10n.play,
                  onTap: notifier.play,
                ),
                 _buildActionButton(
                  icon: Icons.bed,
                  label: l10n.sleep,
                  onTap: notifier.sleep,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStageName(TamagotchiStage stage, AppLocalizations l10n) {
    switch (stage) {
      case TamagotchiStage.baby: return l10n.stageBaby;
      case TamagotchiStage.child: return l10n.stageChild;
      case TamagotchiStage.teen: return l10n.stageTeen;
      case TamagotchiStage.adult: return l10n.stageAdult;
    }
  }

  Widget _buildCharacter(TamagotchiStage stage) {
    double size = 150.0;
    Color color = Colors.purple;
    IconData icon = Icons.pets;

    switch (stage) {
      case TamagotchiStage.baby:
        size = 100.0;
        color = Colors.lightBlue;
        icon = Icons.child_care;
        break;
      case TamagotchiStage.child:
        size = 130.0;
        color = Colors.green;
        icon = Icons.emoji_emotions;
        break;
      case TamagotchiStage.teen:
        size = 160.0;
        color = Colors.orange;
        icon = Icons.directions_run;
        break;
      case TamagotchiStage.adult:
        size = 200.0;
        color = Colors.deepPurple;
        icon = Icons.person;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.6,
          color: color,
        ),
      ),
    );
  }


  Widget _buildStatBadge(IconData icon, double value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text('${value.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          width: 50,
          child: LinearProgressIndicator(
            value: value / 100,
            color: color,
            backgroundColor: color.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: onTap,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
