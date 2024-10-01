// desktop_footer.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinnket/main.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wiredash/wiredash.dart';

import '../database/policy_data.dart';
import '../providers/footer_provider.dart';
import '../utils/external_links.dart';

class DesktopFooter extends StatelessWidget {
  final List<Map<String, dynamic>> socials;

  const DesktopFooter({Key? key, required this.socials}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<FooterStateModel>();

    return Container(
      color: theme.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: _buildLogoAndSocials(theme),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 2,
            child: _buildFooterSection(
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
                      inheritMaterialTheme: true
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
          ),
          Expanded(
            flex: 2,
            child: _buildFooterSection(
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
          ),
          Expanded(
            flex: 2,
            child: _buildContactInfo(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoAndSocials(ThemeData theme) {
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
        const SizedBox(height: 16),
        Text(
          'Beyond Tickets, Beyond Ordinary.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.surface,
          ),
        ),
        const SizedBox(height: 16),
        Image.asset("assets/images/elevateTransparent2.png", width: 150),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: socials.map((social) => SocialIcon(
            icon: social['icon'],
            url: social['url'],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildFooterSection(BuildContext context, String title, IconData icon, List<Widget> items) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildFooterItem(String title, IconData icon, VoidCallback onTap) {
    return Builder(
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.surface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Iconsax.call, color: theme.colorScheme.secondary),
            const SizedBox(width: 8),
            Text(
              'Contact Us',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.surface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'PinniSOFT\nPlot 724/5 Theta House\nMawanda Road\nKampala-Uganda',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.surface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Iconsax.call, color: theme.colorScheme.secondary, size: 16),
            const SizedBox(width: 8),
            Text(
              '(+256) 0200 919 620 | 0393 969 600',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.surface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Iconsax.sms, color: theme.colorScheme.secondary, size: 16),
            const SizedBox(width: 8),
            Text(
              'info@pinnket.com',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.surface,
            )),
          ],
        ),
      ],
    );
  }
}

class SocialIcon extends StatelessWidget {
  final Widget icon;
  final String url;

  const SocialIcon({Key? key, required this.icon, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: () {
        ExternalLinks().openLink(Uri.parse(url));
      },
      icon: icon,
      color: theme.colorScheme.secondary,
      iconSize: 24,
    );
  }
}