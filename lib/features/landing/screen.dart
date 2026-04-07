import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusTrade'),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/signup'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text('Sign up'),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 920;
            final horizontalPadding = isNarrow ? 16.0 : 40.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: isNarrow
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _heroContent(context, isLoggedIn: isLoggedIn),
                                const SizedBox(height: 16),
                                _appPreviewCard(context),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: _heroContent(context, isLoggedIn: isLoggedIn),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 5,
                                  child: _appPreviewCard(context),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _coreFeaturesSection(context, isNarrow: isNarrow),
                  const SizedBox(height: 12),
                  _howItWorksSection(context),
                  const SizedBox(height: 12),
                  _whyUseSection(context, isNarrow: isNarrow),
                  const SizedBox(height: 12),
                  _finalCtaSection(context, isLoggedIn: isLoggedIn),
                  const SizedBox(height: 12),
                  Text(
                    'CampusTrade is a student marketplace for Mae Fah Luang University. Buy, sell, save, and connect with confidence.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _heroContent(
    BuildContext context, {
    required bool isLoggedIn,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _brandVisualRow(context),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _badgeTag(context, icon: Icons.school, text: 'Campus students only'),
            _badgeTag(context, icon: Icons.sell_rounded, text: 'Post items fast'),
            _badgeTag(context, icon: Icons.favorite_rounded, text: 'Wishlist support'),
            _badgeTag(context, icon: Icons.chat_bubble_outline_rounded, text: 'Easy contact'),
          ],
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'Your campus marketplace for textbooks, gadgets, fashion, beauty, and more.',
            style: theme.textTheme.displaySmall?.copyWith(
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
            'Post, browse, save, and chat with confidence in your campus community.',
            style: theme.textTheme.titleMedium?.copyWith(height: 1.4),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _quickStat(context, icon: Icons.auto_graph, label: '120+ active listings'),
            _quickStat(context, icon: Icons.verified_user_outlined, label: 'Verified student users'),
            _quickStat(context, icon: Icons.handshake_outlined, label: 'Safe on-campus exchange'),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go(isLoggedIn ? '/home' : '/'),
              icon: const Icon(Icons.login_rounded),
              label: Text(isLoggedIn ? 'Go to Home' : 'Login now'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/signup'),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Create free account'),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _appPreviewCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular campus items',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _CategoryLogo(icon: Icons.menu_book_rounded, label: 'Books'),
              _CategoryLogo(icon: Icons.devices_rounded, label: 'Electronics'),
              _CategoryLogo(icon: Icons.checkroom_rounded, label: 'Clothes'),
              _CategoryLogo(icon: Icons.face_retouching_natural_rounded, label: 'Beauty'),
            ],
          ),
          const SizedBox(height: 12),
          _listingTile(
            context,
            icon: Icons.directions_run_rounded,
            title: 'Training Shoes',
            subtitle: 'Good condition',
            price: 'THB 150',
            chipText: 'Shoes',
          ),
          const SizedBox(height: 10),
          _listingTile(
            context,
            icon: Icons.face_retouching_natural_rounded,
            title: 'Lipstick',
            subtitle: 'Unused, sealed',
            price: 'THB 100',
            chipText: 'Beauty',
          ),
          const SizedBox(height: 10),
          _listingTile(
            context,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Save items to your wishlist and contact the seller easily.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.25),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _coreFeaturesSection(BuildContext context, {required bool isNarrow}) {
    return _sectionCard(
      title: 'Core Features',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _iconFeatureTile(
            context,
            icon: Icons.verified_user_outlined,
            title: 'Campus-only access',
            subtitle: 'Verified student accounts',
            width: isNarrow ? double.infinity : 290,
          ),
          _iconFeatureTile(
            context,
            icon: Icons.add_box_outlined,
            title: 'Post in minutes',
            subtitle: 'Photo, price, category',
            width: isNarrow ? double.infinity : 290,
          ),
          _iconFeatureTile(
            context,
            icon: Icons.grid_view_rounded,
            title: 'Category browsing',
            subtitle: 'Find items faster',
            width: isNarrow ? double.infinity : 290,
          ),
          _iconFeatureTile(
            context,
            icon: Icons.favorite_border_rounded,
            title: 'Wishlist',
            subtitle: 'Save favorites quickly',
            width: isNarrow ? double.infinity : 290,
          ),
          _iconFeatureTile(
            context,
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Direct chat',
            subtitle: 'Contact owners instantly',
            width: isNarrow ? double.infinity : 290,
          ),
          _iconFeatureTile(
            context,
            icon: Icons.swap_horiz_rounded,
            title: 'Easy exchange',
            subtitle: 'Meet safely on campus',
            width: isNarrow ? double.infinity : 290,
          ),
        ],
      ),
    );
  }

  static Widget _howItWorksSection(BuildContext context) {
    return _sectionCard(
      title: 'How It Works',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _stepChip(
            context,
            step: '1',
            icon: Icons.login_rounded,
            title: 'Login',
            description: 'Sign in with student email',
          ),
          _stepChip(
            context,
            step: '2',
            icon: Icons.storefront_outlined,
            title: 'Browse or post',
            description: 'List or discover items',
          ),
          _stepChip(
            context,
            step: '3',
            icon: Icons.handshake_outlined,
            title: 'Save or contact',
            description: 'Chat and exchange safely',
          ),
        ],
      ),
    );
  }

  static Widget _whyUseSection(BuildContext context, {required bool isNarrow}) {
    return _sectionCard(
      title: 'Why use CampusTrade?',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _valueBadge(
            context,
            icon: Icons.shield_outlined,
            label: 'Trusted student community',
            width: isNarrow ? double.infinity : 290,
          ),
          _valueBadge(
            context,
            icon: Icons.flash_on_outlined,
            label: 'Fast to post and browse',
            width: isNarrow ? double.infinity : 290,
          ),
          _valueBadge(
            context,
            icon: Icons.savings_outlined,
            label: 'Student-friendly prices',
            width: isNarrow ? double.infinity : 290,
          ),
          _valueBadge(
            context,
            icon: Icons.tune_rounded,
            label: 'Clean and organized listings',
            width: isNarrow ? double.infinity : 290,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.go(isLoggedIn ? '/home' : '/'),
                icon: const Icon(Icons.login_rounded),
                label: Text(isLoggedIn ? 'Go to Home' : 'Login now'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/signup'),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Create free account'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  static Widget _iconFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required double width,
  }) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.20)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _stepChip(
    BuildContext context, {
    required String step,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 280,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                step,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(description, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _valueBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double width,
  }) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _listingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required String chipText,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                price,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(subtitle, style: theme.textTheme.bodySmall)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  chipText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _badgeTag(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static Widget _brandVisualRow(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.16),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.20),
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _logoOrb(context, icon: Icons.storefront_rounded),
          _logoOrb(context, icon: Icons.school_rounded),
          _logoOrb(context, icon: Icons.inventory_2_rounded),
          _logoOrb(context, icon: Icons.favorite_rounded),
          _logoOrb(context, icon: Icons.chat_bubble_rounded),
          _logoOrb(context, icon: Icons.bolt_rounded),
        ],
      ),
    );
  }

  static Widget _logoOrb(BuildContext context, {required IconData icon}) {
    final theme = Theme.of(context);
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Icon(icon, color: theme.colorScheme.primary, size: 20),
    );
  }

  static Widget _quickStat(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CategoryLogo extends StatelessWidget {
  const _CategoryLogo({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
