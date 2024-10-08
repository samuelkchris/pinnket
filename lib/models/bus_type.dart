enum BusType { standard, luxury, sleeper }

class Bus {
  final String id;
  final String company;
  final BusType type;
  final int totalSeats;
  final List<List<int>> seatLayout;

  Bus({
    required this.id,
    required this.company,
    required this.type,
    required this.totalSeats,
    required this.seatLayout,
  });

  factory Bus.standard() {
    return Bus(
      id: 'std1',
      company: 'Standard Lines',
      type: BusType.standard,
      totalSeats: 40,
      seatLayout: [
        [1, 2, 0, 3, 4],
        [5, 6, 0, 7, 8],
        [9, 10, 0, 11, 12],
        [13, 14, 0, 15, 16],
        [17, 18, 0, 19, 20],
        [21, 22, 0, 23, 24],
        [25, 26, 0, 27, 28],
        [29, 30, 0, 31, 32],
        [33, 34, 0, 35, 36],
        [37, 38, 0, 39, 40],
      ],
    );
  }

  factory Bus.luxury() {
    return Bus(
      id: 'lux1',
      company: 'Luxury Travels',
      type: BusType.luxury,
      totalSeats: 32,
      seatLayout: [
        [1, 2, 0, 3, 4],
        [5, 6, 0, 7, 8],
        [9, 10, 0, 11, 12],
        [13, 14, 0, 15, 16],
        [17, 18, 0, 19, 20],
        [21, 22, 0, 23, 24],
        [25, 26, 0, 27, 28],
        [29, 30, 0, 31, 32],
      ],
    );
  }

  factory Bus.sleeper() {
    return Bus(
      id: 'slp1',
      company: 'Night Rider',
      type: BusType.sleeper,
      totalSeats: 30,
      seatLayout: [
        [1, 0, 2],
        [3, 0, 4],
        [5, 0, 6],
        [7, 0, 8],
        [9, 0, 10],
        [11, 0, 12],
        [13, 0, 14],
        [15, 0, 16],
        [17, 0, 18],
        [19, 0, 20],
        [21, 0, 22],
        [23, 0, 24],
        [25, 0, 26],
        [27, 0, 28],
        [29, 0, 30],
      ],
    );
  }
}