class Event {
  final String? eid;
  final String? rid;
  final String? name;
  final String? eventdescription;
  final String? eventDate;
  final String? endtime;
  final String? escid;
  final String? bannerURL;
  final String? location;
  final bool? prive;
  final String? dateCreated;
  final String? dateModified;
  final String? venue;
  final String? evLogo;
  final String? eventTerms;
  final bool? refund;
  final int? likes;
  final int? dislikes;
  final bool? acceptDonations;
  final bool? showDonatedAmount;

  // final int? donatedAmount;
  final int? requiredDonation;
  final List<String>? highlights;

  // final bool? paid;
  // final bool? inviteOnly;
  final bool? onlineSale;
  final bool? publishOnline;

  // final bool? gateSale;
  // final bool? tickVer;
  // final bool? selfReg;
  // final bool? includePass;
  // final String? agecategory;
  // final bool? includeAgenda;
  final String? regStruct;
  final String? eventNumber;

  // final List<EventCoupon>? eventCoupons;
  List<EventZone>? eventZones;

  Registration? registration;
  EventSubCategory? eventSubCategory;
  final List<EventSponsor>? eventSponsors;
  final EventAgeCategory? eventAgeCategory;

  Event({
    this.eid,
    this.rid,
    this.name,
    this.eventdescription,
    this.eventDate,
    this.endtime,
    this.escid,
    this.bannerURL,
    this.location,
    this.prive,
    this.dateCreated,
    this.dateModified,
    this.venue,
    this.evLogo,
    this.eventTerms,
    this.refund,
    this.likes,
    this.dislikes,
    // this.paid,
    // this.inviteOnly,
    this.onlineSale,
    this.publishOnline,
    // this.gateSale,
    // this.tickVer,
    // this.selfReg,
    // this.includePass,
    // this.agecategory,
    // this.includeAgenda,
    this.regStruct,
    this.eventNumber,
    // this.eventCoupons,
    this.eventZones,
    this.registration,
    this.eventSubCategory,
    this.eventAgeCategory,
    this.eventSponsors,
    this.acceptDonations,
    this.showDonatedAmount,
    // this.donatedAmount,
    this.requiredDonation,
    this.highlights,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eid: json['eid'] ?? '',
      rid: json['rid'] ?? '',
      name: json['name'] ?? '',
      eventdescription: json['eventdescription'] ?? '',
      eventDate: json['eventDate'] ?? '',
      endtime: json['endtime'] ?? '',
      escid: json['escid'] ?? '',
      bannerURL: json['bannerURL'] ?? '',
      location: json['location'] ?? '',
      prive: json['prive'] ?? false,
      dateCreated: json['dateCreated'] ?? '',
      dateModified: json['dateModified'] ?? '',
      venue: json['venue'] ?? '',
      evLogo: json['evLogo'] ?? '',
      eventTerms: json['eventTerms'] ?? '',
      refund: json['refund'] ?? false,
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      // paid: json['paid'] ?? '',
      // inviteOnly: json['inviteOnly'] ?? '',
      onlineSale: json['onlineSale'] ?? false,
      publishOnline: json['publishOnline'] ?? false,
      // gateSale: json['gateSale'] ?? '',
      // tickVer: json['tickVer'] ?? '',
      // selfReg: json['selfReg'] ?? '',
      // includePass: json['includePass'] ?? '',
      // agecategory: json['agecategory'] ?? '',
      // includeAgenda: json['includeAgenda'] ?? '',
      regStruct: json['regStruct'] ?? '',
      eventNumber: json['eventNumber'] ?? '',
      // eventCoupons: (json['EventCoupons'] as List).isEmpty
      //     ? []
      //     : (json['EventCoupons'] as List)
      //         .map((i) => EventCoupon.fromJson(i))
      //         .toList(),
      eventZones: json['EventZones'] != null
          ? (json['EventZones'] as List)
              .map((i) => EventZone.fromJson(i))
              .toList()
          : [],
      registration: json['Registration'] != null
          ? Registration.fromJson(json['Registration'])
          : null,
      eventSubCategory: json['eventSubCategory'] != null
          ? EventSubCategory.fromJson(json['eventSubCategory'])
          : null,
      eventSponsors: json['EventSponsors'] != null
          ? (json['EventSponsors'] as List)
              .map((i) => EventSponsor.fromJson(i))
              .toList()
          : [],
      // eventAgeCategory: EventAgeCategory.fromJson(json['EventAgeCategory']),
      eventAgeCategory: json['EventAgeCategory'] != null
          ? EventAgeCategory.fromJson(json['EventAgeCategory'])
          : null,
      acceptDonations: json['acceptDonations'] ?? false,
      showDonatedAmount: json['showDonatedAmount'] ?? false,
      // donatedAmount: json['donatedAmount'] ?? 0,
      requiredDonation: json['requiredDonation'] ?? 0,
      highlights: json['highlights'] != null
          ? List<String>.from(json['highlights'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eid': eid,
      'rid': rid,
      'name': name,
      'eventdescription': eventdescription,
      'eventDate': eventDate,
      'endtime': endtime,
      'escid': escid,
      'bannerURL': bannerURL,
      'location': location,
      'prive': prive,
      'dateCreated': dateCreated,
      'dateModified': dateModified,
      'venue': venue,
      'evLogo': evLogo,
      'eventTerms': eventTerms,
      'refund': refund,
      'likes': likes,
      'dislikes': dislikes,
      // 'paid': paid,
      // 'inviteOnly': inviteOnly,
      'onlineSale': onlineSale,
      'publishOnline': publishOnline,
      // 'gateSale': gateSale,
      // 'tickVer': tickVer,
      // 'selfReg': selfReg,
      // 'includePass': includePass,
      // 'agecategory': agecategory,
      // 'includeAgenda': includeAgenda,
      'regStruct': regStruct,
      'eventNumber': eventNumber,
      // 'EventCoupons': eventCoupons,
      'EventZones': eventZones?.toJson(),
      'Registration': registration,
      'eventSubCategory': eventSubCategory,
      'EventAgeCategory': eventAgeCategory,
      'EventSponsors': eventSponsors,
      'acceptDonations': acceptDonations,
      'showDonatedAmount': showDonatedAmount,
      // 'donatedAmount': donatedAmount,
      'requiredDonation': requiredDonation,
      'highlights': highlights,
    };
  }
}

extension on List<EventZone>? {
  toJson() {
    return this?.map((e) => e.toJson()).toList();
  }
}

class EventCoupon {
  final String? ecid;
  final String? eid;
  final String? name;
  final String? expdate;
  final int? cost;
  final bool? renews;
  final int? maxRedeems;

  EventCoupon({
    this.ecid,
    this.eid,
    this.name,
    this.expdate,
    this.cost,
    this.renews,
    this.maxRedeems,
  });

  factory EventCoupon.fromJson(Map<String, dynamic> json) {
    return EventCoupon(
      ecid: json['ecid'],
      eid: json['eid'],
      name: json['name'],
      expdate: json['expdate'],
      cost: json['cost'],
      renews: json['renews'],
      maxRedeems: json['maxRedeems'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ecid': ecid,
      'eid': eid,
      'name': name,
      'expdate': expdate,
      'cost': cost,
      'renews': renews,
      'maxRedeems': maxRedeems,
    };
  }
}

class EventZone {
  final String? zid;
  final String? eid;
  final String? name;
  final int? cost;
  final int? ebcost;
  final String? ebstarts;
  final String? ebends;
  final int? maxtickets;
  final int? sold;
  final bool? isactive;
  final bool? visibleOnApp;
  final String? desc;

  EventZone({
    this.zid,
    this.eid,
    this.name,
    this.cost,
    this.ebcost,
    this.ebstarts,
    this.ebends,
    this.maxtickets,
    this.sold,
    this.isactive,
    this.visibleOnApp,
    this.desc,
  });

  factory EventZone.fromJson(Map<String, dynamic> json) {
    return EventZone(
      zid: json['zid'],
      eid: json['eid'],
      name: json['name'],
      cost: json['cost'],
      ebcost: json['ebcost'],
      ebstarts: json['ebstarts'],
      ebends: json['ebends'],
      maxtickets: json['maxtickets'],
      sold: json['sold'],
      isactive: json['isactive'],
      visibleOnApp: json['visibleOnApp'] ?? false,
      desc: json['desc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zid': zid,
      'eid': eid,
      'name': name,
      'cost': cost,
      'ebcost': ebcost,
      'ebstarts': ebstarts,
      'ebends': ebends,
      'maxtickets': maxtickets,
      'sold': sold,
      'isactive': isactive,
      'visibleOnApp': visibleOnApp,
      'desc': desc,
    };
  }
}

class Registration {
   String? rid;
   String? regname;
   String? email;
   String? phone;
   String? location;
   String? eid;
   String? esid;
   int? cid;
   String? bcard;
   String? logo;
   String? BTcolor;
   String? curr;

  Registration({
    this.rid,
    this.regname,
    this.email,
    this.phone,
    this.location,
    this.eid,
    this.esid,
    this.cid,
    this.bcard,
    this.logo,
    this.BTcolor,
    this.curr,
  });

  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      rid: json['rid'],
      regname: json['regname'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      eid: json['eid'],
      esid: json['esid'],
      cid: json['cid'],
      bcard: json['bcard'],
      logo: json['logo'],
      BTcolor: json['BTcolor'],
      curr: json['curr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rid': rid,
      'regname': regname,
      'email': email,
      'phone': phone,
      'location': location,
      'eid': eid,
      'esid': esid,
      'cid': cid,
      'bcard': bcard,
      'logo': logo,
      'BTcolor': BTcolor,
      'curr': curr,
    };
  }
}

class EventSubCategory {
  final String? id;
  final String? cid;
  final String? name;
  EventManagementCategory? eventManagementCategory;

  EventSubCategory({
    this.id,
    this.cid,
    this.name,
    this.eventManagementCategory,
  });

  factory EventSubCategory.fromJson(Map<String, dynamic> json) {
    return EventSubCategory(
      id: json['id'],
      cid: json['cid'],
      name: json['name'],
      eventManagementCategory: json['eventManagementCategory'] != null
          ? EventManagementCategory.fromJson(json['eventManagementCategory'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cid': cid,
      'name': name,
      'eventManagementCategory': eventManagementCategory,
    };
  }
}

class EventManagementCategory {
  final String? id;
  final String? name;

  EventManagementCategory({
    this.id,
    this.name,
  });

  factory EventManagementCategory.fromJson(Map<String, dynamic> json) {
    return EventManagementCategory(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class EventAgeCategory {
  final String? id;
  final String? name;

  EventAgeCategory({
    this.id,
    this.name,
  });

  factory EventAgeCategory.fromJson(Map<String, dynamic> json) {
    return EventAgeCategory(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class EventSponsor {
  final String? id;
  final String? name;
  final String? url;
  final String? eid;
  final bool? active;

  EventSponsor({
    this.id,
    this.name,
    this.url,
    this.eid,
    this.active,
  });

  factory EventSponsor.fromJson(Map<String, dynamic> json) {
    return EventSponsor(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      eid: json['eid'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'eid': eid,
      'active': active,
    };
  }
}
