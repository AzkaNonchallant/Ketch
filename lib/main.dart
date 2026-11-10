import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final publishableKey =
        dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
        dotenv.env['SUPABASE_ANON_KEY'] ??
        '';
    if (url.isNotEmpty && publishableKey.isNotEmpty) {
      await Supabase.initialize(url: url, publishableKey: publishableKey);
      runApp(const AnimalDiscoveryApp(supabaseReady: true));
      return;
    }
  } catch (_) {
    // Keep the local preview available when Supabase is not configured.
  }
  runApp(const AnimalDiscoveryApp());
}

const _ink = Color(0xFF171717);
const _paper = Color(0xFFF7F6F2);
const _muted = Color(0xFF77766F);

class AnimalDiscoveryApp extends StatelessWidget {
  const AnimalDiscoveryApp({super.key, this.supabaseReady = false});
  final bool supabaseReady;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Animal Discovery',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _ink,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: _paper,
        foregroundColor: _ink,
        surfaceTintColor: Colors.transparent,
      ),
    ),
    home: supabaseReady ? const _AuthGate() : const DiscoveryShell(),
  );
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: Supabase.instance.client.auth.onAuthStateChange,
    builder: (context, _) =>
        Supabase.instance.client.auth.currentSession == null
        ? const _AuthPage()
        : const DiscoveryShell(backendEnabled: true),
  );
}

class _AuthPage extends StatefulWidget {
  const _AuthPage();

