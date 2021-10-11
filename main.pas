unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,pole,gui,graff, StdCtrls,th_ti,gfx,tbitmap_28e,
  PackList_Bitmaps,inifiles;

type
  tdefault_settings = record
   x,y,xx,yy:integer;
   lang:boolean;
   w,h,cou:integer;
   transparent:integer;
   use_icon:boolean;
  end;
  Ticons_list = record
   ico1,ico2,ico3:integer;
   ico1_t,ico2_t,ico3_t:integer;
   ico1_tr,ico2_tr,ico3_tr:integer;
  end;

  Tmainform = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    Status_timer:TThread_timer;
    IconChanger:Ticons_list;
    procedure RenderForm(BT:tbitmap);
    procedure LoadSettings;
    procedure SaveSettings;
    procedure Re_place_coord;
    procedure Re_place_coord_back;
    procedure Reset_ico;
    procedure Clear_ico;
  protected
    procedure WMEXITSIZEMOVE(var Message: TMessage); message WM_EXITSIZEMOVE;
  public
    DC:HDC;
    Pole:TPole;
    GUI:TGUI;
    GFX_effect:TGFX_effect;
    sdvig_l,sdvig_r,sdvig_t,sdvig_b,spx,spy,spw,sph:integer;
    transparent,fclose,transparent_old:integer;

    BBuffered,btmp3,btmp4:Tbitmap;

    BT_back,bt,bt_pole,BT_bufferout,BT_toolbar,btlogodesksoft:tbt;

    PackListBitmaps,PackListBitmapsIco:TPackListBitmaps;
    ListIcons:TPackListTBT;
    //===========
    last_game:boolean;
    default_settings:tdefault_settings;
    ch_size:integer;

    procedure Set_new_pole(w,h,n:integer);
    procedure Load(filename:string);
    procedure Draw_pole;
    procedure Draw_out;
    procedure Draw_buff;
    procedure Status_timer_out(Sender: TObject);
    procedure check_status;

    procedure Load_pictures(Filename:string);
    procedure Draw_ico;
  end;

var
  mainform: Tmainform;
  direc,direcuser:string;
  _Cursor_curent:integer;
  _monitor:integer; //0 - меню, 1 - игра на поле, 2 - победа, 3 - поражение

implementation

uses settings;

{$R *.dfm}
{$R WindowsXP.res}

procedure Tmainform.WMEXITSIZEMOVE(var Message: TMessage);
begin
  Re_place_coord_back;
  SaveSettings;
end;

