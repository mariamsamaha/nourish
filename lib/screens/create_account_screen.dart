import 'package:flutter/material.dart';
import 'package:proj/routes/app_routes.dart';
import 'package:proj/services/auth_service.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  String _selectedCountryCode = '+20'; // default prefix (Egypt)

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: height * 0.04),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top icon + title
                Row(
                  children: [
                  Container(
                     padding: EdgeInsets.all(width * 0.03),
                     decoration: BoxDecoration(
                     color: Colors.green.shade100,
                     borderRadius: BorderRadius.circular(12),
                     ),
                     child: const Icon(Icons.eco, color: Colors.green, size: 28),
                     ),

                  SizedBox(width: width * 0.03),

                  const Text(
                   "Create Account",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),

                    Spacer(),

                   IconButton(
                      icon: const Icon(Icons.settings, size: 28, color: Colors.grey),
                      onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
              
                ),
                  ],
                    ),

                SizedBox(height: height * 0.04),

                // Full Name
                _buildField("Full Name", "John Doe", _nameController, TextInputType.name),

                SizedBox(height: height * 0.02),

                // Email
                _buildField(
                  "Email",
                  "you@example.com",
                  _emailController,
                  TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter Email";
                    // Basic email validation
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),

                SizedBox(height: height * 0.02),

                // Phone Number (with dropdown)
                Text("Phone Number", style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Dropdown for country code
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          items: const [
                            DropdownMenuItem(value: '+1', child: Text('+1 🇺🇸')),
                            DropdownMenuItem(value: '+20', child: Text('+20 🇪🇬')),
                            DropdownMenuItem(value: '+44', child: Text('+44 🇬🇧')),
                            DropdownMenuItem(value: '+91', child: Text('+91 🇮🇳')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCountryCode = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter Phone Number" : null,
                        decoration: InputDecoration(
                          hintText: "555 000 0000",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.02),

                // Password
                _buildField(
                  "Password",
                  "••••••••",
                  _passwordController,
                  TextInputType.visiblePassword,
                  obscure: true,
                ),

                SizedBox(height: height * 0.04),

                // Create Account button
                SizedBox(
                  width: double.infinity,
                  height: height * 0.065,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        
                        try {
                          await _authService.signUpWithEmail(
                            _emailController.text.trim(),
                            _passwordController.text,
                          );
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Account created successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushReplacementNamed(context, AppRoutes.home);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Create Account",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                  ),
                ),

                SizedBox(height: height * 0.02),

                // Already have account? Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signin);
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.03),

                // Terms
                Center(
                  child: Text(
                    "By signing up, you agree to our Terms of Service and Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Custom reusable text field builder
  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller,
    TextInputType type, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: type,
          validator: validator ?? (val) => val == null || val.isEmpty ? "Enter $label" : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
