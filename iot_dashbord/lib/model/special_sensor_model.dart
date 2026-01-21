import 'package:intl/intl.dart';

class SpecialSensorData {
  String installationID;
  String type;
  String? installationLocation;
  DateTime? measurementDate;
  String? measurementDepth;
  String? measurementInterval;

  double? depthMinus0_0;
  double? depthMinus0_5;
  double? depthMinus1_0;
  double? depthMinus1_5;
  double? depthMinus2_0;
  double? depthMinus2_5;
  double? depthMinus3_0;
  double? depthMinus3_5;
  double? depthMinus4_0;
  double? depthMinus4_5;
  double? depthMinus5_0;
  double? depthMinus5_5;
  double? depthMinus6_0;
  double? depthMinus6_5;
  double? depthMinus7_0;
  double? depthMinus7_5;
  double? depthMinus8_0;
  double? depthMinus8_5;
  double? depthMinus9_0;
  double? depthMinus9_5;
  double? depthMinus10_0;
  double? depthMinus10_5;
  double? depthMinus11_0;
  double? depthMinus11_5;
  double? depthMinus12_0;
  double? depthMinus12_5;
  double? depthMinus13_0;
  double? depthMinus13_5;
  double? depthMinus14_0;
  double? depthMinus14_5;
  double? depthMinus15_0;

  int? elapsedDays;
  double? currentWaterLevel;
  double? excavationLevel;
  double? changeAmount;
  double? cumulativeDisplacement;

  double? strainGaugeReading;
  double? stress;
  double? excavationDepth;

  double? absoluteAltitude1;
  double? absoluteAltitude2;
  double? absoluteAltitude3;

  double? subsidence1;
  double? subsidence2;
  double? subsidence3;



  SpecialSensorData({
    required this.installationID,
    required this.type,
    this.installationLocation,
    this.measurementDate,
    this.measurementDepth,
    this.measurementInterval,
    this.depthMinus0_0,
    this.depthMinus0_5,
    this.depthMinus1_0,
    this.depthMinus1_5,
    this.depthMinus2_0,
    this.depthMinus2_5,
    this.depthMinus3_0,
    this.depthMinus3_5,
    this.depthMinus4_0,
    this.depthMinus4_5,
    this.depthMinus5_0,
    this.depthMinus5_5,
    this.depthMinus6_0,
    this.depthMinus6_5,
    this.depthMinus7_0,
    this.depthMinus7_5,
    this.depthMinus8_0,
    this.depthMinus8_5,
    this.depthMinus9_0,
    this.depthMinus9_5,
    this.depthMinus10_0,
    this.depthMinus10_5,
    this.depthMinus11_0,
    this.depthMinus11_5,
    this.depthMinus12_0,
    this.depthMinus12_5,
    this.depthMinus13_0,
    this.depthMinus13_5,
    this.depthMinus14_0,
    this.depthMinus14_5,
    this.depthMinus15_0,
    this.elapsedDays,
    this.currentWaterLevel,
    this.excavationLevel,
    this.changeAmount,
    this.cumulativeDisplacement,
    this.strainGaugeReading,
    this.stress,
    this.excavationDepth,
    this.absoluteAltitude1,
    this.absoluteAltitude2,
    this.absoluteAltitude3,
    this.subsidence1,
    this.subsidence2,
    this.subsidence3,

  });

