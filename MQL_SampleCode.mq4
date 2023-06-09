//+------------------------------------------------------------------+
//|                                                    G_tester2     |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, G_rop"
#property strict
#property indicator_chart_window
#property icon "G_rop.ico"

#define KEY_NUM_1 97 // テンキー1のキーコード
#define KEY_NUM_2 98 // テンキー2のキーコード
#define KEY_NUM_3 99 // テンキー3のキーコード

input string ind_name1 = "インポートバー数以下に設定して下さい"; //勝率計算期間
input int term = 100000;     //インポートバー数

int shift = 0;               //判定足（0：次足判定、1：次々足判定）

input string ind_name2 = "RSIの設定値で逆張り";   //RSI設定
input bool rsi_flag   = false; //RSIのオンオフ
input int  rsi_term   = 14;    //RSIの期間
input int  rsi_u      = 70;    //RSI上限閾値
input int  rsi_l      = 30;    //RSI下限閾値

input string ind_name3 = "ストキャスの設定値で逆張り";   //ストキャス設定
input bool stc_flag   = false; //ストキャスのオンオフ
input int  stc_k_term = 5;     //％K
input int  stc_d_term = 3;     //％D
input int  stc_s_term = 3;     //スローイング
input int stc_u = 80;          //メイン上限閾値
input int stc_l = 20;          //メイン下限閾値
input int stc_s_u = 80;        //シグナル上限閾値
input int stc_s_l = 20;        //シグナル下限閾値

input string ind_name4 = "ボリンジャーバンドの設定値で逆張り";       //ボリンジャーバンド設定
input bool   bb_flag = false;      //ボリンジャーバンドのオンオフ
input int    bb_term = 20;         //ボリンジャーバンド期間
input double bb_term_sigma = 2.0;  //ボリンジャーバンド偏差


input string ind_name5 = "CCIの設定値で逆張り";   //CCI設定
input bool cci_flag   = false; //CCIのオンオフ
input int  cci_term   = 14;    //CCIの期間
input int  cci_u      = 150;   //CCI上限閾値
input int  cci_l      = -150;  //CCI下限閾値

input string ind_name6 = "ローソク足実体がATRの倍率以上でエントリー"; //ATR設定
input bool atr_flag   = false;   //atrのオンオフ
input int  atr_period = 14;     //atr期間
input double  atr_mag = 1;   //atr倍率

input string ind_name7 = "ウィリアムパーセントレンジ設定値で逆張り"; //ウィリアムパーセントレンジ設定
input bool WPR_flag = false;   //WPRのオンオフ
input int WPR_period= 14;      //WPRの期間
extern int WPR_u = -20;          //WPR上限閾値
extern int WPR_l = -80;          //WPR下限閾値

input string ind_name8 = "設定MAの上でHIGHエントリー、下でLOWエントリー"; //MA順張り設定
input bool ma_flag_j = false;    //MA順張りのオンオフ
input int  ma_priod_j =  20;     //MA順張りの期間
input ENUM_MA_METHOD ma_type_j = MODE_SMA; //MAのモード切替

input string ind_name9 = "設定MAの上でLOWエントリー、下でHIGHエントリー"; //MA逆張り設定
input bool ma_flag_g = false;    //MA逆張りのオンオフ
input int  ma_priod_g =  20;     //MA逆張りの期間
input ENUM_MA_METHOD ma_type_g = MODE_SMA; //MA逆張りのモード切替

input string ind_name10 = "勝率表示の色を変更する値"; //勝率表示変更値設定
input double syouritu_clr = 54.5;  //勝率


//表示判定機関
string obj_shift = " ";

//表示内容2
color Price_Color_s = clrWhite;
color Price_Color_b = clrWhite;
int corner1 = 2;
int Price_font_size = 20;
int Price_offset_X  = 50;
int Price_offset_Y  = 100;
int Price_offset_X1 = 50;
int Price_offset_Y1 = 45;
int Price_offset_X2 = 5;
int Price_offset_Y2 = 60;

#property indicator_buffers 5
#property indicator_color1 clrMagenta
#property indicator_width1 2
#property indicator_color2 clrYellow
#property indicator_width2 2
//勝敗アローー
#property indicator_color3 clrRed
#property indicator_width3 2
#property indicator_color4 clrBlue
#property indicator_width4 4

