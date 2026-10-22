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
      'heart_with_arrow', 'revolving_hearts', 'beating_heart', 'growing_heart', 'heart_decoration', 'heart_exclamation', 'pink_heart', 'orange_heart', //
      'yellow_heart', 'green_heart', 'purple_heart', 'heart_on_fire', 'smiling_face_with_hearts', 'smiling_face_with_heart_eyes', 'face_blowing_a_kiss', 'bouquet',
    ]),
    StickerCategory('nature', (l) => l.stickersNature, const [
      'sunflower', 'cherry_blossom', 'four_leaf_clover', 'herb', 'tulip', 'cactus', 'mushroom', 'fallen_leaf', //
      'hibiscus', 'blossom', 'lotus', 'seedling', 'evergreen_tree', 'deciduous_tree', 'maple_leaf', 'leaf_fluttering_in_wind', //
      'shamrock', 'potted_plant', 'sheaf_of_rice', 'hyacinth', 'wilted_flower', 'spiral_shell', 'nest_with_eggs', 'coral',
    ]),
    StickerCategory('sky', (l) => l.stickersSky, const [
      'sun_with_face', 'crescent_moon', 'glowing_star', 'rainbow', 'cloud', 'sparkles', 'star', 'snowflake', //
      'umbrella_with_rain_drops', 'comet', 'high_voltage', 'sun_behind_cloud', 'sun', 'sun_behind_small_cloud', 'sun_behind_large_cloud', 'sun_behind_rain_cloud', //
      'cloud_with_rain', 'cloud_with_lightning', 'cloud_with_lightning_and_rain', 'cloud_with_snow', 'tornado', 'fog', 'wind_face', 'cyclone', //
      'umbrella', 'droplet', 'water_wave', 'snowman', 'full_moon', 'new_moon_face', 'full_moon_face', 'first_quarter_moon_face', //
      'waxing_crescent_moon', 'milky_way', 'ringed_planet', 'dizzy',
    ]),
    StickerCategory('food', (l) => l.stickersFood, const [
      'hot_beverage', 'bubble_tea', 'shortcake', 'strawberry', 'birthday_cake', 'doughnut', 'avocado', 'pizza', //
      'soft_ice_cream', 'croissant', 'cherries', 'watermelon', 'red_apple', 'banana', 'grapes', 'lemon', //
      'peach', 'pineapple', 'blueberries', 'kiwi_fruit', 'hamburger', 'french_fries', 'sushi', 'steaming_bowl', //
      'spaghetti', 'popcorn', 'cookie', 'chocolate_bar', 'candy', 'lollipop', 'cupcake', 'pancakes', //
      'waffle', 'honey_pot', 'tropical_drink', 'teacup_without_handle',
    ]),
    StickerCategory('animals', (l) => l.stickersAnimals, const [
      'cat_face', 'dog_face', 'butterfly', 'panda', 'rabbit_face', 'fox', 'bear', 'penguin', //
      'unicorn', 'hatching_chick', 'turtle', 'octopus', 'koala', 'tiger_face', 'lion', 'monkey_face', //
      'pig_face', 'cow_face', 'frog', 'hamster', 'mouse_face', 'owl', 'duck', 'baby_chick', //
      'dolphin', 'spouting_whale', 'tropical_fish', 'hedgehog', 'sloth', 'otter', 'raccoon', 'honeybee', //
      'lady_beetle', 'snail', 'elephant', 'flamingo',
    ]),
    StickerCategory('hobby', (l) => l.stickersHobby, const [
      'open_book', 'artist_palette', 'headphone', 'camera', 'books', 'musical_notes', 'video_game', 'running_shoe', //
      'soccer_ball', 'guitar', 'laptop', 'pencil', 'memo', 'paintbrush', 'crayon', 'microphone', //
      'studio_microphone', 'musical_keyboard', 'saxophone', 'trumpet', 'violin', 'drum', 'basketball', 'tennis', //
      'volleyball', 'badminton', 'skateboard', 'roller_skate', 'chess_pawn', 'puzzle_piece', 'joystick', 'game_die', //
      'clapper_board', 'television', 'yarn', 'sewing_needle', 'ballet_shoes', 'kite', 'fishing_pole',
    ]),
    StickerCategory('travel', (l) => l.stickersTravel, const [
      'airplane', 'beach_with_umbrella', 'camping', 'world_map', 'snow_capped_mountain', 'luggage', 'automobile', 'compass', //
      'sunrise_over_mountains', 'palm_tree', 'bicycle', 'high_speed_train', 'ship', 'sailboat', 'rocket', 'helicopter', //
      'desert_island', 'volcano', 'mount_fuji', 'statue_of_liberty', 'tokyo_tower', 'ferris_wheel', 'roller_coaster', 'carousel_horse', //
      'motor_scooter', 'bus', 'taxi', 'ticket', 'globe_showing_europe_africa', 'night_with_stars',
    ]),
    StickerCategory('party', (l) => l.stickersParty, const [
      'party_popper', 'balloon', 'wrapped_gift', 'crown', 'confetti_ball', 'trophy', 'christmas_tree', 'jack_o_lantern', //
      'ribbon', 'gem_stone', 'sparkler', 'fireworks', 'firecracker', 'partying_face', 'mirror_ball', 'candle', //
      'bottle_with_popping_cork', 'clinking_glasses', 'clinking_beer_mugs', 'sports_medal', '1st_place_medal', 'reminder_ribbon', 'admission_tickets', 'magic_wand', //
      'crystal_ball', 'ghost', 'red_envelope', 'wind_chime', 'star_struck', 'tanabata_tree',
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
