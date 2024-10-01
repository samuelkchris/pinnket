class DonationDetails {
  final int requiredAmount;
  final int totalCollected;
  final int totalDonations;

  DonationDetails({
    required this.requiredAmount,
    required this.totalCollected,
    required this.totalDonations,
  });

  factory DonationDetails.fromJson(Map<String, dynamic> json) {
    return DonationDetails(
      requiredAmount: json['requiredAmount'] ?? 0,
      totalCollected: json['totalCollected'],
      totalDonations: json['totalDonations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requiredAmount': requiredAmount,
      'totalCollected': totalCollected,
      'totalDonations': totalDonations,
    };
  }
}
