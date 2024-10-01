import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

import '../../providers/user_provider.dart';
import '../../utils/datesplit.dart';

String getAssetName() {
  return 'assets/lottie/transfer.json';
}

class RecievedTicketScreen extends StatefulWidget {
  const RecievedTicketScreen({super.key});

  @override
  State<RecievedTicketScreen> createState() => _RecievedTicketScreenState();
}

class _RecievedTicketScreenState extends State<RecievedTicketScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final transferTickets = userProvider.loginResponse!.received;
    if (transferTickets.isNotEmpty) {
      print("Transfer date: ${transferTickets[0].dateTransfered}");
      print(
          "Transfer date: ${formatDateString(transferTickets[0].dateTransfered)}");
    } else {
      print("Transfer tickets is empty");
    }

    return Container(
        alignment: Alignment.topCenter,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(getAssetName(), width: 100, height: 100),
                const Text(
                  'Received Tickets',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Visibility(
                visible: transferTickets.isEmpty == true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/lottie/nothing.json',
                        width: 100, height: 100),
                    const Text(
                      'You have not received any tickets yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                )),
            Expanded(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        // Mobile layout
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: transferTickets.length,
                          itemBuilder: (context, index) {
                            final transfer = transferTickets[index];
                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Ticket Code: ${transfer.ticketCode}',
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                            Text('Cost: ${transfer.cost}',
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                            Text(
                                                'Date Transferred: ${formatDateString(transfer.dateTransfered)}',
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("FROM",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(transfer.senderName!,
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                            Text(transfer.senderPhone,
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                            Text(transfer.senderEmail,
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        // Desktop layout
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: transferTickets.length,
                          itemBuilder: (context, index) {
                            final transfer = transferTickets[index];
                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Ticket Code: ${transfer.ticketCode}',
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text('Cost: ${transfer.cost}',
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text(
                                                  'Date Transferred: ${formatDateString(transfer.dateTransfered)}',
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("FROM",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(transfer.senderName!,
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text(transfer.senderPhone,
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text(transfer.senderEmail,
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  )
                ],
              ),
            )
          ],
        ));
  }
}
