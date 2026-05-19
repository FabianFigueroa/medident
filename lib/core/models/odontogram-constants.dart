enum ToothState {
  healthy,
  caries,
  filled,
  rootCanal,
  crown,
  implant,
  missing,
  fracture,
  sealant,
}

extension ToothStateX on ToothState {
  String get label {
    switch (this) {
      case ToothState.healthy: return 'Sano';
      case ToothState.caries: return 'Caries';
      case ToothState.filled: return 'Obturado';
      case ToothState.rootCanal: return 'Endodoncia';
      case ToothState.crown: return 'Corona';
      case ToothState.implant: return 'Implante';
      case ToothState.missing: return 'Ausente';
      case ToothState.fracture: return 'Fractura';
      case ToothState.sealant: return 'Sellante';
    }
  }

  int get colorValue {
    switch (this) {
      case ToothState.healthy: return 0xFF4CAF50;
      case ToothState.caries: return 0xFFE53935;
      case ToothState.filled: return 0xFF1E88E5;
      case ToothState.rootCanal: return 0xFF8E24AA;
      case ToothState.crown: return 0xFFF9A825;
      case ToothState.implant: return 0xFF00ACC1;
      case ToothState.missing: return 0xFFBDBDBD;
      case ToothState.fracture: return 0xFFFF6F00;
      case ToothState.sealant: return 0xFF43A047;
    }
  }
}

class ToothData {
  final int number;
  ToothState state;

  ToothData({required this.number, this.state = ToothState.healthy});

  Map<String, dynamic> toMap() => {
        'state': state.name,
      };

  factory ToothData.fromMap(Map<String, dynamic> map, int number) {
    return ToothData(
      number: number,
      state: ToothState.values.firstWhere(
        (s) => s.name == map['state'],
        orElse: () => ToothState.healthy,
      ),
    );
  }
}

const List<int> upperRightTeeth = [18, 17, 16, 15, 14, 13, 12, 11];
const List<int> upperLeftTeeth = [21, 22, 23, 24, 25, 26, 27, 28];
const List<int> lowerLeftTeeth = [31, 32, 33, 34, 35, 36, 37, 38];
const List<int> lowerRightTeeth = [48, 47, 46, 45, 44, 43, 42, 41];
const List<int> allTeeth = [
  ...upperRightTeeth,
  ...upperLeftTeeth,
  ...lowerLeftTeeth,
  ...lowerRightTeeth,
];

bool isUpperTooth(int number) => number >= 11 && number <= 28;
bool isLowerTooth(int number) => number >= 31 && number <= 48;
