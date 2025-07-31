const express = require('express');
const router = express.Router();
const { sql, poolConnect, pool } = require('../db'); // ✅ 수정!
const dbConfig = require('../dbConfig');
const { DateTime } = require('luxon');


// POST or PUT /specialsensor
router.post('/specialsensor', async (req, res) => {
  const {
    InstallationID,
    Type,
    InstallationLocation,
    MeasurementDate,
    MeasurementDepth,
    MeasurementInterval,
    DepthMinus0_0,
    DepthMinus0_5,
    DepthMinus1_0,
    DepthMinus1_5,
    DepthMinus2_0,
    DepthMinus2_5,
    DepthMinus3_0,
    DepthMinus3_5,
    DepthMinus4_0,
    DepthMinus4_5,
    DepthMinus5_0,
    DepthMinus5_5,
    DepthMinus6_0,
    DepthMinus6_5,
    DepthMinus7_0,
    DepthMinus7_5,
    DepthMinus8_0,
    DepthMinus8_5,
    DepthMinus9_0,
    DepthMinus9_5,
    DepthMinus10_0,
    DepthMinus10_5,
    DepthMinus11_0,
    DepthMinus11_5,
    DepthMinus12_0,
    DepthMinus12_5,
    DepthMinus13_0,
    DepthMinus13_5,
    DepthMinus14_0,
    DepthMinus14_5,
    DepthMinus15_0,
    ElapsedDays,
    CurrentWaterLevel,
    ExcavationLevel,
    ChangeAmount,
    CumulativeDisplacement,
    StrainGaugeReading,
    Stress,
    ExcavationDepth,
    AbsoluteAltitude1,
    AbsoluteAltitude2,
    AbsoluteAltitude3,
    Subsidence1,
    Subsidence2,
    Subsidence3,
    DryDays
  } = req.body;
  const data = req.body;

  if (!InstallationID || !Type) {
    return res.status(400).json({ error: 'InstallationID와 Type은 필수입니다.' });
  }

 
  let finalDate;
  try {
    finalDate = new Date(MeasurementDate);
    if (isNaN(finalDate.getTime())) {
      return res.status(400).json({ error: 'MeasurementDate는 yyyy-MM-dd 형식의 문자열이어야 합니다.' });
    }
    data.MeasurementDate = finalDate;
    console.log('🕓 최종 저장 날짜:', finalDate);
  } catch (err) {
    console.error('❌ 날짜 파싱 실패:', err);
    return res.status(400).json({ error: 'MeasurementDate 처리 중 오류 발생' });
  }
  
  

  try {
    const pool = await poolConnect;

    // 기존 데이터 존재 여부 확인 (InstallationID, Type 기준)
    const existingResult = await pool.request()
      .input('InstallationID', sql.NVarChar, InstallationID)
      .input('Type', sql.NVarChar, Type)
      .query(`
        SELECT COUNT(*) AS cnt 
        FROM SpecialSensorData 
        WHERE InstallationID = @InstallationID AND Type = @Type
      `);

    const exists = existingResult.recordset[0].cnt > 0;


    const request = pool.request();
    for (const [key, value] of Object.entries(data)) {
      if (value !== undefined) {
        const type = typeof value === 'number'
          ? sql.Float
          : value instanceof Date
          ? sql.Date
          : sql.NVarChar;
        request.input(key, type, value);
      }
    }


    if (exists) {
      // UPDATE
      await pool.request()
        .input('InstallationID', sql.NVarChar, InstallationID)
        .input('Type', sql.NVarChar, Type)
        .input('InstallationLocation', sql.NVarChar, InstallationLocation)
        .input('MeasurementDate', sql.Date, data.MeasurementDate)
        .input('MeasurementDepth', sql.NVarChar, MeasurementDepth)
        .input('MeasurementInterval', sql.NVarChar, MeasurementInterval)
        .input('DepthMinus0_0', sql.Float, DepthMinus0_0)
        .input('DepthMinus0_5', sql.Float, DepthMinus0_5)
        .input('DepthMinus1_0', sql.Float, DepthMinus1_0)
        .input('DepthMinus1_5', sql.Float, DepthMinus1_5)
        .input('DepthMinus2_0', sql.Float, DepthMinus2_0)
        .input('DepthMinus2_5', sql.Float, DepthMinus2_5)
        .input('DepthMinus3_0', sql.Float, DepthMinus3_0)
        .input('DepthMinus3_5', sql.Float, DepthMinus3_5)
        .input('DepthMinus4_0', sql.Float, DepthMinus4_0)
        .input('DepthMinus4_5', sql.Float, DepthMinus4_5)
        .input('DepthMinus5_0', sql.Float, DepthMinus5_0)
        .input('DepthMinus5_5', sql.Float, DepthMinus5_5)
        .input('DepthMinus6_0', sql.Float, DepthMinus6_0)
        .input('DepthMinus6_5', sql.Float, DepthMinus6_5)
        .input('DepthMinus7_0', sql.Float, DepthMinus7_0)
        .input('DepthMinus7_5', sql.Float, DepthMinus7_5)
        .input('DepthMinus8_0', sql.Float, DepthMinus8_0)
        .input('DepthMinus8_5', sql.Float, DepthMinus8_5)
        .input('DepthMinus9_0', sql.Float, DepthMinus9_0)
        .input('DepthMinus9_5', sql.Float, DepthMinus9_5)
        .input('DepthMinus10_0', sql.Float, DepthMinus10_0)
        .input('DepthMinus10_5', sql.Float, DepthMinus10_5)
        .input('DepthMinus11_0', sql.Float, DepthMinus11_0)
        .input('DepthMinus11_5', sql.Float, DepthMinus11_5)
        .input('DepthMinus12_0', sql.Float, DepthMinus12_0)
        .input('DepthMinus12_5', sql.Float, DepthMinus12_5)
        .input('DepthMinus13_0', sql.Float, DepthMinus13_0)
        .input('DepthMinus13_5', sql.Float, DepthMinus13_5)
        .input('DepthMinus14_0', sql.Float, DepthMinus14_0)
        .input('DepthMinus14_5', sql.Float, DepthMinus14_5)
        .input('DepthMinus15_0', sql.Float, DepthMinus15_0)
        .input('ElapsedDays', sql.Int, ElapsedDays)
        .input('CurrentWaterLevel', sql.Float, CurrentWaterLevel)
        .input('ExcavationLevel', sql.Float, ExcavationLevel)
        .input('ChangeAmount', sql.Float, ChangeAmount)
        .input('CumulativeDisplacement', sql.Float, CumulativeDisplacement)
        .input('StrainGaugeReading', sql.Float, StrainGaugeReading)
        .input('Stress', sql.Float, Stress)
        .input('ExcavationDepth', sql.Float, ExcavationDepth)
        .input('AbsoluteAltitude1', sql.Float, AbsoluteAltitude1)
        .input('AbsoluteAltitude2', sql.Float, AbsoluteAltitude2)
        .input('AbsoluteAltitude3', sql.Float, AbsoluteAltitude3)
        .input('Subsidence1', sql.Float, Subsidence1)
        .input('Subsidence2', sql.Float, Subsidence2)
        .input('Subsidence3', sql.Float, Subsidence3)
        
        .query(`
          UPDATE SpecialSensorData
          SET InstallationLocation = @InstallationLocation,
              MeasurementDate = @MeasurementDate,
              MeasurementDepth = @MeasurementDepth,
              MeasurementInterval = @MeasurementInterval,
              DepthMinus0_0 = @DepthMinus0_0,
              DepthMinus0_5 = @DepthMinus0_5,
              DepthMinus1_0 = @DepthMinus1_0,
              DepthMinus1_5 = @DepthMinus1_5,
              DepthMinus2_0 = @DepthMinus2_0,
              DepthMinus2_5 = @DepthMinus2_5,
              DepthMinus3_0 = @DepthMinus3_0,
              DepthMinus3_5 = @DepthMinus3_5,
              DepthMinus4_0 = @DepthMinus4_0,
              DepthMinus4_5 = @DepthMinus4_5,
              DepthMinus5_0 = @DepthMinus5_0,
              DepthMinus5_5 = @DepthMinus5_5,
              DepthMinus6_0 = @DepthMinus6_0,
              DepthMinus6_5 = @DepthMinus6_5,
              DepthMinus7_0 = @DepthMinus7_0,
              DepthMinus7_5 = @DepthMinus7_5,
              DepthMinus8_0 = @DepthMinus8_0,
              DepthMinus8_5 = @DepthMinus8_5,
              DepthMinus9_0 = @DepthMinus9_0,
              DepthMinus9_5 = @DepthMinus9_5,
              DepthMinus10_0 = @DepthMinus10_0,
              DepthMinus10_5 = @DepthMinus10_5,
              DepthMinus11_0 = @DepthMinus11_0,
              DepthMinus11_5 = @DepthMinus11_5,
              DepthMinus12_0 = @DepthMinus12_0,
              DepthMinus12_5 = @DepthMinus12_5,
              DepthMinus13_0 = @DepthMinus13_0,
              DepthMinus13_5 = @DepthMinus13_5,
              DepthMinus14_0 = @DepthMinus14_0,
              DepthMinus14_5 = @DepthMinus14_5,
              DepthMinus15_0 = @DepthMinus15_0,
              ElapsedDays = @ElapsedDays,
              CurrentWaterLevel = @CurrentWaterLevel,
              ExcavationLevel = @ExcavationLevel,
              ChangeAmount = @ChangeAmount,
              CumulativeDisplacement = @CumulativeDisplacement,
              StrainGaugeReading = @StrainGaugeReading,
              Stress = @Stress,
              ExcavationDepth = @ExcavationDepth,
              AbsoluteAltitude1 = @AbsoluteAltitude1,
              AbsoluteAltitude2 = @AbsoluteAltitude2,
              AbsoluteAltitude3 = @AbsoluteAltitude3,
              Subsidence1 = @Subsidence1,
              Subsidence2 = @Subsidence2,
              Subsidence3 = @Subsidence3

              
          WHERE InstallationID = @InstallationID AND Type = @Type
        `);

      res.status(200).json({ message: '센서 데이터 업데이트 완료' });

    } else {
      // INSERT
      await pool.request()
        .input('InstallationID', sql.NVarChar, InstallationID)
        .input('Type', sql.NVarChar, Type)
        .input('InstallationLocation', sql.NVarChar, InstallationLocation)
        .input('MeasurementDate', sql.Date, data.MeasurementDate)
        .input('MeasurementDepth',sql.NVarChar, MeasurementDepth)
        .input('MeasurementInterval', sql.NVarChar, MeasurementInterval)
        .input('DepthMinus0_0', sql.Float, DepthMinus0_0)
        .input('DepthMinus0_5', sql.Float, DepthMinus0_5)
        .input('DepthMinus1_0', sql.Float, DepthMinus1_0)
        .input('DepthMinus1_5', sql.Float, DepthMinus1_5)
        .input('DepthMinus2_0', sql.Float, DepthMinus2_0)
        .input('DepthMinus2_5', sql.Float, DepthMinus2_5)
        .input('DepthMinus3_0', sql.Float, DepthMinus3_0)
        .input('DepthMinus3_5', sql.Float, DepthMinus3_5)
        .input('DepthMinus4_0', sql.Float, DepthMinus4_0)
        .input('DepthMinus4_5', sql.Float, DepthMinus4_5)
        .input('DepthMinus5_0', sql.Float, DepthMinus5_0)
        .input('DepthMinus5_5', sql.Float, DepthMinus5_5)
        .input('DepthMinus6_0', sql.Float, DepthMinus6_0)
        .input('DepthMinus6_5', sql.Float, DepthMinus6_5)
        .input('DepthMinus7_0', sql.Float, DepthMinus7_0)
        .input('DepthMinus7_5', sql.Float, DepthMinus7_5)
        .input('DepthMinus8_0', sql.Float, DepthMinus8_0)
        .input('DepthMinus8_5', sql.Float, DepthMinus8_5)
        .input('DepthMinus9_0', sql.Float, DepthMinus9_0)
        .input('DepthMinus9_5', sql.Float, DepthMinus9_5)
        .input('DepthMinus10_0', sql.Float, DepthMinus10_0)
        .input('DepthMinus10_5', sql.Float, DepthMinus10_5)
        .input('DepthMinus11_0', sql.Float, DepthMinus11_0)
        .input('DepthMinus11_5', sql.Float, DepthMinus11_5)
        .input('DepthMinus12_0', sql.Float, DepthMinus12_0)
        .input('DepthMinus12_5', sql.Float, DepthMinus12_5)
        .input('DepthMinus13_0', sql.Float, DepthMinus13_0)
        .input('DepthMinus13_5', sql.Float, DepthMinus13_5)
        .input('DepthMinus14_0', sql.Float, DepthMinus14_0)
        .input('DepthMinus14_5', sql.Float, DepthMinus14_5)
        .input('DepthMinus15_0', sql.Float, DepthMinus15_0)
        .input('ElapsedDays', sql.Int, ElapsedDays)
        .input('CurrentWaterLevel', sql.Float, CurrentWaterLevel)
        .input('ExcavationLevel', sql.Float, ExcavationLevel)
        .input('ChangeAmount', sql.Float, ChangeAmount)
        .input('CumulativeDisplacement', sql.Float, CumulativeDisplacement)
        .input('StrainGaugeReading', sql.Float, StrainGaugeReading)
        .input('Stress', sql.Float, Stress)
        .input('ExcavationDepth', sql.Float, ExcavationDepth)
        .input('AbsoluteAltitude1', sql.Float, AbsoluteAltitude1)
        .input('AbsoluteAltitude2', sql.Float, AbsoluteAltitude2)
        .input('AbsoluteAltitude3', sql.Float, AbsoluteAltitude3)
        .input('Subsidence1', sql.Float, Subsidence1)
        .input('Subsidence2', sql.Float, Subsidence2)
        .input('Subsidence3', sql.Float, Subsidence3)
        
        .query(`
          INSERT INTO SpecialSensorData (
            InstallationID, Type, InstallationLocation, MeasurementDate,
            MeasurementDepth, MeasurementInterval,
            DepthMinus0_0, DepthMinus0_5, DepthMinus1_0, DepthMinus1_5, DepthMinus2_0, DepthMinus2_5, DepthMinus3_0, DepthMinus3_5,
            DepthMinus4_0, DepthMinus4_5, DepthMinus5_0, DepthMinus5_5, DepthMinus6_0, DepthMinus6_5, DepthMinus7_0, DepthMinus7_5,
            DepthMinus8_0, DepthMinus8_5, DepthMinus9_0, DepthMinus9_5, DepthMinus10_0, DepthMinus10_5, DepthMinus11_0, DepthMinus11_5,
            DepthMinus12_0, DepthMinus12_5, DepthMinus13_0, DepthMinus13_5, DepthMinus14_0, DepthMinus14_5, DepthMinus15_0,
            ElapsedDays, CurrentWaterLevel, ExcavationLevel, ChangeAmount, CumulativeDisplacement,
            StrainGaugeReading, Stress, ExcavationDepth,
            AbsoluteAltitude1, AbsoluteAltitude2, AbsoluteAltitude3,
            Subsidence1, Subsidence2, Subsidence3
          ) VALUES (
            @InstallationID, @Type, @InstallationLocation, @MeasurementDate,
            @MeasurementDepth, @MeasurementInterval,
            @DepthMinus0_0, @DepthMinus0_5, @DepthMinus1_0, @DepthMinus1_5, @DepthMinus2_0, @DepthMinus2_5, @DepthMinus3_0, @DepthMinus3_5,
            @DepthMinus4_0, @DepthMinus4_5, @DepthMinus5_0, @DepthMinus5_5, @DepthMinus6_0, @DepthMinus6_5, @DepthMinus7_0, @DepthMinus7_5,
            @DepthMinus8_0, @DepthMinus8_5, @DepthMinus9_0, @DepthMinus9_5, @DepthMinus10_0, @DepthMinus10_5, @DepthMinus11_0, @DepthMinus11_5,
            @DepthMinus12_0, @DepthMinus12_5, @DepthMinus13_0, @DepthMinus13_5, @DepthMinus14_0, @DepthMinus14_5, @DepthMinus15_0,
            @ElapsedDays, @CurrentWaterLevel, @ExcavationLevel, @ChangeAmount, @CumulativeDisplacement,
            @StrainGaugeReading, @Stress, @ExcavationDepth,
            @AbsoluteAltitude1, @AbsoluteAltitude2, @AbsoluteAltitude3,
            @Subsidence1, @Subsidence2, @Subsidence3
          )
        `);

      res.status(201).json({ message: '센서 데이터 추가 완료' });
    }
    
        // 🟢 WebSocket 전송 - Type에 따라 분기
        const wss = req.app.get('wss');
        if (wss && wss.clients) {
          let payload;
          switch (Type) {
            case '지중경사계':
              payload = {
                type: 'InclinometerData',
                data: {
                  Type, InstallationID, InstallationLocation, MeasurementDate,
                  DepthMinus0_0, DepthMinus0_5, DepthMinus1_0, DepthMinus1_5, DepthMinus2_0, DepthMinus2_5,
                  DepthMinus3_0, DepthMinus3_5, DepthMinus4_0, DepthMinus4_5, DepthMinus5_0, DepthMinus5_5,
                  DepthMinus6_0, DepthMinus6_5, DepthMinus7_0, DepthMinus7_5, DepthMinus8_0, DepthMinus8_5,
                  DepthMinus9_0, DepthMinus9_5, DepthMinus10_0, DepthMinus10_5, DepthMinus11_0, DepthMinus11_5,
                  DepthMinus12_0, DepthMinus12_5, DepthMinus13_0, DepthMinus13_5, DepthMinus14_0, DepthMinus14_5,
                  DepthMinus15_0
                }
              };
              break;
            case '지하수위계':
              payload = {
                type: 'GroundWaterLevelSensorData',
                data: {
                  Type, InstallationID, InstallationLocation, MeasurementDate,
                  ElapsedDays,CurrentWaterLevel, ExcavationLevel, ChangeAmount, CumulativeDisplacement,
                 }
              };
              break;
            case '변형률계':
              payload = {
                type: 'StrainGaugeData',
                data: {
                  Type, InstallationID, InstallationLocation, MeasurementDate,
                  StrainGaugeReading,
                  Stress,
                  ExcavationDepth
                }
              };
              break;
            case '지표침하계':
              payload = {
                type: 'SettlementMeterData',
                data: {
                  Type, InstallationID, InstallationLocation, MeasurementDate,
                  ElapsedDays,
                  AbsoluteAltitude1, AbsoluteAltitude2, AbsoluteAltitude3,
                  Subsidence1, Subsidence2, Subsidence3,
                }
              };
              break;
            default:
              payload = {
                type: 'specialSensorUpdate',
                data: { ...data, message: 'Special sensor data updated' }
              };
          }
    
          wss.clients.forEach(client => {
            if (client.readyState === 1) {
              client.send(JSON.stringify(payload));
              console.log('센서데이터 webgl에 전송 완료');
            }
          });
        }
  } catch (err) {
    console.error('❌ 센서 데이터 저장 실패:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});

router.post('/specialsensor_unity', async (req, res) => {
  const {
    InstallationID,
    Type,
    InstallationLocation,
    MeasurementDate,
    MeasurementDepth,
    MeasurementInterval,
    DepthMinus0_0,
    DepthMinus0_5,
    DepthMinus1_0,
    DepthMinus1_5,
    DepthMinus2_0,
    DepthMinus2_5,
    DepthMinus3_0,
    DepthMinus3_5,
    DepthMinus4_0,
    DepthMinus4_5,
    DepthMinus5_0,
    DepthMinus5_5,
    DepthMinus6_0,
    DepthMinus6_5,
    DepthMinus7_0,
    DepthMinus7_5,
    DepthMinus8_0,
    DepthMinus8_5,
    DepthMinus9_0,
    DepthMinus9_5,
    DepthMinus10_0,
    DepthMinus10_5,
    DepthMinus11_0,
    DepthMinus11_5,
    DepthMinus12_0,
    DepthMinus12_5,
    DepthMinus13_0,
    DepthMinus13_5,
    DepthMinus14_0,
    DepthMinus14_5,
    DepthMinus15_0,
    ElapsedDays,
    CurrentWaterLevel,
    ExcavationLevel,
    ChangeAmount,
    CumulativeDisplacement,
    StrainGaugeReading,
    Stress,
    ExcavationDepth,
    AbsoluteAltitude1,
    AbsoluteAltitude2,
    AbsoluteAltitude3,
    Subsidence1,
    Subsidence2,
    Subsidence3,
    DryDays
  } = req.body;
  const data = req.body;

  if (!InstallationID || !Type) {
    return res.status(400).json({ error: 'InstallationID와 Type은 필수입니다.' });
  }

 
  let finalDate;
  try {
    finalDate = new Date(MeasurementDate);
    if (isNaN(finalDate.getTime())) {
      return res.status(400).json({ error: 'MeasurementDate는 yyyy-MM-dd 형식의 문자열이어야 합니다.' });
    }
    data.MeasurementDate = finalDate;
    console.log('🕓 최종 저장 날짜:', finalDate);
  } catch (err) {
    console.error('❌ 날짜 파싱 실패:', err);
    return res.status(400).json({ error: 'MeasurementDate 처리 중 오류 발생' });
  }
  
  

  try {
    const pool = await poolConnect;

    // 기존 데이터 존재 여부 확인 (InstallationID, Type 기준)
    const existingResult = await pool.request()
      .input('InstallationID', sql.NVarChar, InstallationID)
      .input('Type', sql.NVarChar, Type)
      .query(`
        SELECT COUNT(*) AS cnt 
        FROM SpecialSensorData 
        WHERE InstallationID = @InstallationID AND Type = @Type
      `);

    const exists = existingResult.recordset[0].cnt > 0;


    const request = pool.request();
    for (const [key, value] of Object.entries(data)) {
      if (value !== undefined) {
        const type = typeof value === 'number'
          ? sql.Float
          : value instanceof Date
          ? sql.Date
          : sql.NVarChar;
        request.input(key, type, value);
      }
    }


    if (exists) {
      // UPDATE
      await pool.request()
        .input('InstallationID', sql.NVarChar, InstallationID)
        .input('Type', sql.NVarChar, Type)
        .input('InstallationLocation', sql.NVarChar, InstallationLocation)
        .input('MeasurementDate', sql.Date, data.MeasurementDate)
        .input('MeasurementDepth', sql.NVarChar, MeasurementDepth)
        .input('MeasurementInterval', sql.NVarChar, MeasurementInterval)
        .input('DepthMinus0_0', sql.Float, DepthMinus0_0)
        .input('DepthMinus0_5', sql.Float, DepthMinus0_5)
        .input('DepthMinus1_0', sql.Float, DepthMinus1_0)
        .input('DepthMinus1_5', sql.Float, DepthMinus1_5)
        .input('DepthMinus2_0', sql.Float, DepthMinus2_0)
        .input('DepthMinus2_5', sql.Float, DepthMinus2_5)
        .input('DepthMinus3_0', sql.Float, DepthMinus3_0)
        .input('DepthMinus3_5', sql.Float, DepthMinus3_5)
        .input('DepthMinus4_0', sql.Float, DepthMinus4_0)
        .input('DepthMinus4_5', sql.Float, DepthMinus4_5)
        .input('DepthMinus5_0', sql.Float, DepthMinus5_0)
        .input('DepthMinus5_5', sql.Float, DepthMinus5_5)
        .input('DepthMinus6_0', sql.Float, DepthMinus6_0)
        .input('DepthMinus6_5', sql.Float, DepthMinus6_5)
        .input('DepthMinus7_0', sql.Float, DepthMinus7_0)
        .input('DepthMinus7_5', sql.Float, DepthMinus7_5)
        .input('DepthMinus8_0', sql.Float, DepthMinus8_0)
        .input('DepthMinus8_5', sql.Float, DepthMinus8_5)
        .input('DepthMinus9_0', sql.Float, DepthMinus9_0)
        .input('DepthMinus9_5', sql.Float, DepthMinus9_5)
        .input('DepthMinus10_0', sql.Float, DepthMinus10_0)
        .input('DepthMinus10_5', sql.Float, DepthMinus10_5)
        .input('DepthMinus11_0', sql.Float, DepthMinus11_0)
        .input('DepthMinus11_5', sql.Float, DepthMinus11_5)
        .input('DepthMinus12_0', sql.Float, DepthMinus12_0)
        .input('DepthMinus12_5', sql.Float, DepthMinus12_5)
        .input('DepthMinus13_0', sql.Float, DepthMinus13_0)
        .input('DepthMinus13_5', sql.Float, DepthMinus13_5)
        .input('DepthMinus14_0', sql.Float, DepthMinus14_0)
        .input('DepthMinus14_5', sql.Float, DepthMinus14_5)
        .input('DepthMinus15_0', sql.Float, DepthMinus15_0)
        .input('ElapsedDays', sql.Int, ElapsedDays)
        .input('CurrentWaterLevel', sql.Float, CurrentWaterLevel)
        .input('ExcavationLevel', sql.Float, ExcavationLevel)
        .input('ChangeAmount', sql.Float, ChangeAmount)
        .input('CumulativeDisplacement', sql.Float, CumulativeDisplacement)
        .input('StrainGaugeReading', sql.Float, StrainGaugeReading)
        .input('Stress', sql.Float, Stress)
        .input('ExcavationDepth', sql.Float, ExcavationDepth)
        .input('AbsoluteAltitude1', sql.Float, AbsoluteAltitude1)
        .input('AbsoluteAltitude2', sql.Float, AbsoluteAltitude2)
        .input('AbsoluteAltitude3', sql.Float, AbsoluteAltitude3)
        .input('Subsidence1', sql.Float, Subsidence1)
        .input('Subsidence2', sql.Float, Subsidence2)
        .input('Subsidence3', sql.Float, Subsidence3)
        
        .query(`
          UPDATE SpecialSensorData
          SET InstallationLocation = @InstallationLocation,
              MeasurementDate = @MeasurementDate,
              MeasurementDepth = @MeasurementDepth,
              MeasurementInterval = @MeasurementInterval,
              DepthMinus0_0 = @DepthMinus0_0,
              DepthMinus0_5 = @DepthMinus0_5,
              DepthMinus1_0 = @DepthMinus1_0,
              DepthMinus1_5 = @DepthMinus1_5,
              DepthMinus2_0 = @DepthMinus2_0,
              DepthMinus2_5 = @DepthMinus2_5,
              DepthMinus3_0 = @DepthMinus3_0,
              DepthMinus3_5 = @DepthMinus3_5,
              DepthMinus4_0 = @DepthMinus4_0,
              DepthMinus4_5 = @DepthMinus4_5,
              DepthMinus5_0 = @DepthMinus5_0,
              DepthMinus5_5 = @DepthMinus5_5,
              DepthMinus6_0 = @DepthMinus6_0,
              DepthMinus6_5 = @DepthMinus6_5,
              DepthMinus7_0 = @DepthMinus7_0,
              DepthMinus7_5 = @DepthMinus7_5,
              DepthMinus8_0 = @DepthMinus8_0,
              DepthMinus8_5 = @DepthMinus8_5,
              DepthMinus9_0 = @DepthMinus9_0,
              DepthMinus9_5 = @DepthMinus9_5,
              DepthMinus10_0 = @DepthMinus10_0,
              DepthMinus10_5 = @DepthMinus10_5,
              DepthMinus11_0 = @DepthMinus11_0,
              DepthMinus11_5 = @DepthMinus11_5,
              DepthMinus12_0 = @DepthMinus12_0,
              DepthMinus12_5 = @DepthMinus12_5,
              DepthMinus13_0 = @DepthMinus13_0,
              DepthMinus13_5 = @DepthMinus13_5,
              DepthMinus14_0 = @DepthMinus14_0,
              DepthMinus14_5 = @DepthMinus14_5,
              DepthMinus15_0 = @DepthMinus15_0,
              ElapsedDays = @ElapsedDays,
              CurrentWaterLevel = @CurrentWaterLevel,
              ExcavationLevel = @ExcavationLevel,
              ChangeAmount = @ChangeAmount,
              CumulativeDisplacement = @CumulativeDisplacement,
              StrainGaugeReading = @StrainGaugeReading,
              Stress = @Stress,
              ExcavationDepth = @ExcavationDepth,
              AbsoluteAltitude1 = @AbsoluteAltitude1,
              AbsoluteAltitude2 = @AbsoluteAltitude2,
              AbsoluteAltitude3 = @AbsoluteAltitude3,
              Subsidence1 = @Subsidence1,
              Subsidence2 = @Subsidence2,
              Subsidence3 = @Subsidence3

              
          WHERE InstallationID = @InstallationID AND Type = @Type
        `);

      res.status(200).json({ message: '센서 데이터 업데이트 완료' });

    } else {
      // INSERT
      await pool.request()
        .input('InstallationID', sql.NVarChar, InstallationID)
        .input('Type', sql.NVarChar, Type)
        .input('InstallationLocation', sql.NVarChar, InstallationLocation)
        .input('MeasurementDate', sql.Date, data.MeasurementDate)
        .input('MeasurementDepth',sql.NVarChar, MeasurementDepth)
        .input('MeasurementInterval', sql.NVarChar, MeasurementInterval)
        .input('DepthMinus0_0', sql.Float, DepthMinus0_0)
        .input('DepthMinus0_5', sql.Float, DepthMinus0_5)
        .input('DepthMinus1_0', sql.Float, DepthMinus1_0)
        .input('DepthMinus1_5', sql.Float, DepthMinus1_5)
        .input('DepthMinus2_0', sql.Float, DepthMinus2_0)
        .input('DepthMinus2_5', sql.Float, DepthMinus2_5)
        .input('DepthMinus3_0', sql.Float, DepthMinus3_0)
        .input('DepthMinus3_5', sql.Float, DepthMinus3_5)
        .input('DepthMinus4_0', sql.Float, DepthMinus4_0)
        .input('DepthMinus4_5', sql.Float, DepthMinus4_5)
        .input('DepthMinus5_0', sql.Float, DepthMinus5_0)
        .input('DepthMinus5_5', sql.Float, DepthMinus5_5)
        .input('DepthMinus6_0', sql.Float, DepthMinus6_0)
        .input('DepthMinus6_5', sql.Float, DepthMinus6_5)
        .input('DepthMinus7_0', sql.Float, DepthMinus7_0)
        .input('DepthMinus7_5', sql.Float, DepthMinus7_5)
        .input('DepthMinus8_0', sql.Float, DepthMinus8_0)
        .input('DepthMinus8_5', sql.Float, DepthMinus8_5)
        .input('DepthMinus9_0', sql.Float, DepthMinus9_0)
        .input('DepthMinus9_5', sql.Float, DepthMinus9_5)
        .input('DepthMinus10_0', sql.Float, DepthMinus10_0)
        .input('DepthMinus10_5', sql.Float, DepthMinus10_5)
        .input('DepthMinus11_0', sql.Float, DepthMinus11_0)
        .input('DepthMinus11_5', sql.Float, DepthMinus11_5)
        .input('DepthMinus12_0', sql.Float, DepthMinus12_0)
        .input('DepthMinus12_5', sql.Float, DepthMinus12_5)
        .input('DepthMinus13_0', sql.Float, DepthMinus13_0)
        .input('DepthMinus13_5', sql.Float, DepthMinus13_5)
        .input('DepthMinus14_0', sql.Float, DepthMinus14_0)
        .input('DepthMinus14_5', sql.Float, DepthMinus14_5)
        .input('DepthMinus15_0', sql.Float, DepthMinus15_0)
        .input('ElapsedDays', sql.Int, ElapsedDays)
        .input('CurrentWaterLevel', sql.Float, CurrentWaterLevel)
        .input('ExcavationLevel', sql.Float, ExcavationLevel)
        .input('ChangeAmount', sql.Float, ChangeAmount)
        .input('CumulativeDisplacement', sql.Float, CumulativeDisplacement)
        .input('StrainGaugeReading', sql.Float, StrainGaugeReading)
        .input('Stress', sql.Float, Stress)
        .input('ExcavationDepth', sql.Float, ExcavationDepth)
        .input('AbsoluteAltitude1', sql.Float, AbsoluteAltitude1)
        .input('AbsoluteAltitude2', sql.Float, AbsoluteAltitude2)
        .input('AbsoluteAltitude3', sql.Float, AbsoluteAltitude3)
        .input('Subsidence1', sql.Float, Subsidence1)
        .input('Subsidence2', sql.Float, Subsidence2)
        .input('Subsidence3', sql.Float, Subsidence3)
        
        .query(`
          INSERT INTO SpecialSensorData (
            InstallationID, Type, InstallationLocation, MeasurementDate,
            MeasurementDepth, MeasurementInterval,
            DepthMinus0_0, DepthMinus0_5, DepthMinus1_0, DepthMinus1_5, DepthMinus2_0, DepthMinus2_5, DepthMinus3_0, DepthMinus3_5,
            DepthMinus4_0, DepthMinus4_5, DepthMinus5_0, DepthMinus5_5, DepthMinus6_0, DepthMinus6_5, DepthMinus7_0, DepthMinus7_5,
            DepthMinus8_0, DepthMinus8_5, DepthMinus9_0, DepthMinus9_5, DepthMinus10_0, DepthMinus10_5, DepthMinus11_0, DepthMinus11_5,
            DepthMinus12_0, DepthMinus12_5, DepthMinus13_0, DepthMinus13_5, DepthMinus14_0, DepthMinus14_5, DepthMinus15_0,
            ElapsedDays, CurrentWaterLevel, ExcavationLevel, ChangeAmount, CumulativeDisplacement,
            StrainGaugeReading, Stress, ExcavationDepth,
            AbsoluteAltitude1, AbsoluteAltitude2, AbsoluteAltitude3,
            Subsidence1, Subsidence2, Subsidence3
          ) VALUES (
            @InstallationID, @Type, @InstallationLocation, @MeasurementDate,
            @MeasurementDepth, @MeasurementInterval,
            @DepthMinus0_0, @DepthMinus0_5, @DepthMinus1_0, @DepthMinus1_5, @DepthMinus2_0, @DepthMinus2_5, @DepthMinus3_0, @DepthMinus3_5,
            @DepthMinus4_0, @DepthMinus4_5, @DepthMinus5_0, @DepthMinus5_5, @DepthMinus6_0, @DepthMinus6_5, @DepthMinus7_0, @DepthMinus7_5,
            @DepthMinus8_0, @DepthMinus8_5, @DepthMinus9_0, @DepthMinus9_5, @DepthMinus10_0, @DepthMinus10_5, @DepthMinus11_0, @DepthMinus11_5,
            @DepthMinus12_0, @DepthMinus12_5, @DepthMinus13_0, @DepthMinus13_5, @DepthMinus14_0, @DepthMinus14_5, @DepthMinus15_0,
            @ElapsedDays, @CurrentWaterLevel, @ExcavationLevel, @ChangeAmount, @CumulativeDisplacement,
            @StrainGaugeReading, @Stress, @ExcavationDepth,
            @AbsoluteAltitude1, @AbsoluteAltitude2, @AbsoluteAltitude3,
            @Subsidence1, @Subsidence2, @Subsidence3
          )
        `);

      res.status(201).json({ message: '센서 데이터 추가 완료' });
    }
    
      
  } catch (err) {
    console.error('❌ 센서 데이터 저장 실패:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});

// 최근 1일 내 센서 데이터 조회 (타입별 그룹)
router.get('/recent-specialsensor-data', async (req, res) => {
    try {
      const pool = await poolConnect;
      const result = await pool.request()
        .query(`
          SELECT *
          FROM SpecialSensorData
          WHERE MeasurementDate >= DATEADD(DAY, -1, GETDATE())
          ORDER BY MeasurementDate ASC
        `);
  
      // 타입별로 분류
      const grouped = {
        InclinometerData: [],
        GroundWaterLevelSensorData: [],
        StrainGaugeData: [],
        SettlementMeterData: []
      };
  
      for (const row of result.recordset) {
        switch (row.Type) {
          case '지중경사계':
            grouped.InclinometerData.push({
              Type: row.Type,
              InstallationID: row.InstallationID,
              InstallationLocation: row.InstallationLocation,
              MeasurementDate: row.MeasurementDate,
              DepthMinus0_0: row.DepthMinus0_0,
              DepthMinus0_5: row.DepthMinus0_5,
              DepthMinus1_0: row.DepthMinus1_0,
              DepthMinus1_5: row.DepthMinus1_5,
              DepthMinus2_0: row.DepthMinus2_0,
              DepthMinus2_5: row.DepthMinus2_5,
              DepthMinus3_0: row.DepthMinus3_0,
              DepthMinus3_5: row.DepthMinus3_5,
              DepthMinus4_0: row.DepthMinus4_0,
              DepthMinus4_5: row.DepthMinus4_5,
              DepthMinus5_0: row.DepthMinus5_0,
              DepthMinus5_5: row.DepthMinus5_5,
              DepthMinus6_0: row.DepthMinus6_0,
              DepthMinus6_5: row.DepthMinus6_5,
              DepthMinus7_0: row.DepthMinus7_0,
              DepthMinus7_5: row.DepthMinus7_5,
              DepthMinus8_0: row.DepthMinus8_0,
              DepthMinus8_5: row.DepthMinus8_5,
              DepthMinus9_0: row.DepthMinus9_0,
              DepthMinus9_5: row.DepthMinus9_5,
              DepthMinus10_0: row.DepthMinus10_0,
              DepthMinus10_5: row.DepthMinus10_5,
              DepthMinus11_0: row.DepthMinus11_0,
              DepthMinus11_5: row.DepthMinus11_5,
              DepthMinus12_0: row.DepthMinus12_0,
              DepthMinus12_5: row.DepthMinus12_5,
              DepthMinus13_0: row.DepthMinus13_0,
              DepthMinus13_5: row.DepthMinus13_5,
              DepthMinus14_0: row.DepthMinus14_0,
              DepthMinus14_5: row.DepthMinus14_5,
              DepthMinus15_0: row.DepthMinus15_0
            });
            break;
          case '지하수위계':
            grouped.GroundWaterLevelSensorData.push({
              Type: row.Type,
              InstallationID: row.InstallationID,
              InstallationLocation: row.InstallationLocation,
              MeasurementDate: row.MeasurementDate,
              ElapsedDays: row.ElapsedDays,
              CurrentWaterLevel: row.CurrentWaterLevel,
              ExcavationLevel: row.ExcavationLevel,
              ChangeAmount: row.ChangeAmount,
              CumulativeDisplacement: row.CumulativeDisplacement
            });
            break;
          case '변형률계':
            grouped.StrainGaugeData.push({
              Type: row.Type,
              InstallationID: row.InstallationID,
              InstallationLocation: row.InstallationLocation,
              MeasurementDate: row.MeasurementDate,
              StrainGaugeReading: row.StrainGaugeReading,
              Stress: row.Stress,
              ExcavationDepth: row.ExcavationDepth
            });
            break;
          case '지표침하계':
            grouped.SettlementMeterData.push({
              Type: row.Type,
              InstallationID: row.InstallationID,
              InstallationLocation: row.InstallationLocation,
              MeasurementDate: row.MeasurementDate,
              ElapsedDays: row.ElapsedDays,
              AbsoluteAltitude1: row.AbsoluteAltitude1,
              AbsoluteAltitude2: row.AbsoluteAltitude2,
              AbsoluteAltitude3: row.AbsoluteAltitude3,
              Subsidence1: row.Subsidence1,
              Subsidence2: row.Subsidence2,
              Subsidence3: row.Subsidence3
            });
            break;
        }
      }
  
      res.status(200).json({ message: '최근 센서 데이터 조회 성공', data: grouped });
    } catch (err) {
      console.error('❌ recent-specialsensor-data 오류:', err);
      res.status(500).json({ error: '서버 오류' });
    }
  });
module.exports = router;
