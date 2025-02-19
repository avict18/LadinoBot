//+------------------------------------------------------------------+
//|                                                    AutoTrend.mqh |
//|                                                   Rodrigo Landim |
//|                                        http://www.emagine.com.br |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Landim"
#property link      "http://www.emagine.com.br"

class AutoTrend {
   private:
   public:
      AutoTrend();
      ~AutoTrend();

      double positionLTB(long chart_id, datetime time);
      double positionLTA(long chart_id, datetime time);
      bool brokeLTB(long chart_id, datetime time);
      bool brokeLTA(long chart_id, datetime time);
      int generateLTB(datetime start, ENUM_TIMEFRAMES period = PERIOD_M1, long chart_id = 0, int candles = 15);
      int generateLTA(datetime start, ENUM_TIMEFRAMES period = PERIOD_M1, long chart_id = 0, int candles = 15);
      void clearLine(long chart_id = 0);
      double lastSupport(ENUM_TIMEFRAMES period = PERIOD_M1, long chart_id = 0, int candles = 15);
      double lastResistance(ENUM_TIMEFRAMES period = PERIOD_M1, long chart_id = 0, int candles = 15);
};

double AutoTrend::positionLTB(long chart_id, datetime time) {
   string name = "ltb_" + IntegerToString(chart_id);
   return ObjectGetValueByTime(chart_id, name, time);
}

double AutoTrend::positionLTA(long chart_id, datetime time) {
   string name = "lta_" + IntegerToString(chart_id);
   return ObjectGetValueByTime(chart_id, name, time);
}

bool AutoTrend::brokeLTB(long chart_id, datetime time) {
   double tickMin = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   price = NormalizeDouble(price, _Digits);
   price = price - MathMod(price, tickMin);
   
   string name = "ltb_" + IntegerToString(chart_id);
   double currentPosition = ObjectGetValueByTime(chart_id, name, time);
   return price > currentPosition;
}

bool AutoTrend::brokeLTA(long chart_id, datetime time) {
   double tickMin = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   price = NormalizeDouble(price, _Digits);
   price = price - MathMod(price, tickMin);
   
   string name = "lta_" + IntegerToString(chart_id);
   double currentPosition = ObjectGetValueByTime(chart_id, name, time);
   return price < currentPosition;
}

int AutoTrend::generateLTB(datetime start, ENUM_TIMEFRAMES period = PERIOD_M1, long chart_id = 0, int candles = 15) {

   MqlRates rates[];
   if(CopyRates(_Symbol, period, 0, candles, rates) != candles) {
      Print("CopyRates of ",_Symbol," failed, no history");
      return 0;
   }

   int leftCandleIndex = 1;
   int rightCandleIndex = ArraySize(rates) - 1;
   MqlRates leftCandle = rates[leftCandleIndex];
   MqlRates rightCandle = rates[rightCandleIndex];

   for (int i = 1; i < ArraySize(rates); i++) {
      if (rates[i].time < start) {
         leftCandle = rates[i];
         leftCandleIndex = i;
      }
      else if (rates[i].high >= leftCandle.high) {
         leftCandle = rates[i];
         leftCandleIndex = i;
      }
   }
   bool inDowntrend = true;
   for (int i = leftCandleIndex + 1; i < ArraySize(rates); i++) {
      if (inDowntrend && (rates[i-1].high < rates[i].high))
         inDowntrend = false;
      if (!inDowntrend && (rates[i-1].high > rates[i].high)) {
         rightCandle = rates[i];
         rightCandleIndex = i;
         break;
      }
   }
   
   ObjectDelete(chart_id, "lta_" + IntegerToString(chart_id));
   string name = "ltb_" + IntegerToString(chart_id);
   if (ObjectFind(chart_id, name) < 0) {
      if (ObjectCreate(chart_id, name, OBJ_TREND, 0, leftCandle.time, leftCandle.high, rightCandle.time, rightCandle.high)) {
         ObjectSetInteger(chart_id, name, OBJPROP_WIDTH, 2);
         ObjectSetInteger(chart_id, name, OBJPROP_COLOR, clrRed);
         ObjectSetInteger(chart_id, name, OBJPROP_RAY_RIGHT, true);
         ObjectSetInteger(chart_id, name, OBJPROP_SELECTABLE, true);
      }
      else {
         Print("Error creating the LTB.");
         return 0;
      }
   }
   else {
      ObjectMove(chart_id, name, 0, leftCandle.time, leftCandle.high);
      ObjectMove(chart_id, name, 1, rightCandle.time, rightCandle.high);
   }

   double currentPosition = 0;
   for (int i = leftCandleIndex; i < rightCandleIndex; i++) {
      currentPosition = ObjectGetValueByTime(0, name, rates[i].time);
      if (currentPosition != 0 && currentPosition < rates[i].high) {
         ObjectMove(chart_id, name, 1, rates[i].time, rates[i].high);
         ChartRedraw(chart_id);
      }
   }
   return rightCandleIndex - leftCandleIndex;
}