procedure Tmainform.FormCreate(Sender: TObject);
begin
  direc:=extractfilepath(application.ExeName);
 // direcuser:=extractfilepath(application.ExeName);
  direcuser:=NormalDir(PERSONAL)+'\desksoft_clickomania\';
  createdir_f(direcuser);
  Screen.Cursors[100]:=LoadCursor(0,IDC_HAND);
  bt_pole:=tbt.Create;
  _monitor:=0;
  fclose:=0;
  ch_size:=-1;

  transparent:=0; transparent_old:=255;
  LoadSettings;

  bt:=tbt.Create;
  Pole:=TPole.Create;
  GUI:=TGUI.Create;
  GUI.GButtons.Set_language(default_settings.lang);
  GFX_effect:=TGFX_effect.Create;
  last_game:=false;
  GUI.GButtons.Visible_butt(2,last_game);

  sdvig_l:=32;
  sdvig_r:=32;
  sdvig_t:=56;
  sdvig_b:=32;
  spx:=0;
  spy:=0;
  spw:=0;
  sph:=0;
  randomize;
  BT_back:=tbt.Create;

  btlogodesksoft:=tbt.Create;

  btmp3:=Tbitmap.Create;
  btmp4:=Tbitmap.Create;

  BT_bufferout:=tbt.Create;
  BT_toolbar:=tbt.Create;

  BBuffered:=Tbitmap.Create;
  BBuffered.PixelFormat:=pf32bit;

  PackListBitmaps:=TPackListBitmaps.Create;
  PackListBitmaps.Load(direc+'main.28e');
  {PackListBitmaps.Add_bitmap_from_file(direc+'tool_im.bmp');
  PackListBitmaps.Add_bitmap_from_file(direc+'tool_i.bmp');
  PackListBitmaps.Add_bitmap_from_file(direc+'under_pole.bmp');    //2
  PackListBitmaps.Add_bitmap_from_file(direc+'under_pole_mask.bmp');
  PackListBitmaps.Add_bitmap_from_file(direc+'35_32.bmp');
  PackListBitmaps.Add_bitmap_from_file(direc+'11mm.bmp'); //5
  PackListBitmaps.Add_bitmap_from_file(direc+'22mm.bmp');
  PackListBitmaps.Add_bitmap_from_file(direc+'logodesksoft.bmp');
  PackListBitmaps.Add_bitmap_from_file(direc+'_system_font.bmp');

  PackListBitmaps.Add_bitmap_from_file(direc+'but_l.bmp');
  PackListBitmaps.Add_bitmap_from_file(direc+'but_ll.bmp');
  PackListBitmaps.Add_bitmap_from_file(direc+'but_m.bmp');

  PackListBitmaps.Save(direc+'main.28e');     }
  btlogodesksoft.load_from_bitmap(PackListBitmaps.GetBitmap(7).Bitmap);
  GUI.GFont.Load_font(PackListBitmaps.GetBitmap(8).Bitmap);
  GUI.GButtons.Setskin(PackListBitmaps.GetBitmap(9).Bitmap,
  PackListBitmaps.GetBitmap(10).Bitmap,
  PackListBitmaps.GetBitmap(11).Bitmap);

  Clear_ico;
  ListIcons:=TPackListTBT.Create;
  PackListBitmapsIco:=TPackListBitmaps.Create;
  Load_pictures(direc+'ico.28e');
 {
  Вот так это делалось :)
  PackListBitmapsIco.Add_bitmap_from_file(direc+'ico\crii_0.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'ico\crii_1.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'ico\crii_2.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'ico\crii_3.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'ico\crii_4.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'ico\crii_5.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'ico\crii_6.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'ico\crii_7.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'ico\crii_8.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'ico\crii_9.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'ico\crii_10.bmp');
  PackListBitmapsIco.Save(direc+'ico.28e');  }

  DC:=GetDC(0);

  Status_timer:=TThread_timer.Create;
  Status_timer.OnTimer:=Status_timer_out;
  Status_timer.Interval:=15;

  
  Load(direcuser+'save_game.txt');
  Re_place_coord;
  check_status;
end;

procedure Tmainform.Set_new_pole(w,h,n:integer);
var ccol:tcolor;
begin
 if(n<>0) then
 Pole.set_widthheight(w,h);
 bt_pole.set_widthheight(w*pole.element_w,h*pole.element_h);
 BT_back.set_widthheight(bt_pole.DIBWidth+sdvig_r+sdvig_l,bt_pole.DIBHeight+sdvig_t+sdvig_b);

 Copy32assing(PackListBitmaps.GetBitmap(5).Bitmap,btmp3);
 Copy32assing(PackListBitmaps.GetBitmap(6).Bitmap,btmp4);
 btmp3.PixelFormat:=pf32bit;
 btmp4.PixelFormat:=pf24bit;
 ccol:=rgb(random(64)+128,random(64)+128,random(64)+128);
 PrepareColorBitmap(btmp3,ccol);
 CopyRectIco_rect(btmp3,btmp4,BT_back,sdvig_l,sdvig_t,sdvig_r,sdvig_b);

 Copy32assing(PackListBitmaps.GetBitmap(0).Bitmap,btmp3);
 Copy32assing(PackListBitmaps.GetBitmap(1).Bitmap,btmp4);
 btmp3.PixelFormat:=pf32bit;
 btmp4.PixelFormat:=pf24bit;
 PrepareColorBitmap(btmp3,ColorDarker(ccol,89));
 BT_toolbar.set_widthheight(BT_back.DIBWidth-32-16,32);
 CopyRectIco_rect(btmp3,btmp4,BT_toolbar,16,16,16,16);
 //BT_toolbar.Draw_alpha_a(BT_back,16+8,24);

 BT_bufferout.set_widthheight(BT_back.DIBWidth+spx+spw,BT_back.DIBHeight+spy+sph);
 BBuffered.Width:=BT_bufferout.DIBWidth;
 BBuffered.Height:=BT_bufferout.DIBHeight;