  @override
  State<_AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<_AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_register) {
        final result = await auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (result.session == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cek email untuk konfirmasi akunmu.')),
          );
        }
      } else {
        await auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal terhubung. Coba lagi sebentar.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.nature_people_outlined, size: 52),
                const SizedBox(height: 28),
                Text(
                  _register ? 'Join the explorers.' : 'Welcome back, explorer.',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to keep your field notes together.',
                  style: TextStyle(color: _muted),
                ),
                const SizedBox(height: 24),
                _Panel(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (value) =>
                              value == null || !value.contains('@')
                              ? 'Masukkan email yang valid'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) =>
                              value == null || value.length < 6
                              ? 'Password minimal 6 karakter'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _Button(
                          label: _busy
                              ? 'Please wait…'
                              : (_register ? 'Create account' : 'Sign in'),
                          icon: _register
                              ? Icons.person_add_alt_1
                              : Icons.login,
                          onPressed: _busy ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _register = !_register),
                  child: Text(
                    _register
                        ? 'Already have an account? Sign in'
                        : 'New here? Create an account',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class DiscoveryShell extends StatefulWidget {
  const DiscoveryShell({super.key, this.backendEnabled = false});
  final bool backendEnabled;

  @override
  State<DiscoveryShell> createState() => _DiscoveryShellState();
}

class _DiscoveryShellState extends State<DiscoveryShell> {
  int _tab = 0;
  File? _photo;
  bool _saved = false;
  bool _identifying = false;
  bool _loadingObservations = false;
  String? _identificationError;
  String? _collectionError;
  List<Map<String, dynamic>> _candidates = [];
  List<Map<String, dynamic>> _observations = [];
  int _selectedCandidate = 0;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.backendEnabled) _loadObservations();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 85);
    if (image != null && mounted) {
      setState(() {
        _photo = File(image.path);
        _saved = false;
        _candidates = [];
        _selectedCandidate = 0;
        _identificationError = null;
        _tab = 1;
      });
    }
  }

  Future<void> _identifyPhoto() async {
    if (_photo == null) return;
    setState(() {
      _identifying = true;
      _identificationError = null;
      _candidates = [];
    });
    try {
      final path = _photo!.path.toLowerCase();
      final mimeType = path.endsWith('.png')
          ? 'image/png'
          : path.endsWith('.webp')
          ? 'image/webp'
          : 'image/jpeg';
      final response = await Supabase.instance.client.functions.invoke(
        'identify-animal',
        body: {
          'mimeType': mimeType,
          'image': base64Encode(await _photo!.readAsBytes()),
        },
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final candidates = (data['candidates'] as List? ?? [])
          .map((candidate) => Map<String, dynamic>.from(candidate as Map))
          .toList();
      if (!mounted) return;
      setState(() {
        _candidates = candidates;
        _selectedCandidate = 0;
        if (candidates.isEmpty) {
          _identificationError =
              'Tidak ada hewan yang bisa dikenali di foto ini. Coba foto lain.';
        }
      });
    } on FunctionException catch (error) {
      if (mounted) {
        setState(
          () => _identificationError = error.details is Map
              ? (error.details as Map)['error']?.toString() ??
                    error.reasonPhrase
              : error.reasonPhrase,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _identificationError =
              'Identifikasi gagal. Periksa koneksi lalu coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _identifying = false);
    }
  }

  Future<void> _saveDiscovery() async {
    if (!widget.backendEnabled) {
      setState(() => _saved = true);
      return;
    }
    if (_photo == null || _candidates.isEmpty) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final candidate = _candidates[_selectedCandidate];
    final path = _photo!.path.toLowerCase();
    final extension = path.endsWith('.png')
        ? 'png'
        : path.endsWith('.webp')
        ? 'webp'
        : 'jpg';
    final mimeType = extension == 'jpg' ? 'image/jpeg' : 'image/$extension';
    final imagePath = '${user.id}/${const Uuid().v4()}.$extension';
    try {
      await Supabase.instance.client.storage
          .from('observations')
          .upload(
            imagePath,
            _photo!,
            fileOptions: FileOptions(contentType: mimeType),
          );
      try {
        await Supabase.instance.client.from('observations').insert({
          'user_id': user.id,
          'image_path': imagePath,
          'common_name': candidate['common_name'],
          'scientific_name': candidate['scientific_name'],
          'confidence': candidate['confidence'],
          'description': candidate['description'],
        });
      } catch (_) {
        await Supabase.instance.client.storage.from('observations').remove([
          imagePath,
        ]);
        rethrow;
      }
      if (mounted) {
        setState(() => _saved = true);
        await _loadObservations();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Penemuan disimpan ke koleksi.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan. Coba lagi sebentar.')),
        );
      }
    }
  }

  Future<void> _loadObservations() async {
    if (!widget.backendEnabled) return;
    setState(() {
      _loadingObservations = true;
      _collectionError = null;
    });
    try {
      final rows = await Supabase.instance.client
          .from('observations')
          .select()
          .order('created_at', ascending: false);
      final observations = <Map<String, dynamic>>[];
      for (final row in rows) {
        final observation = Map<String, dynamic>.from(row);
        observation['image_url'] = await Supabase.instance.client.storage
            .from('observations')
            .createSignedUrl(observation['image_path'] as String, 3600);
        observations.add(observation);
      }
      if (mounted) setState(() => _observations = observations);
    } catch (_) {
      if (mounted) {
        setState(
          () => _collectionError =
              'Koleksi gagal dimuat. Tarik untuk mencoba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _loadingObservations = false);
    }
  }

  Future<void> _deleteObservation(Map<String, dynamic> observation) async {
    try {
      await Supabase.instance.client
          .from('observations')
          .delete()
          .eq('id', observation['id']);
      try {
        await Supabase.instance.client.storage.from('observations').remove([
          observation['image_path'] as String,
        ]);
      } catch (_) {
        // The record is gone; failed cleanup only leaves a private orphaned file.
      }
      await _loadObservations();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus penemuan. Coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomePage(
        onDiscover: () => setState(() => _tab = 1),
        savedCount: widget.backendEnabled
            ? _observations.length
            : (_saved ? 1 : 0),
      ),
      _DiscoveryPage(
        photo: _photo,
        onPick: _pickImage,
        saved: _saved,
        onSave: _saveDiscovery,
        backendEnabled: widget.backendEnabled,
        candidates: _candidates,
        selectedCandidate: _selectedCandidate,
        identifying: _identifying,
        error: _identificationError,
        onIdentify: _identifyPhoto,
        onSelectCandidate: (index) =>
            setState(() => _selectedCandidate = index),
      ),
      _CollectionPage(
        photo: _photo,
        saved: _saved,
        observations: _observations,
        loading: _loadingObservations,
        error: _collectionError,
        onRefresh: _loadObservations,
        onDelete: _deleteObservation,
        onDiscover: () => setState(() => _tab = 1),
      ),
      const _AchievementsPage(),
      const _ProfilePage(),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _tab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          setState(() => _tab = index);
          if (index == 2) _loadObservations();
        },
        backgroundColor: _paper,
        indicatorColor: _ink,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.center_focus_weak),
            selectedIcon: Icon(Icons.center_focus_strong, color: Colors.white),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark, color: Colors.white),
            label: 'Collection',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: Colors.white),
            label: 'Awards',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.onDiscover, required this.savedCount});
  final VoidCallback onDiscover;
  final int savedCount;

  @override
  Widget build(BuildContext context) => _Page(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'ANIMAL DISCOVERY',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Hello, explorer.',
          style: TextStyle(
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'A little curiosity goes a long way.',
          style: TextStyle(color: _muted, fontSize: 16),
        ),
        const SizedBox(height: 26),
        _Panel(
          color: _ink,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.nature_people_outlined,
                color: Colors.white,
                size: 34,
              ),
              const SizedBox(height: 24),
              const Text(
                'What did you\ncome across?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Take a closer look at the wildlife around you.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 22),
              _Button(
                label: 'Identify an animal',
                icon: Icons.arrow_forward,
                onPressed: onDiscover,
                inverted: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _SectionTitle('Your field notes', trailing: 'TODAY'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '$savedCount',
                label: 'Species saved',
                icon: Icons.bookmark_outline,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: _StatTile(
                value: '1 day',
                label: 'Current streak',
                icon: Icons.local_fire_department_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _Panel(
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 28),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Look, don’t disturb',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Give wild animals space and observe safely.',
                      style: TextStyle(color: _muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DiscoveryPage extends StatelessWidget {
  const _DiscoveryPage({
    required this.photo,
    required this.onPick,
    required this.saved,
    required this.onSave,
    required this.backendEnabled,
    required this.candidates,
    required this.selectedCandidate,
    required this.identifying,
    required this.error,
    required this.onIdentify,
    required this.onSelectCandidate,
  });
  final File? photo;
  final Future<void> Function(ImageSource) onPick;
  final bool saved;
  final VoidCallback onSave;
  final bool backendEnabled, identifying;
  final List<Map<String, dynamic>> candidates;
  final int selectedCandidate;
  final String? error;
  final VoidCallback onIdentify;
  final ValueChanged<int> onSelectCandidate;

  @override
  Widget build(BuildContext context) => _Page(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Discovery',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Start with a photo of your find.',
          style: TextStyle(color: _muted),
        ),
        const SizedBox(height: 22),
        if (photo == null) ...[
          _Panel(
            child: Column(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEAE4),
                    border: Border.all(color: _ink, width: 2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.photo_camera_outlined, size: 64),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Ready when you are',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a clear photo where the animal is easy to see.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted),
                ),
                const SizedBox(height: 20),
                _Button(
                  label: 'Take a photo',
                  icon: Icons.camera_alt_outlined,
                  onPressed: () => onPick(ImageSource.camera),
                ),
                const SizedBox(height: 10),
                _Button(
                  label: 'Choose from gallery',
                  icon: Icons.photo_library_outlined,
                  onPressed: () => onPick(ImageSource.gallery),
                  outlined: true,
                ),
              ],
            ),
          ),
        ] else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              photo!,
              height: 270,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (backendEnabled) ...[
                  const Text(
                    'Identification',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Hasil AI adalah rekomendasi, bukan kepastian ilmiah.',
                    style: TextStyle(color: _muted),
                  ),
                  if (candidates.isEmpty) ...[
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        style: const TextStyle(color: Color(0xFF9B2525)),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _Button(
                      label: identifying
                          ? 'Menganalisis foto…'
                          : 'Identify animal',
                      icon: identifying
                          ? Icons.hourglass_top
                          : Icons.auto_awesome_outlined,
                      onPressed: identifying ? null : onIdentify,
                    ),
                  ] else ...[
                    const SizedBox(height: 14),
                    for (var i = 0; i < candidates.length; i++) ...[
                      _CandidateCard(
                        candidate: candidates[i],
                        selected: selectedCandidate == i,
                        onTap: () => onSelectCandidate(i),
                      ),
                      if (i < candidates.length - 1) const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 16),
                    _Button(
                      label: saved
                          ? 'Saved to collection'
                          : 'Confirm & save discovery',
                      icon: saved ? Icons.check : Icons.bookmark_add_outlined,
                      onPressed: saved ? null : onSave,
                    ),
                  ],
                ] else ...[
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sample identification',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _Tag('DEMO'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is a preview only',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AI identification is not connected yet. No species has been identified from this photo.',
                    style: TextStyle(color: _muted),
                  ),
                  const SizedBox(height: 16),
                  _Button(
                    label: saved
                        ? 'Saved to collection'
                        : 'Save photo to collection',
                    icon: saved ? Icons.check : Icons.bookmark_add_outlined,
                    onPressed: saved ? null : onSave,
                  ),
                ],
                const SizedBox(height: 10),
                _Button(
                  label: 'Choose another photo',
                  icon: Icons.refresh,
                  onPressed: () => onPick(ImageSource.gallery),
                  outlined: true,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        const Text(
          'Tip: photograph from a safe distance. Never handle wildlife for a better shot.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
      ],
    ),
  );
}

class _CollectionPage extends StatelessWidget {
  const _CollectionPage({
    required this.photo,
    required this.saved,
    required this.observations,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onDelete,
    required this.onDiscover,
  });
  final File? photo;
  final bool saved;
  final List<Map<String, dynamic>> observations;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Map<String, dynamic>) onDelete;
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) => _Page(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Collection',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          observations.isNotEmpty
              ? '${observations.length} field notes saved'
              : saved
              ? '1 field note saved'
              : 'Your discoveries, all in one place.',
          style: const TextStyle(color: _muted),
        ),
        const SizedBox(height: 22),
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (error != null)
          _Panel(
            child: Column(
              children: [
                Text(error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                _Button(
                  label: 'Try again',
                  icon: Icons.refresh,
                  onPressed: onRefresh,
                ),
              ],
            ),
          )
        else if (observations.isNotEmpty)
          for (final observation in observations) ...[
            _ObservationCard(
              observation: observation,
              onDelete: () => onDelete(observation),
            ),
            const SizedBox(height: 14),
          ]
        else if (saved && photo != null)
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    photo!,
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Unidentified observation',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Saved today · awaiting identification',
                  style: TextStyle(color: _muted),
                ),
                const SizedBox(height: 12),
                const _Tag('PHOTO NOTE'),
              ],
            ),
          )
        else
          _Panel(
            child: Column(
              children: [
                const Icon(Icons.collections_bookmark_outlined, size: 54),
                const SizedBox(height: 14),
                const Text(
                  'Your collection is waiting',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Save a photo or confirmed species and it’ll show up here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted),
                ),
                const SizedBox(height: 18),
                _Button(
                  label: 'Start exploring',
                  icon: Icons.arrow_forward,
                  onPressed: onDiscover,
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _AchievementsPage extends StatelessWidget {
  const _AchievementsPage();
  @override
  Widget build(BuildContext context) => _Page(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Achievements',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Small steps make great explorers.',
          style: TextStyle(color: _muted),
        ),
        const SizedBox(height: 22),
        const _Achievement(
          icon: Icons.flag_outlined,
          title: 'First Discovery',
          description: 'Save your first observation',
          progress: '0 / 1',
        ),
        const SizedBox(height: 12),
        const _Achievement(
          icon: Icons.explore_outlined,
          title: 'Explorer',
          description: 'Discover 5 different species',
          progress: '0 / 5',
        ),
        const SizedBox(height: 12),
        const _Achievement(
          icon: Icons.calendar_month_outlined,
          title: 'Consistent Explorer',
          description: 'Explore on 7 different days',
          progress: '1 / 7',
        ),
      ],
    ),
  );
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();
  @override
  Widget build(BuildContext context) => _Page(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Profile',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 22),
        _Panel(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: _ink,
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guest explorer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Local preview profile',
                    style: TextStyle(color: _muted),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _MenuRow(
          icon: Icons.insights_outlined,
          title: 'Exploration statistics',
        ),
        const _MenuRow(icon: Icons.notifications_none, title: 'Notifications'),
        const _MenuRow(
          icon: Icons.info_outline,
          title: 'About Animal Discovery',
        ),
        const SizedBox(height: 12),
        const Text(
          'Profile sync is managed by your Supabase account.',
          style: TextStyle(color: _muted),
        ),
        const SizedBox(height: 14),
        _Button(
          label: 'Sign out',
          icon: Icons.logout,
          outlined: true,
          onPressed: () async {
            try {
              await Supabase.instance.client.auth.signOut();
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal keluar. Coba lagi.')),
                );
              }
            }
          },
        ),
      ],
    ),
  );
}

