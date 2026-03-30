// lib/game/weather/weather_data.dart
import 'weather_types.dart';

// Mapeamento mundo → clima (100 mundos iniciais)
const List<WeatherType> kWorldWeather = [
  WeatherType.leaves,   // 0  Floresta
  WeatherType.rain,     // 1  Oceano
  WeatherType.sand,     // 2  Deserto
  WeatherType.embers,   // 3  Vulcão
  WeatherType.snow,     // 4  Gelo
  WeatherType.fog,      // 5  Caverna
  WeatherType.rain,     // 6  Pântano
  WeatherType.sand,     // 7  Savana
  WeatherType.snow,     // 8  Tundra
  WeatherType.petals,   // 9  Ilha
  WeatherType.dust,     // 10 Montanha
  WeatherType.leaves,   // 11 Selva
  WeatherType.fog,      // 12 Abismo
  WeatherType.sparks,   // 13 Neon
  WeatherType.petals,   // 14 Cogumelos
  WeatherType.dust,     // 15 Ruínas
  WeatherType.embers,   // 16 Submundo
  WeatherType.crystals, // 17 Cristal
  WeatherType.stars,    // 18 Aurora
  WeatherType.sparks,   // 19 Robótico
  WeatherType.bubbles,  // 20 Submarino
  WeatherType.fog,      // 21 Fantasma
  WeatherType.electricity, // 22 Dragão
  WeatherType.stars,    // 23 Cósmico
  WeatherType.divine,   // 24 Infinito
  WeatherType.bubbles,  // 25 Coral
  WeatherType.leaves,   // 26 Bambu
  WeatherType.rain,     // 27 Tempestade
  WeatherType.sand,     // 28 Areia
  WeatherType.fog,      // 29 Vapor
  WeatherType.leaves,   // 30 Pradaria
  WeatherType.stars,    // 31 Espaço
  WeatherType.embers,   // 32 Lava
  WeatherType.fog,      // 33 Névoa
  WeatherType.petals,   // 34 Fada
  WeatherType.dust,     // 35 Pirata
  WeatherType.snow,     // 36 Antártica
  WeatherType.bubbles,  // 37 Biolum.
  WeatherType.fog,      // 38 Trevas
  WeatherType.petals,   // 39 Mel
  WeatherType.petals,   // 40 Sakura
  WeatherType.sparks,   // 41 Espelho
  WeatherType.embers,   // 42 Toxico
  WeatherType.sparks,   // 43 Mecha
  WeatherType.petals,   // 44 Sonho
  WeatherType.petals,   // 45 Arco-íris
  WeatherType.embers,   // 46 Fogo Gelo
  WeatherType.sand,     // 47 Pirâmide
  WeatherType.stars,    // 48 Alien
  WeatherType.stars,    // 49 Eclipse
  WeatherType.petals,   // 50 Bambolê
  WeatherType.dust,     // 51 Granito
  WeatherType.rain,     // 52 Ciclone
  WeatherType.leaves,   // 53 Espinhos
  WeatherType.dust,     // 54 Relíquia
  WeatherType.sparks,   // 55 Vórtex
  WeatherType.dust,     // 56 Ferrugem
  WeatherType.fog,      // 57 Zen
  WeatherType.fog,      // 58 Bruxa
  WeatherType.crystals, // 59 Platina
  WeatherType.fog,      // 60 Nuvem
  WeatherType.dust,     // 61 Lodo
  WeatherType.stars,    // 62 Pulsar
  WeatherType.fog,      // 63 Esqueleto
  WeatherType.crystals, // 64 Safira
  WeatherType.crystals, // 65 Esmeralda
  WeatherType.crystals, // 66 Rubi
  WeatherType.crystals, // 67 Ametista
  WeatherType.fog,      // 68 Obsidiana
  WeatherType.dust,     // 69 Titânio
  WeatherType.sparks,   // 70 Plasma
  WeatherType.bubbles,  // 71 Vácuo
  WeatherType.electricity, // 72 Caos
  WeatherType.stars,    // 73 Oráculo
  WeatherType.embers,   // 74 Templo
  WeatherType.embers,   // 75 Fênix
  WeatherType.bubbles,  // 76 Kraken
  WeatherType.dust,     // 77 Golem
  WeatherType.stars,    // 78 Quasar
  WeatherType.stars,    // 79 Éter
  WeatherType.electricity, // 80 Relâmpago
  WeatherType.embers,   // 81 Magma
  WeatherType.dust,     // 82 Mito
  WeatherType.fog,      // 83 Necro
  WeatherType.divine,   // 84 Serafim
  WeatherType.fog,      // 85 Sombra
  WeatherType.embers,   // 86 Veleno
  WeatherType.fog,      // 87 Espectro
  WeatherType.electricity, // 88 Titã
  WeatherType.sparks,   // 89 Nexus
  WeatherType.embers,   // 90 Abaddon
  WeatherType.dust,     // 91 Arcano
  WeatherType.fog,      // 92 Singul.
  WeatherType.divine,   // 93 Divino
  WeatherType.bubbles,  // 94 Abissal
  WeatherType.leaves,   // 95 Primordial
  WeatherType.stars,    // 96 Astral
  WeatherType.divine,   // 97 Eterno
  WeatherType.electricity, // 98 Omega
  WeatherType.divine,   // 99 Lendário
];

// Quantidade alvo de partículas por clima
const Map<WeatherType, int> kTargetParticleCount = {
  WeatherType.none: 0,
  WeatherType.rain: 180,
  WeatherType.snow: 120,
  WeatherType.fog: 60,
  WeatherType.leaves: 80,
  WeatherType.embers: 100,
  WeatherType.sand: 150,
  WeatherType.stars: 60,
  WeatherType.bubbles: 70,
  WeatherType.sparks: 90,
  WeatherType.petals: 80,
  WeatherType.crystals: 60,
  WeatherType.dust: 110,
  WeatherType.electricity: 40,
  WeatherType.divine: 50,
};
