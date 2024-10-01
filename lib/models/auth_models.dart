class LoginResponse {
  final String message;
  final List<Ticket> tickets;
  final List<Transfer> transfers;
  final List<Received> received;

  LoginResponse({
    required this.message,
    required this.tickets,
    required this.transfers,
    required this.received,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'],
      tickets: List<Ticket>.from(
          json['tickets'].map((item) => Ticket.fromJson(item))),
      transfers: List<Transfer>.from(
          json['transfers'].map((item) => Transfer.fromJson(item))),
      received: List<Received>.from(
          json['received'].map((item) => Received.fromJson(item))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'tickets': tickets.map((ticket) => ticket.toJson()).toList(),
      'transfers': transfers.map((transfer) => transfer.toJson()).toList(),
      'received': received.map((received) => received.toJson()).toList(),
    };
  }
}

class Received {
  final String ticketCode;
  final String dateTransfered;
  final String senderEmail;
  final String senderName;
  final String senderPhone;
  final int cost;

  Received({
    required this.ticketCode,
    required this.dateTransfered,
    required this.senderEmail,
    required this.senderName,
    required this.senderPhone,
    required this.cost,
  });

  factory Received.fromJson(Map<String, dynamic> json) {
    return Received(
      ticketCode: json['ticketCode'] ?? '',
      dateTransfered: json['dateTransfered'] ?? '',
      senderEmail: json['senderEmail'] ?? '',
      senderName: json['senderName'] ?? '',
      senderPhone: json['senderPhone'] ?? '',
      cost: json['cost'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketCode': ticketCode,
      'dateTransfered': dateTransfered,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'senderPhone': senderPhone,
      'cost': cost,
    };
  }
}

class Transfer {
  final String ticketCode;
  final String dateTransfered;
  final String receiverEmail;
  final String receiverPhone;
  final String receiverName;
  final int cost;

  Transfer({
    required this.ticketCode,
    required this.dateTransfered,
    required this.receiverEmail,
    required this.cost,
    required this.receiverPhone,
    required this.receiverName,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      ticketCode: json['ticketCode'],
      dateTransfered: json['dateTransfered'],
      receiverEmail: json['receiverEmail'],
      cost: json['cost'],
      receiverPhone: json['receiverPhone'],
      receiverName: json['receiverName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketCode': ticketCode,
      'dateTransfered': dateTransfered,
      'receiverEmail': receiverEmail,
      'cost': cost,
      'receiverPhone': receiverPhone,
      'receiverName': receiverName,
    };
  }
}

class Ticket {
  final String serialNumber;
  final String purchaseDate;
  final String ticketCode;
  final String cost;
  final String eventName;
  final String eventDescription;
  final String eventVenue;
  final String eventLocation;
  final String eventZone;
  final String eventDate;
  final String eventTime;
  final List<Map<String, String>> eventSponsors;
  final int admits;
  final String ticketHTML;

  Ticket({
    required this.serialNumber,
    required this.purchaseDate,
    required this.ticketCode,
    required this.cost,
    required this.eventName,
    required this.eventDescription,
    required this.eventVenue,
    required this.eventLocation,
    required this.eventZone,
    required this.eventDate,
    required this.eventTime,
    required this.eventSponsors,
    required this.admits,
    required this.ticketHTML,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      serialNumber: json['serialNumber'],
      purchaseDate: json['purchaseDate'],
      ticketCode: json['ticketCode'],
      cost: json['cost'],
      eventName: json['eventName'],
      eventDescription: json['eventDescription'],
      eventVenue: json['eventVenue'],
      eventLocation: json['eventLocation'],
      eventZone: json['eventZone'],
      eventDate: json['eventDate'],
      eventTime: json['eventTime'],
      eventSponsors: List<Map<String, String>>.from(
          json['eventSponsors'].map((item) => Map<String, String>.from(item))),
      admits: json['admits'],
      ticketHTML: json['ticketHTML'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serialNumber': serialNumber,
      'purchaseDate': purchaseDate,
      'ticketCode': ticketCode,
      'cost': cost,
      'eventName': eventName,
      'eventDescription': eventDescription,
      'eventVenue': eventVenue,
      'eventLocation': eventLocation,
      'eventZone': eventZone,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'eventSponsors': eventSponsors.map((sponsor) => sponsor).toList(),
      'admits': admits,
      'ticketHTML': ticketHTML,
    };
  }
}
