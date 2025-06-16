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
  late InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBannerAds();
    _loadInterstitialAd();
  }

  void _loadBannerAds() {
    _topBannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6721734106426198/3033200286',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();

    _bottomBannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6721734106426198/3033200286',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-6721734106426198/8389554469',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _switchLanguage(String lang) {
    setState(() {
      _locale = Locale(lang);
    });
  }

  String t(String id, {String? lang}) {
    final translations = {
      'select_language': {'id': 'Pilih Bahasa', 'en': 'Select Language'},
      'enter_number': {'id': 'Masukkan nomor WA', 'en': 'Enter WA number'},
      'enter_message': {'id': 'Tulis pesan Anda', 'en': 'Write your message'},
      'send_to_wa': {'id': 'Kirim ke WA', 'en': 'Send to WA'},
      'empty_number': {
        'id': 'Nomor tidak boleh kosong!',
        'en': 'Number cannot be empty!'
      },
      'opening_wa': {'id': 'Membuka WA...', 'en': 'Opening WA...'},
    };

    return translations[id]?[_locale.languageCode] ?? id;
  }

  Future<void> _launchWA() async {
    final phone = _phoneController.text.trim();
    final message = Uri.encodeComponent(_messageController.text);

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t('empty_number')),
      ));
      return;
    }

    final url = 'https://wa.me/$phone?text=$message';

    if (_isInterstitialAdReady) {
      _interstitialAd?.show();
      _loadInterstitialAd();
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t('opening_wa')),
    ));

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    _interstitialAd?.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInterstitialAdReady) {
      _interstitialAd?.show();
      _loadInterstitialAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WA Tanpa Simpan Nomor',
      locale: _locale,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.green[700],
          title: const Text('WA Tanpa Simpan Nomor'),
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