end;

procedure Tmainform.Load(filename:string);
begin
if not(fileexists(filename)) then begin
 Reset_ico;
 Set_new_pole(default_settings.w,default_settings.h,1);
 Re_place_coord; Draw_pole;
 exit;
end;
 pole.LoadToFile(filename);
 pole.Check_end_game;
 Reset_ico;

 if(pole.Width<7)or(pole.Height<7) then
  Set_new_pole(default_settings.w,default_settings.h,1) else
 Set_new_pole(pole.Width,pole.Height,0);
 Re_place_coord;
 
 if(pole.status.status=0) then begin
   last_game:=true;
   GUI.GButtons.Visible_butt(2,last_game);
 end else begin
   last_game:=false;
   GUI.GButtons.Visible_butt(2,last_game);
 end;
 Draw_pole;
end;

procedure Tmainform.Draw_pole;
begin
 bt.Assing_TBT(BT_back);
 case _monitor of
   1: begin
     bt_pole.clear;
     Pole.Draw(bt_pole);
     bt_pole.Draw_alpha_a(bt,sdvig_l,sdvig_t);
     GFX_effect.Draw(bt,sdvig_l,sdvig_t);
     BT_toolbar.Draw_alpha_a(bt,16+8,24);
    if(default_settings.lang) then
     GUI.GFont._sys_font_draw(bt,bt.DIBWidth-(16+8+24+length(GUI.language.eng.score+': '+inttostr(pole.status.score))*7),24+12,GUI.language.eng.score+': '+inttostr(pole.status.score))
    else
     GUI.GFont._sys_font_draw(bt,bt.DIBWidth-(16+8+24+length(GUI.language.rus.score+': '+inttostr(pole.status.score))*7),24+12,GUI.language.rus.score+': '+inttostr(pole.status.score));
   end;
   0: begin

     btlogodesksoft.Draw_alpha_a(bt,bt.DIBWidth-btlogodesksoft.DIBWidth-sdvig_l,bt.DIBHeight-btlogodesksoft.DIBHeight-sdvig_b);
   end;
   2: begin
    if(default_settings.lang) then begin
     GUI.GFont._sys_font_draw(bt,(bt.DIBWidth-7*(length(GUI.language.eng.defeat))) div 2,24+16,GUI.language.eng.defeat);
     GUI.GFont._sys_font_draw(bt,(bt.DIBWidth-7*(length(GUI.language.eng.score+': '+inttostr(pole.status.score)))) div 2,24+16+11,GUI.language.eng.score+': '+inttostr(pole.status.score));
    end else begin
     GUI.GFont._sys_font_draw(bt,(bt.DIBWidth-7*(length(GUI.language.rus.defeat))) div 2,24+16,GUI.language.rus.defeat);
     GUI.GFont._sys_font_draw(bt,(bt.DIBWidth-7*(length(GUI.language.eng.score+': '+inttostr(pole.status.score)))) div 2,24+16+11,GUI.language.rus.score+': '+inttostr(pole.status.score));
    end;
   end;
   3: begin
    if(default_settings.lang) then begin
     GUI.GFont._sys_font_draw(bt,(bt.DIBWidth-7*(length(GUI.language.eng.victory))) div 2,24+16,GUI.language.eng.victory);
     GUI.GFont._sys_font_draw(bt,(bt.DIBWidth-7*(length(GUI.language.eng.score+': '+inttostr(pole.status.score)))) div 2,24+16+11,GUI.language.eng.score+': '+inttostr(pole.status.score));
    end else begin
     GUI.GFont._sys_font_draw(bt,(bt.DIBWidth-7*(length(GUI.language.rus.victory))) div 2,24+16,GUI.language.rus.victory);
     GUI.GFont._sys_font_draw(bt,(bt.DIBWidth-7*(length(GUI.language.rus.score+': '+inttostr(pole.status.score)))) div 2,24+16+11,GUI.language.eng.score+': '+inttostr(pole.status.score));
    end;
   end;
 end;

 GUI.Draw(bt);
 Draw_buff;
