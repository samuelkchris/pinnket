

class TicketResponse {
  final List<String> tickets;
  final EventDetails eventDetails;
  final ZoneDetails zoneDetails;
  final DateTime purchasedOn;

  TicketResponse({
    required this.tickets,
    required this.eventDetails,
    required this.zoneDetails,
    required this.purchasedOn,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      tickets: List<String>.from(json['tickets']),
      eventDetails: EventDetails.fromJson(json['eventDetails']),
      zoneDetails: ZoneDetails.fromJson(json['zoneDetails']),
      purchasedOn: DateTime.parse(json['purchasedOn']),
    );
  }
}

class ZoneDetails {
  final String zid;
  final String eid;
  final String name;
  final int cost;
  final int? ebcost;
  final String? ebstarts;
  final String? ebends;
  final int? maxtickets;
  final bool? isActive;
  final bool? visibleOnApp;
  final String desc;

  ZoneDetails({
    required this.zid,
    required this.eid,
    required this.name,
    required this.cost,
    this.ebcost,
    this.ebstarts,
    this.ebends,
    this.maxtickets,
    this.isActive,
    this.visibleOnApp,
    required this.desc,
  });

  factory ZoneDetails.fromJson(Map<String, dynamic> json) {
    return ZoneDetails(
      zid: json['zid'] ?? '',
      eid: json['eid'] ?? '',
      name: json['name'] ?? '',
      cost: json['cost'] ?? 0,
      ebcost: json['ebcost'] ?? 0,
      ebstarts: json['ebstarts'] ?? '',
      ebends: json['ebends'] ?? '',
      maxtickets: json['maxtickets'] ?? 0,
      isActive: json['isactive'] ?? false,
      visibleOnApp: json['visibleOnApp'] ?? false,
      desc: json['desc'] ?? '',
    );
  }
}

class EventDetails {
  final String? eid;
  final String? rid;
  final String? name;
  final String? eventdescription;
  final String? eventDate;
  final String? endtime;
  final String? escid;
  final String? bannerURL;
  final String? location;
  final String? dateCreated;
  final String? dateModified;
  final String? venue;
  final bool? paid;
  final bool? inviteOnly;
  final bool? onlineSale;
  final bool? gateSale;
  final bool? tickVer;
  final bool? selfReg;
  final bool? includePass;
  final bool? includeCoupon;
  final bool? sendPassAfterReg;
  final bool? passVerification;
  final bool? includeAgenda;
  final bool? ticketPass;
  final bool? contactSharing;
  final bool? attendeeVer;
  final String? agecategory;
  final String? regStruct;
  final String? eventNumber;

  EventDetails({
    this.eid,
    this.rid,
    this.name,
    this.eventdescription,
    this.eventDate,
    this.endtime,
    this.escid,
    this.bannerURL,
    this.location,
    this.dateCreated,
    this.dateModified,
    this.venue,
    this.paid,
    this.inviteOnly,
    this.onlineSale,
    this.gateSale,
    this.tickVer,
    this.selfReg,
    this.includePass,
    this.includeCoupon,
    this.sendPassAfterReg,
    this.passVerification,
    this.agecategory,
    this.includeAgenda,
    this.ticketPass,
    this.regStruct,
    this.contactSharing,
    this.attendeeVer,
    this.eventNumber,
  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      eid: json['eid'] ?? '',
      rid: json['rid'] ?? '',
      name: json['name'] ?? '',
      eventdescription: json['eventdescription'] ?? '',
      eventDate: json['eventDate'] ?? '',
      endtime: json['endtime'] ?? '',
      escid: json['escid'] ?? '',
      bannerURL: json['bannerURL'] ?? '',
      location: json['location'] ?? '',
      dateCreated: json['dateCreated'] ?? '',
      dateModified: json['dateModified'] ?? '',
      venue: json['venue'] ?? '',
      paid: json['paid'] ?? false,
      inviteOnly: json['inviteOnly'] ?? false,
      onlineSale: json['onlineSale'] ?? false,
      gateSale: json['gateSale'] ?? false,
      tickVer: json['tickVer'] ?? false,
      selfReg: json['selfReg'] ?? false,
      includePass: json['includePass'] ?? false,
      includeCoupon: json['includeCoupon'] ?? false,
      sendPassAfterReg: json['sendPassAfterReg'] ?? false,
      passVerification: json['passVerification'] ?? false,
      agecategory: json['agecategory'] ?? '',
      includeAgenda: json['includeAgenda'] ?? false,
      ticketPass: json['ticketPass'] ?? false,
      regStruct: json['regStruct'] ?? '',
      contactSharing: json['contactSharing'] ?? false,
      attendeeVer: json['attendeeVer'] ?? false,
      eventNumber: json['eventNumber'] ?? '',
    );
  }
}