double BuySignal[];
double SellSignal[];

double MarkW[];
double MarkL[];


bool keyflag = true;
int pos = 1;

//+------------------------------------------------------------------+
//|                            開始時処理                             |
//+------------------------------------------------------------------+
int OnInit()
  {

   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, BuySignal);

   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, SellSignal);

   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 161);
   SetIndexBuffer(2, MarkW);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 251);
   SetIndexBuffer(3, MarkL);

   EventSetMillisecondTimer(500);


//背景表示

   string box2 = "box2";
   string box3 = "box3";

   ObjectCreate(box2, OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSet(box2, OBJPROP_CORNER, corner1);
   ObjectSet(box2, OBJPROP_BGCOLOR, clrWhite);     
   ObjectSet(box2, OBJPROP_XSIZE, 650);            
   ObjectSet(box2, OBJPROP_YSIZE, 230);           
   ObjectSet(box2, OBJPROP_XDISTANCE, 30);
   ObjectSet(box2, OBJPROP_YDISTANCE, 250);

   ObjectCreate(box3, OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSet(box3, OBJPROP_CORNER, corner1);
   ObjectSet(box3, OBJPROP_BGCOLOR, clrDarkBlue);
   ObjectSet(box3, OBJPROP_XSIZE, 640);
   ObjectSet(box3, OBJPROP_YSIZE, 220);
   ObjectSet(box3, OBJPROP_XDISTANCE, 35);
   ObjectSet(box3, OBJPROP_YDISTANCE, 245);

   ObjectCreate("obj_shift",OBJ_LABEL,0,0,0);
   ObjectSet("obj_shift", OBJPROP_CORNER, corner1);
   ObjectSet("obj_shift", OBJPROP_XDISTANCE, 50);
   ObjectSet("obj_shift", OBJPROP_YDISTANCE, 200);


//指定期間
   if(Period() == 15)
     {pos = 5;}
   if(Period() == 30)
     {pos = 7;}
   if(Period() == 60)
     {pos = 10;}
   if(Period() == 240)
     {pos = 15;}
   if(Period() == 1440)
     {pos = 50;}
   if(Period() == 10080)
     {pos = 100;}
   if(Period() == 43200)
     {pos = 100;}
   if(Period() >  5)
     {obj_shift = IntegerToString(Period()) +"分";}

   if(Period() == 5)
     {
      obj_shift = "短期";
      pos = 3;
     }

   if(Period() == 1)
     {obj_shift = "1分";}

   if(term >= Bars)
     {
      ObjectDelete("error_period");
      ObjectCreate("error_period",OBJ_LABEL,0,0,0);
      ObjectSetText("error_period","期間が長すぎます！" + IntegerToString(Bars - 7)+"以下にしてください", Price_font_size, "HGP明朝E",  Price_Color_b);
      ObjectSet("error_period", OBJPROP_CORNER, corner1);
      ObjectSet("error_period", OBJPROP_XDISTANCE, Price_offset_X1);
      ObjectSet("error_period", OBJPROP_YDISTANCE, Price_offset_Y1);
     }

   return(0);
  }

//+------------------------------------------------------------------+
//|                           終了時処理                              |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("Sell");
   ObjectDelete("Buy");
   ObjectDelete("Bar");
   ObjectDelete("obj_shift");
   ObjectDelete("error_period");
   ObjectDelete("box2");
   ObjectDelete("box3");

   return(0);
  }