class _Achievement extends StatelessWidget {
  const _Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
  });
  final IconData icon;
  final String title, description, progress;
  @override
  Widget build(BuildContext context) => _Panel(
    child: Row(
      children: [
        Icon(icon, size: 32),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: _muted)),
            ],
          ),
        ),
        Text(progress, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.selected,
    required this.onTap,
  });
  final Map<String, dynamic> candidate;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final confidence = (candidate['confidence'] as num).toDouble();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0EFEA) : Colors.white,
          border: Border.all(color: _ink, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate['common_name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    candidate['scientific_name'] as String,
                    style: const TextStyle(
                      color: _muted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    candidate['description'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(confidence * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObservationCard extends StatelessWidget {
  const _ObservationCard({required this.observation, required this.onDelete});
  final Map<String, dynamic> observation;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            observation['image_url'] as String,
            height: 210,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              height: 140,
              color: const Color(0xFFECEAE4),
              child: const Center(
                child: Icon(Icons.broken_image_outlined, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          observation['common_name'] as String? ?? 'Unidentified observation',
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        if (observation['scientific_name'] != null) ...[
          const SizedBox(height: 3),
          Text(
            observation['scientific_name'] as String,
            style: const TextStyle(color: _muted, fontStyle: FontStyle.italic),
          ),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                'Saved ${DateTime.parse(observation['created_at'] as String).toLocal().toString().substring(0, 10)}',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ),
            IconButton(
              tooltip: 'Remove from collection',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ],
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: _ink),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    trailing: const Icon(Icons.chevron_right),
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String value, label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        Text(label, style: const TextStyle(color: _muted, fontSize: 13)),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.trailing});
  final String title, trailing;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
      ),
      Text(
        trailing,
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w800,
          color: _muted,
        ),
      ),
    ],
  );
}

class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
    child: child,
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.color = Colors.white});
  final Widget child;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: _ink, width: 1.7),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: _ink, offset: Offset(4, 4))],
    ),
    child: child,
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      border: Border.all(color: _ink),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    ),
  );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
    this.inverted = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool outlined, inverted;
  @override
  Widget build(BuildContext context) {
    final background = inverted
        ? Colors.white
        : (outlined ? Colors.transparent : _ink);
    final foreground = inverted || outlined ? _ink : Colors.white;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: inverted ? Colors.white : _ink, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: _ink, offset: Offset(3, 3))],
        ),
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 19),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            disabledBackgroundColor: background,
            disabledForegroundColor: foreground.withValues(alpha: 0.65),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
