import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:tvplus/integrations/supabase_service.dart';
import 'package:go_router/go_router.dart';

@NowaGenerated()
class AuthPage extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() {
    return _AuthPageState();
  }
}

@NowaGenerated()
class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _nombreController = TextEditingController();

  bool _isLogin = true;

  bool _isLoading = false;

  final _codeController = TextEditingController();

  bool _useCode = false;

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      if (_useCode) {
        final bool isValid = await SupabaseService().signInWithCode(
          _codeController.text,
        );
        if (isValid) {
          if (mounted) {
            context.go('/');
          }
          return;
        } else {
          throw Exception('Código de acceso no válido o expirado');
        }
      }
      if (_isLogin) {
        await SupabaseService().signIn(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await SupabaseService().signUpWithProfile(
          _emailController.text,
          _passwordController.text,
          _nombreController.text,
        );
      }
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Error: ${e.toString()}';
        if (e.toString().contains('429')) {
          errorMsg = 'Demasiados intentos. Intenta más tarde o usa un código.';
        } else if (e.toString().contains('Exception:')) {
          errorMsg = e.toString().replaceFirst('Exception: ', '');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    Colors.red.withValues(alpha: 0.05),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Icon(
                          Icons.tv_rounded,
                          size: 60,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _useCode
                            ? 'Acceso rápido'
                            : (_isLogin ? 'TvPlus' : 'Crea tu cuenta'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _useCode
                            ? 'Ingresa tu código de invitación'
                            : 'aritoLp',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                          letterSpacing: 1.2,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 48),
                      if (_useCode)
                        _buildTextField(
                          _codeController,
                          'Código de acceso',
                          Icons.vpn_key_outlined,
                        )
                      else ...[
                        if (!_isLogin) ...[
                          _buildTextField(
                            _nombreController,
                            'Nombre completo',
                            Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildTextField(
                          _emailController,
                          'Email',
                          Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _passwordController,
                          'Contraseña',
                          Icons.lock_outline,
                          isPassword: true,
                        ),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  _useCode
                                      ? 'Validar Código'
                                      : (_isLogin ? 'Entrar' : 'Registrarse'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!_useCode)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '¿Quieres recibir un código de validación? Escríbenos al correo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: () => setState(() {
                          _useCode = !_useCode;
                        }),
                        child: Text(
                          _useCode
                              ? 'Volver a Email/Password'
                              : '¿Tienes un código de acceso?',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                      if (!_useCode)
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin
                                ? '¿No tienes cuenta? Regístrate'
                                : '¿Ya tienes cuenta? Inicia sesión',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
