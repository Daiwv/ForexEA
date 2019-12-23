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

extern bool isCanTrade;





int lastOrderTime;
int backupTime;
bool isTestMode;
bool buySignal;
bool sellSignal;

int CurrentLot;

double maxFloating;
// ui elements
string tradeOnOffBtnName = "TradeOnOff";
string buyBtnName = "Buy";
string sellBtnName = "Sell";
string lotInputFieldName = "LotInput";
string slPipInputFieldName = "StopLossPip";
string tpPipInputFieldName = "TakeProfitLossPip";
string lotLabelName = "LotLabel";
string StoplossLabelName = "StoplossLabel";
string TakeprofitLabelName = "TakeprofitLabel";

int state;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   isCanTrade = true;
   //init param
    maxFloating = 0;
    CurrentLot = 0;
    state = -1;
    DisplayText("a");
    SetupUI();
   // AddButton();
//---
   return(INIT_SUCCEEDED);
  }
  
void SetupUI()
{
   Button(0,tradeOnOffBtnName, "On/Off",0,20);
   Button(0,buyBtnName, "Buy",0,80);
   Button(0,sellBtnName, "Sell",0,140);
    
   InputFiled(0, lotInputFieldName, "0.1", 190 ,80,0,60,50);
   InputFiled(0, slPipInputFieldName, "0.1", 190 ,140,0,60,50);
   InputFiled(0, tpPipInputFieldName, "0.1", 350 ,140,0,60,50);
       
   Label(0, lotLabelName, "Lot: ", 110 ,95,0);
   Label(0, StoplossLabelName, "StopLoss: ", 110 ,155,0);
   Label(0, TakeprofitLabelName, "Take profit: ", 260 ,155,0);
}