end;

procedure Tmainform.Draw_buff;
begin
 BT_bufferout.clear;
 bt.Draw_alpha_a(BT_bufferout,spx,spy);
// BT_ico1.Draw_alpha_a(BT_bufferout,0,0);
 Draw_ico;
 BT_bufferout.Save_to_bitmap(BBuffered);
 RenderForm(BBuffered);
end;

procedure Tmainform.Draw_out;
begin
 Draw_buff;
end;

procedure Tmainform.PaintBox1Paint(Sender: TObject);
begin
 Draw_pole;
end;

procedure Tmainform.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  pole.SaveToFile(direcuser+'save_game.txt');
end;

procedure Tmainform.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const SC_DRAGMOVE : Longint = $F012;
var i,ii:integer;
begin
  if(Button=mbRight) then begin
   if(_monitor=1) then begin
     _monitor:=0;
      Draw_pole;
   end else
    if(_monitor=0)and(last_game) then begin
       _monitor:=1;
        Draw_pole;
        check_status;
    end;
   exit;
  end;

  i:=GUI.GetClick(x-spx,y-spy,bt);
  if(i<>-1) then begin
   case i of
    0,4,6: begin
      if(default_settings.w<>pole.Width)or(default_settings.h<>pole.Height) then begin
        ch_size:=3;
        check_status;
      end else begin
       Reset_ico;
       Set_new_pole(default_settings.w,default_settings.h,1);
       Re_place_coord;
       Pole.Generate(default_settings.cou);
       last_game:=true;
       GUI.GButtons.Visible_butt(2,last_game);
       _monitor:=1;
       Draw_pole;
       check_status;
      end;
    end;
    1: begin
     fclose:=1;
     check_status;
    end;
    2: begin
      if(last_game) then begin
        _monitor:=1;
        Draw_pole;
        check_status;
      end;
    end;
    3: begin
      ii:=FormSettings.GetSettings(default_settings);
       if(ii>0) then begin
        SaveSettings;
        if(not(last_game))and(ii=2) then begin
          ch_size:=1;
          check_status;
        end else
         GUI.GButtons.Set_language(default_settings.lang);
       end;
    end;
    5,7: begin
       _monitor:=0;
       Draw_pole;
    end;
   end;

  end else begin

   if(_monitor=1)and(InRect(x-spx,y-spy,sdvig_l,sdvig_t,sdvig_l+pole.Width*pole.element_w,sdvig_t+pole.Height*pole.element_h)) then begin
     pole.Click(x-spx-sdvig_l,y-spy-sdvig_t,GFX_effect);
     check_status;
    end else begin
      ReleaseCapture;
      SendMessage(Handle, WM_SYSCOMMAND, SC_DRAGMOVE, 0);
    end;
  end;
end;

procedure Tmainform.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var i:integer;
begin
  i:=GUI.GetKey(Key);
  case i of
   2: begin
     _monitor:=0;
     Draw_pole;
   end;
  end;
end;

procedure Tmainform.RenderForm(BT:tbitmap);
var zsize:TSize; zpoint:TPoint; zbf:TBlendFunction;
    TopLeft: TPoint;