int start()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                            タイマー処理                             |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(term >= Bars && keyflag != true) return;   //処理を軽くするため、キーが押された時だけ再計算する
     
    keyflag = false;
    
    double win_sell    = 0; //売りの勝数
    double lose_sell   = 0; //売りの負数
    double win_buy     = 0; //買いの勝数
    double lose_buy    = 0; //買いの負数
    double rate_sell   = 0; //売りの勝率
    double rate_buy    = 0; //買いの勝率

    for(int i=term-1; i>=0; i--)
      {
       // インジケータ宣言
       double cci = iCCI(NULL,0,cci_term,PRICE_TYPICAL,i+shift+2);
       double rsi = iRSI(NULL,0,rsi_term,PRICE_CLOSE,i+shift+2);
       double stc_m = iStochastic(NULL,0,stc_k_term,stc_d_term,stc_s_term,MODE_SMA,0,MODE_MAIN,i+shift+2);
       double stc_s = iStochastic(NULL,0,stc_k_term,stc_d_term,stc_s_term,MODE_SMA,0,MODE_SIGNAL,i+shift+2);
       double bb_up = iBands(NULL,0,bb_term,bb_term_sigma,0,PRICE_CLOSE,MODE_UPPER,i+shift+2);
       double bb_down = iBands(NULL,0,bb_term,bb_term_sigma,0,PRICE_CLOSE,MODE_LOWER,i+shift+2);
       double atr = iATR(NULL,0,atr_period,i+shift+2);
       double close = iClose(NULL,0,i+shift+2);
       double open = iOpen(NULL,0,i+shift+2);
       double body = MathAbs(open - close);
       double ma_j = iMA(NULL,0,ma_priod_j,0,ma_type_j,PRICE_CLOSE,i+shift+2);
       double ma_g = iMA(NULL,0,ma_priod_g,0,ma_type_g,PRICE_CLOSE,i+shift+2);
       double wpr = iWPR(NULL,0,WPR_period,i+shift+2);
       
       //on off
       int cci_u_d = 0;
       int cci_l_d = 0;
       int rsi_u_d = 0;
       int rsi_l_d = 0;
       int sto_u_d = 0;
       int sto_l_d = 0;
       
       if(cci_flag == false)
         {
          cci_u_d = -10000;
          cci_l_d = 10000;
         }

       if(rsi_flag == false)
         {
          rsi_u_d = -100;
          rsi_l_d = 100;
         }

       if(stc_flag == false)
         {
          sto_u_d = -100;
          sto_l_d = 100;
         }

       if(bb_flag == false)
         {
          bb_up = 0;
          bb_down = 10000;
         }
       if(atr_flag == false) atr = 0;

       if(ma_flag_j == false) ma_j = close;

       if(ma_flag_g == false) ma_g = close;

       if(WPR_flag == false)
         {
          WPR_u = -1000;
          WPR_l = 1000;
         }
       //------------Low条件-----------
       if(
          cci >= cci_u + cci_u_d
          && rsi >= rsi_u + rsi_u_d
          && stc_m >= stc_u + sto_u_d
          && stc_s >= stc_u + sto_u_d
          && bb_up <= close
          && body >= atr*atr_mag
          && ma_j >= close
          && ma_g <= close
          && wpr >= WPR_u
       )
         {
          SellSignal[i+shift+2] = iHigh(NULL,0,i+shift+2) + Point*10;

          //==========勝率数加算===========
          if(Open[i+shift+1]> Close[i+1])
            {
             win_sell += 1;
             MarkW[i+shift+2] = iHigh(NULL,0,i+shift+2) + Point*20*pos;
            }
            
          //==========敗北数加算===========
          else
             if(Open[i+shift+1] <= Close[i+1])
               {
                lose_sell += 1;
                MarkL[i+shift+2] = iHigh(NULL,0,i+shift+2) + Point*20*pos;
               }
             else {}
         }
       else
         {
          SellSignal[i+shift+2] = EMPTY_VALUE;
         }
       //------------High条件-----------
       if(
          cci <= cci_l   + cci_l_d
          && rsi <= rsi_l   + rsi_l_d
          && stc_m <= stc_l + sto_l_d
          && stc_s <= stc_l + sto_l_d
          && bb_down >= close
          && body  >= atr*atr_mag
          && ma_j  <= close
          && ma_g  >= close
          && wpr   <= WPR_l
       )
         {
          BuySignal[i+shift+2] = iLow(NULL,0,i+shift+2) - Point * 10;
          
          //==========勝率数加算===========
          if(Open[i+shift+1] < Close[i+1])
            {
             win_buy += 1;
             MarkW[i+shift+2] = iLow(NULL,0,i+shift+2) - Point*20*pos ;
            }
            
          //==========敗北数加算===========
          else
             if(Open[i+shift+1] >= Close[i+1])
               {
                lose_buy += 1;
                MarkL[i+shift+2] = iLow(NULL,0,i+shift+2) - Point*20*pos ;
               }
             else {}
         }
       else
         {
          BuySignal[i+shift+2] = EMPTY_VALUE;
         }
      }

    ObjectDelete("Sell");
    ObjectDelete("Buy");
    ObjectDelete("Bar");
    double all_sell = win_sell + lose_sell;  //売りの合計数
    double all_buy  = win_buy + lose_buy ;  //買いの合計数
    if(all_sell != 0)
      {
       rate_sell = win_sell*100 / all_sell;
      }
    if(all_buy != 0)
      {
       rate_buy = win_buy*100 / all_buy;
      }
    if(rate_sell > syouritu_clr)
      {
       Price_Color_s = clrYellow;
      }
    if(rate_buy > syouritu_clr)
      {
       Price_Color_b = clrYellow;
      }

    ObjectCreate("Sell",OBJ_LABEL,0,0,0);
    ObjectSetText("Sell","Sell   勝ち数: "+DoubleToStr(win_sell,0)+" 負け数: " +DoubleToStr(lose_sell,0)+" 勝率＝" +DoubleToStr(rate_sell,1)+"%", Price_font_size, "HGP明朝E",  Price_Color_s);
    ObjectSet("Sell", OBJPROP_CORNER, corner1);
    ObjectSet("Sell", OBJPROP_XDISTANCE, Price_offset_X);
    ObjectSet("Sell", OBJPROP_YDISTANCE, Price_offset_Y);
    ObjectCreate("Buy",OBJ_LABEL,0,0,0);
    ObjectSetText("Buy","Buy   勝ち数: "+DoubleToStr(win_buy,0)+" 負け数: "+DoubleToStr(lose_buy,0)+" 勝率＝"+DoubleToStr(rate_buy,1)+"%", Price_font_size, "HGP明朝E",  Price_Color_b);
    ObjectSet("Buy", OBJPROP_CORNER, corner1);
    ObjectSet("Buy", OBJPROP_XDISTANCE, Price_offset_X1);
    ObjectSet("Buy", OBJPROP_YDISTANCE, Price_offset_Y1);
    ObjectCreate("Bar",OBJ_LABEL,0,0,0);
    ObjectSetText("Bar","テスト可能バー数 = "+IntegerToString(Bars), Price_font_size, "HGP明朝E",  clrWhite);
    ObjectSet("Bar", OBJPROP_CORNER, 2);
    ObjectSet("Bar", OBJPROP_XDISTANCE, 50);
    ObjectSet("Bar", OBJPROP_YDISTANCE, 150);
    ObjectSetText("obj_shift","判定期間: "+obj_shift, Price_font_size, "HGP明朝E",  clrWhite);

  }