int AutoTrend::generateLTA(datetime start, ENUM_TIMEFRAMES period = PERIOD_M1, long chart_id = 0, int candles = 15) {

   MqlRates rates[];
   if(CopyRates(_Symbol, period, 0, candles, rates) != candles) {
      Print("CopyRates of ",_Symbol," failed, no history");
      return 0;
   }

   int leftCandleIndex = 1;
   int rightCandleIndex = ArraySize(rates) - 1;
   MqlRates leftCandle = rates[leftCandleIndex];
   MqlRates rightCandle = rates[rightCandleIndex];

   for (int i = 1; i < ArraySize(rates); i++) {
      if (rates[i].time < start) {
         leftCandle = rates[i];
         leftCandleIndex = i;
      }
      else if (rates[i].low <= leftCandle.low) {
         leftCandle = rates[i];
         leftCandleIndex = i;
      }
   }
   bool inUptrend = true;
   for (int i = leftCandleIndex + 1; i < ArraySize(rates); i++) {
      if (inUptrend && (rates[i-1].low > rates[i].low))
         inUptrend = false;
      if (!inUptrend && (rates[i-1].low < rates[i].low)) {
         rightCandle = rates[i];
         rightCandleIndex = i;
         break;
      }
   }
   
   ObjectDelete(chart_id, "ltb_" + IntegerToString(chart_id));
   string name = "lta_" + IntegerToString(chart_id);
   if (ObjectFind(chart_id, name) < 0) {
      if (ObjectCreate(chart_id, name, OBJ_TREND, 0, leftCandle.time, leftCandle.low, rightCandle.time, rightCandle.low)) {
         ObjectSetInteger(chart_id, name, OBJPROP_WIDTH, 2);
         ObjectSetInteger(chart_id, name, OBJPROP_COLOR, clrGreen);
         ObjectSetInteger(chart_id, name, OBJPROP_RAY_RIGHT, true);
         ObjectSetInteger(chart_id, name, OBJPROP_SELECTABLE, true);
      }
      else {
         Print("Error creating the LTA.");
         return 0;
      }
   }
   else {
      ObjectMove(chart_id, name, 0, leftCandle.time, leftCandle.low);
      ObjectMove(chart_id, name, 1, rightCandle.time, rightCandle.low);
   }

   double currentPosition = 0;
   for (int i = leftCandleIndex; i < rightCandleIndex; i++) {
      currentPosition = ObjectGetValueByTime(0, name, rates[i].time);
      if (currentPosition != 0 && currentPosition > rates[i].low) {
         ObjectMove(chart_id, name, 1, rates[i].time, rates[i].low);
         ChartRedraw(chart_id);
      }
   }
      
   return rightCandleIndex - leftCandleIndex;
}

void AutoTrend::clearLine(long chart_id = 0) {
   ObjectDelete(chart_id, "lta_" + IntegerToString(chart_id));
   ObjectDelete(chart_id, "ltb_" + IntegerToString(chart_id));
}

double AutoTrend::lastSupport(ENUM_TIMEFRAMES period = PERIOD_M1, long chart_id = 0, int candles = 15) {
   MqlRates rates[];
   if(CopyRates(_Symbol, period, 0, candles, rates) != candles) {
      Print("CopyRates of ",_Symbol," failed, no history");
      return 0;
   }
   double support = rates[ArraySize(rates) - 1].low;
   for (int i = ArraySize(rates) - 2; i >= 0; i--) {
      if (rates[i].low <= support)
         support = rates[i].low;
   }
   return support;
}

double AutoTrend::lastResistance(ENUM_TIMEFRAMES period = PERIOD_M1, long chart_id = 0, int candles = 15) {
   MqlRates rates[];
   if(CopyRates(_Symbol, period, 0, candles, rates) != candles) {
      Print("CopyRates of ",_Symbol," failed, no history");
      return 0;
   }
   double resistance = rates[ArraySize(rates) - 1].high;
   for (int i = ArraySize(rates) - 2; i >= 0; i--) {
      if (rates[i].high >= resistance)
         resistance = rates[i].high;
   }
   return resistance;
}

AutoTrend::AutoTrend() {
}

AutoTrend::~AutoTrend() {
}
