import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lottie/lottie.dart';
import 'package:pinnket/api/api_service.dart';
import 'package:pinnket/services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/user_provider.dart';

class TicketPurchasesScreen extends StatefulWidget {
  const TicketPurchasesScreen({super.key});

  @override
  State<TicketPurchasesScreen> createState() => _TicketPurchasesScreenState();
}

class _TicketPurchasesScreenState extends State<TicketPurchasesScreen> {
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  PullToRefreshController? pullToRefreshController;
  String url = "";
  double progress = 0;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: Colors.orange),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final tickets = userProvider.loginResponse?.tickets;

    if (tickets == null) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
        ),
      );
    }

    return tickets.isNotEmpty
        ? Container(
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
                    Lottie.asset('assets/lottie/payment.json',
                        width: 60, height: 60),
                    const Text(
                      'Ticket Purchases',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Expanded(
                  child: Stack(
                    children: [
                      FittedBox(
                        fit: BoxFit.fill,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: InAppWebView(
                            initialData: InAppWebViewInitialData(
                                data: concatenateTickets()),
                            initialSettings: settings,
                            pullToRefreshController: pullToRefreshController,
                            onWebViewCreated: (controller) async {
                              webViewController = controller;
                              if (!kIsWeb) {
                                webViewController?.addJavaScriptHandler(
                                  handlerName: 'showToast',
                                  callback: (args) {
                                    String message = args[0];
                                    if (message == 'Download started') {
                                      ToastManager()
                                          .showInfoToast(context, message);
                                    } else if (message == 'Download complete') {
                                      ToastManager()
                                          .showSuccessToast(context, message);
                                    } else {
                                      ToastManager()
                                          .showErrorToast(context, message);
                                    }
                                  },
                                );
                              }
                            },
                            onLoadStart: (controller, url) {
                              setState(() {
                                this.url = url.toString();
                                isLoaded = false;
                              });
                            },
                            onPermissionRequest: (controller, request) async {
                              return PermissionResponse(
                                  resources: request.resources,
                                  action: PermissionResponseAction.GRANT);
                            },
                            shouldOverrideUrlLoading:
                                (controller, navigationAction) async {
                              var uri = navigationAction.request.url!;
                              if (![
                                "http",
                                "https",
                                "file",
                                "chrome",
                                "data",
                                "javascript",
                                "about"
                              ].contains(uri.scheme)) {
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                  return NavigationActionPolicy.CANCEL;
                                }
                              }
                              return NavigationActionPolicy.ALLOW;
                            },
                            onLoadStop: (controller, url) async {
                              pullToRefreshController?.endRefreshing();
                              setState(() {
                                this.url = url.toString();
                                isLoaded = true;
                              });
                            },
                            onProgressChanged: (controller, progress) {
                              if (progress == 100) {
                                pullToRefreshController?.endRefreshing();
                              }
                              setState(() {
                                this.progress = progress / 100;
                                isLoaded = progress == 100;
                              });
                            },
                            onConsoleMessage: (controller, consoleMessage) {
                              print(
                                  "consoleMessage: ${consoleMessage.message}");
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  String concatenateTickets() {
    final userProvider = context.read<UserProvider>();
    final tickets = userProvider.loginResponse!.tickets;
    final baseUrl = ApiService().baseUrl;
    String allTicketsHTML = """
    <html>
    <head>
      <style>
      // fit the ticket to the page width
      @media (max-width: 600px) {
        .ticket {
          width: 100%;
          height: auto;
          box-sizing: border-box;
        }
      }
      .button {
        display: inline-flex;
        align-items: center;
        background-color: #4CAF50;
        color: white;
        padding: 8px 16px;
        border: none;
        border-radius: 20px;
        cursor: pointer;
        font-family: Arial, sans-serif;
        font-size: 12px;
        font-weight: bold;
        text-decoration: none;
        transition: background-color 0.3s;
      }
      .button:hover {
        background-color: #45a049;
      }
      .button .icon {
        margin-right: 4px;
        width: 18px;
        height: 18px;
      }
      .button .separator {
        margin: 0 4px;
      }
      .button-container {
        display: flex;
        justify-content: center;
        margin-top: 20px;
        margin-bottom: 20px;
      }
    </style>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.5.3/jspdf.min.js"></script>
    <script src="https://html2canvas.hertzen.com/dist/html2canvas.js"></script>
    </head>
    <body>
 <script>
    \$(document).ready(function() {
      window.downloadTicket = function(ticketNumber) {
        var url = "$baseUrl/api/events/pinnket/download/" + ticketNumber;

        toastr.options = {
          "closeButton": true,
          "debug": false,
          "newestOnTop": false,
          "progressBar": true,
          "positionClass": "toast-top-center",
          "preventDuplicates": false,
          "onclick": null,
          "showDuration": "300",
          "hideDuration": "1000",
          "timeOut": "5000",
          "extendedTimeOut": "1000",
          "showEasing": "swing",
          "hideEasing": "linear",
          "showMethod": "fadeIn",
          "hideMethod": "fadeOut",
        }

        toastr.info('Download started');

        fetch(url)
          .then(response => {
            if (!response.ok) {
              throw new Error('HTTP status ' + response.status);
            }
            return response.blob();
          })
          .then(blob => {
            // Check if the blob is empty or not a PDF
            if (blob.size === 0 || blob.type !== 'application/pdf') {
              throw new Error('Invalid document');
            }
            
            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = ticketNumber + '.pdf';
            document.body.appendChild(link);
            toastr.info('Download in progress');
            link.click();
            document.body.removeChild(link);

            toastr.success('Download complete');
          })
          .catch(error => {
            console.error('Download error:', error);
            if (error.message === 'Invalid document') {
              toastr.error('Event has expired or ticket is no longer available');
            } else if (error.message.startsWith('HTTP status')) {
              toastr.error('Event has expired or ticket is no longer available');
            } else {
              toastr.error('Download failed: ' + error.message);
            }
          });
      }
    });
    </script>
    """;

    for (var ticket in tickets) {
      int i = tickets.indexOf(ticket);
      allTicketsHTML += '''
      <div id="ticket$i" class="ticket$i">${ticket.ticketHTML}</div>
      <div class="button-container">
        <button class="button" type="button" onclick="downloadTicket('${ticket.ticketCode}')">
          <svg class="icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
            <polyline points="7 10 12 15 17 10"></polyline>
            <line x1="12" y1="15" x2="12" y2="3"></line>
          </svg>
          <span class="separator">|</span>
          <span>Download Now</span>
        </button>
      </div>
    ''';
    }

    allTicketsHTML += "</body></html>";
    return allTicketsHTML;
  }
}
