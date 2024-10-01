import 'dart:html' as html;
import 'dart:js' as js;
import 'package:intl/intl.dart';
import 'package:pinnket/services/toast_service.dart';
import '../models/event_models.dart';

class EventGuidePdfGenerator {
  static void downloadEventGuidePdf(Event event, context) async {
    ToastManager().showInfoToast(context, 'Preparing PDF...');

    final bannerDataUrl = await _getImageDataUrl(event.bannerURL ?? event.evLogo ?? '');
    final sponsorDataUrls = await _getSponsorDataUrls(event.eventSponsors ?? []);

    final htmlContent = _generateEventGuideHtml(event, bannerDataUrl, sponsorDataUrls);
    ToastManager().showInfoToast(context, 'Generating PDF...');
    _convertHtmlToPdfAndDownload(htmlContent, '${event.name}_guide.pdf');
    ToastManager().showSuccessToast(context, 'PDF generated successfully');
  }

  static Future<String> _getImageDataUrl(String imageUrl) async {
    try {
      final response = await html.HttpRequest.request(
        imageUrl,
        method: 'GET',
        responseType: 'arraybuffer',
      );
      final blob = html.Blob([response.response], 'image/png');
      final reader = html.FileReader();
      reader.readAsDataUrl(blob);
      await reader.onLoad.first;
      return reader.result as String;
    } catch (e) {
      print('Error loading image: $e');
      return '';
    }
  }

  static Future<Map<String, String>> _getSponsorDataUrls(List<EventSponsor> sponsors) async {
    Map<String, String> dataUrls = {};
    for (var sponsor in sponsors) {
      if (sponsor.active == true && sponsor.url != null) {
        dataUrls[sponsor.name!] = await _getImageDataUrl(sponsor.url!);
      }
    }
    return dataUrls;
  }

