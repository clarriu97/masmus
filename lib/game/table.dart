/// Seats go round the table in speaking order, 0 → 1 → 2 → 3 (R-ORD-2).
/// Seats 0 and 2 are one pair (team 0), 1 and 3 the other (team 1).
const seats = [0, 1, 2, 3];

int nextSeat(int seat) => (seat + 1) % 4;

int teamOf(int seat) => seat % 2;

/// The four seats in speaking order, starting with the [mano].
List<int> speakingOrder(int mano) => [
  for (var i = 0; i < 4; i++) (mano + i) % 4,
];
