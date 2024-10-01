import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pinnket/screens/ticket_utils/receive_ticket_screen.dart';
import 'package:pinnket/screens/ticket_utils/send_ticket_screen.dart';
import 'package:yaru/icons.dart';
import 'package:yaru/widgets.dart';

import '../app/main_screen.dart';

class TicketTransfer extends StatefulWidget {
  const TicketTransfer({super.key});

  @override
  State<TicketTransfer> createState() => _TicketTransferState();
}

class _TicketTransferState extends State<TicketTransfer>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return MainScreen(
      showSearchFAB: false,
      bodySliver: [
        SliverToBoxAdapter(
          child: AutofillGroup(
            child: Container(
              width: size.width * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset("assets/lottie/transfer.json",
                          width: 100, height: 100),
                      const Text(
                        'Transfer Ticket',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  YaruDialogTitleBar(
                    title: SizedBox(
                      width: 500,
                      child: YaruTabBar(
                        tabController: _tabController,
                        tabs: const [
                          YaruTab(
                            label: 'Transfer',
                            icon: Icon(YaruIcons.forward),
                          ),
                          YaruTab(
                            label: 'Receive',
                            icon: Icon(YaruIcons.inbox_filled),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 600,
                    height: 500,
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        Center(child: SendTicket()),
                        Center(child: ReceiveTicket()),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
