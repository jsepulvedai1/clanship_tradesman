import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';
import 'package:clanship_mobile_tradesman/core/utils/lower_case_text_formatter.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 1; // 1: Email, 2: OTP, 3: New Password, 4: Success
  bool _isLoading = false;
  String _errorMessage = '';

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _resetToken = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  /// Direct HTTP POST to the GraphQL endpoint, bypassing graphql_flutter entirely.
  Future<Map<String, dynamic>?> _graphqlPost(String query, Map<String, dynamic> variables) async {
    final url = Uri.parse(EnvConfig.instance.baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query, 'variables': variables}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body.containsKey('errors') && (body['errors'] as List).isNotEmpty) {
      final firstError = (body['errors'] as List).first;
      throw Exception(firstError['message'] ?? 'Error desconocido.');
    }
    return body['data'] as Map<String, dynamic>?;
  }

  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      _showError(l10n.registerErrorFillAll);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _graphqlPost(
        r'''
          mutation RequestPasswordReset($email: String!) {
            requestPasswordReset(email: $email) {
              success
              message
            }
          }
        ''',
        {'email': email},
      );

      final success = data?['requestPasswordReset']?['success'] as bool? ?? false;
      final msg = data?['requestPasswordReset']?['message'] as String? ?? '';

      if (success) {
        setState(() {
          _currentStep = 2;
          _isLoading = false;
        });
      } else {
        _showError(msg.isNotEmpty ? msg : 'Error');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim().toLowerCase();
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showError('Por favor, ingresa el código de 6 dígitos.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _graphqlPost(
        r'''
          mutation VerifyPasswordResetOtp($email: String!, $otpCode: String!) {
            verifyPasswordResetOtp(email: $email, otpCode: $otpCode) {
              success
              message
              resetToken
            }
          }
        ''',
        {'email': email, 'otpCode': otp},
      );

      final success = data?['verifyPasswordResetOtp']?['success'] as bool? ?? false;
      final msg = data?['verifyPasswordResetOtp']?['message'] as String? ?? '';
      final token = data?['verifyPasswordResetOtp']?['resetToken'] as String? ?? '';

      if (success && token.isNotEmpty) {
        setState(() {
          _resetToken = token;
          _currentStep = 3;
          _isLoading = false;
        });
      } else {
        _showError(msg.isNotEmpty ? msg : 'El código no es válido.');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.length < 6) {
      _showError(l10n.registerErrorPasswordLength);
      return;
    }
    if (password != confirmPassword) {
      _showError(l10n.registerErrorPasswordMismatch);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _graphqlPost(
        r'''
          mutation ResetPasswordWithOtp($email: String!, $resetToken: String!, $newPassword: String!) {
            resetPasswordWithOtp(email: $email, resetToken: $resetToken, newPassword: $newPassword) {
              success
              message
            }
          }
        ''',
        {
          'email': email,
          'resetToken': _resetToken,
          'newPassword': password,
        },
      );

      final success = data?['resetPasswordWithOtp']?['success'] as bool? ?? false;
      final msg = data?['resetPasswordWithOtp']?['message'] as String? ?? '';

      if (success) {
        setState(() {
          _currentStep = 4;
          _isLoading = false;
        });
      } else {
        _showError(msg.isNotEmpty ? msg : 'Error');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep < 4
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0D2B45)),
                onPressed: () {
                  if (_currentStep > 1) {
                    setState(() {
                      _currentStep--;
                      _errorMessage = '';
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
        title: Text(
          _currentStep == 4 ? l10n.forgotPasswordSuccessTitle : l10n.forgotPasswordTitle,
          style: const TextStyle(
            color: Color(0xFF0D2B45),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentStep < 4) ...[
                Row(
                  children: List.generate(3, (index) {
                    final isActive = index + 1 <= _currentStep;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF0D2B45) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
              ],

              if (_errorMessage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFCCCC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFFF5252)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Color(0xFFFF5252), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_currentStep == 1) _buildEmailStep(l10n),
              if (_currentStep == 2) _buildOtpStep(l10n),
              if (_currentStep == 3) _buildPasswordStep(l10n),
              if (_currentStep == 4) _buildSuccessStep(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.forgotPasswordTitle,
          style: const TextStyle(
            color: Color(0xFF0D2B45),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.forgotPasswordSubtitle,
          style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          inputFormatters: [LowerCaseTextFormatter()],
          style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14),
          decoration: InputDecoration(
            labelText: l10n.registerEmailHint,
            prefixIcon: const Icon(Icons.mail_outline, size: 20),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D2B45),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  l10n.forgotPasswordSendCode,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildOtpStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.forgotPasswordVerifyCode,
          style: const TextStyle(
            color: Color(0xFF0D2B45),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.forgotPasswordEnterOtp,
          style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF0D2B45),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: const InputDecoration(
            labelText: 'OTP',
            counterText: '',
            prefixIcon: Icon(Icons.lock_clock_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D2B45),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  l10n.forgotPasswordVerifyCode,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _sendOtp,
            child: Text(
              l10n.forgotPasswordSendCode,
              style: const TextStyle(
                color: Color.fromARGB(255, 71, 169, 255),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.forgotPasswordNewPassword,
          style: const TextStyle(
            color: Color(0xFF0D2B45),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.forgotPasswordNewPassword,
          style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: l10n.forgotPasswordNewPassword,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: l10n.forgotPasswordConfirmNewPassword,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D2B45),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  l10n.forgotPasswordResetButton,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEEFBF7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF0B6E4F),
              size: 80,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            l10n.forgotPasswordSuccessTitle,
            style: const TextStyle(
              color: Color(0xFF0D2B45),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            l10n.forgotPasswordSuccessDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D2B45),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            l10n.forgotPasswordBackToLogin,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

