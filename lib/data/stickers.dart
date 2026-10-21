import '../l10n/app_localizations.dart';

class StickerCategory {
  const StickerCategory(this.id, this.name, this.items);

  final String id;
  final String Function(AppLocalizations) name;
  final List<String> items;
}

/// Sticker art: Fluent Emoji by Microsoft (MIT), turned into die-cut stickers by
/// tool/gen_stickers.mjs. The first [kFreeStickersPerCategory] of each category are free.
const kFreeStickersPerCategory = 4;

String stickerAsset(String id) => 'assets/stickers/$id.webp';

abstract final class Stickers {
  static final categories = <StickerCategory>[
    StickerCategory('love', (l) => l.stickersLove, const [
      'red_heart', 'sparkling_heart', 'love_letter', 'rose', 'heart_with_ribbon', 'two_hearts', 'kiss_mark', 'teddy_bear', //
    ]),
    StickerCategory('nature', (l) => l.stickersNature, const [
      'sunflower', 'cherry_blossom', 'four_leaf_clover', 'herb', 'tulip', 'cactus', 'mushroom', 'fallen_leaf', //
    ]),
    StickerCategory('sky', (l) => l.stickersSky, const [
      'sun_with_face', 'crescent_moon', 'glowing_star', 'rainbow', 'cloud', 'sparkles', 'star', 'snowflake', //
      'umbrella_with_rain_drops', 'comet', 'high_voltage', 'sun_behind_cloud',
    ]),
    StickerCategory('food', (l) => l.stickersFood, const [
      'hot_beverage', 'bubble_tea', 'shortcake', 'strawberry', 'birthday_cake', 'doughnut', 'avocado', 'pizza', //
      'soft_ice_cream', 'croissant', 'cherries', 'watermelon',
    ]),
    StickerCategory('animals', (l) => l.stickersAnimals, const [
      'cat_face', 'dog_face', 'butterfly', 'panda', 'rabbit_face', 'fox', 'bear', 'penguin', //
      'unicorn', 'hatching_chick', 'turtle', 'octopus',
    ]),
    StickerCategory('hobby', (l) => l.stickersHobby, const [
      'open_book', 'artist_palette', 'headphone', 'camera', 'books', 'musical_notes', 'video_game', 'running_shoe', //
      'soccer_ball', 'guitar', 'laptop', 'pencil', 'memo',
    ]),
    StickerCategory('travel', (l) => l.stickersTravel, const [
      'airplane', 'beach_with_umbrella', 'camping', 'world_map', 'snow_capped_mountain', 'luggage', 'automobile', //
      'compass', 'sunrise_over_mountains', 'palm_tree',
    ]),
    StickerCategory('party', (l) => l.stickersParty, const [
      'party_popper', 'balloon', 'wrapped_gift', 'crown', 'confetti_ball', 'trophy', 'christmas_tree', 'jack_o_lantern', //
      'ribbon', 'gem_stone',
    ]),
  ];

  static bool isPro(String id) {
    for (final c in categories) {
      final i = c.items.indexOf(id);
      if (i >= 0) return i >= kFreeStickersPerCategory;
    }
    return false;
  }

  static int get count => categories.fold(0, (n, c) => n + c.items.length);
}
