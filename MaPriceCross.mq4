//+------------------------------------------------------------------+
//|                                                 MaPriceCross.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

extern int MA_Short=160;
extern int MA_Long=10;
extern ENUM_MA_METHOD MA_Method = MODE_EMA;
extern int MagicNumber;
extern float standardLot = 0.1;


int lastState = -1 ; //-1 chua init, 0 la init, 1 below, 2 above

bool isWait;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
   if(Volume[0] > 1)
         return;
   
   int current = CheckMA();
   
   if(current == 1 && lastState  == 2 )
   {
      
      DisplayText("sell");
      
      //Open(false,0,0);
      //Close(true);
   }
   
   if(current == 2 && lastState  == 1 )
   {
      
      DisplayText("buy");
      //Open(true,0,0);
      //Close(false);
   }
   
   
  
   
   
   
   if(current > 0)
   {
      lastState = current;
      isWait = false;
   }
   else
   {
      isWait = true;
   }
   
  }
//+------------------------------------------------------------------+

void Open(bool isBuy, float stoplossPip, float takeprofitPip)
{
   if (isBuy)
   {
      if(OrderSend(Symbol(),OP_BUY, GetLot(), Ask,3,stoplossPip, takeprofitPip,"",MagicNumber,0,clrBlue) < 0)
      {
         DisplayText("Open buy order fail:"+GetLastError());
      }
     
   }
   else
   {
      if(OrderSend(Symbol(),OP_SELL, GetLot(), Bid,3,stoplossPip,
       takeprofitPip,"",MagicNumber,0,clrBlue) < 0)
      {
         DisplayText("Open buy order fail:"+GetLastError());
      }
     
   }
}
void Close(bool isBuy)
{
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)== false)
         continue;
       
      if(OrderSymbol() != Symbol())
         continue;
      
      if(OrderMagicNumber() != MagicNumber)
         continue;
       
      //DebugSignal(maLong,maShort,Open[1],Close[1]);
      if(OrderType() == OP_BUY && isBuy)
      {
         
         //if((Open[1] > maShort && Close[1] < maShort && maShort < maLong) || Close[1] < maShort)
         {
            if(!OrderClose(OrderTicket(),OrderLots(), Bid, 3,clrWhite))
            {
               DisplayText("Closing order error:"+GetLastError());
            }
            
         }
      }
      
      if(OrderType() == OP_SELL  && !isBuy)
      {
         
         //if((Open[1] < maShort && Close[1] > maShort && maShort > maLong) || Close[1]> maShort)
         {
            if(!OrderClose(OrderTicket(),OrderLots(), Ask, 3,clrWhite))
            {
               DisplayText("Closing order error:"+GetLastError());
            }
            else
            {
               DisplayText("Total order: "+OrdersTotal());
            }
         }
      }
      
     }
}


float GetLot()
{
   return standardLot;
}



int CheckMA()
{
   double maShort = iMA(NULL,0,MA_Short,0,MA_Method,PRICE_CLOSE,0);
   double maLong = iMA(NULL, 0,MA_Long,0,MA_Method,PRICE_CLOSE,0);
   
   if(maShort < maLong)
   {
      return 1;
   }
   
   if(maShort > maLong)
   {
      return 2;
   }
   
   if(maShort == maLong)
   {
      return 0;
   }
   return -1;
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