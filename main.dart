// main.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const SmokeApp());

enum Language { english, chinese, french }

class SmokeApp extends StatefulWidget {
  const SmokeApp({super.key});
  @override
  State<SmokeApp> createState() => _SmokeAppState();
}

class _SmokeAppState extends State<SmokeApp> {
  Language _lang = Language.english;
  String? _registeredEmail;
  String? _registeredPassword;

  void _registerUser(String email, String password) {
    setState(() {
      _registeredEmail = email;
      _registeredPassword = password;
    });
  }

  void _switchLanguage(Language lang) {
    setState(() => _lang = lang);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smoke App',
      debugShowCheckedModeBanner: false,
      home: StartPage(
        language: _lang,
        onLangChange: _switchLanguage,
        registeredEmail: _registeredEmail,
        registeredPassword: _registeredPassword,
        onRegistered: _registerUser,
      ),
    );
  }
}

class StartPage extends StatelessWidget {
  final Language language;
  final void Function(Language) onLangChange;
  final String? registeredEmail;
  final String? registeredPassword;
  final void Function(String, String) onRegistered;

  const StartPage({
    super.key,
    required this.language,
    required this.onLangChange,
    required this.registeredEmail,
    required this.registeredPassword,
    required this.onRegistered,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t("Smoke App", language)),
        actions: [
          PopupMenuButton<Language>(
            icon: const Icon(Icons.language),
            onSelected: onLangChange,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Language.english,
                child: Text("English"),
              ),
              const PopupMenuItem(value: Language.chinese, child: Text("中文")),
              const PopupMenuItem(
                value: Language.french,
                child: Text("Français"),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RegisterPage(
                    language: language,
                    onRegistered: onRegistered,
                  ),
                ),
              ),
              child: Text(_t("Register", language)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginPage(
                    language: language,
                    registeredEmail: registeredEmail,
                    registeredPassword: registeredPassword,
                    onLoginSuccess: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    ),
                  ),
                ),
              ),
              child: Text(_t("Login", language)),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  final Language language;
  final void Function(String, String) onRegistered;

  const RegisterPage({required this.language, required this.onRegistered});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? confirm;
  String code = '';
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  String generateCode() => List.generate(6, (_) => Random().nextInt(10)).join();

  void sendCode() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      code = generateCode();
      print("Verification code: $code");
      _showCodeDialog();
    }
  }

  void _showCodeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_t("Enter Code", widget.language)),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: _t("Enter 6-digit code", widget.language),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (codeController.text == code) {
                Navigator.pop(context);
                _showPasswordDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_t("Invalid code", widget.language))),
                );
              }
            },
            child: Text(_t("Verify", widget.language)),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_t("Set Password", widget.language)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: _t("Password", widget.language),
              ),
            ),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: _t("Confirm Password", widget.language),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (passwordController.text == confirmController.text &&
                  passwordController.text.length >= 6) {
                widget.onRegistered(email!, passwordController.text);
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _t("Passwords do not match", widget.language),
                    ),
                  ),
                );
              }
            },
            child: Text(_t("Register", widget.language)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(_t("Register", widget.language)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: _t("Email", widget.language),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => email = v,
                validator: (v) => v!.contains('@')
                    ? null
                    : _t("Invalid email", widget.language),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendCode,
                child: Text(_t("Send Verification Code", widget.language)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final Language language;
  final String? registeredEmail;
  final String? registeredPassword;
  final VoidCallback onLoginSuccess;

  LoginPage({
    required this.language,
    required this.registeredEmail,
    required this.registeredPassword,
    required this.onLoginSuccess,
  });

  final emailCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(_t("Login", language)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: _t("Email", language)),
            ),
            TextField(
              controller: pwdCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: _t("Password", language)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (emailCtrl.text == registeredEmail &&
                    pwdCtrl.text == registeredPassword) {
                  onLoginSuccess();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_t("Invalid credentials", language)),
                    ),
                  );
                }
              },
              child: Text(_t("Login", language)),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int openCount = 0;
  int dailyLimit = 10;
  DateTime today = DateTime.now();

  void incrementCounter() {
    if (openCount < dailyLimit) {
      setState(() => openCount++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La limite journalière a été dépassée et l'étui à cigarettes est verrouillé !",
          ),
        ),
      );
    }
  }

  void resetCountIfNewDay() {
    final now = DateTime.now();
    if (now.day != today.day ||
        now.month != today.month ||
        now.year != today.year) {
      setState(() {
        today = now;
        openCount = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    resetCountIfNewDay();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildMainTab(),
      const UsageChartPage(),
      const CommunityPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Boîte intelligente"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Homepage'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Communautaire',
          ),
        ],
      ),
    );
  }

  Widget _buildMainTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Nombre d'ouvertures aujourd'hui :$openCount / $dailyLimit",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: incrementCounter,
            child: const Text("Simuler l'ouverture d'un paquet de cigarettes"),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text("Fixer la limite journalière. "),
              Expanded(
                child: Slider(
                  value: dailyLimit.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: dailyLimit.toString(),
                  onChanged: (val) => setState(() => dailyLimit = val.toInt()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Aide et contact"),
        content: const Text(
          "Adress: 12 Av. Léonard de Vinci, 92400 Courbevoie\n"
          "Twitter/Instagram: smoke_team\n"
          "Telephone: 07 12 34 56 78\n"
          "Email: smoketeam@gmail.com",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }
}

class UsageChartPage extends StatelessWidget {
  const UsageChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> weeklyUsage = [
      {'week': 'W1', 'avg': 9},
      {'week': 'W2', 'avg': 7},
      {'week': 'W3', 'avg': 6},
      {'week': 'W4', 'avg': 5},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(" La fréquence à laquelle vous fumez !"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: WeeklyLineChart(weeklyUsage: weeklyUsage),
      ),
    );
  }
}

class WeeklyLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyUsage;

  const WeeklyLineChart({super.key, required this.weeklyUsage});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChartWidget(weeklyUsage: weeklyUsage),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyUsage;

  const LineChartWidget({super.key, required this.weeklyUsage});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < weeklyUsage.length) {
                  return Text(weeklyUsage[index]['week']);
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
            ),
          ),
        ),
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: List.generate(
              weeklyUsage.length,
              (index) => FlSpot(
                index.toDouble(),
                (weeklyUsage[index]['avg'] as num).toDouble(),
              ),
            ),
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<_Post> posts = [];
  final TextEditingController commentCtrl = TextEditingController();
  File? selectedImage;

  final picker = ImagePicker();

  void _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => selectedImage = File(pickedFile.path));
    }
  }

  void _submitPost() {
    if (commentCtrl.text.isNotEmpty || selectedImage != null) {
      posts.insert(0, _Post(commentCtrl.text, selectedImage));
      commentCtrl.clear();
      selectedImage = null;
      setState(() {});
    }
  }

  void _showExpertContact() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Contacter un expert"),
        content: const Text(
          "Dr. Jeanne Dupont\n"
          "Spécialiste en tabacologie\n"
          "Téléphone : 06 45 12 89 23\n"
          "Email : jeanne.dupont@smoketeam.fr\n\n"
          "Dr. Marc Lemoine\n"
          "Psychologue addictologue\n"
          "Téléphone : 07 88 56 32 10\n"
          "Email : marc.lemoine@smoketeam.fr\n\n",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("communautaire"),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: _showExpertContact,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPostInput(),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, i) => _buildPostTile(posts[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostInput() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: commentCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText:
                  "Notez vos mots de motivation ou vos sentiments à l'égard de l'arrêt du tabac.",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Télécharger une image"),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _submitPost,
                icon: const Icon(Icons.send),
                label: const Text("Post"),
              ),
            ],
          ),
          if (selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Image.file(selectedImage!, height: 100),
            ),
        ],
      ),
    );
  }

  Widget _buildPostTile(_Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(post.text),
        subtitle: post.image != null
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.file(post.image!, height: 150),
              )
            : null,
      ),
    );
  }
}

