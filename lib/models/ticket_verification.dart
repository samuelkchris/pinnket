class TicketVerificationResponse {
  final String verificationMessage;
  final EventInformation eventInformation;
  final ZoneInformation zoneInformation;
  final String purchaseDate;

  TicketVerificationResponse(
      {required this.verificationMessage,
      required this.eventInformation,
      required this.zoneInformation,
      required this.purchaseDate});

  factory TicketVerificationResponse.fromJson(Map<String, dynamic> json) {
    return TicketVerificationResponse(
      verificationMessage: json['message'],
      eventInformation: EventInformation.fromJson(json['eventDetails']),
      zoneInformation: ZoneInformation.fromJson(json['zoneDetails']),
      purchaseDate: json['purchasedOn'],
    );
  }
}

class EventInformation {
  final String eventId;
  final String eventName;

  EventInformation({required this.eventId, required this.eventName});

  factory EventInformation.fromJson(Map<String, dynamic> json) {
    return EventInformation(
      eventId: json['eid'],
      eventName: json['name'],
    );
  }
}

class ZoneInformation {
  final String zoneId;
  final String zoneName;

  ZoneInformation({required this.zoneId, required this.zoneName});

  factory ZoneInformation.fromJson(Map<String, dynamic> json) {
    return ZoneInformation(
      zoneId: json['zid'],
      zoneName: json['name'],
    );
  }
}
