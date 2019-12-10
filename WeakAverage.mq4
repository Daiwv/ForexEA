//+------------------------------------------------------------------+
//|                                                  WeakAverage.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int MagicNumber;
extern int TargetDay;
extern int offSetAmount = 500;

extern float Lot;
extern int TakeProfit;
extern int StopLoss;


bool isDisplayed;
string HighestLineName = "HighestHorizontalLine";
string LowestLineName = "LowestHorizontalLine";
string AverageLineName = "AverageHorizontalLine";
string AverageHighLineName = "AverageHighHorizontalLine";
string AverageLowLineName = "AverageLowHorizontalLine";

double highest;
double lowest;
double average;
double averageHigh;
double averageLow;
bool isInited;

enum SignalTouch{NonInit = 0,TouchTop=1,TouchBottom=2};

SignalTouch CurrentChoise;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   isDisplayed = false;
   //DisplayText(CaclulateDaysDistance());
   DisplaySinalLine();
   AddButton();
   isInited = false;
   CurrentChoise = 0;
   DisplayText(CurrentChoise);
//---
   return(INIT_SUCCEEDED);
  }
////////////////
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
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam=="abc")
      {
         //DisplayText("Click");
         //ObjectSetInteger(0,"abc",OBJPROP_STATE,false);
         DisplaySinalLine();
      }
   }
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
  
  

void CalculateSignalLine()
{
   lowest = 1000000;
   highest = 0;
   int days = CaclulateDaysDistance();
   for(int i=1;i<=days;i++)
   {
      float tmpHigh = iHigh(NULL,PERIOD_D1,i);
      float tmpLow = iLow(NULL,PERIOD_D1,i);
      if(tmpHigh > highest)
      {
         highest =tmpHigh;
         Alert("higer:"+i," ",highest);
      }
      if(tmpLow < lowest)
      {
         lowest = tmpLow;
         Alert("lower:"+i," ",lowest);
      }
      
   }
   average = (highest + lowest) / 2 ;
   averageHigh = average + (offSetAmount*Point());
   averageLow = average - (offSetAmount*Point());
   Alert(average," ",averageHigh," ",averageLow," ",highest," ",lowest);
}

int CaclulateDaysDistance()
{
   int thisWeek = TimeDayOfWeek(TimeCurrent());
   thisWeek = 2;
   int lastWeek = 6 -TargetDay;
   return thisWeek +lastWeek;
}


void DisplaySinalLine()
{
   
      if(!isDisplayed)
      {
         // is displayed delete it
         CalculateSignalLine();
         if(!ObjectCreate(HighestLineName, OBJ_HLINE, 0, Time[0], highest, 0, 0))
            Alert("Create highest error: ",GetLastError());
         if(!ObjectCreate(LowestLineName, OBJ_HLINE, 0, Time[0], lowest, 0, 0))
            Alert("Create highest error: ",GetLastError());
         if(!ObjectCreate(AverageLineName, OBJ_HLINE, 0, Time[0], average, 0, 0))
            Alert("Create highest error: ",GetLastError());
         if(!ObjectCreate(AverageHighLineName, OBJ_HLINE, 0, Time[0], averageHigh, 0, 0))
            Alert("Create highest error: ",GetLastError());
         if(!ObjectCreate(AverageLowLineName, OBJ_HLINE, 0, Time[0], averageLow, 0, 0))          
            Alert("Create highest error: ",GetLastError());
         if(!ObjectSet(AverageHighLineName,OBJPROP_COLOR,Yellow))
            Alert("Create highest error: ",GetLastError());
         if(!ObjectSet(AverageLowLineName,OBJPROP_COLOR,Yellow))          
            Alert("Create highest error: ",GetLastError());
            
         isInited = true;
      }
      else
      {
         // is not displayed show it
         if(!ObjectDelete(0,HighestLineName) || !ObjectDelete(0,HighestLineName) || ! ObjectDelete(0,AverageLineName) || !ObjectDelete(0,AverageHighLineName) || !ObjectDelete(0,AverageLowLineName))
         {
            DisplayText("Delete Horizontal line error: "+GetLastError());
         }
         else
         {
            isInited = false;
         }
      }
      isDisplayed = !isDisplayed;
   
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
      //only check for open once at first tick 
      if(Volume[0] <= 1)
      {
         CheckForReInit();
         CheckForOpen();
      }
  }
//+------------------------------------------------------------------+


void CheckForReInit()
{
   if(TimeDayOfWeek(TimeCurrent()) == TargetDay)
   {
      
     CalculateSignalLine();
   }
}
void CheckForOpen()
{
   if(isDisplayed)
   {
      if(Close[1] >= averageHigh && CurrentChoise !=1)
      {
         //touch the high open sell
         DebugSignal(false);
         if(OrderSend(Symbol(),OP_SELL, Lot, Bid,3,Ask + StopLoss*Point(),Bid - TakeProfit*Point(),"",MagicNumber,0,clrRed)<0)
         {
            DisplayText("Open sell order fail:"+GetLastError());
         }
         else
         {
            CurrentChoise = 1;
         }
      }
      if(Close[1] <= averageLow && CurrentChoise != 2 )
      {
         // touch the low open buy
         DebugSignal(true);
         if(OrderSend(Symbol(),OP_BUY, Lot, Ask,3,Bid - StopLoss*Point(),Ask + TakeProfit*Point(),"",MagicNumber,0,clrBlue) < 0)
         {
            DisplayText("Open buy order fail:"+GetLastError());
         }
         else
         {
            CurrentChoise = 2;
         }
      }
   }
   else
   {
      DisplayText("Not Displayed");
   }
}

void DebugSignal(bool isBuy)
{

      if(!ObjectCreate(TimeCurrent(), OBJ_ARROW_DOWN, 0, Time[0], averageLow, 0, 0))
         Alert("Create highest error: ",GetLastError());
  
       if(!ObjectCreate(TimeCurrent(), OBJ_ARROW_UP, 0, Time[0], averageHigh  , 0, 0))
         Alert("Create highest error: ",GetLastError());

}

void checkForClose()
{

}