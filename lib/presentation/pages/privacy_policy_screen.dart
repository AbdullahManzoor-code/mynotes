import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Introduction'),
            _buildSectionText(
              'Your privacy is important to us. This Privacy Policy explains how MyNotes handles your personal data when you use our application.',
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('Data Storage'),
            _buildSectionText(
              'MyNotes is designed to be a local-first application. Most of your notes, todos, and reminders are stored directly on your device using a local database.',
            ),
            SizedBox(height: 16.h),
            _buildSectionText(
              '• All notes and attachments stay on your local device unless you explicitly use a cloud sync or backup feature.\n'
              '• We do not have access to your private notes.',
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('Permissions We Request'),
            _buildSectionText(
              'To provide the best experience, MyNotes may request the following permissions:',
            ),
            SizedBox(height: 12.h),
            _buildPermissionItem('Camera', 'To attach photos to your notes.'),
            _buildPermissionItem(
              'Microphone',
              'For voice-to-text notes and audio recordings.',
            ),
            _buildPermissionItem(
              'Location',
              'To provide location-based reminders and mapping features.',
            ),
            _buildPermissionItem(
              'Storage',
              'To save and load attachments or export your data.',
            ),
            _buildPermissionItem(
              'Biometrics',
              'To secure your notes using your device\'s fingerprint or face recognition.',
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('Third-Party Services'),
            _buildSectionText(
              'We use certain third-party services to enhance app functionality:',
            ),
            SizedBox(height: 12.h),
            _buildSectionText(
              '• Google Maps API: Used for location-based reminders and display.\n'
              '• ML Kit: Used for on-device text recognition and AI parsing.',
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('Data Safety'),
            _buildSectionText(
              'We do not sell, trade, or otherwise transfer your personally identifiable information to outside parties. Any data shared is for the sole purpose of providing technical functionality required by the app.',
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('Contact Us'),
            _buildSectionText(
              'If you have any questions regarding this privacy policy, you may contact us via our official support channels.',
            ),
            SizedBox(height: 40.h),
            Center(
              child: Text(
                'Last updated: February 12, 2026',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade300,
        fontSize: 14.sp,
        height: 1.5,
      ),
    );
  }

  Widget _buildPermissionItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 14.sp,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextSpan(text: description),
          ],
        ),
      ),
    );
  }
}
