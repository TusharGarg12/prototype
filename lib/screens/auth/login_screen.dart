import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'student';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(email, _selectedRole);

    if (!mounted) return;

    if (ok) {
      if (_selectedRole == 'admin') {
        context.go('/admin');
      } else if (_selectedRole == 'kitchen') {
        context.go('/kitchen?role=kitchen');
      } else {
        context.go('/dashboard');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Login failed'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return GlobalGlassScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64, height: 64,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('SM', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF1E293B))),
              ),

              const Text('Sign in to SMMS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: Color(0xFF0F172A), letterSpacing: -0.5)),
              const SizedBox(height: 48),

              Container(
                width: double.infinity, height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                  decoration: const InputDecoration(
                    hintText: 'College email address',
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SELECT ROLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569), letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildRoleButton('student', 'Student')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildRoleButton('admin', 'Admin')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildRoleButton('kitchen', 'Kitchen')),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.70),
                    foregroundColor: const Color(0xFF1D4ED8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFF93C5FD), width: 0.5),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'By continuing, you agree to SMMS Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String roleValue, String label) {
    final isSelected = _selectedRole == roleValue;
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedRole = roleValue),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.white.withOpacity(0.70) : Colors.white.withOpacity(0.60),
          foregroundColor: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: isSelected ? Colors.white.withOpacity(0.80) : Colors.white.withOpacity(0.70),
              width: 0.5,
            ),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
