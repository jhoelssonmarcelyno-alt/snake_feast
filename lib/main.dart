import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/main_menu/main_menu_overlay.dart';
import 'game/snake_engine.dart';
import 'utils/constants.dart';
import 'overlays/game_over.dart';
import 'overlays/hud/hud_overlay.dart';
import 'overlays/settings_overlay.dart';
import 'overlays/pause_overlay.dart';
import 'overlays/revive_overlay.dart';
import 'overlays/shop_overlay.dart';
import 'overlays/lobby_overlay.dart';
import 'overlays/ranking_overlay.dart';
import 'game/overlays/win_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const SnakeFeastApp());
}

class SnakeFeastApp extends StatelessWidget {
  const SnakeFeastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Feast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final SnakeEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = SnakeEngine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: GameWidget<SnakeEngine>(
              game: _engine,
              overlayBuilderMap: {
                kOverlayMainMenu: (context, game) =>
                    MainMenuOverlay(engine: game),
                kOverlayGameOver: (context, game) =>
                    GameOverOverlay(engine: game),
                kOverlayHud: (context, game) => HudOverlay(engine: game),
                kOverlaySettings: (context, game) =>
                    SettingsOverlay(engine: game),
                kOverlayPause: (context, game) => PauseOverlay(engine: game),
                kOverlayShop: (context, game) => ShopOverlay(engine: game),
                kOverlayRevive: (context, game) => ReviveOverlay(engine: game),
                kOverlayLobby: (context, game) => LobbyOverlay(engine: game),
                kOverlayRanking: (context, game) =>
                    RankingOverlay(
                      engine: game,
                      onClose: () {
                        game.overlays.remove(kOverlayRanking);
                      },
                    ),
                kOverlayWin: (context, game) => WinOverlay(game: game),
              },
              initialActiveOverlays: const [kOverlayMainMenu],
            ),
          );
        },
      ),
    );
  }
}
