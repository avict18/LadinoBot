//+------------------------------------------------------------------+
//|                                                         HiLo.mqh |
//|                                                   Rodrigo Landim |
//|                                        http://www.emagine.com.br |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Landim"
#property link      "http://www.emagine.com.br"
#property version   "1.00"

#resource "\\Indicators\\gann_hi_lo_activator_ssl.ex5"

#include <LadinoBot/Utils.mqh>

class HiLo {
   private:
      ENUM_TREND_SIGNAL _currentTrend;
      int HiLoHandle;
      int _period;
   public:
      HiLo();
      bool initialize(int period = 4, ENUM_TIMEFRAMES chartTime = PERIOD_CURRENT, long chartId = 0);
      double currentPosition();
      ENUM_TREND_SIGNAL currentTrend();
      bool checkTrend();
      virtual void onTrendChanged(ENUM_TREND_SIGNAL newTrend);
};

HiLo::HiLo() {
   HiLoHandle = 0;
   _currentTrend = UNDEFINED;
   _period = 4;
}

bool HiLo::initialize(int period = 4, ENUM_TIMEFRAMES chartTime = PERIOD_CURRENT, long chartId = 0) {
   _period = period;
   HiLoHandle = iCustom(_Symbol, chartTime, "::Indicators\\gann_hi_lo_activator_ssl", _period);
   if(HiLoHandle == INVALID_HANDLE) {
      Print("Error creating HiLo indicator");
      return false;
   }
   ChartIndicatorAdd(chartId, 0, HiLoHandle); 
   return true;
}

double HiLo::currentPosition() {
   double hiloBuffer[1];
   if(CopyBuffer(HiLoHandle,0,0,1,hiloBuffer) != 1) {
      Print("CopyBuffer from HiLo failed, no data");
      return -1;
   }
   return hiloBuffer[0];
}

ENUM_TREND_SIGNAL HiLo::currentTrend() {
   double hiloTrend[1];
   if(CopyBuffer(HiLoHandle,4,0,1,hiloTrend) != 1) {
      Print("CopyBuffer from HiLo failed, no data");
      return false;
   }
   if (hiloTrend[0] > 0)
      return BULLISH;
   else if (hiloTrend[0] < 0) 
      return BEARISH;
   else
      return UNDEFINED;
}

bool HiLo::checkTrend() {
   ENUM_TREND_SIGNAL trend = currentTrend();
   if (_currentTrend != trend) {
      _currentTrend = trend;
      onTrendChanged(_currentTrend);
   }
   return true;
}

void HiLo::onTrendChanged(ENUM_TREND_SIGNAL newTrend) {
   // 
}
