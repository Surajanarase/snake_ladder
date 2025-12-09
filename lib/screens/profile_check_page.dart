// File: lib/screens/profile_check_page.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'home_page.dart';

class ProfileCheckPage extends StatefulWidget {
  const ProfileCheckPage({super.key});

  @override
  State<ProfileCheckPage> createState() => _ProfileCheckPageState();
}

class _ProfileCheckPageState extends State<ProfileCheckPage> {
  bool _isChecking = true;
  bool _showProfileForm = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final profile = await DatabaseHelper.instance.getUserProfile();
    
    // Check if profile is complete
    final username = profile['username'] ?? 'Player';
    final gender = profile['gender'] ?? 'Not specified';
    final age = profile['age'] ?? 0;
    
    if (!mounted) return;
    
    // If profile is incomplete, show form directly
    if (username == 'Player' || gender == 'Not specified' || age == 0) {
      setState(() {
        _isChecking = false;
        _showProfileForm = true;
      });
    } else {
      // Profile complete, navigate to home immediately
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // Minimal empty state while checking
      return const Scaffold(
        backgroundColor: Color(0xFF667eea),
        body: SizedBox.shrink(),
      );
    }

    if (_showProfileForm) {
      return _buildProfileFormPage();
    }

    // This shouldn't show, but just in case
    return const Scaffold(
      backgroundColor: Color(0xFF667eea),
      body: SizedBox.shrink(),
    );
  }

  Widget _buildProfileFormPage() {
    final usernameController = TextEditingController(text: '');
    final ageController = TextEditingController();
    String? selectedGender;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive sizing
                  final isSmallScreen = constraints.maxWidth < 360;
                  final isTablet = constraints.maxWidth >= 600;
                  final maxWidth = isTablet ? 500.0 : (isSmallScreen ? 340.0 : 450.0);
                  final logoSize = isTablet ? 110.0 : (isSmallScreen ? 85.0 : 100.0);
                  final titleSize = isTablet ? 26.0 : (isSmallScreen ? 20.0 : 24.0);
                  final subtitleSize = isTablet ? 14.0 : (isSmallScreen ? 12.0 : 13.0);
                  final padding = isTablet ? 32.0 : (isSmallScreen ? 20.0 : 28.0);
                  
                  return Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: StatefulBuilder(
                      builder: (context, setFormState) => Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✅ APP LOGO
                            Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667eea).withAlpha(100),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'assets/icon/app_icon.png',
                                  width: logoSize,
                                  height: logoSize,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 18 : 24),
                            
                            // Title
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Welcome to Health Quest!',
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                ),
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 4 : 6),
                            
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Complete your profile to start your health journey',
                                  style: TextStyle(
                                    fontSize: subtitleSize,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 18 : 20),
                            
                            // Username Field
                            TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: 'Your Name',
                                hintText: 'Enter your name',
                                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF667eea)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 14 : 16),
                            
                            // Gender Dropdown
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: isSmallScreen ? 14 : 16,
                                      ),
                                      border: InputBorder.none,
                                      prefixIcon: const Icon(Icons.wc, color: Color(0xFF667eea)),
                                    ),
                                    hint: const Text('Gender'),
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF667eea)),
                                    dropdownColor: Colors.white,
                                    items: ['Male', 'Female'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Row(
                                          children: [
                                            Icon(
                                              value == 'Male' ? Icons.male : Icons.female,
                                              color: const Color(0xFF667eea),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(value),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setFormState(() {
                                        selectedGender = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 14 : 16),
                            
                            // Age Field
                            TextField(
                              controller: ageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Your Age',
                                hintText: 'Enter your age',
                                prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFF667eea)),
                                suffixText: 'years',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 20 : 22),
                            
                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final username = usernameController.text.trim();
                                  final age = int.tryParse(ageController.text.trim()) ?? 0;
                                  
                                  if (username.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter your name'),
                                        backgroundColor: Color(0xFFE74C3C),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  if (selectedGender == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select your gender'),
                                        backgroundColor: Color(0xFFE74C3C),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  if (age <= 0 || age > 150) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a valid age (1-150)'),
                                        backgroundColor: Color(0xFFE74C3C),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  final initials = username.length >= 2 
                                      ? username.substring(0, 2).toUpperCase()
                                      : username.substring(0, 1).toUpperCase();
                                  
                                  await DatabaseHelper.instance.updateUserDetails(
                                    username,
                                    initials,
                                    selectedGender!, // ✅ Fixed: Now non-nullable after validation
                                    age,
                                  );
                                  
                                  if (!context.mounted) return;
                                  
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => const HomePage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667eea),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 16 : 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.rocket_launch, size: isSmallScreen ? 18 : 20),
                                    SizedBox(width: isSmallScreen ? 6 : 8),
                                    Text(
                                      'Start Playing!',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}