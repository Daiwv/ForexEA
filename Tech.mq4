//+------------------------------------------------------------------+
//|                                                         Tech.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


extern int TakeProfit = 4000;
extern int StopLoss = 4000;  
extern int MA_Period1 = 10;
extern int MA_Period2 = 20;
extern double FilterPip = 0;
extern int MagicNumber = 2012;

bool isTestMode;
bool buySignal;
bool sellSignal;
int minute;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   buySignal = true;
   sellSignal = true;
   //int ticket= OrderSend(Symbol(), OP_BUY, 0.01, Ask, 10, Bid - StopLoss * Point, Bid + TakeProfit * Point,NULL,MagicNumber);
   DisplayText(OrdersTotal());
  
 
     if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS,MODE_TRADES) == true)
        DisplayText(OrderTicket());
     
   
  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
  
  bool IsOrderExist()
{
   for(int i=0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES) == false||
         OrderSymbol() != Symbol() ||
         OrderMagicNumber() != MagicNumber)
      {
         continue;
      }
      return true;
   }
   return false;
}
int index= 0;
void DisplayText(string msg)
{
   index +=1;
   string name = "label_object:"+ index; 
   int pos = 50 + ((index % 5 ) *100);
   ObjectCreate(name, OBJ_TEXT, 0, Time[0], Close[0]+pos*Point); //draw an up arrow
   ObjectSet(name, OBJPROP_XDISTANCE, 200);
   ObjectSet(name, OBJPROP_YDISTANCE, 3000);
   ObjectSetText(name, msg, 10, "Times New Roman", Yellow);
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(OrdersTotal()>0){
      //DisplayText("Co order");
   }  
   //DisplayText("sssss");
 /*  bool isCanBuy = CanBuy(sellSignal);
   bool isCanSell = CanSell(buySignal);
   
   if(isCanBuy && TimeHour(TimeCurrent())!=-minute)
   {
     // OpenOrder(true);
     
      minute = TimeHour(TimeCurrent());
      
      string name = "Dn-"+TimeCurrent();
      ObjectCreate(name, OBJ_ARROW, 0, Time[0], Close[0]-50*Point); //draw an up arrow
      ObjectSet(name, OBJPROP_STYLE, STYLE_DASHDOT);
      ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
      ObjectSet(name, OBJPROP_COLOR,Green);
   }
   
   if(isCanSell && TimeHour(TimeCurrent())!=minute)
   {
      OpenOrder(false);
      minute = TimeHour(TimeCurrent());
      
      string name = "Dn-i"+TimeCurrent();
      ObjectCreate(name, OBJ_ARROW, 0, Time[0], Close[0]+50*Point); //draw an up arrow
      ObjectSet(name, OBJPROP_STYLE, STYLE_DASHDOT);
      ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
      ObjectSet(name, OBJPROP_COLOR,Red);
   }
   if(isCanBuy || isCanSell)
   {
      buySignal = isCanBuy;
      sellSignal = isCanSell;
   }
   */
  }
//+------------------------------------------------------------------+
double DiffPips(double _p1,double _p2)
{
   double DiffPips = MathAbs(NormalizeDouble(Close[1]-Open[1],Digits)/Point);
   return (NormalizeDouble((DiffPips/10),0));
}
bool CanBuy(bool isCanSell)
{
   //neu gia nam tren 2 duong ma
   double ma1 = iMA(Symbol(), Period(),MA_Period1,0,0,0,1);
   double ma2 = iMA(Symbol(), Period(),MA_Period2,0,0,0,1);
   if(Close[0] > ma1 && Close[0] > ma2 )
   {
      if(DiffPips(Close[1],ma2) >= FilterPip && isCanSell)
      {
         return true;
      }
      else
      {
         return false;
      }
   }
   else
   {
      return false;
   }
}

bool CanSell(bool isCanbuy)
{
   //neu gia nam tren 2 duong ma
   double ma1 = iMA(Symbol(), Period(),MA_Period1,0,0,0,1);
   double ma2 = iMA(Symbol(), Period(),MA_Period2,0,0,0,1);
   if(Close[0] < ma1 && Close[0] < ma2)
   {
       if(DiffPips(Close[1],ma2) >= FilterPip && isCanbuy)
      {
         return true;
      }
      else
      {
         return false;
      }
   }
   else
   {
      return false;
   }
}

bool OpenOrder(bool isBuy)
{
  int ticket ;
  if(isBuy)
  {
    ticket= OrderSend(Symbol(), OP_BUY, GetLot(), Ask, 10, Bid - StopLoss * Point, Bid + TakeProfit * Point);
  }
  else
  {
    ticket= OrderSend(Symbol(), OP_SELL, GetLot(), Bid, 10, Ask + StopLoss * Point, Ask  - TakeProfit * Point);
  }
  Alert(GetLot());
  if(ticket < 0 )
  {
    return false;
  }
  else
  {
     return true;
  }
}

float GetLot()
{
  // return (AccountBalance()*Risk)/StopLoss * (Point *10);
  return 0.01;
 
}