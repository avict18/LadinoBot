//+------------------------------------------------------------------+
//|                                                       Ladino.mq5 |
//|                                                   Rodrigo Landim |
//|                                        http://www.emagine.com.br |
//+------------------------------------------------------------------+
#property copyright     "Rodrigo Landim"
#property link          "http://www.emagine.com.br"
#property version       "1.03"
#property description   "Free Expert Advisor working using HiLo and MM starting the"
#property description   "operation when the HiLo change and MM cross the candle."

#include <Trade/Trade.mqh>
#include <LadinoBot/Utils.mqh>
#include <LadinoBot/Views/LogPanel.mqh>
#include <LadinoBot/LadinoBot.mqh>

LadinoBot _ladinoBot;

input ENUM_TIME         EntryTime = HORARIO_1000;                       // Start Time
input ENUM_TIME         CloseTime = HORARIO_1600;                       // Closing Time
input ENUM_TIME         ExitTime = HORARIO_1630;                        // Exit Time
input ENUM_OPERATION    OperationType = BUY_SELL;                       // Operation type
input ENUM_ASSET        AssetType = ASSET_INDEX;                        // Asset type
input ENUM_RISK         RiskManagement = RISK_PROGRESSIVE;              // Risk management
input ENUM_ENTRY        EntryCondition = HILO_CROSS_MM_T1_TICK;         // Entry condition
input double            BrokerageFee = 0.16;                             // Brokerage value
input double            PointValue = 0.2;                                // Value per point

input bool              UseTrendlineT1 = true;                          // T1 Use Trendline
input bool              UseSupportResistanceT1 = false;                 // T1 Support and Resistance
input int               HiloPeriodT1 = 13;                               // T1 HiLo Periods
input bool              UseHiloTrendT1 = true;                          // T1 HiLo set Trend
input int               MovingAverageT1 = 9;                             // T1 Moving average

input bool              UseExtraGraphT2 = false;                        // T2 Graph Extra
input ENUM_TIMEFRAMES   GraphTimeT2 = PERIOD_M20;                       // T2 Graph Time
input int               HiloPeriodT2 = 13;                               // T2 HiLo Periods
input bool              UseHiloTrendT2 = false;                         // T2 HiLo set Trend
input bool              UseSupportResistanceT2 = false;                 // T2 Support and Resistance
input int               MovingAverageT2 = 9;                             // T2 Moving average

input bool              UseExtraGraphT3 = false;                        // T3 Graph Extra
input ENUM_TIMEFRAMES   GraphTimeT3 = PERIOD_H2;                        // T3 Graph Time
input bool              IsHiloActiveT3 = false;                          // T3 HiLo Active
input int               HiloPeriodT3 = 5;                                // T3 HiLo Periods
input bool              UseHiloTrendT3 = true;                          // T3 HiLo set Trend
input bool              UseSupportResistanceT3 = false;                 // T3 Support and Resistance
input int               MovingAverageT3 = 9;                             // T3 Moving average

input double            MinStopLoss = 30;                                // Min Loss Stop
input double            MaxStopLoss = 50;                                // Max Loss Stop
input double            ExtraStop = 20;                                  // Extra Stop
input ENUM_STOP         InitialStop = STOP_T1_CURRENT_CANDLE;           // Initial Stop
input double            FixedStop = 0;                                    // Fixed Stop Value
input bool              ForceOperation = true;                           // Force operation
input bool              ForceEntry = true;                               // Force entry

input double            TrendlineExtra = 10;                             // Trendline Extra
input int               MaxDailyGain = 400;                              // Daily Max Gain
input int               MaxDailyLoss = -30;                              // Daily Max Loss
input double            MaxPositionGain = 400;                           // Operation Max Gain
input bool              PositionIncreaseActive = false;                  // Run Position Increase
input double            PositionStopExtra = 20;                          // Run Position Stop Extra
input int               PositionIncreaseMin = 80;                        // Run Position Increase Minimal
input int               BreakEvenPosition = 0;                           // Break Even Position
input int               BreakEvenValue = 0;                              // Break Even Value
input int               BreakEvenVolume = 0;                             // Break Even Volume
input int               InitialVolume = 2;                               // Initial Volume
input int               MaxVolume = 2;                                   // Max Volume

input ENUM_OBJECTIVE    ObjectiveCondition1 = OBJECTIVE_FIXED;          // Goal 1 Condition
input int               ObjectiveVolume1 = 1;                            // Goal 1 Volume
input int               ObjectivePosition1 = 40;                         // Goal 1 Position
input ENUM_STOP         ObjectiveStop1 = STOP_T1_PREVIOUS_CANDLE;       // Goal 1 Stop
input ENUM_OBJECTIVE    ObjectiveCondition2 = OBJECTIVE_NONE;           // Goal 2 Condition
input int               ObjectiveVolume2 = 1;                            // Goal 2 Volume
input int               ObjectivePosition2 = 0;                          // Goal 2 Position
input ENUM_STOP         ObjectiveStop2 = STOP_T1_PREVIOUS_CANDLE;       // Goal 2 Stop
input ENUM_OBJECTIVE    ObjectiveCondition3 = OBJECTIVE_FIXED;          // Goal 3 Condition
input int               ObjectiveVolume3 = 0;                            // Goal 3 Volume
input int               ObjectivePosition3 = 0;                          // Goal 3 Position
input ENUM_STOP         ObjectiveStop3 = STOP_T2_PREVIOUS_CANDLE;       // Goal 3 Stop

