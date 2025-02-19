//+------------------------------------------------------------------+
//|                                            Candlestick.mqh |
//|                                                   Rodrigo Landim |
//|                                        http://www.emagine.com.br |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Landim"
#property link      "http://www.emagine.com.br"
#property version   "1.00"

#include <LadinoBot/Utils.mqh>

class Candlestick {
   private:

   public:
      Candlestick();
      ~Candlestick();
      bool getCandle(MqlRates& rt, VELA& candle, ENUM_TIMEFRAMES period = PERIOD_CURRENT);
      ENUM_CANDLE_PATTERN candlePattern(ENUM_TIMEFRAMES period = PERIOD_CURRENT);
      string candlePatternText(ENUM_CANDLE_PATTERN pattern);
      bool isBullish(ENUM_CANDLE_PATTERN pattern);
      bool isBearish(ENUM_CANDLE_PATTERN pattern);
};

//+------------------------------------------------------------------+
bool Candlestick::getCandle(MqlRates& rt, VELA& candle, ENUM_TIMEFRAMES period = PERIOD_CURRENT) {

   ZeroMemory(candle);

   MqlRates rates[];
   if(CopyRates(_Symbol, period, 0, CANDLE_CHECK_COUNT, rates) < CANDLE_CHECK_COUNT) {
      return false;
   }
   double average = 0, total = 0;
   for(int i=0; i < CANDLE_CHECK_COUNT; i++) {
      average += rates[i].close;
      total = total + MathAbs(rates[i].open - rates[i].close);
   }
   average = average / CANDLE_CHECK_COUNT;
   total = total / CANDLE_CHECK_COUNT;
   ArrayFree(rates);

   candle.time = rt.time;
   candle.open = rt.open;
   candle.high = rt.high;
   candle.low = rt.low;
   candle.close = rt.close;
   candle.body = MathAbs(candle.close - candle.open);
   if (candle.close > candle.open)
      candle.upperShadow = candle.high - candle.close;
   else
      candle.upperShadow = candle.high - candle.open;
   if (candle.close <= candle.open)
      candle.lowerShadow = candle.close - candle.low;
   else
      candle.lowerShadow = candle.open - candle.low;
   candle.wick = candle.upperShadow + candle.lowerShadow;
   candle.size = candle.high + candle.low;
   
   if(average < candle.close) 
      candle.trend = BULLISH;
   if(average > candle.close)
      candle.trend = BEARISH;
   if(average == candle.close)
      candle.trend = UNDEFINED;
   
   if (candle.close > candle.open)
      candle.type = BULLISH;
   else if (candle.close < candle.open)
      candle.type = BEARISH;
   else
      candle.type = NONE;
   candle.shape = SHAPE_NONE;
   if(candle.body > total * 1.3) 
      candle.shape = SHAPE_LONG;
   if(candle.body < total * 0.5) 
      candle.shape = SHAPE_SHORT;
   if(candle.body < candle.size * 0.03)
      candle.shape = SHAPE_DOJI;
      
   if((candle.lowerShadow < candle.body * 0.01 || candle.upperShadow < candle.body * 0.01) && candle.body > 0) {
      if(candle.shape == SHAPE_LONG)
         candle.shape = SHAPE_MARIBOZU_LONG;
      else
         candle.shape = SHAPE_MARIBOZU;
   }

   if (candle.lowerShadow > (candle.body * 2) && candle.upperShadow < (candle.body * 0.1))
      candle.shape = SHAPE_HAMMER;
      
   if (candle.lowerShadow < (candle.body * 0.1) && candle.upperShadow > (candle.body * 2))
      candle.shape = SHAPE_INVERTED_HAMMER;
   
   if(candle.shape == SHAPE_SHORT && candle.lowerShadow > candle.body && candle.upperShadow > candle.body)
      candle.shape = SHAPE_SPINNING_TOP;
      
   return true;
}

ENUM_CANDLE_PATTERN Candlestick::candlePattern(ENUM_TIMEFRAMES period = PERIOD_CURRENT) { 
   MqlRates rt[4];
   if(CopyRates(_Symbol, period, 0, 4, rt) != 4) {
      Print("CopyRates of " + _Symbol + " failed, no history");
      return UNDEFINED;
   }
   
   VELA candle1, candle2, candle3;
   if (!(getCandle(rt[2], candle3) && getCandle(rt[1], candle2) && getCandle(rt[0], candle1)))
      return UNDEFINED;

   bool isBullish = 
      (candle1.type != BEARISH && candle2.type != BEARISH) &&
      (candle1.close < candle2.close && candle1.high < candle2.high && candle1.low < candle2.low);
   bool isBearish = 
      (candle1.type != BULLISH && candle2.type != BULLISH) &&
      (candle1.close > candle2.close && candle1.high > candle2.high && candle1.low > candle2.low);
   
   // Hammer - Reversal to Bullish
   if (isBearish && candle3.shape == SHAPE_HAMMER) {
      return HAMMER;
   }
   // Inverted Hammer - Reversal to Bullish
   if (isBearish && candle3.shape == SHAPE_INVERTED_HAMMER) {
      return INVERTED_HAMMER;
   }
   
   // Hanging Man - Reversal to Bearish
   if (isBullish && candle3.shape == SHAPE_HAMMER) {
      return HANGING_MAN;
   }
   // Shooting Star - Reversal to Bearish
   if (isBullish && candle3.shape == SHAPE_INVERTED_HAMMER) {
      return SHOOTING_STAR;
   }

   // Inside Candle reversal to Bearish
   if (isBullish && candle3.type == BEARISH && candle2.type == BULLISH) {
      if (candle2.body >= candle3.body && candle2.close >= candle3.open && candle2.open <= candle3.close)
         return INSIDE_CANDLE_BEARISH;
   }
   // Inside Candle reversal to Bullish
   if (isBearish && candle3.type == BULLISH && candle2.type == BEARISH) {
      if (candle2.body >= candle3.body && candle2.open >= candle3.close && candle2.close <= candle3.open)
         return INSIDE_CANDLE_BULLISH;
   }
   
   return UNDEFINED;
}

string Candlestick::candlePatternText(ENUM_CANDLE_PATTERN pattern) {
   string text;
   switch (pattern) {
      case HAMMER:
         text = "The current candle pattern is a hammer! Reversal to bullish!";
         break;
      case SHOOTING_STAR:
         text = "The current candle pattern is a shooting star! Reversal to bearish!";
         break;
      case INSIDE_CANDLE_BEARISH:
         text = "Inside Candle! Reversal to BEARISH!";
         break;
      case INSIDE_CANDLE_BULLISH:
         text = "Inside Candle! Reversal to BULLISH!";
         break;
      default:
         text = "The current candle pattern is undefined!";
         break;
   }
   return text;
}

bool Candlestick::isBullish(ENUM_CANDLE_PATTERN pattern) {
   return (pattern == HAMMER || pattern == INVERTED_HAMMER || pattern == BELT_HOLD_BULL || pattern == INSIDE_CANDLE_BULLISH);
}

bool Candlestick::isBearish(ENUM_CANDLE_PATTERN pattern) {
   return (pattern == HANGING_MAN || pattern == SHOOTING_STAR || pattern == BELT_HOLD_BEAR || pattern == INSIDE_CANDLE_BEARISH);
}

//+------------------------------------------------------------------+
Candlestick::Candlestick() {
}

Candlestick::~Candlestick(){
}
