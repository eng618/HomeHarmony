import 'package:flutter/material.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: November 19, 2025',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Introduction',
              'Welcome to Home Harmony. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you as to how we look after your personal data when you visit our application and tell you about your privacy rights and how the law protects you.',
            ),
            _buildSection(
              '2. Data We Collect',
              'We may collect, use, store and transfer different kinds of personal data about you which we have grouped together follows:\n\n'
              '• Identity Data: includes first name, last name, username or similar identifier.\n'
              '• Contact Data: includes email address.\n'
              '• Usage Data: includes information about how you use our application.',
            ),
            _buildSection(
              '3. How We Use Your Data',
              'We will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances:\n\n'
              '• Where we need to perform the contract we are about to enter into or have entered into with you.\n'
              '• Where it is necessary for our legitimate interests (or those of a third party) and your interests and fundamental rights do not override those interests.\n'
              '• Where we need to comply with a legal or regulatory obligation.',
            ),
            _buildSection(
              '4. Data Security',
              'We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used or accessed in an unauthorized way, altered or disclosed. In addition, we limit access to your personal data to those employees, agents, contractors and other third parties who have a business need to know.',
            ),
            _buildSection(
              '5. Contact Us',
              'If you have any questions about this privacy policy or our privacy practices, please contact us at: support@homeharmony.app',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
