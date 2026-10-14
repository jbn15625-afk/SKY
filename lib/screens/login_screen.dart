import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegistering = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _message = '';
  Color _messageColor = AppColors.muted;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _message = '';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _message = 'جارٍ المعالجة...';
      _messageColor = AppColors.muted;
    });

    try {
      if (_isRegistering) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = _mapAuthError(error.code, error.message);
        _messageColor = AppColors.error;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message = 'حدث خطأ: $error';
        _messageColor = AppColors.error;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _mapAuthError(String code, String? fallback) {
    const errors = {
      'email-already-in-use': 'هذا البريد مسجل بالفعل. حاول تسجيل الدخول.',
      'invalid-email': 'يرجى إدخال بريد إلكتروني صحيح.',
      'invalid-credential': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      'wrong-password': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      'user-not-found': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      'weak-password': 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل.',
      'network-request-failed': 'تعذر الاتصال. تحقق من الإنترنت.',
      'too-many-requests': 'محاولات كثيرة. انتظر قليلًا ثم حاول مجددًا.',
      'operation-not-allowed':
          'فعّل تسجيل الدخول بالبريد وكلمة المرور من Firebase Console.',
      'unauthorized-domain':
          'هذا النطاق غير مسموح. أضفه إلى Authorized domains في إعدادات Authentication.',
    };

    return errors[code] ?? 'حدث خطأ: ${fallback ?? code}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 1.1,
            colors: [Color(0xFF202020), AppColors.bg],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x88000000),
                      blurRadius: 80,
                      offset: Offset(0, 25),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(36),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Ani',
                            children: [
                              TextSpan(
                                text: 'merc',
                                style: TextStyle(color: AppColors.pink),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'مرحبًا بك في عالم Animerc',
                          style: GoogleFonts.cairo(
                            color: AppColors.pink,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRegistering ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
                          style: GoogleFonts.cairo(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRegistering
                              ? 'أنشئ حسابك وابدأ رحلتك مع Animerc.'
                              : 'سجّل دخولك للعودة إلى عالمك المفضل.',
                          style: GoogleFonts.cairo(
                            color: AppColors.muted,
                            fontSize: 13,
                            height: 1.9,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'البريد الإلكتروني',
                          style: GoogleFonts.cairo(
                            color: AppColors.label,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 11),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          autofillHints: const [AutofillHints.email],
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: _inputDecoration('name@example.com'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            }
                            if (!value.contains('@')) {
                              return 'يرجى إدخال بريد إلكتروني صحيح.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 19),
                        Text(
                          'كلمة المرور',
                          style: GoogleFonts.cairo(
                            color: AppColors.label,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 11),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textDirection: TextDirection.ltr,
                          autofillHints: [
                            _isRegistering
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: _inputDecoration('أدخل كلمة المرور').copyWith(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال كلمة المرور';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF090909),
                              disabledBackgroundColor: Colors.white70,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: GoogleFonts.cairo(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF090909),
                                    ),
                                  )
                                : Text(
                                    _isRegistering
                                        ? 'إنشاء الحساب'
                                        : 'تسجيل الدخول',
                                  ),
                          ),
                        ),
                        if (_message.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            _message,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              height: 1.8,
                              color: _messageColor,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _isRegistering
                                  ? 'لديك حساب بالفعل؟'
                                  : 'ليس لديك حساب؟',
                              style: GoogleFonts.cairo(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                            TextButton(
                              onPressed: _isLoading ? null : _toggleMode,
                              child: Text(
                                _isRegistering ? 'تسجيل الدخول' : 'إنشاء حساب',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(color: AppColors.muted, fontSize: 14),
      filled: true,
      fillColor: AppColors.inputBg,
      contentPadding: const EdgeInsets.all(13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.white),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