class _Post {
  final String text;
  final File? image;
  _Post(this.text, this.image);
}

String _t(String text, Language lang) {
  final key = lang.name;
  final map = {
    'Smoke App': {'chinese': '智能烟盒', 'french': 'Fumée'},
    'Register': {'chinese': '注册', 'french': 'Inscription'},
    'Login': {'chinese': '登录', 'french': 'Connexion'},
    'Email': {'chinese': '邮箱', 'french': 'E-mail'},
    'Password': {'chinese': '密码', 'french': 'Mot de passe'},
    'Confirm Password': {'chinese': '确认密码', 'french': 'Confirmer'},
    'Send Verification Code': {'chinese': '发送验证码', 'french': 'Envoyer le code'},
    'Enter Code': {'chinese': '输入验证码', 'french': 'Entrez le code'},
    'Enter 6-digit code': {'chinese': '输入6位码', 'french': 'Code à 6 chiffres'},
    'Verify': {'chinese': '验证', 'french': 'Vérifier'},
    'Set Password': {'chinese': '设置密码', 'french': 'Définir le mot de passe'},
    'Passwords do not match': {
      'chinese': '密码不一致',
      'french': 'Mot de passe différent',
    },
    'Invalid email': {'chinese': '无效邮箱', 'french': 'Email invalide'},
    'Invalid code': {'chinese': '验证码错误', 'french': 'Code incorrect'},
    'Invalid credentials': {
      'chinese': '账号或密码错误',
      'french': 'Identifiants erronés',
    },
  };
  return map[text]?[key] ?? text;
}
