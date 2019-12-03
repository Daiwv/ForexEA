//+------------------------------------------------------------------+
//|                                                          2MA.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//---------------------------------------------------------
//Input Properties
//---------------------------------------------------------
extern int MagicNumber = 2060;
extern int TakeProfit = 40;
extern int StopLoss = 40;  
extern int MA_Period1 = 5;
extern int MA_Period2 = 5;
extern int MA_Long;
extern int MA_Short;
extern ENUM_MA_METHOD MA_Method;
extern double Risk =0.02;
extern double FilterPip = 5;
extern int FilterTime = 1 ;

int lastOrderTime;
int backupTime;
bool isTestMode;
bool buySignal;
bool sellSignal;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   buySignal = true;
   sellSignal = true;
   DisplayText("start");
         
      
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
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
   bool isCanBuy = CanBuy(sellSignal);
   bool isCanSell = CanSell(buySignal);
   
   
   
      if(OrdersTotal()>0)
      {
         if((OrderType() == 1 && isCanBuy) || (OrderType() == 0 && isCanSell))
         {
            if(CloseOrder())
            {
               Alert(OrderType(), " Order Closed successfully ",OrderTicket(),"-",TimeHour(TimeCurrent()));
               
               if(IsTesting())
               {
                  int tmp = TimeHour(TimeCurrent());
                  if(tmp>=(24-Period()/60))
                  {
                     tmp -= 24;
                  }
                  backupTime = tmp;
               }
            }
            else
            {
               Alert("Order Closing error",GetLastError());
            }
         }
      }
      else
      {
         if(OrderSelect(OrdersHistoryTotal()-1 ,SELECT_BY_POS,MODE_HISTORY) || IsTesting())
         {  
           
            int targetHour ;
            if(IsTesting())
            {
               targetHour = backupTime;
            }
            else
            {
               targetHour = TimeHour(OrderOpenTime());
            }
               
            if(TimeHour(Time[0])- targetHour >= (Period()/60) * FilterTime)
            {  
                
               if(isCanBuy)
               {
                  
                  if(OpenOrder(true))
                  {
                     Alert("Open buy order successfully");
                  }
                  else
                  {
                     Alert("Open buy order fall");
                  }

               }
               else if(isCanSell)
               {
                 
                  if(OpenOrder(false))
                  {
                     Alert("Open sell order successfully");
                  }
                  else
                  {
                     Alert("Open sell order fall");
                  }               
               }  
            }
         }   
        
      } 
     if(isCanBuy || isCanSell)
     {
        buySignal = isCanBuy;
        sellSignal = isCanSell;
     }
     
   }
//+------------------------------------------------------------------+

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

bool PriceFilter()
{
   return false;
}

void CheckForClose()
{
   if(Volume[0]>1)
      return;
   
   double maShort = iMA(NULL,0,MA_Short,0,MA_Method,PRICE_CLOSE,0);
   //double maLong = iMA(Symbol(), Period(),MA_Long,0,0,0,1);
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)== false)
         continue;
       
      if(OrderSymbol() != Symbol())
         continue;
      
      if(OrderMagicNumber() != MagicNumber)
         continue;
       
      if(OrderType() == OP_BUY)
      {
         if(Open[1] > maShort && Close[1] < maShort)
         {
            if(!OrderClose(OrderTicket(),OrderLots(), Bid, 3,clrWhite))
            {
               Print("Closing order error:"+GetLastError());
            }
            
         }
      }
      
      if(OrderType == OP_SELL)
      {
         if(Open[1] < maShort && Close[1] > maShort)
         {
            if(!OrderClose(OrderTicket(),OrderLots(), Bid, 3,clrWhite))
            {
               Print("Closing order error:"+GetLastError());
            }
         }
      }
      
     }
}

double DiffPips(double _p1,double _p2)
{
   double DiffPips = MathAbs(NormalizeDouble( _p1 - _p2,Digits)/Point);
   //Alert("_p1: ",_p1," _p2: ",_p2," digits: ",3," diff:",DiffPips);
   return (NormalizeDouble((DiffPips),0));
}


bool CanBuy(bool isCanSell)
{
   //neu gia nam tren 2 duong ma
   double ma1 = iMA(Symbol(), Period(),MA_Period1,0,0,0,1);
   double ma2 = iMA(Symbol(), Period(),MA_Period2,0,0,0,1);
   if(Close[0] > ma1 && Close[0] > ma2 )
   {
      if(DiffPips(Close[1],ma1) >= FilterPip && LastOrderFilter(true) /* && isCanSelltrue*/)
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
       if(DiffPips(Close[1],ma1) >= FilterPip && LastOrderFilter(false)/* && isCanbuy && LastOrderFilter(false)true */ )
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


void DisplayText(string msg)
{
   string name = "label_object:"/*+TimeCurrent()*/; 
   ObjectCreate(name, OBJ_TEXT, 0, Time[0], Close[0]+50*Point); //draw an up arrow
   ObjectSet(name, OBJPROP_XDISTANCE, 200);
   ObjectSet(name, OBJPROP_YDISTANCE, 100);
   ObjectSetText(name, "sai ", 10, "Times New Roman", Red);
}

bool LastOrderFilter(bool isBuy)
{
   if(true)
   {
      if(!OrderSelect(OrdersHistoryTotal()-1, SELECT_BY_POS,MODE_HISTORY))
      {
        DisplayText("sai gi do");
      }
      //neu vua roi buy va lo
     /* if( isBuy && OrderType() == OP_BUY && OrderProfit() < 0 ||
         !isBuy && OrderType() == OP_SELL && OrderProfit() < 0 )*/
      if(OrderProfit()<0)
      {
         DisplayText("lai lo");
         //return false;
      }
      
      return true;
      
      
   }
   else
   {
   return true;
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

bool CloseOrder()
{
  
  if(OrderSelect(0,SELECT_BY_POS))
  {
     return OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(), 10);
  }
  else
  {
     return false;
  }
}

float GetLot()
{
  // return (AccountBalance()*Risk)/StopLoss * (Point *10);
  return Risk;
 
}