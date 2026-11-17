/// Curated, high-fidelity English Voice Model for Repeat Speaker.
/// Replaces hundreds of raw engine strings with 5 distinct, premium voices.
class CuratedVoice {
  final String id;
  final String title;
  final String subtitle;
  final String locale;
  final String flag;
  final String gender;
  final String qualityBadge;
  final String samplePreview;
  // Matched native voice name on device if available
  String? matchedNativeName;

  CuratedVoice({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.locale,
    required this.flag,
    required this.gender,
    required this.qualityBadge,
    required this.samplePreview,
    this.matchedNativeName,
  });

  /// The 5 official curated voice models for Repeat Speaker
  static List<CuratedVoice> getCuratedList() {
    return [
      CuratedVoice(
        id: 'us_studio_female',
        title: 'US Studio',
        subtitle: 'Natural, articulate American studio tone',
        locale: 'en-US',
        flag: '🇺🇸',
        gender: 'Female',
        qualityBadge: 'Studio HD',
        samplePreview: 'Hello! I am your US Studio voice for smooth, natural repeat listening.',
      ),
      CuratedVoice(
        id: 'us_clarity_male',
        title: 'US Clarity',
        subtitle: 'Deep, focused American narrator',
        locale: 'en-US',
        flag: '🇺🇸',
        gender: 'Male',
        qualityBadge: 'Neural Audio',
        samplePreview: 'Hello! I am your US Clarity voice, built for clear pronunciation and focus.',
      ),
      CuratedVoice(
        id: 'uk_elegance_female',
        title: 'British Elegance',
        subtitle: 'Sophisticated, classic British pronunciation',
        locale: 'en-GB',
        flag: '🇬🇧',
        gender: 'Female',
        qualityBadge: 'Natural HD',
        samplePreview: 'Greetings! I am British Elegance, providing clear and refined phrasing.',
      ),
      CuratedVoice(
        id: 'uk_warmth_male',
        title: 'British Warmth',
        subtitle: 'Warm, calm, authoritative British cadence',
        locale: 'en-GB',
        flag: '🇬🇧',
        gender: 'Male',
        qualityBadge: 'Studio Grade',
        samplePreview:
            'Good day! I am British Warmth, ideal for long memorization loops.',
      ),
      CuratedVoice(
        id: 'au_crisp_natural',
        title: 'Australian Crisp',
        subtitle: 'Bright, friendly Australian cadence',
        locale: 'en-AU',
        flag: '🇦🇺',
        gender: 'Natural',
        qualityBadge: 'Ultra Clear',
        samplePreview: "G'day! I am Australian Crisp, ready to loop your phrases effortlessly.",
      ),
    ];
  }

  /// Binds each curated voice to the highest quality matching native voice on the device.
  static void bindNativeVoices(
    List<CuratedVoice> curatedList,
    List<Map<String, String>> deviceVoices,
  ) {
    if (deviceVoices.isEmpty) return;

    for (final curated in curatedList) {
      final targetLocale = curated.locale.toLowerCase().replaceAll('_', '-');

      // Find matching voices for this locale
      final candidates = deviceVoices.where((v) {
        final loc = (v['locale'] ?? '').toLowerCase().replaceAll('_', '-');
        return loc == targetLocale || loc.startsWith(targetLocale);
      }).toList();

      if (candidates.isEmpty) {
        // Fallback to any en-US or first English voice
        final fallback = deviceVoices.firstWhere(
          (v) => (v['locale'] ?? '').toLowerCase().contains('en'),
          orElse: () => deviceVoices.first,
        );
        curated.matchedNativeName = fallback['name'];
        continue;
      }

      // Prioritize Google natural / neural voices matching gender or id
      Map<String, String>? bestCandidate;
      final isFemale = curated.gender == 'Female';

      for (final c in candidates) {
        final name = (c['name'] ?? '').toLowerCase();
        final matchesGender = isFemale
            ? (name.contains('female') ||
                  name.contains('#f') ||
                  name.contains('woman'))
            : (name.contains('male') ||
                  name.contains('#m') ||
                  name.contains('man'));

        final isHighQuality =
            name.contains('network') ||
            name.contains('google') ||
            name.contains('natural') ||
            name.contains('neural');

        if (matchesGender && isHighQuality) {
          bestCandidate = c;
          break;
        }
      }

      bestCandidate ??= candidates.firstWhere((c) {
        final name = (c['name'] ?? '').toLowerCase();
        return isFemale
            ? (name.contains('female') || name.contains('#f'))
            : (name.contains('male') || name.contains('#m'));
      }, orElse: () => candidates.first);

      curated.matchedNativeName = bestCandidate['name'];
    }
  }
}
