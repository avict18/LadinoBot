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

ENUM_TIME      EntryTime = HORARIO_1000;                           // Start Time
ENUM_TIME      CloseTime = HORARIO_1600;                           // Closing Time
ENUM_TIME      ExitTime = HORARIO_1630;                            // Exit Time
ENUM_OPERATION OperationType = BUY_SELL;                          // Operation type
ENUM_ASSET     AssetType = ASSET_INDEX;                            // Asset type
ENUM_RISK      RiskManagement = RISK_PROGRESSIVE;                  // Risk management
ENUM_ENTRY     EntryCondition = HILO_CROSS_MM_T1_TICK;             // Entry condition
double          BrokerageFee = 0.16;                                // Brokerage fee
double          ValuePerPoint = 0.2;                               // Value per point

bool            T1UseTrendline = true;                             // T1 Use Trendline
bool            T1SRSupportResistance = true;                      // T1 Support and Resistance
int             T1HiLoPeriod = 13;                                 // T1 HiLo Periods
bool            T1HiLoTrend = true;                                // T1 HiLo set Trend
int             T1MA = 9;                                          // T1 Moving Average

bool            T2ExtraChart = false;                              // T2 Extra Chart
ENUM_TIMEFRAMES T2ChartTimeframe = PERIOD_M20;                     // T2 Graph Time
int             T2HiLoPeriod = 13;                                 // T2 HiLo Periods
bool            T2HiLoTrend = false;                               // T2 HiLo set Trend
bool            T2SRSupportResistance = false;                     // T2 Support and Resistance
int             T2MA = 9;                                          // T2 Moving Average

bool            T3ExtraChart = false;                              // T3 Extra Chart
ENUM_TIMEFRAMES T3ChartTimeframe = PERIOD_H2;                      // T3 Graph Time
bool            T3HiLoActive = false;                              // T3 HiLo Active
int             T3HiLoPeriod = 5;                                  // T3 HiLo Periods
bool            T3HiLoTrend = true;                                // T3 HiLo set Trend
bool            T3SRSupportResistance = false;                     // T3 Support and Resistance
int             T3MA = 9;                                          // T3 Moving Average

double          MinStopLoss = 30;                                   // Min Stop Loss
double          MaxStopLoss = 50;                                   // Max Stop Loss
double          ExtraStopLoss = 10;                                 // Extra Stop Loss
ENUM_STOP       InitialStop = STOP_FIXED;                           // Initial Stop
double          FixedStop = 20;                                     // Fixed Stop Value
bool            ForceOperation = true;                             // Force operation
bool            ForceEntry = true;                                  // Force entry

double          TrendlineExtra = 10;                                // Trendline Extra
int             MaxDailyGain = 1000;                                // Max Daily Gain
int             MaxDailyLoss = -30;                                 // Max Daily Loss
double          MaxPositionGain = 400;                              // Max Position Gain
bool            PositionIncreaseActive = true;                      // Run Position Increase
double          PositionIncreaseStopExtra = 20;                     // Run Position Increase Extra Stop
int             PositionIncreaseMin = 80;                           // Run Position Increase Minimal
int             BreakEven = 100;                                    // Break Even Position
int             BreakEvenValue = 0;                                 // Break Even Value
int             BreakEvenVolume = 1;                                // Break Even Volume
int             InitialVolume = 2;                                  // Initial Volume
int             MaxVolume = 2;                                      // Max Volume

ENUM_OBJECTIVE  GoalCondition1 = GOAL_FIXED;                        // Goal 1 Condition
int             GoalVolume1 = 1;                                    // Goal 1 Volume
int             GoalPosition1 = 40;                                  // Goal 1 Position
ENUM_STOP       GoalStop1 = STOP_FIXED;                             // Goal 1 Stop
ENUM_OBJECTIVE  GoalCondition2 = GOAL_NONE;                         // Goal 2 Condition
int             GoalVolume2 = 1;                                    // Goal 2 Volume
int             GoalPosition2 = 0;                                   // Goal 2 Position
ENUM_STOP       GoalStop2 = STOP_T1_HILO;                           // Goal 2 Stop
ENUM_OBJECTIVE  GoalCondition3 = GOAL_FIXED;                        // Goal 3 Condition
int             GoalVolume3 = 0;                                    // Goal 3 Volume
int             GoalPosition3 = 0;                                   // Goal 3 Position
ENUM_STOP       GoalStop3 = STOP_T2_CANDLE_PREVIOUS;                // Goal 3 Stop