void initializeParameters() {

   _ladinoBot.setEntryTime(EntryTime);
   _ladinoBot.setCloseTime(CloseTime);
   _ladinoBot.setExitTime(ExitTime);
   _ladinoBot.setOperationType(OperationType);
   _ladinoBot.setAssetType(AssetType);
   _ladinoBot.setRiskManagement(RiskManagement);
   _ladinoBot.setEntryCondition(EntryCondition);
   _ladinoBot.setBrokerageFee(BrokerageFee);
   _ladinoBot.setPointValue(PointValue);

   _ladinoBot.setUseTrendlineT1(UseTrendlineT1);
   _ladinoBot.setUseSupportResistanceT1(UseSupportResistanceT1);
   _ladinoBot.setHiloPeriodT1(HiloPeriodT1);
   _ladinoBot.setUseHiloTrendT1(UseHiloTrendT1);
   _ladinoBot.setMovingAverageT1(MovingAverageT1);

   _ladinoBot.setUseExtraGraphT2(UseExtraGraphT2);
   _ladinoBot.setGraphTimeT2(GraphTimeT2);
   _ladinoBot.setHiloPeriodT2(HiloPeriodT2);
   _ladinoBot.setUseHiloTrendT2(UseHiloTrendT2);
   _ladinoBot.setUseSupportResistanceT2(UseSupportResistanceT2);
   _ladinoBot.setMovingAverageT2(MovingAverageT2);

   _ladinoBot.setUseExtraGraphT3(UseExtraGraphT3);
   _ladinoBot.setGraphTimeT3(GraphTimeT3);
   _ladinoBot.setIsHiloActiveT3(IsHiloActiveT3);
   _ladinoBot.setHiloPeriodT3(HiloPeriodT3);
   _ladinoBot.setUseHiloTrendT3(UseHiloTrendT3);
   _ladinoBot.setUseSupportResistanceT3(UseSupportResistanceT3);
   _ladinoBot.setMovingAverageT3(MovingAverageT3);

   _ladinoBot.setMinStopLoss(MinStopLoss);
   _ladinoBot.setMaxStopLoss(MaxStopLoss);
   _ladinoBot.setExtraStop(ExtraStop);
   _ladinoBot.setInitialStop(InitialStop);
   _ladinoBot.setFixedStop(FixedStop);
   _ladinoBot.setForceOperation(ForceOperation);
   _ladinoBot.setForceEntry(ForceEntry);

   _ladinoBot.setTrendlineExtra(TrendlineExtra);
   _ladinoBot.setMaxDailyGain(MaxDailyGain);
   _ladinoBot.setMaxDailyLoss(MaxDailyLoss);
   _ladinoBot.setMaxPositionGain(MaxPositionGain);
   _ladinoBot.setPositionIncreaseActive(PositionIncreaseActive);
   _ladinoBot.setPositionStopExtra(PositionStopExtra);
   _ladinoBot.setPositionIncreaseMin(PositionIncreaseMin);
   _ladinoBot.setBreakEvenPosition(BreakEvenPosition);
   _ladinoBot.setBreakEvenValue(BreakEvenValue);
   _ladinoBot.setBreakEvenVolume(BreakEvenVolume);
   _ladinoBot.setInitialVolume(InitialVolume);
   _ladinoBot.setMaxVolume(MaxVolume);

   _ladinoBot.setObjectiveCondition1(ObjectiveCondition1);
   _ladinoBot.setObjectiveVolume1(ObjectiveVolume1);
   _ladinoBot.setObjectivePosition1(ObjectivePosition1);
   _ladinoBot.setObjectiveStop1(ObjectiveStop1);
   _ladinoBot.setObjectiveCondition2(ObjectiveCondition2);
   _ladinoBot.setObjectiveVolume2(ObjectiveVolume2);
   _ladinoBot.setObjectivePosition2(ObjectivePosition2);
   _ladinoBot.setObjectiveStop2(ObjectiveStop2);
   _ladinoBot.setObjectiveCondition3(ObjectiveCondition3);
   _ladinoBot.setObjectiveVolume3(ObjectiveVolume3);
   _ladinoBot.setObjectivePosition3(ObjectivePosition3);
   _ladinoBot.setObjectiveStop3(ObjectiveStop3);
}

int OnInit() {

   EventSetTimer(60); 

   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
   ChartSetInteger(0, CHART_AUTOSCROLL, true);
   
   _logs.initialize();
   _logs.addLog("Initializing LadinoBot...");
   
   initializeParameters();
   _ladinoBot.createStatusControls();
   _ladinoBot.initialize();
   
   _logs.addLog("LadinoBot successfully launched.");
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   EventKillTimer();
}

void OnTick() {
   _ladinoBot.onTick();
}

void OnTimer(){
   _ladinoBot.onTimer();
}

double OnTester() {
   return _ladinoBot.onTester();
}

void OnTradeTransaction( 
   const MqlTradeTransaction& transaction, // structure of business transactions 
   const MqlTradeRequest&     request,     // requested structure 
   const MqlTradeResult&      result       // result structure 
) {
   _ladinoBot.onTrade(transaction, request, result);
}