  factory SpecialSensorData.fromJson(Map<String, dynamic> json) {
    return SpecialSensorData(
      installationID: json['InstallationID'],
      type: json['Type'],
      installationLocation: json['InstallationLocation'],
      measurementDate: json['MeasurementDate'] != null
          ? DateTime.parse(json['MeasurementDate'])
          : null,

      measurementDepth: json['measurementDepth'],

      measurementInterval: json['measurementInterval'],

      depthMinus0_0: (json['DepthMinus0_0'] as num?)?.toDouble(),
      depthMinus0_5: (json['DepthMinus0_5'] as num?)?.toDouble(),
      depthMinus1_0: (json['DepthMinus1_0'] as num?)?.toDouble(),
      depthMinus1_5: (json['DepthMinus1_5'] as num?)?.toDouble(),
      depthMinus2_0: (json['DepthMinus2_0'] as num?)?.toDouble(),
      depthMinus2_5: (json['DepthMinus2_5'] as num?)?.toDouble(),
      depthMinus3_0: (json['DepthMinus3_0'] as num?)?.toDouble(),
      depthMinus3_5: (json['DepthMinus3_5'] as num?)?.toDouble(),
      depthMinus4_0: (json['DepthMinus4_0'] as num?)?.toDouble(),
      depthMinus4_5: (json['DepthMinus4_5'] as num?)?.toDouble(),
      depthMinus5_0: (json['DepthMinus5_0'] as num?)?.toDouble(),
      depthMinus5_5: (json['DepthMinus5_5'] as num?)?.toDouble(),
      depthMinus6_0: (json['DepthMinus6_0'] as num?)?.toDouble(),
      depthMinus6_5: (json['DepthMinus6_5'] as num?)?.toDouble(),
      depthMinus7_0: (json['DepthMinus7_0'] as num?)?.toDouble(),
      depthMinus7_5: (json['DepthMinus7_5'] as num?)?.toDouble(),
      depthMinus8_0: (json['DepthMinus8_0'] as num?)?.toDouble(),
      depthMinus8_5: (json['DepthMinus8_5'] as num?)?.toDouble(),
      depthMinus9_0: (json['DepthMinus9_0'] as num?)?.toDouble(),
      depthMinus9_5: (json['DepthMinus9_5'] as num?)?.toDouble(),
      depthMinus10_0: (json['DepthMinus10_0'] as num?)?.toDouble(),
      depthMinus10_5: (json['DepthMinus10_5'] as num?)?.toDouble(),
      depthMinus11_0: (json['DepthMinus11_0'] as num?)?.toDouble(),
      depthMinus11_5: (json['DepthMinus11_5'] as num?)?.toDouble(),
      depthMinus12_0: (json['DepthMinus12_0'] as num?)?.toDouble(),
      depthMinus12_5: (json['DepthMinus12_5'] as num?)?.toDouble(),
      depthMinus13_0: (json['DepthMinus13_0'] as num?)?.toDouble(),
      depthMinus13_5: (json['DepthMinus13_5'] as num?)?.toDouble(),
      depthMinus14_0: (json['DepthMinus14_0'] as num?)?.toDouble(),
      depthMinus14_5: (json['DepthMinus14_5'] as num?)?.toDouble(),
      depthMinus15_0: (json['DepthMinus15_0'] as num?)?.toDouble(),

      elapsedDays: json['ElapsedDays'],
      currentWaterLevel: (json['CurrentWaterLevel'] as num?)?.toDouble(),
      excavationLevel: (json['ExcavationLevel'] as num?)?.toDouble(),
      changeAmount: (json['ChangeAmount'] as num?)?.toDouble(),
      cumulativeDisplacement: (json['CumulativeDisplacement'] as num?)?.toDouble(),

      strainGaugeReading: (json['StrainGaugeReading'] as num?)?.toDouble(),
      stress: (json['Stress'] as num?)?.toDouble(),
      excavationDepth: (json['ExcavationDepth'] as num?)?.toDouble(),

      absoluteAltitude1: (json['AbsoluteAltitude1'] as num?)?.toDouble(),
      absoluteAltitude2: (json['AbsoluteAltitude2'] as num?)?.toDouble(),
      absoluteAltitude3: (json['AbsoluteAltitude3'] as num?)?.toDouble(),

      subsidence1: (json['Subsidence1'] as num?)?.toDouble(),
      subsidence2: (json['Subsidence2'] as num?)?.toDouble(),
      subsidence3: (json['Subsidence3'] as num?)?.toDouble(),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'InstallationID': installationID,
      'Type': type,
      'InstallationLocation': installationLocation,
      'MeasurementDate': measurementDate != null
          ? DateFormat('yyyy-MM-dd').format(measurementDate!)
          : null,
      'MeasurementDepth': measurementDepth,
      'MeasurementInterval': measurementInterval,

      'DepthMinus0_0': depthMinus0_0,
      'DepthMinus0_5': depthMinus0_5,
      'DepthMinus1_0': depthMinus1_0,
      'DepthMinus1_5': depthMinus1_5,
      'DepthMinus2_0': depthMinus2_0,
      'DepthMinus2_5': depthMinus2_5,
      'DepthMinus3_0': depthMinus3_0,
      'DepthMinus3_5': depthMinus3_5,
      'DepthMinus4_0': depthMinus4_0,
      'DepthMinus4_5': depthMinus4_5,
      'DepthMinus5_0': depthMinus5_0,
      'DepthMinus5_5': depthMinus5_5,
      'DepthMinus6_0': depthMinus6_0,
      'DepthMinus6_5': depthMinus6_5,
      'DepthMinus7_0': depthMinus7_0,
      'DepthMinus7_5': depthMinus7_5,
      'DepthMinus8_0': depthMinus8_0,
      'DepthMinus8_5': depthMinus8_5,
      'DepthMinus9_0': depthMinus9_0,
      'DepthMinus9_5': depthMinus9_5,
      'DepthMinus10_0': depthMinus10_0,
      'DepthMinus10_5': depthMinus10_5,
      'DepthMinus11_0': depthMinus11_0,
      'DepthMinus11_5': depthMinus11_5,
      'DepthMinus12_0': depthMinus12_0,
      'DepthMinus12_5': depthMinus12_5,
      'DepthMinus13_0': depthMinus13_0,
      'DepthMinus13_5': depthMinus13_5,
      'DepthMinus14_0': depthMinus14_0,
      'DepthMinus14_5': depthMinus14_5,
      'DepthMinus15_0': depthMinus15_0,

      'ElapsedDays': elapsedDays,
      'CurrentWaterLevel': currentWaterLevel,
      'ExcavationLevel': excavationLevel,
      'ChangeAmount': changeAmount,
      'CumulativeDisplacement': cumulativeDisplacement,

      'StrainGaugeReading': strainGaugeReading,
      'Stress': stress,
      'ExcavationDepth': excavationDepth,

      'AbsoluteAltitude1': absoluteAltitude1,
      'AbsoluteAltitude2': absoluteAltitude2,
      'AbsoluteAltitude3': absoluteAltitude3,

      'Subsidence1': subsidence1,
      'Subsidence2': subsidence2,
      'Subsidence3': subsidence3,


    };
  }
}
