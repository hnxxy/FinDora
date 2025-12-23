import 'package:flutter/material.dart';
import 'login_email.dart';
import 'sing_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3C4C4), Color(0xFFD88B8B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Image.asset(
                      'assets/logo_findora.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // WELCOME TEXT
                  const Text(
                    'WELCOME',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // LOGIN WITH GOOGLE BUTTON
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97D7D),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text(
                      'Login with google',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () async {
                      // Open Google account picker & sign in
                      try {
                        final GoogleSignInAccount? account =
                            await GoogleSignIn().signIn();
                        if (account == null) {
                          // User cancelled the picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login dibatalkan')),
                          );
                          return;
                        }

                        // You can access account.email, account.displayName, etc.
                        // Optionally exchange tokens via account.authentication
                        // For now navigate to home after successful sign-in
                        Navigator.pushNamed(context, '/home');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login gagal: $e')),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // LOGIN WITH EMAIL BUTTON
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97D7D),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.email_outlined, size: 24),
                    label: const Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginEmail(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  // REGISTER LINK → ke halaman signup
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SignUpScreen(), // ✅ arahkan ke halaman signup
                        ),
                      );
                    },
                    child: const Text(
                      'Belum memiliki akun? Daftar',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
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
}
