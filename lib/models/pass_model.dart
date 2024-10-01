import 'event_models.dart';

class PassInfo {
  final String? id;
  final String? name;
  final String? face;
  final String? eid;
  final String? pcid;
  final bool? pstatus;
  final String? tagid;
  final bool? entered;
  final String? enteredAt;
  final Event? event;
  // final DocumentTag? documentTag;
  final EventPassCategory? eventPassCategory;

  PassInfo({
    required this.face,
    required this.id,
    required this.name,
    required this.eid,
    required this.pcid,
    required this.pstatus,
    required this.tagid,
    required this.entered,
    required this.enteredAt,
    required this.event,
    // required this.documentTag,
    required this.eventPassCategory,
  });

  factory PassInfo.fromJson(Map<String, dynamic> json) {
    try {
      return PassInfo(
        id: json['id'],
        name: json['name'],
        eid: json['eid'],
        pcid: json['pcid'],
        pstatus: json['pstatus'],
        tagid: json['tagid'],
        entered: json['entered'],
        enteredAt: json['enteredAt'],
        event: Event.fromJson(json['event']),
        // documentTag: DocumentTag.fromJson(json['DocumentTag']),
        eventPassCategory:
            EventPassCategory.fromJson(json['eventPassCategory']),
        face: json['face'],
      );
    } catch (e) {
      print('An error occurred: $e');
      rethrow;
    }
  }
}

class DocumentTag {
  final String tagid;
  final String tagName;
  final String codeType;
  final String dateCreated;
  final String docNumber;
  final String din;
  final String batchNo;
  final String? clientId;

  DocumentTag({
    required this.tagid,
    required this.tagName,
    required this.codeType,
    required this.dateCreated,
    required this.docNumber,
    required this.din,
    required this.batchNo,
    this.clientId,
  });

  factory DocumentTag.fromJson(Map<String, dynamic> json) {
    return DocumentTag(
      tagid: json['tagid'],
      tagName: json['tagName'],
      codeType: json['codeType'],
      dateCreated: json['dateCreated'],
      docNumber: json['docNumber'],
      din: json['din'],
      batchNo: json['batchNo'],
      clientId: json['clientId'],
    );
  }
}

class EventPassCategory {
  final String id;
  final String name;
  final String eid;
  final List<PassCategoryZone> passCategoryZones;

  EventPassCategory({
    required this.id,
    required this.name,
    required this.eid,
    required this.passCategoryZones,
  });

  factory EventPassCategory.fromJson(Map<String, dynamic> json) {
    return EventPassCategory(
      id: json['id'],
      name: json['name'],
      eid: json['eid'],
      passCategoryZones: (json['PassCategoryZones'] as List<dynamic>)
          .map((zone) => PassCategoryZone.fromJson(zone))
          .toList(),
    );
  }
}

class PassCategoryZone {
  final String id;
  final String pcid;
  final String zid;
  final EventZone eventZone;
  final bool pstate;

  PassCategoryZone({
    required this.id,
    required this.pcid,
    required this.zid,
    required this.eventZone,
    required this.pstate,
  });

  factory PassCategoryZone.fromJson(Map<String, dynamic> json) {
    return PassCategoryZone(
      id: json['id'],
      pcid: json['pcid'],
      zid: json['zid'],
      eventZone: EventZone.fromJson(json['EventZone']),
      pstate: json['pstate'],
    );
  }
}

class EventZone {
  final String zid;
  final String eid;
  final String name;
  final int cost;
  final int? ebcost;
  final String? ebstarts;
  final String? ebends;

  EventZone({
    required this.zid,
    required this.eid,
    required this.name,
    required this.cost,
    this.ebcost,
    this.ebstarts,
    this.ebends,
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
    );
  }
}
