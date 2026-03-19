import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final textColor = const Color(0xFFF6F8FF);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B153E), Color(0xFF1442A6), Color(0xFF2A7BFF)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -160,
                right: -120,
                child: _blurBlob(
                  size: 320,
                  color: const Color(0xFF9ED4FF).withValues(alpha: 0.24),
                ),
              ),
              Positioned(
                bottom: -180,
                left: -120,
                child: _blurBlob(
                  size: 380,
                  color: const Color(0xFFFF9E6D).withValues(alpha: 0.20),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 980;
                  final horizontalPadding = isNarrow ? 20.0 : 56.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 26),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Icon(Icons.storefront_rounded, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'CampusTrade',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => context.go('/signup'),
                              style: TextButton.styleFrom(
                                foregroundColor: textColor,
                                backgroundColor: Colors.white.withValues(alpha: 0.10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              label: const Text('Create free account'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        if (isNarrow)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _heroContent(
                                context,
                                isLoggedIn: isLoggedIn,
                                textColor: textColor,
                              ),
                              const SizedBox(height: 20),
                              _appPreviewCard(context),
                            ],
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: _heroContent(
                                  context,
                                  isLoggedIn: isLoggedIn,
                                  textColor: textColor,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 5,
                                child: _appPreviewCard(context),
                              ),
                            ],
                          ),
                        const SizedBox(height: 28),
                        _coreFeaturesSection(isNarrow: isNarrow),
                        const SizedBox(height: 18),
                        _howItWorksSection(),
                        const SizedBox(height: 18),
                        _whyUseSection(isNarrow: isNarrow),
                        const SizedBox(height: 18),
                        _finalCtaSection(context, isLoggedIn: isLoggedIn),
                        const SizedBox(height: 16),
                        _footerSection(),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _blurBlob({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 80,
              spreadRadius: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroContent(
    BuildContext context, {
    required bool isLoggedIn,
    required Color textColor,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _glassTag(icon: Icons.school, text: 'Only for campus students'),
            _glassTag(icon: Icons.sell_rounded, text: 'Post items fast'),
            _glassTag(icon: Icons.favorite_rounded, text: 'Save your favorites'),
            _glassTag(icon: Icons.chat_bubble_outline_rounded, text: 'Contact sellers easily'),
          ],
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'Your campus marketplace for textbooks, gadgets, fashion, beauty, and more.',
            style: theme.textTheme.displaySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            'CampusTrade helps students exchange new or used items inside the university community. You can post your items, browse listings by category, save items to your wishlist, and contact sellers quickly and easily.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor.withValues(alpha: 0.92),
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go(isLoggedIn ? '/home' : '/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF123B9C),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Login now'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/signup'),
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: textColor.withValues(alpha: 0.6)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Create free account'),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _appPreviewCard(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.13),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular campus items',
            style: text.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _listingTile(
            icon: Icons.directions_run_rounded,
            title: 'Training Shoes',
            subtitle: 'Good condition',
            price: 'THB 150',
            chipText: 'Shoes',
          ),
          const SizedBox(height: 10),
          _listingTile(
            icon: Icons.face_retouching_natural_rounded,
            title: 'Lipstick',
            subtitle: 'Unused, sealed',
            price: 'THB 100',
            chipText: 'Beauty',
          ),
          const SizedBox(height: 10),
          _listingTile(
            icon: Icons.headphones_rounded,
            title: 'Wireless Headphones',
            subtitle: 'Battery lasts all day',
            price: 'THB 700',
            chipText: 'Electronics',
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.favorite_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Save items to your wishlist and contact the seller easily.',
                    style: TextStyle(color: Colors.white, height: 1.25),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _coreFeaturesSection({required bool isNarrow}) {
    return _sectionCard(
      title: 'Core Features',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _infoTile(
            title: 'Campus-only access',
            description:
                'Sign in using your university email account for a safer student marketplace.',
            width: isNarrow ? double.infinity : 320,
          ),
          _infoTile(
            title: 'Easy item posting',
            description:
                'Add your item photo, title, price, description, and category in just a few simple steps.',
            width: isNarrow ? double.infinity : 320,
          ),
          _infoTile(
            title: 'Category browsing',
            description:
                'Browse items under Electronics, Clothes, Shoes, Beauty, Books, Food, and Other.',
            width: isNarrow ? double.infinity : 320,
          ),
          _infoTile(
            title: 'Wishlist support',
            description: 'Save items you like and view them later from your profile page.',
            width: isNarrow ? double.infinity : 320,
          ),
          _infoTile(
            title: 'Contact seller',
            description: 'Open the item detail page and contact the seller easily.',
            width: isNarrow ? double.infinity : 320,
          ),
        ],
      ),
    );
  }

  static Widget _howItWorksSection() {
    return _sectionCard(
      title: 'How It Works',
      child: Column(
        children: [
          _stepTile(
            step: 'Step 1',
            title: 'Login',
            description: 'Login with your MFU student email account.',
          ),
          SizedBox(height: 10),
          _stepTile(
            step: 'Step 2',
            title: 'Browse or post',
            description: 'Browse available items or post your own item for sale.',
          ),
          SizedBox(height: 10),
          _stepTile(
            step: 'Step 3',
            title: 'Save or contact',
            description:
                'Save interesting items to your wishlist or contact the seller directly.',
          ),
        ],
      ),
    );
  }

  static Widget _whyUseSection({required bool isNarrow}) {
    return _sectionCard(
      title: 'Why use CampusTrade?',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _infoTile(
            title: 'Safe for students',
            description: 'Only campus users can access the platform.',
            width: isNarrow ? double.infinity : 320,
          ),
          _infoTile(
            title: 'Quick and simple',
            description: 'Post and find items without complicated steps.',
            width: isNarrow ? double.infinity : 320,
          ),
          _infoTile(
            title: 'Affordable choices',
            description: 'Buy useful secondhand items at student-friendly prices.',
            width: isNarrow ? double.infinity : 320,
          ),
          _infoTile(
            title: 'Organized experience',
            description: 'Search and browse items by category with ease.',
            width: isNarrow ? double.infinity : 320,
          ),
        ],
      ),
    );
  }

  static Widget _finalCtaSection(BuildContext context, {required bool isLoggedIn}) {
    return _sectionCard(
      title: 'Ready to start?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Login now and explore student listings on CampusTrade.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.92), height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.go(isLoggedIn ? '/home' : '/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF123B9C),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Login now'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/signup'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Create free account'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _footerSection() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'CampusTrade is a student marketplace for Mae Fah Luang University.\nBuy, sell, save, and connect with confidence.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.88),
          height: 1.45,
        ),
      ),
    );
  }

  static Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  static Widget _infoTile({
    required String title,
    required String description,
    required double width,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _stepTile({
    required String step,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _listingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required String chipText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.white.withValues(alpha: 0.9), size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  chipText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _glassTag({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
