import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:wiredash/wiredash.dart';

import '../database/policy_data.dart';
import '../providers/footer_provider.dart';
import '../utils/external_links.dart';

class MobileFooter extends StatelessWidget {
  final List<Map<String, dynamic>> socials;

  const MobileFooter({Key? key, required this.socials}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<FooterStateModel>();

    return Container(
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogoAndSlogan(theme),
          const SizedBox(height: 16),
          _buildSocialLinks(theme),
          const SizedBox(height: 16),
          _buildFooterSection(
            context,
            'Useful Links',
            Iconsax.link,
            [
              _buildFooterItem('Pricing', Iconsax.money, () {
                provider.setSelectedDoc(pricing);
                provider.setSelectedNavItem(1);
                provider.setTitle('Reference');
                context.go('/reference');
              }),
              _buildFooterItem('FAQs', Iconsax.message_question, () {
                provider.setSelectedDoc(faqs);
                provider.setSelectedNavItem(2);
                provider.setTitle('Reference');
                context.go('/reference');
              }),
              _buildFooterItem('Feedback', Iconsax.message, () {
                Wiredash.of(context)
                    .show(inheritMaterialTheme: true);

              }),
              _buildFooterItem('Survey', Iconsax.clipboard_text, () {
                Wiredash.of(context).showPromoterSurvey(
                    force: true,
                    inheritMaterialTheme: true,

                );
              }),
              _buildFooterItem('Disclaimer', Iconsax.document, () {
                provider.setSelectedDoc(disclaimer);
                provider.setSelectedNavItem(0);
                provider.setTitle('Reference');
                context.go('/reference');
              }),
            ],
          ),
          const SizedBox(height: 16),
          _buildFooterSection(
            context,
            'Our Policies',
            Iconsax.shield,
            [
              _buildFooterItem('Privacy Policy', Iconsax.lock, () {
                provider.setSelectedDoc(privacyPolicy);
                provider.setSelectedNavItem(7);
                provider.setTitle('Reference');
                context.go('/reference');
              }),
              _buildFooterItem('Terms of Use', Iconsax.document_text, () {
                provider.setSelectedDoc(termsOfUse);
                provider.setSelectedNavItem(3);
                context.go('/reference');
              }),
              _buildFooterItem('Refund Policy', Iconsax.money_recive, () {
                provider.setSelectedDoc(refundPolicy);
                provider.setSelectedNavItem(5);
                provider.setTitle('Reference');
                context.go('/reference');
              }),
              _buildFooterItem('Transfer Policy', Iconsax.arrow_right, () {
                provider.setSelectedDoc(transferPolicy);
                provider.setSelectedNavItem(8);
                provider.setTitle('Reference');
                context.go('/reference');
              }),
              _buildFooterItem('Cookie Policy', Icons.cookie, () {
                provider.setSelectedDoc(cookiePolicy);
                provider.setSelectedNavItem(6);
                provider.setTitle('Reference');
                context.go('/reference');
              }),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactInfo(context),
        ],
      ),
    );
  }

  Widget _buildLogoAndSlogan(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 40,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/sc.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Beyond Tickets, Beyond Ordinary.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.surface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Image.asset("assets/images/elevateTransparent2.png", width: 150),
      ],
    );
  }

  Widget _buildSocialLinks(ThemeData theme) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: socials
          .map((social) => SocialIcon(
                icon: IconTheme(
                  data: const IconThemeData(color: Colors.black),
                  child: social['icon'],
                ),
                url: social['url'],
              ))
          .toList(),
    );
  }

  Widget _buildFooterSection(
      BuildContext context, String title, IconData icon, List<Widget> items) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.surface),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildFooterItem(String title, IconData icon, VoidCallback onTap) {
    return Builder(
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final color = theme.colorScheme.surface;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    Icon(Iconsax.arrow_right_3, color: color, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactInfo(BuildContext context) {
  final theme = Theme.of(context);
  return _buildFooterSection(
    context,
    'Contact Us',
    Iconsax.call,
    [
      _buildFooterItem(
        'PinniSOFT\nPlot 724/5 Theta House\nMawanda Road\nKampala-Uganda',
        Iconsax.location,
        () {},
      ),
      _buildFooterItem(
        '(+256) 0200 919 620 | 0393 969 600',
        Iconsax.call,
        () {},
      ),
      _buildFooterItem(
        'info@pinnket.com',
        Iconsax.sms,
        () {},
      ),
    ],
  );
}
}

class SocialIcon extends StatelessWidget {
  final Widget icon;
  final String url;

  const SocialIcon({super.key, required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: () {
        ExternalLinks().openLink(Uri.parse(url));
      },
      icon: icon,
      color: theme.colorScheme.surface,
      iconSize: 24,
    );
  }
}
