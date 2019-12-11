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

extern static string IndicatorProperties0 = "---Main Signal---";
extern ENUM_MA_METHOD MA_Method = MODE_EMA;
extern int MA_Short=160;
extern int MA_Long=10;

extern bool isUseMoneyManagement;
extern bool isUseFilter;

extern static string IndicatorProperties1 = "---Money Management---";
extern double StandardLot = 0.01;
extern double MinLot =0.02;
extern double AdditionalLot=0.01;
extern double AdditionalDistance;
extern int AdditionalMaxLot=3;

extern static string IndicatorProperties2 = "---Take profit and Stop Loss---";
extern bool isUseTakeprofit;
extern int TakeProfitPoint = 40;
extern bool isUseStoploss;
extern int StopLossPoint = 40; 

extern static string IndicatorProperties4 = "---Filter---";
extern bool isUseTimeFilter;
extern bool isUseBBFilter;

extern static string IndicatorProperties5 = "---Time---";
extern int TimeFilterBegin=8;
extern int TimeFilterEnd=10;

extern static string IndicatorProperties6 = "---Boliger band---";
extern int BBPeriod;
extern double BBDevision;







int lastOrderTime;
int backupTime;
bool isTestMode;
bool buySignal;
bool sellSignal;

int CurrentLot;

double maxFloating;

int state;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
     
   //init param
    maxFloating = 0;
    CurrentLot = 0;
    state = -1;
    DisplayText("aa");
   // AddButton();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   DisplayText("floating: "+maxFloating);
   
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
         if(!isUseTakeprofit || !isUseStoploss)
         {
            CheckForClose();
         }
         CheckForAddOrder();
      }
      else
      {
          CheckForOpen();
      }
      if(AccountEquity()- AccountBalance()< maxFloating)
      { 
        maxFloating = AccountEquity()-AccountBalance();
        
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
      float takeProfit= 0;
      float stopLoss = 0;
      
      
      if((Open[1] < maShort && Close[1] > maShort && Close[1] > maLong && maShort > maLong && DoFilter(true)))
      {
         
         if(isUseTakeprofit)
         {
            if(isUseTakeprofit)
               takeProfit = Ask+ TakeProfitPoint * Point();
            if(isUseStoploss)
               stopLoss = Bid - StopLossPoint * Point();
         }
         
         
         if(OrderSend(Symbol(),OP_BUY, GetLot(), Ask,3,stopLoss,takeProfit,"",MagicNumber,0,clrBlue) < 0)
         {
            DisplayText("Open buy order fail:"+GetLastError());
         }
         else
         {
            CurrentLot +=1;
            state = 0;
         }
      }
      
      if((Open[1] > maShort && Close[1] < maShort && Close[1] < maLong && maShort < maLong && DoFilter(false)))
      {
        
         if(isUseTakeprofit)
         {
            if(isUseTakeprofit)
               takeProfit = Bid - TakeProfitPoint * Point();
            if(isUseStoploss)
               stopLoss = Ask + StopLossPoint * Point();
         
         }
         if(OrderSend(Symbol(),OP_SELL, GetLot(), Bid,3,stopLoss,takeProfit,"",MagicNumber,0,clrRed)<0)
         {
            DisplayText("Open buy order fail:"+GetLastError());
         }
         else
         {
            CurrentLot +=1;
            state = 0;
         }
      }
      
   }

void CheckForClose()
{
   if(Volume[0]>1)
      return;
   
   double maShort = iMA(NULL,0,MA_Short,0,MA_Method,PRICE_CLOSE,0);
   double maLong = iMA(NULL, 0,MA_Long,0,MA_Method,PRICE_CLOSE,0);
   
   
   
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)== false)
         continue;
       
      if(OrderSymbol() != Symbol())
         continue;
      
      if(OrderMagicNumber() != MagicNumber)
         continue;
       
      //DebugSignal(maLong,maShort,Open[1],Close[1]);
      if(OrderType() == OP_BUY)
      {
         
         if((Open[1] > maShort && Close[1] < maShort && maShort < maLong) || Close[1] < maShort)
         {
            if(!OrderClose(OrderTicket(),OrderLots(), Bid, 3,clrWhite))
            {
               DisplayText("Closing order error:"+GetLastError());
            }
            else
            {
               DisplayText("Total order: "+OrdersTotal());
               CurrentLot -= 1;
               state = 1;
            }
            
         }
      }
      
      if(OrderType() == OP_SELL)
      {
         
         if((Open[1] < maShort && Close[1] > maShort && maShort > maLong) || Close[1]> maShort)
         {
            if(!OrderClose(OrderTicket(),OrderLots(), Ask, 3,clrWhite))
            {
               DisplayText("Closing order error:"+GetLastError());
            }else
            {
               DisplayText("Total order: "+OrdersTotal());
               CurrentLot -= 1;
               state = 1;
            }
         }
      }
      
     }
}

