//+------------------------------------------------------------------+
//|                                                           SR.mqh |
//|                                                   Rodrigo Landim |
//|                                        http://www.emagine.com.br |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Landim"
#property link      "http://www.emagine.com.br"
#property version   "1.00"

#include <LadinoBot/Utils.mqh>

class SR {
   private:
      ENUM_TIMEFRAMES _period;
      int MAX_CANDLE;
      int FractalHandle;
      ENUM_TREND_SIGNAL trendSR;
      double dailyHigh;
      double dailyLow;
      double SellBuffer[];
      double BuyBuffer[];
   public:
      SR();
      ~SR();
      bool initialize(ENUM_TIMEFRAMES period = PERIOD_CURRENT);
      bool update(SUPPORT_RESISTANCE_DATA& data[]);
      double dailyLow();
      double dailyHigh();
      ENUM_TREND_SIGNAL currentTrend(SUPPORT_RESISTANCE_DATA& data[], double price);
      double currentSupport(SUPPORT_RESISTANCE_DATA& data[]);
      double currentResistance(SUPPORT_RESISTANCE_DATA& data[]);
      virtual void writeLog(string msg);
};
//+------------------------------------------------------------------+
SR::SR() {
   trendSR = UNDEFINED;
   dailyHigh = 0;
   dailyLow = 0;
   MAX_CANDLE = 100;
}

SR::~SR() {
}

bool SR::initialize(ENUM_TIMEFRAMES period = PERIOD_CURRENT) {

   _period = period;

   FractalHandle = iFractals(_Symbol, _period);
   if(FractalHandle == INVALID_HANDLE) {
      Print("Error creating fractal indicator.");
      return false;
   }
   return true;
}

bool SR::update(SUPPORT_RESISTANCE_DATA& data[]) {

   const int start = 1;

   double resistance[], support[];
   
   ArrayResize(resistance, MAX_CANDLE);
   ArrayResize(support, MAX_CANDLE);
   ArrayFree(resistance);
   ArrayFree(support);
   
   if (CopyBuffer(FractalHandle, 0, start, MAX_CANDLE, resistance) <= 0) {
      Print("Error creating support and resistance indicator.");
      return false;
   }
   if (CopyBuffer(FractalHandle, 1, start, MAX_CANDLE, support) <= 0) {
      Print("Error creating support and resistance indicator.");
      return false;
   }
 
   MqlRates rt[];
   ArrayResize(rt, MAX_CANDLE);
   if(CopyRates(_Symbol, _period, start, MAX_CANDLE, rt) != MAX_CANDLE) {
      Print("CopyRates of ",_period," failed, no history");
      return false;
   }
   
   SUPPORT_RESISTANCE_DATA data2[];
   ArrayFree(data2);
   int a = 0;
   double s = support[0];
   double r = resistance[0];
   for (int i = 0; i < MAX_CANDLE; i++) {
      if (resistance[i] != EMPTY_VALUE && resistance[i] != r) {
         r = resistance[i];
         if (resistance[i] > 0) {
            ArrayResize(data2, ArraySize(data2) + 1);
            data2[a].index = i;
            data2[a].time = rt[i].time;
            data2[a].position = NormalizeDouble(r, _Digits);
            data2[a].type = TYPE_RESISTANCE;
            a++;
         }         
      }
      if (support[i] != EMPTY_VALUE && support[i] != s) {
         s = support[i];
         if (support[i] > 0) {
            ArrayResize(data2, ArraySize(data2) + 1);
            data2[a].index = i;
            data2[a].time = rt[i].time;
            data2[a].position = NormalizeDouble(s, _Digits);
            data2[a].type = TYPE_SUPPORT;
            a++;
         }
      }
   }
   
   if (ArraySize(data2) > 0) {
      a = -1;
      ArrayFree(data);
      for (int i = 0; i < ArraySize(data2); i++) {
         if (ArraySize(data) > 0 && data[a].type == data2[i].type) {
            if ((data[a].type == TYPE_RESISTANCE && data2[i].position > data[a].position) ||
                (data[a].type == TYPE_SUPPORT && data2[i].position < data[a].position)) {
               data[a].index = data2[i].index;
               data[a].time = data2[i].time;
               data[a].position = data2[i].position;
               data[a].type = data2[i].type;
            }
         }
         else {
            a++;
            ArrayResize(data, ArraySize(data) + 1);
            data[a].index = data2[i].index;
            data[a].time = data2[i].time;
            data[a].position = data2[i].position;
            data[a].type = data2[i].type;
         }
      }
   }
   return true;
}

double SR::dailyLow() {
   return dailyLow;
}

double SR::dailyHigh() {
   return dailyHigh;
}

ENUM_TREND_SIGNAL SR::currentTrend(SUPPORT_RESISTANCE_DATA& data[], double price) {
   ENUM_TREND_SIGNAL trend = UNDEFINED;
   double currentSupport = -1;
   double currentResistance = -1;
   double previousSupport = -1;
   double previousResistance = -1;
   for (int i = ArraySize(data) - 1; i >= 0; i--) {
      if (currentResistance > 0 && previousResistance > 0 && currentSupport > 0 && previousSupport > 0)
         break;
      if (data[i].type == TYPE_RESISTANCE) {
         if (currentResistance > 0 && previousResistance < 0) 
            previousResistance = data[i].position;
         else if (currentResistance < 0) 
            currentResistance = data[i].position;
      }
      else if (data[i].type == TYPE_SUPPORT) {
         if (currentSupport > 0 && previousSupport < 0) 
            previousSupport = data[i].position;
         else if (currentSupport < 0) 
            currentSupport = data[i].position;
      }
   }
   if (currentSupport > previousSupport && currentResistance > previousResistance && price > currentSupport)
      trend = BULLISH;
   if (currentSupport < previousSupport && currentResistance < previousResistance && price < currentResistance)
      trend = BEARISH;
   return trend;
}

double SR::currentSupport(SUPPORT_RESISTANCE_DATA& data[]) {
   double support = -1;
   for (int i = ArraySize(data) - 1; i >= 0; i--) {
      if (data[i].type == TYPE_SUPPORT) {
         support = data[i].position;
         break;
      }
   }  
   return support;
}

double SR::currentResistance(SUPPORT_RESISTANCE_DATA& data[]) {
   double resistance = -1;
   for (int i = ArraySize(data) - 1; i >= 0; i--) {
      if (data[i].type == TYPE_RESISTANCE) {
         resistance = data[i].position;
         break;
      }
   }  
   return resistance;
}

void SR::writeLog(string msg){
   Print(msg);
}
