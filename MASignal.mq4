//+------------------------------------------------------------------+
//|                                                     MASignal.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//input
extern int Ma0=5;
extern int Ma1=7;
extern int Ma2=40;


extern int TakeProfit = 40;
extern int StopLoss = 40;
extern double Risk = 0.1;  

extern double MinimunOffset;

static bool isSellOpened;
static bool isBuyOpened;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double lot = (Risk*AccountBalance())/((StopLoss*Point)*10);
   //Alert("lot "+lot);
   //Alert("risk "+(Risk*AccountBalance()));
   //Alert("sl"+(StopLoss*Point)*10);
   //Alert("stoploss point:"+(StopLoss*Point));
   
   Alert(Ask,"---",Ask+StopLoss*Point);
   
   /*isBuyOpened = true;

   
   double ma0 =  iMA(Symbol(), Period(),Ma0,0,0,0,1);
  double ma1 =  iMA(Symbol(), Period(),Ma1,0,0,0,1);
  double ma2 =  iMA(Symbol(), Period(),Ma2,0,0,0,1);

  Alert("--------");

  if( Close[0]>ma1 && Close[0]> ma0)
  {
    Alert( true);
  }
  else
  {
    Alert( false);
  }
  Alert(Close[0]);
  Alert(ma0);
  Alert(ma1);
  Alert(ma2);
   Alert("--------");*/
   
   
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
/*  if(CanBuy())
  {
    Alert("Can buy");
    isBuyOpened = true;
    isSellOpened = false;
  }*/
  
 /* if(CanSell())
  {
    Alert("Can sell");
    isBuyOpened = false;
    isSellOpened = true;
  }
  */


  if(OrdersTotal() > 0)
  {
    //dang mo order roi
    if(isSellOpened)
    {
      if(CanBuy())
      {
        if(CloseOrder())
        {
         Alert("Close Successfully");
        }
        else
        {
         Alert("error Closing:",GetLastError());
        }
      }
    }
    
  }  
  else
  {
    if(CanSell())
    {
      if(OpenOrder(false))
     {
        Alert("Open sell sucessfully");
        isSellOpened = true;
     }
     else
     {
       Alert("Error: ",GetLastError());
     }
    }
   
  }



/*

  if(isBuyOpened)
  {
    if(CanSell() )
    {
       if(CloseOrder())
       {
         Alert("Close Successfully");
       }
       else
       {
         Alert("error Closing:",GetLastError());
       }
    }
  }
  else
  {
    if(CanBuy() && OrdersTotal()==0 )
    {
     //openBuyOrder
     if(OpenOrder(true))
     {
       Alert("Open buy sucessfully");
       isBuyOpened = true;
     }
     else
     {
       Alert("Error: ",GetLastError());
     }
   }
  }/*
  /*
  if(isSellOpened)
  {
    if(CanBuy())
    {
       if(CloseOrder())
       {
         isSellOpened = false;
         isBuyOpened = false;
         Alert("Close Successfully");
       }
       else
       {
         Alert("error Closing:",GetLastError());
       }
    }
  }
  else
  {
   if(CanSell() && OrdersTotal()==0)
   {
     //open selll order
     if(OpenOrder(false))
     {
        Alert("Open sell sucessfully");
        isSellOpened = true;
     }
     else
     {
       Alert("Error: ",GetLastError());
     }
   }
  }*/
 }
//+------------------------------------------------------------------+


bool CanSell()
{
  double ma0 = iMA(Symbol(), Period(),Ma0,0,0,0,1);
  double ma1 = iMA(Symbol(), Period(),Ma1,0,0,0,1);
  double ma2 = iMA(Symbol(), Period(),Ma2,0,0,0,1);
  
  
  if(Close[0] < ma0 && Close[0] < ma1)
  {
    return true;  
  }
  else
  {
    return false;
  }

   
}

bool CanBuy()
{
  double ma0 =  iMA(Symbol(), Period(),Ma0,0,0,0,1);
  double ma1 =  iMA(Symbol(), Period(),Ma1,0,0,0,1);
  double ma2 =  iMA(Symbol(), Period(),Ma2,0,0,0,1);


  if( Close[0] > ma0 && Close[0] > ma1)
  {
    return true;
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

double GetLot()
{

  return Risk;
  double lot = (Risk*AccountBalance())/(StopLoss*Point);
  if(lot<0.01)
  {  
    return 0.01;
  }
  else
  {
    return lot;
  }
}
