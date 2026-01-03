import 'package:flutter/material.dart';
import 'package:shop_app/core/utils/components.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? expandedSection;

  final List<PolicySection> sections = [
    PolicySection(
      icon: Icons.description,
      title: "Information We Collect",
      color: Colors.blue,
      items: [
        "Personal details: name, email, phone number, shipping address",
        "Payment information (processed securely through third-party payment services)",
        "Device information: device type, OS version, IP address",
        "App usage data, cookies, and analytics",
      ],
    ),
    PolicySection(
      icon: Icons.visibility,
      title: "How We Use Your Information",
      color: Colors.purple,
      items: [
        "Create and manage your account",
        "Process orders and payments",
        "Deliver products and provide customer support",
        "Send notifications and order updates",
        "Improve app performance and security",
        "Detect and prevent fraud",
      ],
    ),
    PolicySection(
      icon: Icons.people,
      title: "Sharing Your Information",
      color: Colors.pink,
      items: [
        "We do not sell your personal information",
        "Delivery companies (for order shipping)",
        "Payment processors",
        "Analytics tools",
        "Authorities if required by law",
      ],
    ),
    PolicySection(
      icon: Icons.lock,
      title: "Data Security",
      color: Colors.green,
      items: [
        "We use industry-standard security practices to protect your data",
        "However, no method of transmission over the internet is 100% secure",
        "Please keep your login information safe",
      ],
    ),
    PolicySection(
      icon: Icons.shield,
      title: "Your Rights",
      color: Colors.orange,
      items: [
        "Access and update your account information",
        "Request deletion of your account",
        "Disable notifications",
        "Opt out of marketing messages",
        "Contact us at: support@smartshop.com",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ Colors.purple.shade600,Colors.blue.shade600,],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Animated App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: defulttext(
                  context: context,
                  data: 'Privacy Policy',
                  fw: FontWeight.bold,
                  // style: TextStyle(
                  //   fontWeight: FontWeight.bold,
                  //   shadows: [
                  //     Shadow(
                  //       offset: Offset(0, 1),
                  //       blurRadius: 3.0,
                  //       color: Colors.black26,
                  //     ),
                  //   ],
                  // ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade600, Colors.purple.shade600],
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/profile/privacy.png",
                      width: 33,
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Introduction Card
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Card(
                        elevation: 8,
                        shadowColor: Colors.blue.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            // gradient: LinearGradient(
                            //   colors: [Colors.white, Colors.blue.shade50],
                            // ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      // color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade700,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: defulttext(
                                      fSize: 14,
                                      color: Colors.grey,
                                      fw: FontWeight.w500,
                                      data: 'Last updated: 22-Nov-2025',
                                      context: context,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              RichText(
                                text: TextSpan(
                                  style:  TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Welcome to '),
                                    TextSpan(
                                      text: 'Smart Shop',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          '. We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains what information we collect, how we use it, and your rights.',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Policy Sections
                    ...List.generate(sections.length, (index) {
                      return TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: _buildPolicySection(sections[index], index),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Additional Sections
                    _buildInfoCard(
                      icon: Icons.child_care,
                      title: "Children's Privacy",
                      content:
                          "This app is not intended for children under 13. We do not knowingly collect personal information from children.",
                      gradient: [
                        Colors.yellow.shade100,
                        Colors.orange.shade100,
                      ],
                      iconColor: Colors.orange,
                    ),

                    const SizedBox(height: 16),

                    _buildInfoCard(
                      icon: Icons.update,
                      title: "Changes to This Policy",
                      content:
                          "We may update this Privacy Policy from time to time. Significant changes will be communicated through the app or email.",
                      gradient: [Colors.green.shade100, Colors.teal.shade100],
                      iconColor: Colors.green,
                    ),

                    const SizedBox(height: 16),

                    // Contact Card
                    Card(
                      elevation: 8,
                      shadowColor: Colors.purple.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.purple.shade600,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.contact_support,
                              size: 50,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            defulttext(
                              context: context,
                              data: 'Contact Us',
                              fSize: 24,
                              fw: FontWeight.bold,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            _buildContactItem(
                              Icons.email,
                              'support@smartshop.com',
                            ),
                            const SizedBox(height: 12),
                            _buildContactItem(Icons.phone, '+1-234-567-8900'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(PolicySection section, int index) {
    final isExpanded = expandedSection == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: isExpanded ? 12 : 6,
        shadowColor: section.color.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: section.color, width: 5)),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      expandedSection = isExpanded ? null : index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'icon_$index',
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: section.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              section.icon,
                              color: section.color,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: defulttext(
                            data: section.title,
                            context: context,
                            fw: FontWeight.bold,
                            fSize: 18,
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: section.color,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isExpanded
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            children: section.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: section.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: defulttext(
                                        context: context,
                                        data: item,
                                        fSize: 15,

                                        // color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required List<Color> gradient,
    required Color iconColor,
  }) {
    return Card(
      elevation: 6,
      shadowColor: iconColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // gradient: LinearGradient(colors: gradient),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  defulttext(
                    data: title,
                    context: context,
                    fSize: 18,
                    fw: FontWeight.bold,
                    color: iconColor,
                  ),
                  const SizedBox(height: 8),
                  defulttext(
                    context: context,
                    data: content,
                    fSize: 14,
                    // color: Colors.grey.shade800,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          defulttext(
            context: context,
            data: text,
            fSize: 16,
            fw: FontWeight.w500,
            // color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class PolicySection {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> items;

  PolicySection({
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
  });
}
