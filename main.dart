// main.dart
import 'dart:math';
import 'package:flutter/material.dart';

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
                    onLoginSuccess: () => Navigator.pushReplacement(
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smoke App"),
        leading: const BackButton(),
      ),
      body: const Center(child: Text("Welcome to Smoke App 🚬")),
    );
  }
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
