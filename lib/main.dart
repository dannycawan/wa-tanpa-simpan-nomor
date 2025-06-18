import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale _locale = const Locale('id');

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBannerAds();
  }

  void _loadBannerAds() {
    _topBannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6721734106426198/3033200286', // AdMob Asli
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => print('Top Banner Ad Loaded'),
        onAdFailedToLoad: (ad, error) {
          print('Top Banner Ad Failed: $error');
          ad.dispose();
        },
      ),
    )..load();

    _bottomBannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6721734106426198/3033200286', // AdMob Asli
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => print('Bottom Banner Ad Loaded'),
        onAdFailedToLoad: (ad, error) {
          print('Bottom Banner Ad Failed: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _switchLanguage(String lang) {
    setState(() {
      _locale = Locale(lang);
    });
  }

  String t(String id) {
    final translations = {
      'app_title': {
        'id': 'WA Tanpa Simpan Nomor',
        'en': 'WA Without Save Number',
      },
      'select_language': {'id': 'Pilih Bahasa', 'en': 'Select Language'},
      'enter_number': {'id': 'Masukkan nomor WA', 'en': 'Enter WA number'},
      'example_number': {
        'id': 'Contoh: 6281234567890 (tanpa + atau 0 di depan)',
        'en': 'Example: 15551234567 (no + or leading 0)',
      },
      'enter_message': {'id': 'Tulis pesan Anda', 'en': 'Write your message'},
      'send_to_wa': {'id': 'Kirim ke WA', 'en': 'Send to WA'},
      'empty_number': {
        'id': 'Nomor tidak boleh kosong!',
        'en': 'Number cannot be empty!',
      },
      'opening_wa': {'id': 'Membuka WA...', 'en': 'Opening WhatsApp...'},
    };
    return translations[id]?[_locale.languageCode] ?? id;
  }

  Future<void> _launchWA() async {
    String rawPhone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');

    if (rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('empty_number'))),
      );
      return;
    }

    // Format nomor: jika mulai dari 0, ubah ke 62 (Indonesia)
    final phone = rawPhone.startsWith('0')
        ? '62${rawPhone.substring(1)}'
        : rawPhone;

    final message = Uri.encodeComponent(_messageController.text.trim());
    final url = 'https://api.whatsapp.com/send?phone=$phone&text=$message';
    final uri = Uri.parse(url);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('opening_wa'))),
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka WhatsApp')),
      );
    }
  }

  @override
  void dispose() {
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: t('app_title'),
      locale: _locale,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.green[700],
          title: Text(t('app_title')),
          actions: [
            DropdownButton<String>(
              value: _locale.languageCode,
              dropdownColor: Colors.white,
              underline: const SizedBox(),
              icon: const Icon(Icons.language, color: Colors.white),
              onChanged: (String? lang) {
                if (lang != null) _switchLanguage(lang);
              },
              items: const [
                DropdownMenuItem(value: 'id', child: Text('🇮🇩 ID')),
                DropdownMenuItem(value: 'en', child: Text('🇺🇸 EN')),
              ],
            )
          ],
        ),
        body: Column(
          children: [
            if (_topBannerAd != null)
              SizedBox(height: 50, child: AdWidget(ad: _topBannerAd!)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: t('enter_number'),
                        hintText: t('example_number'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: t('enter_message'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: _launchWA,
                      icon: const Icon(Icons.send),
                      label: Text(t('send_to_wa')),
                    ),
                  ],
                ),
              ),
            ),
            if (_bottomBannerAd != null)
              SizedBox(height: 50, child: AdWidget(ad: _bottomBannerAd!)),
          ],
        ),
      ),
    );
  }
}
