//+------------------------------------------------------------------+
//|                                                SimpleExperts.mq4 |
//|                                           Copyright 2019,hao.Tu. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,hao.Tu."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern int BuyHour = 0;
extern int SellHour = 14;
extern int TakeProfit = 40;
extern int StopLoss = 40;  
extern int MA_Period = 5;
extern double Risk =0.02;

//global variable
static bool isFirstTick = true;
static bool isClosing = false;
static int ticket =0;

double currentLot=0;
static bool isReady;
//extern int MA1_Period = 20;
//extern int MA2_Period = 90;

int OnInit()
  {
//---//
   //isReady = true;
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
  
  double ma1 = iMA(Symbol(), Period(),MA_Period,0,0,0,1);
 // double ma2 = iMA(Symbol(),Period(),MA2_Period,0,0,0,1);
  
  
   if(Hour() ==  BuyHour)
   {
     if(isFirstTick)
     {
       Alert("first tick");
       isFirstTick = false;
       //mua vao
       if(Close[0] > ma1 )
       {
         GetLot();
         ticket = OrderSend(Symbol(), OP_BUY, currentLot, Ask, 10, Bid - StopLoss * Point, Bid + TakeProfit * Point, "Set by sample expert");
         if(ticket < 0 )
         {
           Alert("Error sending Order: "+GetLastError());
         }
         else
         {
           isClosing = true;
           isReady = false;
         }
       }
       else
       {
         //ban ra
         ticket = OrderSend(Symbol(), OP_SELL, currentLot, Bid, 10, Ask + StopLoss * Point, Ask  - TakeProfit * Point, "Set by sample expert");
         if(ticket <0)
         {
           Alert("Error sending Order!");        
         }
         else
         {
           isClosing = true;
         }
       }
     }
   }
   else
   {
      
      isFirstTick = true;
      if(isClosing == true)
      {
         if(Hour() == SellHour)
         {
          //check and close old order
          bool res;
          res = OrderSelect(ticket,SELECT_BY_TICKET);
          if(res ==true)
          {
            // neu chua close thi close
            if(OrderCloseTime()==0)
            {
              bool res2;
              res2 = OrderClose(ticket,currentLot,OrderClosePrice(), 10);
              if(res2 == true)
              {
                // close thanh cong
                isClosing = false;
              }
              else
              {
                Alert("Error on closing order #",ticket,GetLastError());
              }
            }
          }
         }  
      }
   }
   
  }
//+------------------------------------------------------------------+

void GetLot()
{
  // return (AccountBalance()*Risk)/StopLoss * (Point *10);
  currentLot = Risk;
}

void CheckAndClose()
{
   //check and close old order
   bool res;
   res = OrderSelect(0,SELECT_BY_POS);
   double lot = OrderLots();
   int ticketNo = OrderTicket();
   if(res ==true)
   {
     Alert("= true");
     // neu chua close thi close
     if(OrderCloseTime()==0)
     {
       Alert("close time ==0");
       bool res2;
       res2 = OrderClose(ticketNo,lot,OrderClosePrice(), 10);
       if(res2 == true)
       {
         // close thanh cong
         isClosing = false;
       }
       else
       {
         Alert("Error on closing order #",ticket);
       }     
     }
     else
     {
       Alert("ordertime khac 0");
     }
    }
    else
    {
      Alert("res bang false");
    }
}



