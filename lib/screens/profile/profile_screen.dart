import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:go_router/go_router.dart';
import 'package:pinnket/screens/profile/recieved_tickets.dart';
import 'package:pinnket/screens/profile/ticket_purchases_screen.dart';
import 'package:pinnket/screens/profile/ticket_transfer_screen.dart';
import 'package:provider/provider.dart';

import '../../policies/references.dart';
import '../../providers/footer_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/toast_service.dart';
import '../../utils/external_links.dart';
import '../app/main_screen.dart';
import '../../models/auth_models.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _navItems = const [
    NavItemModel(
        name: 'Ticket Purchases',
        icon: Icons.airplane_ticket_outlined,
        selectedIcon: Icons.airplane_ticket),
    NavItemModel(
        name: 'Ticket Transfers',
        icon: Icons.swap_horiz_outlined,
        selectedIcon: Icons.swap_horiz),
    NavItemModel(
        name: 'Received Tickets',
        icon: Icons.call_received_outlined,
        selectedIcon: Icons.call_received),
  ];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        setState(() {});
      } else {
        setState(() {});
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    const fontSize = 10.0;
    const url = 'https://www.pinnitags.com';
    final year = DateTime.now().year;
    final userProvider = context.watch<UserProvider>();
    final footerProvider = context.watch<FooterStateModel>();

    return MainScreen(
      showFooter: false,
      bodySliver: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              SideMenu(
                mode: MediaQuery.of(context).size.width < 600
                    ? SideMenuMode.compact
                    : SideMenuMode.open,
                builder: (data) {
                  return SideMenuData(
                    header: ListTile(
                      title: Text(
                        'Welcome, ${userProvider.name ?? 'User'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(userProvider.email ?? ''),
                    ).showOrNull(data.isOpen),
                    items: [
                      ..._navItems.map(
                        (e) => SideMenuItemDataTile(
                          isSelected: footerProvider.selectedNavItem ==
                              _navItems.indexOf(e),
                          onTap: () {
                            footerProvider
                                .setSelectedNavItem(_navItems.indexOf(e));
                            _updateSelectedPage(e.name, footerProvider,
                                userProvider.loginResponse);
                          },
                          title: e.name,
                          icon: Icon(e.icon, color: const Color(0xff164943)),
                          selectedIcon: Icon(e.selectedIcon,
                              color: const Color(0xff164943)),
                        ),
                      ),
                      // Add Logout option
                      SideMenuItemDataTile(
                        onTap: () => _handleLogout(context),
                        title: 'Logout',
                        icon:
                            const Icon(Icons.logout, color: Color(0xff164943)),
                        isSelected: false,
                      ),
                    ],
                    footer: ListTile(
                      title: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text:
                              '© Copyright PinnKET $year. All Rights Reserved ',
                          children: [
                            TextSpan(
                              text: 'PinniTAGS',
                              style: const TextStyle(
                                fontFamily: 'Segoe UI',
                                color: Colors.green,
                                fontSize: fontSize,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ExternalLinks().openLink(Uri.parse(url));
                                },
                            ),
                          ],
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: fontSize,
                        ),
                      ).showOrNull(data.isOpen),
                    ),
                  );
                },
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20.0),
                  child: footerProvider.selectedProfilePage,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _updateSelectedPage(String pageName, FooterStateModel provider,
      LoginResponse? loginResponse) {
    switch (pageName) {
      case 'Ticket Purchases':
        provider.updateProfilePage(const TicketPurchasesScreen());
        break;
      case 'Ticket Transfers':
        provider.updateProfilePage(const TicketTransferScreen());
        break;
      case 'Received Tickets':
        provider.updateProfilePage(const RecievedTicketScreen());
        break;
    }
  }

  void _handleLogout(BuildContext context) {
    context.read<UserProvider>().logout();
    context.go('/');
    ToastManager().showSuccessToast(context, 'Logout successful');
  }
}

extension on Widget {
  Widget? showOrNull(bool isShow) => isShow ? this : null;
}
