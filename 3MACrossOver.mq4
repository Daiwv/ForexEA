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
extern bool IsUseTP;
extern bool IsUseFilter;
extern double AdditionalLot=0.01;
extern int TimeFilterBegin=8;
extern int TimeFilterEnd=10;
extern int MA_Period1 = 5;
extern int MA_Period2 = 5;
extern int MA_Long=10;
extern int MA_Short=160;
extern ENUM_MA_METHOD MA_Method = MODE_EMA;
extern double MinLot =0.02;
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
     
   //DisplayText("start");
    MinLot = MarketInfo(Symbol(),MODE_MINLOT);
    DisplayText("min lot:"+MinLot); 
      
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
      //
      if(IsOrderExist())
      {
         if(!IsUseTP)
         {
            CheckForClose();
         }
      }
      else
      {
          CheckForOpen();
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

void CheckForOpen()
   {
      
      if(Volume[0] > 1)
         return;
      
      double maShort = iMA(NULL,0,MA_Short,0,MA_Method,PRICE_CLOSE,0);
      double maLong = iMA(NULL,0,MA_Long,0,MA_Method,PRICE_CLOSE,0);
      
      if((Open[1] < maShort && Close[1] > maShort && Close[1] > maLong && maShort > maLong && DoFilter(true)))
      {
         
         if(IsUseTP)
         {
            if(OrderSend(Symbol(),OP_BUY, GetLot(), Ask,3,Bid - StopLoss*Point(),Ask + TakeProfit*Point(),"",MagicNumber,0,clrBlue) < 0)
            {
               DisplayText("Open buy order fail:"+GetLastError());
            }
         }
         else
         {
         
            if(OrderSend(Symbol(),OP_BUY, GetLot(), Ask,3,0,0,"",MagicNumber,0,clrBlue) < 0)
            {
               DisplayText("Open buy order fail:"+GetLastError());
            }
         }
      }
      
      if((Open[1] > maShort && Close[1] < maShort && Close[1] < maLong && maShort < maLong && DoFilter(false)))
      {
        
         if(IsUseTP)
         {
            if(OrderSend(Symbol(),OP_SELL, GetLot(), Bid,3,Ask + StopLoss*Point(),Bid - TakeProfit*Point(),"",MagicNumber,0,clrRed)<0)
            {
               DisplayText("Open buy order fail:"+GetLastError());
            }
         }
         else
         {
            if(OrderSend(Symbol(),OP_SELL, GetLot(), Bid,3,0,0,"",MagicNumber,0,clrRed)<0)
            {
               DisplayText("Open buy order fail:"+GetLastError());
            }
         }
         
      }
      
   }

void CheckForClose()
{
   if(Volume[0]>1)
      return;
   
   double maShort = iMA(NULL,0,MA_Short,0,MA_Method,PRICE_CLOSE,0);
   double maLong = iMA(Symbol(), Period(),MA_Long,0,0,0,1);
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
         if((Open[1] > maShort && Close[1] < maShort && maShort < maLong)||(Open[1]<maShort))
         {
            if(!OrderClose(OrderTicket(),OrderLots(), Bid, 3,clrWhite))
            {
               DisplayText("Closing order error:"+GetLastError());
            }
            
         }
      }
      
      if(OrderType() == OP_SELL)
      {
         if((Open[1] < maShort && Close[1] > maShort && maShort > maLong) || (Open[1]>maShort))
         {
            if(!OrderClose(OrderTicket(),OrderLots(), Ask, 3,clrWhite))
            {
               DisplayText("Closing order error:"+GetLastError());
            }
         }
      }
      
     }
}

bool DoFilter(bool CheckForBuy)
{
   
   if(!IsUseFilter)
   {
      DisplayText("no fileterss");
      return true;
   }
   
   //TimeFilter
   //if(TimeHour(TimeCurrent()) >= TimeFilterBegin/* && TimeHour(TimeCurrent()) <= TimeFilterEnd*/)
   {
      
      if(OrdersHistoryTotal()<1)
         return true;
      //DisplayText("history hop le:"+OrdersHistoryTotal());
         
       
         
      for(int i=OrdersHistoryTotal()-1;i>=0;i--)
      {
         
         if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)== false)
         {
            DisplayText("select fail");
            continue;
         }
       
         if(OrderSymbol() != Symbol())
         {
            DisplayText("Symbol khac");
            continue;
         }
      
         if(OrderMagicNumber() != MagicNumber)
         {  
            DisplayText("magic number khac");
            continue;
         }
         if(i==OrdersHistoryTotal()-1)
         {
            //DisplayText("ticket: "+OrderTicket());
         }
         
         
         if(OrderProfit()<0)
         {
            if(CheckForBuy && OrderType() == OP_SELL)
            {
              
               //DisplayText("buy:"+OrderTicket()+"-"+OrdersHistoryTotal());
               return true;
            }
            if(!CheckForBuy && OrderType() == OP_BUY)
            {
               //DisplayText("sell:"+OrderTicket()+"-"+OrdersHistoryTotal());
               
               return true;
            }
            return false;
         }
         else
         {
            DisplayText("Lenh nay loi"+OrderTicket()+"   "+OrderProfit());
            return true;
         }
     }
   }
   
   return false;
   
}



double DiffPips(double _p1,double _p2)
{
   double DiffPips = MathAbs(NormalizeDouble( _p1 - _p2,Digits)/Point);
   //Alert("_p1: ",_p1," _p2: ",_p2," digits: ",3," diff:",DiffPips);
   return (NormalizeDouble((DiffPips),0));
}




int index= 0;
void DisplayText(string msg)
{
   index +=1;
   string name = "label_object:"+ index; 
   int pos = 50 + ((index % 3 ) *100);
   ObjectCreate(name, OBJ_TEXT, 0, Time[0], Close[0]+pos*Point); //draw an up arrow
   ObjectSet(name, OBJPROP_XDISTANCE, 200);
   ObjectSet(name, OBJPROP_YDISTANCE, 3000);
   ObjectSetText(name, msg, 10, "Times New Roman", Yellow);
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
  
  for(int i=OrdersHistoryTotal()-1;i>=0;i--)
    {
     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
      continue;
     if(OrderSymbol() != Symbol())
      continue;
     if(OrderMagicNumber() != MagicNumber)
      continue;
     if(OrderProfit()<0)
     {
      DisplayText("lenh lo");
      return MinLot;
     }
     else
     {
      DisplayText("lenh loi");
      return MinLot + MarketInfo(Symbol(),MODE_MINLOT);
     }
      
     
    }
    DisplayText("");
    return MinLot;
}