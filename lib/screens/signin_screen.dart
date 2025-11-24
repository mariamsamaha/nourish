import 'package:flutter/material.dart';
import 'package:proj/routes/app_routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
                // Top icon + title (Sign In)
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(width * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.green.shade500, // Darker green as per image
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.eco, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: width * 0.04),
                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                    Spacer(),
                    // 3 dots
                    Icon(Icons.more_horiz, size: 30, color: Colors.black87),
                  ],
                ),

                SizedBox(height: height * 0.06),

                // Email
                _buildField("Email", "you@example.com", _emailController, TextInputType.emailAddress),

                SizedBox(height: height * 0.03),

                // Password
                _buildField("Password", "••••••••", _passwordController, TextInputType.visiblePassword, obscure: true),

                SizedBox(height: height * 0.02),

                // Forgot Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.02),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: height * 0.065,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Navigate to Home/FoodDetails on success
                        Navigator.pushNamed(context, AppRoutes.home);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.04),

                // Divider "or"
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("or", style: TextStyle(color: Colors.grey.shade500)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                SizedBox(height: height * 0.04),

                // Google Button
                SizedBox(
                  width: double.infinity,
                  height: height * 0.065,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.email_outlined, color: Colors.black87), // Placeholder for Google icon
                        SizedBox(width: 10),
                        Text(
                          "Continue with Google",
                          style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: height * 0.06),

                // Don't have an account? Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller,
    TextInputType type, {
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: type,
          validator: (val) => val == null || val.isEmpty ? "Enter $label" : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
