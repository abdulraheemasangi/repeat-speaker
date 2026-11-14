import 'package:flutter/material.dart';

class VoiceSelectorDialog extends StatelessWidget {
  final List<Map<String, String>> voices;
  final Map<String, String>? currentVoice;
  final ValueChanged<Map<String, String>> onVoiceSelected;

  const VoiceSelectorDialog({
    super.key,
    required this.voices,
    required this.currentVoice,
    required this.onVoiceSelected,
  });

  String _cleanVoiceName(String name) {
    if (name.isEmpty) return "Default Voice";
    // Many Android voices have names like en-us-x-sfg#female_1-local
    // Let's make it more friendly to read
    return name
        .replaceAll('en-us-x-', 'US: ')
        .replaceAll('en-gb-x-', 'UK: ')
        .replaceAll('en-au-x-', 'AU: ')
        .replaceAll('en-in-x-', 'IN: ')
        .replaceAll('-local', ' (Offline)')
        .replaceAll('-network', ' (High Quality)');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.record_voice_over_rounded, color: colorScheme.primary),
          const SizedBox(width: 10),
          const Text(
            "English Voices",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      content: SizedBox(
        width: double.maxFinite,
        child: voices.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "No alternative English voices found on this device. Using system default voice.",
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: voices.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final voice = voices[index];
                  final name = voice['name'] ?? '';
                  final locale = voice['locale'] ?? '';
                  final isSelected =
                      currentVoice != null &&
                      currentVoice!['name'] == name &&
                      currentVoice!['locale'] == locale;

                  final bool isGoogle =
                      name.toLowerCase().contains('google') ||
                      name.toLowerCase().contains('natural');

                  return RadioListTile<String>(
                    value: "$name|$locale",
                    groupValue: currentVoice != null
                        ? "${currentVoice!['name']}|${currentVoice!['locale']}"
                        : null,
                    onChanged: (_) {
                      onVoiceSelected(voice);
                      Navigator.of(context).pop();
                    },
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _cleanVoiceName(name),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isGoogle)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Google",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      locale,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.outline,
                      ),
                    ),
                    activeColor: colorScheme.primary,
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
