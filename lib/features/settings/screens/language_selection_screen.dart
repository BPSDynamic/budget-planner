import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/language_provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = context.read<LanguageProvider>().currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        elevation: 0,
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return ListView.builder(
            itemCount: languageProvider.languages.length,
            itemBuilder: (context, index) {
              final language = languageProvider.languages[index];
              final isSelected = _selectedLanguage == language;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectLanguage(context, language),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            language,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        else
                          Icon(
                            Icons.circle_outlined,
                            color: Colors.grey.shade400,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _selectLanguage(BuildContext context, String language) async {
    await context.read<LanguageProvider>().setLanguage(language);
    await context.read<SettingsProvider>().setLanguage(language);
    setState(() {
      _selectedLanguage = language;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Language changed to $language')),
      );
      Navigator.pop(context);
    }
  }
}