void SetUIElementsPosition(const long ID=0, const string name="", const int x = 100, const int y = 10, const int sizeX = 100, const int sizeY = 50)
{
   ObjectSetInteger(ID,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(ID,name,OBJPROP_XSIZE,sizeX);
   ObjectSetInteger(ID,name,OBJPROP_YSIZE,sizeY);
   ObjectSetInteger(ID,name,OBJPROP_BACK, false);
   
}

bool Label(const long ID=0, const string name="", const string text="", const int x = 100, const int y = 10, const int sub_window = 0)
{
   if(!ObjectCreate(ID,name,OBJ_LABEL,sub_window,0,0,0))
     // return false;
   
   ObjectSetString(ID,name,OBJPROP_TEXT,text);
   ObjectSetString(ID,name,OBJPROP_FONT,"Arial"); 
   ObjectSetInteger(ID,name,OBJPROP_FONTSIZE,10); 
   ObjectSetInteger(ID,name,OBJPROP_COLOR,clrWhite);// mau chu
   SetUIElementsPosition(ID,name,x,y);
   
   return true;
    
}

bool InputFiled(const long ID=0, const string name="", const string text="InputField", const int x = 100, const int y = 10, const int sub_window = 0, const int sizeX = 100, const int sizeY = 50)
{
   if(!ObjectCreate(ID,name,OBJ_EDIT,sub_window,0,0,0))
     // return false;
   
   
   ObjectSetString(ID,name,OBJPROP_TEXT,text);
   ObjectSetString(ID,name,OBJPROP_FONT,"Arial"); 
   ObjectSetInteger(ID,name,OBJPROP_FONTSIZE,10); 
   ObjectSetInteger(ID,name,OBJPROP_COLOR,clrBlack);// mau chu
   SetUIElementsPosition(ID,name,x,y,sizeX, sizeY);
   
   return true;
    
}


bool Button(const long   ID=0,               // chart's ID 
            const string name="",            // button name
            const string text="Button",      // text
            const int    x=100,              // X coordinate 
            const int    y=10,               // Y coordinate
            const int    sub_window=0)       // subwindow index
                                            
{
   if(!ObjectCreate(ID,name,OBJ_BUTTON,sub_window,0,0,0))
 
   
   
   SetUIElementsPosition(ID,name,x,y);
   ObjectSetString(ID,name,OBJPROP_TEXT,text);
   ObjectSetString(ID,name,OBJPROP_FONT,"Arial"); 
   ObjectSetInteger(ID,name,OBJPROP_FONTSIZE,10); 
   ObjectSetInteger(ID,name,OBJPROP_COLOR,clrWhite);// mau chu

   if(name == tradeOnOffBtnName)
   {
      if(isCanTrade)
      {
         ObjectSetInteger(ID,name, OBJPROP_BGCOLOR,clrGreen);
      
      }
      else
      {
         ObjectSetInteger(ID,name, OBJPROP_BGCOLOR,clrRed);
      }
      
      
   }
   else if(name == buyBtnName)
   {
      ObjectSetInteger(ID,name, OBJPROP_BGCOLOR,clrGreen);
     
   }
   else if(name == sellBtnName)
   {
      ObjectSetInteger(ID,name, OBJPROP_BGCOLOR,clrRed);
   }
   
   
   
   DisplayText("is can trade "+isCanTrade);
   ObjectSetInteger(ID,name,OBJPROP_BORDER_COLOR,clrWhiteSmoke); 
 
   //ObjectSetInteger(ID,name,OBJPROP_BACK,true); 
   ObjectSetInteger(ID,name,OBJPROP_STATE,true);             //button is pressed.
   ObjectSetInteger(ID,name,OBJPROP_SELECTABLE,true); 
   ObjectSetInteger(ID,name,OBJPROP_SELECTED,false); 
   ObjectSetInteger(ID,name,OBJPROP_HIDDEN,true); 
   ObjectSetInteger(ID,name,OBJPROP_ZORDER,0); 
 return(true);
  } 

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == tradeOnOffBtnName )
      {
         isCanTrade = !isCanTrade;
         
         if(isCanTrade)
            ObjectSetInteger(0,tradeOnOffBtnName,OBJPROP_BGCOLOR,clrGreen); 
         else
            ObjectSetInteger(0,tradeOnOffBtnName,OBJPROP_BGCOLOR,clrRed); 
            
         DisplayText(ObjectGetString(0,"abc",OBJPROP_TEXT));
         DisplayText("is Can trade " + isCanTrade); 
       }
       
       if(sparam == buyBtnName)
       {
         //DisplayText("Lot: " + ObjectGetString(0,lotInputFieldName,OBJPROP_TEXT));
         //DisplayText("Take profit: " + ObjectGetString(0,tpPipInputFieldName,OBJPROP_TEXT));
         //DisplayText("Stop loss: " + ObjectGetString(0,slPipInputFieldName,OBJPROP_TEXT));
         double lot = StrToDouble(ObjectGetString(0,lotInputFieldName,OBJPROP_TEXT));
         double stopLossPip = StrToDouble(ObjectGetString(0,slPipInputFieldName,OBJPROP_TEXT)) * Point;
         double takeprofitPip = StrToDouble(ObjectGetString(0,tpPipInputFieldName,OBJPROP_TEXT)) * Point;
         OpenOrder(true,lot,stopLossPip,takeprofitPip);
       }
       if(sparam == sellBtnName)
       {
         //DisplayText("Lot: " + ObjectGetString(0,lotInputFieldName,OBJPROP_TEXT));
         //DisplayText("Take profit: " + ObjectGetString(0,tpPipInputFieldName,OBJPROP_TEXT));
         //DisplayText("Stop loss: " + ObjectGetString(0,slPipInputFieldName,OBJPROP_TEXT));
         double lot = StrToDouble(ObjectGetString(0,lotInputFieldName,OBJPROP_TEXT));
         double stopLossPip = StrToDouble(ObjectGetString(0,slPipInputFieldName,OBJPROP_TEXT)) * Point;
         double takeprofitPip = StrToDouble(ObjectGetString(0,tpPipInputFieldName,OBJPROP_TEXT)) * Point;
         OpenOrder(false,lot,stopLossPip,takeprofitPip);
       }
     
  }
}

void OpenOrder(bool isBuy, float lot, float stoplossPip, float takeprofitPip)
{
   if (isBuy)
   {
      if(OrderSend(Symbol(),OP_BUY, GetLot(), Ask,3,Bid - stoplossPip,Ask + takeprofitPip,"",MagicNumber,0,clrBlue) < 0)
      {
         DisplayText("Open buy order fail:"+GetLastError());
      }
      else
      {
         CurrentLot +=1;
         state = 0;
      }
   }
   else
   {
      if(OrderSend(Symbol(),OP_SELL, GetLot(), Bid,3,Ask + stoplossPip,Bid - takeprofitPip,"",MagicNumber,0,clrBlue) < 0)
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
         if(isCanTrade)
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


//+------------------------------------------------------------------+ 
//| Create the button                                                | 
//+------------------------------------------------------------------+ 








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