  static String _generateEventGuideHtml(Event event, String bannerDataUrl, Map<String, String> sponsorDataUrls) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    final eventStart = DateTime.parse(event.eventDate ?? '');
    final eventEnd = DateTime.parse(event.endtime ?? '');

    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>${_escapeHtml(event.name)} - Event Guide</title>
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;700&display=swap');
        body { font-family: 'Roboto', sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f0f0f0; }
        .container { max-width: 1000px; margin: 0 auto; background-color: #ffffff; box-shadow: 0 0 20px rgba(0,0,0,0.1); }
        .header { position: relative; color: #ffffff; text-align: center; padding: 80px 0; overflow: hidden; }
        .header::before { content: ""; position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: url($bannerDataUrl) no-repeat center center; background-size: cover; filter: blur(5px); z-index: -1; }
        .header-content { position: relative; z-index: 1; background-color: rgba(0,0,0,0.6); padding: 30px; border-radius: 10px; }
        h1 { font-size: 48px; margin-bottom: 10px; text-shadow: 2px 2px 4px rgba(0,0,0,0.5); }
        h2 { color: #2c3e50; font-size: 28px; margin-top: 40px; margin-bottom: 20px; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .content { padding: 40px; }
        .event-details, .organizer-details { background-color: #e8f6ff; border-radius: 10px; padding: 30px; margin-bottom: 40px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .event-description { white-space: pre-wrap; background-color: #f9f9f9; padding: 25px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .sponsors { display: flex; flex-wrap: wrap; justify-content: center; gap: 30px; margin-top: 40px; }
        .sponsor { text-align: center; background-color: #ffffff; padding: 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); transition: transform 0.3s ease; }
        .sponsor:hover { transform: translateY(-5px); }
        .sponsor img { max-width: 120px; height: auto; border-radius: 5px; }
        .ticket-info { background-color: #e8f5e9; border-radius: 10px; padding: 30px; margin-top: 40px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .zone { margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid #4caf50; }
        .zone:last-child { border-bottom: none; }
        .terms-conditions { background-color: #f9f9f9; border-radius: 10px; padding: 30px; margin-top: 40px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .terms-content { padding: 20px; background-color: #ffffff; border-radius: 5px; }
        .button { display: inline-block; padding: 12px 24px; background-color: #3498db; color: #ffffff; text-decoration: none; border-radius: 25px; transition: background-color 0.3s, transform 0.3s; font-weight: bold; }
        .button:hover { background-color: #2980b9; transform: translateY(-2px); }
        @media print {
          body { background-color: #ffffff; }
          .container { box-shadow: none; max-width: none; }
          .header, .event-details, .event-description, .ticket-info, .organizer-details, .sponsors, .terms-conditions {
            page-break-inside: avoid;
          }
          h2 { page-break-after: avoid; }
          .terms-conditions { page-break-before: always; }
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <div class="header-content">
            <h1>${_escapeHtml(event.name)}</h1>
            <p>${dateFormat.format(eventStart)} - ${dateFormat.format(eventEnd)}</p>
            <p>${_escapeHtml(event.location)}</p>
          </div>
        </div>
        
        <div class="content">
          <div class="event-details">
            <h2>Event Details</h2>
            <p><strong>Date:</strong> ${dateFormat.format(eventStart)} - ${dateFormat.format(eventEnd)}</p>
            <p><strong>Time:</strong> ${timeFormat.format(eventStart)} - ${timeFormat.format(eventEnd)}</p>
            <p><strong>Location:</strong> ${_escapeHtml(event.location)}</p>
            <p><strong>Venue:</strong> ${_escapeHtml(event.venue ?? 'Not specified')}</p>
            <p><strong>Category:</strong> ${_escapeHtml(event.eventSubCategory?.eventManagementCategory?.name ?? 'Not specified')}</p>
            <p><strong>Subcategory:</strong> ${_escapeHtml(event.eventSubCategory?.name ?? 'Not specified')}</p>
            ${event.eventAgeCategory != null ? '<p><strong>Age Category:</strong> ${_escapeHtml(event.eventAgeCategory?.name)}</p>' : ''}
            <p><strong>Event Number:</strong> ${_escapeHtml(event.eventNumber ?? 'Not specified')}</p>
            <p><strong>Online Sale:</strong> ${event.onlineSale == true ? 'Available' : 'Not available'}</p>
            <p><strong>Refund Policy:</strong> ${event.refund == true ? 'Refunds allowed' : 'No refunds'}</p>
          </div>

          <h2>Event Description</h2>
          <div class="event-description">
            ${_escapeHtml(event.eventdescription)}
          </div>

          ${_generateTicketInfo(event)}

          ${_generateOrganizerInfo(event)}

          ${_generateSponsorsSection(event, sponsorDataUrls)}

          ${_generateTermsAndConditions(event)}
        </div>
      </div>
    </body>
    </html>
    ''';
  }

  static String _generateTermsAndConditions(Event event) {
    return '''
      <div class="terms-conditions">
        <h2>Terms and Conditions</h2>
        <div class="terms-content">
          ${_escapeHtml(event.eventTerms)}
        </div>
      </div>
    ''';
  }


  static String _generateTicketInfo(Event event) {
    if (event.eventZones == null || event.eventZones!.isEmpty) {
      return '';
    }

    var ticketInfo = '<h2>Ticket Information</h2><div class="ticket-info">';
    for (var zone in event.eventZones!) {
      // if (zone.visibleOnApp != true) continue;
      ticketInfo += '''
        <div class="zone">
          <h3>${_escapeHtml(zone.name)}</h3>
          <p><strong>Price:</strong> ${zone.cost} ${event.registration?.curr ?? ''}</p>
          ${zone.ebcost != null ? '<p><strong>Early Bird Price:</strong> ${zone.ebcost} ${event.registration?.curr ?? ''}</p>' : ''}
          ${zone.ebstarts != null ? '<p><strong>Early Bird Starts:</strong> ${zone.ebstarts}</p>' : ''}
          ${zone.ebends != null ? '<p><strong>Early Bird Ends:</strong> ${zone.ebends}</p>' : ''}
          <p><strong>Available Tickets:</strong> ${zone.maxtickets != null ? zone.maxtickets! - (zone.sold ?? 0) : 'Unlimited'}</p>
          ${zone.desc != null ? '<p><strong>Description:</strong> ${_escapeHtml(zone.desc)}</p>' : ''}
        </div>
      ''';
    }
    ticketInfo += '</div>';
    return ticketInfo;
  }

  static String _generateOrganizerInfo(Event event) {
    if (event.registration == null) return '';

    return '''
      <h2>Organizer Information</h2>
      <div class="organizer-details">
        <p><strong>Name:</strong> ${_escapeHtml(event.registration!.regname ?? 'Not specified')}</p>
        <p><strong>Email:</strong> ${_escapeHtml(event.registration!.email ?? 'Not specified')}</p>
        <p><strong>Phone:</strong> ${_escapeHtml(event.registration!.phone ?? 'Not specified')}</p>
        <p><strong>Location:</strong> ${_escapeHtml(event.registration!.location ?? 'Not specified')}</p>
      </div>
    ''';
  }

  static String _generateSponsorsSection(Event event, Map<String, String> sponsorDataUrls) {
    if (event.eventSponsors == null || event.eventSponsors!.isEmpty) {
      return '';
    }

    var sponsorsHtml = '<h2>Event Sponsors</h2><div class="sponsors">';
    for (var sponsor in event.eventSponsors!) {
      if (sponsor.active == true) {
        final dataUrl = sponsorDataUrls[sponsor.name] ?? 'https://via.placeholder.com/100x100.png?text=Sponsor';
        sponsorsHtml += '''
          <div class="sponsor">
            <img src="${dataUrl}" alt="${_escapeHtml(sponsor.name)}">
            <p>${_escapeHtml(sponsor.name)}</p>
          </div>
        ''';
      }
    }
    sponsorsHtml += '</div>';
    return sponsorsHtml;
  }
  

  static String _escapeHtml(String? text) {
    if (text == null) return '';
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;')
        .replaceAll('\n', '<br>');
  }

  static void _convertHtmlToPdfAndDownload(String htmlContent, String fileName) {
    js.context.callMethod('generatePDF', [htmlContent, fileName]);
  }
}