//+------------------------------------------------------------------+
//|                     勝敗マーカー削除                               |
//+------------------------------------------------------------------+

void ResetMarks()
  {
   for(int i=Bars-1; i>=0; i--)
     {
      MarkW[ i ] = EMPTY_VALUE;
      MarkL[ i ] = EMPTY_VALUE;
     }
  }

//+------------------------------------------------------------------+
//|                       キーボードのイベント                         |
//+------------------------------------------------------------------+

void OnChartEvent(
   const int     id,      // イベントID
   const long&   lparam,  // long型イベント
   const double& dparam,  // double型イベント
   const string& sparam)  // string型イベント
  {

   if(id == CHARTEVENT_KEYDOWN)
     {
      ResetMarks();
      keyflag = true;
     }

  //==============5分足==================
   if(Period() == 5)
     {
      if(id == CHARTEVENT_KEYDOWN)
        {
         switch(int(lparam))
           {
            case KEY_NUM_1:
               obj_shift = "短期";
               shift = 0;
               break;

            case KEY_NUM_2:
               obj_shift = "中期";
               shift = 1;
               break;

            case KEY_NUM_3:
               obj_shift = "長期";
               shift = 2;
               break;

           }

        }
     }
     
  //==============1分足==================
   if(Period() == 1)
     {
      if(id == CHARTEVENT_KEYDOWN)
        {
         switch(int(lparam))
           {
            case KEY_NUM_1:
               obj_shift = "1分";
               shift = 0;
               break;

            case KEY_NUM_2:
               obj_shift = "3分";
               shift = 2;
               break;

            case KEY_NUM_3:
               obj_shift = "5分";
               shift = 4;
               break;

           }

        }
     }
  }
