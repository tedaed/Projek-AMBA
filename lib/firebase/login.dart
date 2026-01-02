import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/data/data_buku.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'registerEmail.dart';
import 'registerGoogle.dart';
import 'lupaPassword.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late final GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    // ✅ Initialize GoogleSignIn dengan clientId untuk Web
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb 
        ? '548588515842-7prmqlk98atl3oesior8q4d0gl7gqd4t.apps.googleusercontent.com'
        : null,
      scopes: ['email', 'profile'],
    );
  }

  Future<void> signInWithEmailPassword() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password tidak boleh kosong')),
      );
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Verifikasi Email'),
              content: const Text(
                'Kami telah mengirimkan email verifikasi untuk akun anda.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ok'),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (user != null && user.emailVerified) {
        final prefs = await SharedPreferences.getInstance();
        final username = prefs.getString('pending_username_${user.email}');
        final gender = prefs.getString('gender_temp_${user.email}');

        if (username != null && gender != null) {
          await user.updateDisplayName(username);
          await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
            'gender': gender,
          });
          await prefs.remove('username_temp_${user.email}');
          await prefs.remove('gender_temp_${user.email}');
        }

        if (mounted) {
          Navigator.pushNamed(context, '/home');
        }
      }
    } on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan, silahkan diulang kembali')),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      // ✅ Sign out dulu untuk clear cache
      await _googleSignIn.signOut();

      // ✅ Trigger Google Sign In
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ User cancelled sign in');
        return;
      }

      final email = googleUser.email;

      final googleAuth = await googleUser.authentication;
      
      print('✅ ID TOKEN: ${googleAuth.idToken}');
      print('✅ ACCESS TOKEN: ${googleAuth.accessToken}');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();

      if (!mounted) return;

      if (userDoc.exists) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterGooglePage(
              email: email,
              initialUsername: user.displayName,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      String message;
      if (e.code == 'account-exists-with-different-credential') {
        message = 'Akun dengan email ini sudah ada. Silakan login dengan email dan password.';
      } else {
        message = 'Terjadi kesalahan saat login dengan Google: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  Future<void> signUp() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegisterEmailPage()),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(URL_backgroundLogin),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "MUSA",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: signInWithEmailPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Login"),
              ),
              const SizedBox(height: 1),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                  );
                },
                child: const Text(
                  'Lupa kata sandi?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("atau"),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: Image.asset('assets/icon/google.png', height: 24),
                label: const Text("Lanjutkan dengan Google"),
                onPressed: signInWithGoogle,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: signUp,
                child: const Text("Belum punya akun? Registrasi!"),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dengan mendaftar, Anda sudah menyetujui',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    launchUrl(Uri.parse('https://www.alkitab.or.id/tentang-kami/syarat-ketentuan'));
                  },
                  child: const Text(
                    'Syarat dan Ketentuan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Text(' serta ', style: TextStyle(fontSize: 12)),
                InkWell(
                  onTap: () {
                    launchUrl(Uri.parse('https://www.alkitab.or.id/tentang-kami/kebijakan-privasi'));
                  },
                  child: const Text(
                    'Kebijakan Privasi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