void DebugSignal(float pointA, float pointB, float pointC,float pointD)
{
   DisplayText(ObjectsTotal());
   for(int i=0;i<ObjectsTotal();i++)
     {
         if(!ObjectDelete(0, ObjectName(i)))
         {
            DisplayText("Delete error:"+GetLastError());
         }
     }

    
    if(!ObjectCreate(TimeCurrent()+"0", OBJ_ARROW_DOWN, 0, Time[0], pointA, 0, 0))
         Alert("Create pointA error: ",GetLastError());
    if(!ObjectCreate(TimeCurrent()+"1", OBJ_ARROW_DOWN, 0, Time[0], pointB  , 0, 0))
         Alert("Create pointB error: ",GetLastError());
    if(!ObjectCreate(TimeCurrent()+"2", OBJ_ARROW_UP, 0, Time[0], pointC  , 0, 0))
         Alert("Create pointC error: ",GetLastError());
    if(!ObjectCreate(TimeCurrent()+"3", OBJ_ARROW_UP, 0, Time[0], pointD  , 0, 0))
         Alert("Create pointD error: ",GetLastError());
}

void CheckForLossCut()
{
   
}

void CheckForAddOrder()
{
   if(Volume[0]>1)
      return;
      
    if(state != 0)
      return;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)== false)
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
         //DisplayText("Check add");
         
         
         double a = 0;
         double b= 0;
         
         
        if(OrderType() == OP_BUY)
        {
            a = Close[1];
            b = OrderOpenPrice();
        }   
        if(OrderType() == OP_SELL)
        {
            a = OrderOpenPrice();
            b = Close[1];
        } 
         
         
         if(MathAbs(Close[1]-OrderOpenPrice()) >= AdditionalDistance *Point())
         {
            if(CurrentLot <= AdditionalMaxLot )
            {
               
               double price = 0;
               if(OrderType() == OP_BUY)
               {
                  price = Ask;
               }
               else
               {
                  price = Bid;
               }
               
            
               if(OrderSend(Symbol(),OrderType(), MinLot, price,3,0,0,"",MagicNumber,0,clrRed)<0)
               {
                  DisplayText("Open buy order fail:"+GetLastError());
               }
               else
               {
                  CurrentLot +=1;
               }
               CurrentLot +=1;
               //DisplayText("Add lot:"+OrderTicket()+" "+OrdersTotal());
               break;   
            }
            
         }
         else
         {
            //DisplayText("khong lon hon: "+(Close[1]-OrderOpenPrice())+" "+Close[1]+" "+OrderOpenPrice());
            break;
         }
     }
     
}

bool DoFilter(bool CheckForBuy)
{
   
   if(isUseTimeFilter)
   {
      if(TimeHour(TimeCurrent()) <= TimeFilterBegin && TimeHour(TimeCurrent()) >= TimeFilterEnd)
         return false;
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
            //DisplayText("Lenh nay loi"+OrderTicket()+"   "+OrderProfit());
            return true;
         }
     }
   }
   
   return false;
   
}


int index= 0;
void DisplayText(string msg)
{
   index +=1;
   string name = "label_object:"+ index; 
   int pos = 50 + ((index % 300 ) *100);
   ObjectCreate(name, OBJ_TEXT, 0, Time[0], Close[0]+pos*Point); //draw an up arrow
   ObjectSet(name, OBJPROP_XDISTANCE, 200);
   ObjectSet(name, OBJPROP_YDISTANCE, 3000);
   ObjectSetText(name, msg, 10, "Times New Roman", Yellow);
}


void AddButton()
{
  /* string name = "button_obj"; 
   int pos = 50 ;
   ObjectCreate(name, OBJ_BUTTON, 0, Time[0], Close[0]+pos*Point); //draw an up arrow
   ObjectSet(name, OBJPROP_XDISTANCE, 200);
   ObjectSet(name, OBJPROP_YDISTANCE, 3000);*/
   
   if(!ObjectCreate("abc", OBJ_BUTTON, 0, Time[0], Close[0]+5*Point))
     {
     
      DisplayText(GetLastError());
     }
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam=="abc")
        {
         DisplayText("Click");
         ObjectSetInteger(0,"abc",OBJPROP_STATE,false);
        }
     
  }
}





float GetLot()
{
  // return (AccountBalance()*Risk)/StopLoss * (Point *10);
  if(isUseMoneyManagement)
  {
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
         continue;
      if(OrderSymbol() != Symbol())
         continue;
      if(OrderMagicNumber() != MagicNumber)
         continue;
      if(OrderProfit()<0)
      {
         //DisplayText("lenh lo");
         return MinLot;
      }
      else
      {
         //DisplayText("lenh loi");
        // return MinLot +AdditionalLot;
        return StandardLot;
      }
   }
   DisplayText("");
   return MinLot;
  }
   else
   {
      return StandardLot;
   }
    
}