void initializeParameters() {

   _ladinoBot.setEntryTime(EntryTime);
   _ladinoBot.setCloseTime(CloseTime);
   _ladinoBot.setExitTime(ExitTime);
   _ladinoBot.setOperationType(OperationType);
   _ladinoBot.setAssetType(AssetType);
   _ladinoBot.setRiskManagement(RiskManagement);
   _ladinoBot.setEntryCondition(EntryCondition);
   _ladinoBot.setBrokerageFee(BrokerageFee);
   _ladinoBot.setValuePerPoint(ValuePerPoint);

   _ladinoBot.setT1UseTrendline(T1UseTrendline);
   _ladinoBot.setT1SRSupportResistance(T1SRSupportResistance);
   _ladinoBot.setT1HiLoPeriod(T1HiLoPeriod);
   _ladinoBot.setT1HiLoTrend(T1HiLoTrend);
   _ladinoBot.setT1MA(T1MA);

   _ladinoBot.setT2ExtraChart(T2ExtraChart);
   _ladinoBot.setT2ChartTimeframe(T2ChartTimeframe);
   _ladinoBot.setT2HiLoPeriod(T2HiLoPeriod);
   _ladinoBot.setT2HiLoTrend(T2HiLoTrend);
   _ladinoBot.setT2SRSupportResistance(T2SRSupportResistance);
   _ladinoBot.setT2MA(T2MA);

   _ladinoBot.setT3ExtraChart(T3ExtraChart);
   _ladinoBot.setT3ChartTimeframe(T3ChartTimeframe);
   _ladinoBot.setT3HiLoActive(T3HiLoActive);
   _ladinoBot.setT3HiLoPeriod(T3HiLoPeriod);
   _ladinoBot.setT3HiLoTrend(T3HiLoTrend);
   _ladinoBot.setT3SRSupportResistance(T3SRSupportResistance);
   _ladinoBot.setT3MA(T3MA);

   _ladinoBot.setMinStopLoss(MinStopLoss);
   _ladinoBot.setMaxStopLoss(MaxStopLoss);
   _ladinoBot.setExtraStopLoss(ExtraStopLoss);
   _ladinoBot.setInitialStop(InitialStop);
   _ladinoBot.setFixedStop(FixedStop);
   _ladinoBot.setForceOperation(ForceOperation);
   _ladinoBot.setForceEntry(ForceEntry);

   _ladinoBot.setTrendlineExtra(TrendlineExtra);
   _ladinoBot.setMaxDailyGain(MaxDailyGain);
   _ladinoBot.setMaxDailyLoss(MaxDailyLoss);
   _ladinoBot.setMaxPositionGain(MaxPositionGain);
   _ladinoBot.setPositionIncreaseActive(PositionIncreaseActive);
   _ladinoBot.setPositionIncreaseStopExtra(PositionIncreaseStopExtra);
   _ladinoBot.setPositionIncreaseMin(PositionIncreaseMin);
   _ladinoBot.setBreakEven(BreakEven);
   _ladinoBot.setBreakEvenValue(BreakEvenValue);
   _ladinoBot.setBreakEvenVolume(BreakEvenVolume);
   _ladinoBot.setInitialVolume(InitialVolume);
   _ladinoBot.setMaxVolume(MaxVolume);

   _ladinoBot.setGoalCondition1(GoalCondition1);
   _ladinoBot.setGoalVolume1(GoalVolume1);
   _ladinoBot.setGoalPosition1(GoalPosition1);
   _ladinoBot.setGoalStop1(GoalStop1);
   _ladinoBot.setGoalCondition2(GoalCondition2);
   _ladinoBot.setGoalVolume2(GoalVolume2);
   _ladinoBot.setGoalPosition2(GoalPosition2);
   _ladinoBot.setGoalStop2(GoalStop2);
   _ladinoBot.setGoalCondition3(GoalCondition3);
   _ladinoBot.setGoalVolume3(GoalVolume3);
   _ladinoBot.setGoalPosition3(GoalPosition3);
   _ladinoBot.setGoalStop3(GoalStop3);
}

int OnInit() {

   EventSetTimer(60); 

   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
   ChartSetInteger(0, CHART_AUTOSCROLL, true);
   
   _logs.initialize();
   _logs.addLog(INFO_INIT);
   
   initializeParameters();
   _ladinoBot.createStatusControls();
   _ladinoBot.initialize();
   
   _logs.addLog(INFO_INIT_SUCCESS);
   
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
   const MqlTradeTransaction& trans,   // trade transaction structure 
   const MqlTradeRequest&     request, // requested structure 
   const MqlTradeResult&      result   // result structure 
) {
   _ladinoBot.onTrade(trans, request, result);
}