begin
  width:=BT.Width;
  height:=BT.Height;

  zsize.cx := BT.Width;
  zsize.cy := BT.Height;
  zpoint := Point(0,0);

  with zbf do begin
    BlendOp := AC_SRC_OVER;
    BlendFlags := 0;
    AlphaFormat := AC_SRC_ALPHA;
    SourceConstantAlpha :=transparent;
  end;
  TopLeft:=BoundsRect.TopLeft;

  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
  //красотища будет! %)
  UpdateLayeredWindow(Handle,DC,@TopLeft,@zsize,BT.Canvas.Handle,@zpoint,clblack,@zbf, ULW_ALPHA);
end;

procedure Tmainform.Status_timer_out(Sender: TObject);
var _stop,f:boolean;
begin
_stop:=true;

 if (fclose=1) then begin
  if(transparent>0) then begin
       _stop:=false;
       transparent:=transparent-10; if(transparent<0) then transparent:=0;
       Draw_out;
   end else close;
  if(_stop) then Status_timer.Enabled:=false;
  exit;
 end;

 if(transparent<255)and(ch_size=-1) then begin
   if(transparent<transparent_old) then begin
     //  if(transparent=0) then Reset_ico;
        _stop:=false;
        transparent:=transparent+10;
        if(transparent>transparent_old) then transparent:=transparent_old;
        Draw_out;
    end else begin
        transparent:=transparent_old;
        Draw_out;
        _stop:=false;
    end;
 end;

 if(ch_size<>-1) then begin
   if(ch_size=1) then begin
     if(transparent>0) then begin
        _stop:=false;
        transparent:=transparent-15;
        if(transparent<=0) then transparent:=0;
        Draw_out;
      end else begin
        transparent:=0;
        Draw_out;
        _stop:=false;
        ch_size:=2;
        Reset_ico;
        Set_new_pole(default_settings.w,default_settings.h,1);
        Re_place_coord;
        Draw_pole;
     end;
   end else
    if(ch_size=3) then begin
     if(transparent>0) then begin
        _stop:=false;
        transparent:=transparent-15;
        if(transparent<=0) then transparent:=0;
        Draw_out;
      end else begin
        transparent:=0;
        Draw_out;
        _stop:=false;
        ch_size:=2;
        Reset_ico;
        Set_new_pole(default_settings.w,default_settings.h,1);
        Re_place_coord;
        Pole.Generate(default_settings.cou);
        last_game:=true;
        GUI.GButtons.Visible_butt(2,last_game);
        GUI.GButtons.Set_language(default_settings.lang);
        _monitor:=1;
        Draw_pole;
        Re_place_coord;
     end;
   end else
    if(ch_size=2) then begin
       if(transparent<transparent_old) then begin
         _stop:=false;
         transparent:=transparent+10;
         if(transparent>transparent_old) then transparent:=transparent_old;
         Draw_out;
       end else begin
         transparent:=transparent_old;
         Draw_out;
       end;
    end;
 end;

 case _monitor of
  1: begin
    if(GFX_effect.Timer<>-1) then _stop:=false;
    f:=not(_stop);

    if(pole.Animate_tick=1) then begin
      f:=true;
      _stop:=false;
    end;
    if(f) then Draw_pole else Draw_out;

    if(_stop)and(pole.status.status=1) then begin
     _monitor:=2;
     last_game:=false;
     GUI.GButtons.Visible_butt(2,last_game);
     Draw_pole;
    end else
      if(_stop)and(pole.status.status=2) then begin
        _monitor:=3;
        last_game:=false;
        GUI.GButtons.Visible_butt(2,last_game);
        Draw_pole;
      end;
  end;
   0: begin
     Draw_out;
   end;
 end;
if(_stop) then Status_timer.Enabled:=false;
end;

procedure Tmainform.check_status;
begin
if not(Status_timer.Enabled) then Status_timer.Enabled:=true;
end;

