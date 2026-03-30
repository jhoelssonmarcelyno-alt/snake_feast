import 'dart:math';
import 'head_painter.dart';
import 'fallback_head.dart';
import 'cat_head.dart';
import 'dog_head.dart';
import 'lion_head.dart';
import 'fox_head.dart';
import 'rabbit_head.dart';
import 'wolf_head.dart';
import 'tiger_head.dart';
import 'bear_head.dart';
import 'eagle_head.dart';
import 'dragon_head.dart';
import 'elephant_head.dart';
import 'squirrel_head.dart';
import 'bee_head.dart';
import 'ant_head.dart';
import 'beetle_head.dart';
import 'ladybug_head.dart';
import 'butterfly_head.dart';
import 'phoenix_head.dart';
import 'hydra_head.dart';
import 'rainbow_head.dart';
import 'jormungandr_head.dart';
import 'nidhogg_head.dart';
import 'apophis_head.dart';
import 'quetzalcoatl_head.dart';
import 'ouroboros_head.dart';
import 'tiamat_head.dart';
import 'fafnir_head.dart';
import 'shenlong_head.dart';
import 'leviathan_head.dart';
import 'behemoth_head.dart';
import 'griffin_head.dart';
import 'chimera_head.dart';
import 'kraken_head.dart';

/// Registro central de todas as cabecas de animais.
/// Para adicionar novo animal: crie XXX_head.dart, importe aqui, adicione no mapa.
class HeadRegistry {
  HeadRegistry._();

  static final Map<String, HeadPainter> _painters = {
    // Comuns
    'cat':          CatHead(),
    'dog':          DogHead(),
    'lion':         LionHead(),
    'fox':          FoxHead(),
    'rabbit':       RabbitHead(),
    'squirrel':     SquirrelHead(),
    'bee':          BeeHead(),
    'ant':          AntHead(),
    'beetle':       BeetleHead(),
    'ladybug':      LadybugHead(),
    'butterfly':    ButterflyHead(),
    // Incomuns
    'wolf':         WolfHead(),
    'tiger':        TigerHead(),
    'bear':         BearHead(),
    'elephant':     ElephantHead(),
    'eagle':        EagleHead(),
    'dragon':       DragonHead(),
    'phoenix':      PhoenixHead(),
    'hydra':        HydraHead(),
    // Lendarios / Miticos
    'jormungandr':  JormungandrHead(),
    'nidhogg':      NidhoggHead(),
    'apophis':      ApophisHead(),
    'quetzalcoatl': QuetzalcoatlHead(),
    'ouroboros':    OuroborosHead(),
    'tiamat':       TiamatHead(),
    'fafnir':       FafnirHead(),
    'shenlong':     ShenlongHead(),
    'leviathan':    LeviathanHead(),
    'behemoth':     BehemothHead(),
    'griffin':      GriffinHead(),
    'chimera':      ChimeraHead(),
    'kraken':       KrakenHead(),
    // Mitico especial
    'rainbow':      RainbowHead(),
  };

  /// Retorna o HeadPainter correto para o headType.
  /// Se nao encontrar, retorna FallbackHead (cobra generica - nunca visivel em branco).
  static HeadPainter get(String headType) =>
      _painters[headType] ?? FallbackHead();
}
