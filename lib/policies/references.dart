import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:pinnket/utils/hider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/policy_data.dart';
import '../providers/footer_provider.dart';
import '../screens/app/main_screen.dart';
import '../utils/external_links.dart';
import '../utils/layout.dart';
import '../widgets/header.dart';

class ReferenceScreen extends StatefulWidget {
  static const String routeName = '/references';

  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late WidgetBuilder _widgetBuilder;
  late Future<String> _jsonString;
  bool isSelected = false;
  bool isEditMode = false;
  bool isEditModeForOptions = false;
  final _navItems = const [
    NavItemModel(
        name: 'Disclaimer',
        icon: Icons.dangerous_outlined,
        selectedIcon: Icons.dangerous),
    NavItemModel(
        name: 'Pricing',
        icon: Icons.monetization_on_outlined,
        selectedIcon: Icons.monetization_on),
    NavItemModel(
        name: 'FAQs',
        icon: Icons.question_answer_outlined,
        selectedIcon: Icons.question_answer),
    NavItemModel(
        name: 'Terms of Use',
        icon: Icons.info_outlined,
        selectedIcon: Icons.info),
    NavItemModel(
        name: 'Security',
        icon: Icons.verified_user_outlined,
        selectedIcon: Icons.verified_user),
    NavItemModel(
        name: 'Refund Policy',
        icon: Icons.account_balance_wallet_outlined,
        selectedIcon: Icons.account_balance_wallet),
    NavItemModel(
        name: 'Cookie Policy',
        icon: Icons.cookie_outlined,
        selectedIcon: Icons.cookie),
    NavItemModel(
        name: 'Privacy Policy',
        icon: Icons.privacy_tip_outlined,
        selectedIcon: Icons.privacy_tip),
    NavItemModel(
        name: 'Transfer Policy',
        icon: Icons.swap_horiz_outlined,
        selectedIcon: Icons.swap_horiz),
  ];

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
  );
  String? selectedCategory;

  String userId = '2';
  DateTime createdAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    callJavaScriptMethods();
    handleEditMode();
  }

  handleEditMode() {
    String? editMode = html.window.localStorage['editMode'];

    if (editMode == 'true') {
      setState(() {
        isEditMode = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const fontSize = 10.0;
    const url = 'https://www.pinnitags.com';
    final year = DateTime.now().year;
    final size = MediaQuery.of(context).size;
    final provider = context.watch<FooterStateModel>();

    md.markdownToHtml(provider.selectedDoc ?? '');

    String getHtmlText(String doc) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
      return md.markdownToHtml(doc);
    }

    return MainScreen(
      showFooter: false,
      isScrollable: false,
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
                  items: [
                    ..._navItems.map(
                      (e) => SideMenuItemDataTile(
                        isSelected:
                            provider.selectedNavItem == _navItems.indexOf(e),
                        onTap: () {
                          if (e.name == 'Disclaimer') {
                            provider.setSelectedDoc(disclaimer);
                            provider.setSelectedNavItem(_navItems.indexOf(e));
                          } else if (e.name == 'FAQs') {
                            provider.setSelectedDoc(faqs);
                            provider.setSelectedNavItem(_navItems.indexOf(e));
                          } else if (e.name == 'Terms of Use') {
                            provider.setSelectedDoc(termsOfUse);
                            provider.setSelectedNavItem(_navItems.indexOf(e));
                          } else if (e.name == 'Security') {
                            provider.setSelectedDoc(security);
                            provider.setSelectedNavItem(_navItems.indexOf(e));
                          } else if (e.name == 'Pricing') {
                            provider.setSelectedDoc(pricing);
                            provider.setSelectedNavItem(_navItems.indexOf(e));
                          } else if (e.name == 'Refund Policy') {
                            provider.setSelectedDoc(refundPolicy);
                            provider.setSelectedNavItem(_navItems.indexOf(e));
                          } else if (e.name == 'Cookie Policy') {
                            provider.setSelectedDoc(cookiePolicy);
                            provider.setSelectedNavItem(_navItems.indexOf(e));
                          } else if (e.name == 'Privacy Policy') {
                            provider.setSelectedDoc(privacyPolicy);
                            provider.setSelectedNavItem(_navItems.indexOf(e));
                          } else if (e.name == 'Transfer Policy') {
                            provider.setSelectedDoc(transferPolicy);
                            provider.setSelectedNavItem(_navItems.indexOf(e));
                          }
                        },
                        title: e.name,
                        icon: Icon(
                          e.icon,
                          color: const Color(0xff164943),
                        ),
                        selectedIcon: Icon(
                          e.selectedIcon,
                          color: const Color(0xff164943),
                        ),
                      ),
                    ),
                  ],
                  footer: ListTile(
                    title: Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        text: '© Copyright PinnKET $year. All Rights Reserved ',
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
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: Colors.white,
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.all(20.0),
                      child: isEditModeForOptions
                          ? _widgetBuilder(context)
                          : SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  Html(
                                    data:
                                        getHtmlText(provider.selectedDoc ?? ''),
                                  ),
                                  SizedBox(height: 80),
                                  // Add space at the end of the page
                                ],
                              ),
                            ),
                    )
                  ],
                ),
              ),
            )
          ],
        )),
      ],
    );
  }
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
    List.generate(len, (index) => r.nextInt(33) + 89),
  );
}

extension on Widget {
  Widget? showOrNull(bool isShow) => isShow ? this : null;
}

class NavItemModel {
  const NavItemModel({
    required this.name,
    required this.icon,
    required this.selectedIcon,
  });

  final String name;
  final IconData icon;
  final IconData selectedIcon;
}