procedure Tmainform.FormMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
var xx,yy:integer;
begin
 if(_monitor=0) then begin
  xx:=bt.DIBWidth-btlogodesksoft.DIBWidth-sdvig_l;
  yy:=bt.DIBHeight-btlogodesksoft.DIBHeight-sdvig_b;
  if(InRect(x-spx,y-spy,xx,yy,xx+btlogodesksoft.DIBWidth,yy+btlogodesksoft.DIBHeight)) then Cursor:=100 else Cursor:=crDefault;
 end;
  if(GUI.GetCoord(x-spx,y-spy,bt)) then begin
    Draw_pole;
  end;
end;

procedure Tmainform.LoadSettings;
var _ini:Tinifile;
begin
 _ini:=TInifile.Create(direcuser+'config.txt');
  try
    default_settings.x:=_ini.ReadInteger('settings','x',-1);
    default_settings.y:=_ini.ReadInteger('settings','y',-1);
    default_settings.lang:=_ini.ReadBool('settings','lang',true);
    default_settings.use_icon:=_ini.ReadBool('settings','use_icon',true);
    default_settings.w:=_ini.ReadInteger('settings','w',10);
    default_settings.h:=_ini.ReadInteger('settings','h',15);
    default_settings.cou:=_ini.ReadInteger('settings','cou',3);
    default_settings.transparent:=_ini.ReadInteger('settings','x',255);
    if(default_settings.w<7) then default_settings.w:=7;
    if(default_settings.h<7) then default_settings.h:=7;
  finally
  _ini.Free;
 end;
end;

procedure Tmainform.SaveSettings;
var _ini:Tinifile;
begin
 _ini:=TInifile.Create(direcuser+'config.txt');
  try
   _ini.WriteBool('settings','lang',default_settings.lang);
   _ini.WriteBool('settings','use_icon',default_settings.use_icon);
   _ini.WriteInteger('settings','x',default_settings.x);
   _ini.WriteInteger('settings','y',default_settings.y);
   _ini.WriteInteger('settings','w',default_settings.w);
   _ini.WriteInteger('settings','h',default_settings.h);
   _ini.WriteInteger('settings','cou',default_settings.cou);
   _ini.WriteInteger('settings','transparent',default_settings.transparent);
  finally
  _ini.Free;
 end;
end;

procedure Tmainform.Re_place_coord;
var rWorkArea:Trect;
begin
  if(default_settings.x=-1)and(default_settings.y=-1) then begin
     SystemParametersInfo(SPI_GETWORKAREA, 0, @rWorkArea, 0);
     default_settings.x:=(rWorkArea.Right-rWorkArea.Left) div 2;
     default_settings.y:=(rWorkArea.Bottom-rWorkArea.Top) div 2;
  end;
  default_settings.xx:=default_settings.x-(BT_back.DIBWidth div 2)-spx;
  default_settings.yy:=default_settings.y-(BT_back.DIBHeight div 2)-spy;
  left:=default_settings.xx;
  top:=default_settings.yy;
end;

procedure Tmainform.Re_place_coord_back;
begin
  default_settings.xx:=left+spx;
  default_settings.yy:=top+spy;
  default_settings.x:=default_settings.xx+(BT_back.DIBWidth div 2);
  default_settings.y:=default_settings.yy+(BT_back.DIBHeight div 2);
end;

procedure Tmainform.Load_pictures(Filename:string);
var i:integer;
begin
if( not fileexists(filename)) then exit;
 PackListBitmapsIco.clear;
 PackListBitmapsIco.Load(Filename);
 ListIcons.clear;
 for i:=0 to PackListBitmapsIco.GetCountBitmaps-1 do begin
  ListIcons.Add_bitmap(PackListBitmapsIco.GetBitmap(i).Bitmap);
 end;
 PackListBitmapsIco.clear;
 Clear_ico;
end;

procedure Tmainform.Draw_ico;
begin
//вот такая костыляка ))))
//тут не учитывается, что иконка может быть шире самого поля
//будет тогда обрезаться
if( not default_settings.use_icon) then exit;

 if(IconChanger.ico1<>-1) then begin
  if(ListIcons.GetCountBitmaps>IconChanger.ico1) then
   ListIcons.GetBitmap(IconChanger.ico1).Bitmap.Draw_alpha_a(BT_bufferout,0,0);
 end;

 if(IconChanger.ico2<>-1) then begin
  if(ListIcons.GetCountBitmaps>IconChanger.ico2) then
   ListIcons.GetBitmap(IconChanger.ico2).Bitmap.Draw_alpha_a(BT_bufferout, BT_bufferout.DIBWidth-spw-spx  , trunc( BT_back.DIBHeight*0.4+spy)-(ListIcons.GetBitmap(IconChanger.ico2).Bitmap.DIBHeight div 2) );
 end;

 if(IconChanger.ico3<>-1) then begin
  if(ListIcons.GetCountBitmaps>IconChanger.ico3) then
   ListIcons.GetBitmap(IconChanger.ico3).Bitmap.Draw_alpha_a(BT_bufferout, trunc( BT_back.DIBWidth*0.26+spx)-(ListIcons.GetBitmap(IconChanger.ico3).Bitmap.DIBWidth div 2), BT_bufferout.DIBHeight-sph-spy );
 end;
 // BT_bufferout.savebitmap2file(direc+'3aaaa4.bmp'); //так, для дебага :)
 //дебуга-га-га %)
end;

procedure Tmainform.Reset_ico;
var cou:integer;
begin
 Clear_ico;
 spw:=0;
 sph:=0;
 spx:=0;
 spy:=0;
 if( not default_settings.use_icon) then exit;

 cou:=ListIcons.GetCountBitmaps;
 if(cou<>0) then begin
  if(cou<2) then begin
   IconChanger.ico1:=random(cou);
   spx:=trunc(ListIcons.GetBitmap(IconChanger.ico1).Bitmap.DIBWidth*0.4);
   spy:=trunc(ListIcons.GetBitmap(IconChanger.ico1).Bitmap.DIBHeight*0.4);

   spw:=0;
   sph:=0;
   end else
    if(cou<4) then begin
     IconChanger.ico1:=random(cou);
     IconChanger.ico2:=random(cou);
     spw:=trunc(ListIcons.GetBitmap(IconChanger.ico2).Bitmap.DIBWidth*0.7);
     sph:=0;
     IconChanger.ico2_t:=spw;
     spx:=trunc(ListIcons.GetBitmap(IconChanger.ico1).Bitmap.DIBWidth*0.4);
     spy:=trunc(ListIcons.GetBitmap(IconChanger.ico1).Bitmap.DIBHeight*0.4);
    end else begin
       
       IconChanger.ico1:=random(cou);
       IconChanger.ico2:=random(cou);
       IconChanger.ico3:=random(cou);

       spx:=trunc(ListIcons.GetBitmap(IconChanger.ico1).Bitmap.DIBWidth*0.4);
       spy:=trunc(ListIcons.GetBitmap(IconChanger.ico1).Bitmap.DIBHeight*0.4);

       spw:=trunc(ListIcons.GetBitmap(IconChanger.ico2).Bitmap.DIBWidth*0.7);
       IconChanger.ico2_t:=spw;

       sph:=trunc(ListIcons.GetBitmap(IconChanger.ico3).Bitmap.DIBHeight*0.7);
       IconChanger.ico3_t:=sph;
      end;
 end;
end;

procedure Tmainform.Clear_ico;
begin
 IconChanger.ico1:=-1;
 IconChanger.ico2:=-1;
 IconChanger.ico3:=-1;
 IconChanger.ico1_t:=-1;
 IconChanger.ico2_t:=-1;
 IconChanger.ico3_t:=-1;
 IconChanger.ico1_tr:=255;
 IconChanger.ico2_tr:=255;
 IconChanger.ico3_tr:=255;
end;

end.
