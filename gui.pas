unit gui;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,graff,tbitmap_28e;

const
  gui_button_w=128;
  gui_button_h=32;
  gui_button_space=8;

type
  TlangStrings = record
    score:string;
    victory:string;
    defeat:string;
  end;
  Tlanguage = record
    rus:TlangStrings;
    eng:TlangStrings;
  end;
  

  pButtons = ^TButtons;
  TButtons = record
   id,display:word;
   left,top,width,height:integer;
   caption:string;
   visible:boolean;
  end;

  TGFont = class
   private
    _sys_font:TBT;
    function _sys_font_coord(b:char):tpoint;
   public
    constructor Create;
    destructor Destroy; override;
    procedure _sys_font_draw(BTDest:TBT; x,y:integer; s:string);
    procedure Load_font(bt:tbitmap);
  end;

  TGButtons = class
   private
     FList:TList;
     Bback,Bmask:Tbitmap;
     Bfill,Bfilli:tbt;
     sd_l,sd_r,sd_t,sd_b:integer;
     procedure Draw_button(BT:tbt; GFont:TGFont; BB:pButtons; num,c:integer);
   public
     xb,yb:integer;
     current_butt:integer;
     constructor Create;
     destructor Destroy; override;
     procedure Add_button(display,id,l,t,w,h:integer);

     procedure Loadbuttons;

     procedure Draw_buttons(BT:tbt; GFont:TGFont; disp:integer);
     function Click_buttons(x,y,disp:integer; w,h:integer):integer;

     function SetXY(x,y,w,h:integer):integer;
     procedure Setskin(bt1,bt2,bt3:tbitmap);

     procedure Set_language(b:boolean);
     procedure Visible_butt(id:integer; vis:boolean);
  end;

  

  TGUI = class
   private
    current_butt:integer;
   public
    GButtons:TGButtons;
    GFont:TGFont;
    language:Tlanguage;
    constructor Create;
    destructor Destroy; override;

    function GetCoord(x,y:integer; bt:tbt):boolean;
    function GetClick(x,y:integer; bt:tbt):integer;
    function GetKey(Key: Word):integer;
    procedure Draw(BT:tbt);
  end;

  function InRect(x,y,left,top,right,down:double):boolean;
  function InRect2(x,y:double; r:trect):boolean;
  function PERSONAL:string;
  procedure createdir_f(dir:string);
  function NormalDir(const DirName: string): string;

implementation

uses main,ShlObj,ActiveX;

function InRect(x,y,left,top,right,down:double):boolean;
begin
if (x>left)and(x<right)and(y>top)and(y<down) then InRect:=true else InRect:=false;
end;

function InRect2(x,y:double; r:trect):boolean;
begin
if (x>r.Left)and(x<r.Right)and(y>r.Top)and(y<r.Bottom) then InRect2:=true else InRect2:=false;
end;

constructor TGButtons.Create;
begin
 inherited;
 FList:=TList.Create;
 Loadbuttons;
 xb:=0;
 yb:=0;
 Bback:=Tbitmap.Create;
 Bmask:=Tbitmap.Create;
 Bfill:=tbt.Create;
 Bfilli:=tbt.Create;
 sd_l:=16;
 sd_r:=16;
 sd_t:=16;
 sd_b:=16;
 current_butt:=-1;
end;

destructor TGButtons.Destroy;
var i:integer; Buttons:pButtons;
begin
  for i:=0 to FList.Count-1 do begin
   Buttons:=pButtons(FList.Items[i]);
   Dispose(Buttons);
  end;
  FList.Free;
  Bback.Free;
  Bmask.free;
  Bfill.Free;
  Bfilli.Free;
 inherited;
end;

procedure TGButtons.Add_button(display,id,l,t,w,h:integer);
var Buttons:pButtons;
begin
 New(Buttons);
 Buttons.id:=id;
 Buttons.display:=display;
 Buttons.left:=l;
 Buttons.top:=t;
 Buttons.width:=w;
 Buttons.height:=h;
 Buttons.caption:='';
 Buttons.visible:=true;
 Flist.Add(TObject(Buttons));
end;

procedure TGButtons.Loadbuttons;
begin
  Add_button(0,0,24,-1,gui_button_w,gui_button_h);
  Add_button(0,2,24,-1,gui_button_w,gui_button_h);
  Add_button(0,3,24,-1,gui_button_w,gui_button_h);
  Add_button(0,1,24,-1,gui_button_w,gui_button_h);

  Add_button(2,4,24,-1,gui_button_w,gui_button_h);
  Add_button(2,5,24,-1,gui_button_w,gui_button_h);

  Add_button(3,6,24,-1,gui_button_w,gui_button_h);
  Add_button(3,7,24,-1,gui_button_w,gui_button_h);
  Set_language(false);
end;

procedure TGButtons.Set_language(b:boolean);
var Buttons:pButtons; i:integer;
begin
 //мда, глупая реализация, ну да ладно :)
 for i:=0 to FList.Count-1 do begin
   Buttons:=pButtons(FList.Items[i]);
   if(b) then begin
    case Buttons.id of
     0: Buttons.caption:='New game';
     2: Buttons.caption:='Resume';
     1: Buttons.caption:='Exit';
     3: Buttons.caption:='Settings';

     4: Buttons.caption:='New game';
     5: Buttons.caption:='Back';
     6: Buttons.caption:='New game';
     7: Buttons.caption:='back';
    end;
   end else begin
    case Buttons.id of
     0: Buttons.caption:='Новая игра';
     2: Buttons.caption:='Продолжить';
     1: Buttons.caption:='Выход';
     3: Buttons.caption:='Настройки';
     4: Buttons.caption:='Еще раз';
     5: Buttons.caption:='В меню';
     6: Buttons.caption:='Еще раз';
     7: Buttons.caption:='В меню';
    end;
   end;
 end;
end;

function TGButtons.SetXY(x,y,w,h:integer):integer;
var Buttons:pButtons; i,num,numc,xx,yy:integer;
begin
 xb:=x;
 yb:=y;
 result:=-1;
 num:=0;
 for i:=0 to FList.Count-1 do
  if(pButtons(FList.Items[i]).display=_monitor)and(pButtons(FList.Items[i]).top=-1)and(pButtons(FList.Items[i]).visible) then
    inc(num);
 numc:=num;

 for i:=0 to FList.Count-1 do begin
   Buttons:=pButtons(FList.Items[i]);
   if(Buttons.display=_monitor)and(Buttons.visible) then
    if(Buttons.top=-1) then begin
      xx:=(w-Buttons.width) div 2;
      yy:=((h-(numc*Buttons.height+(numc-1)*gui_button_space)) div 2)+(numc-num)*Buttons.height+(numc-num)*gui_button_space;
      if(InRect(x,y,xx,yy,xx+Buttons.width,yy+Buttons.height)) then result:=Buttons.id;
      dec(num);
    end else
      if(InRect(x,y,Buttons.left,Buttons.top,Buttons.left+Buttons.width,Buttons.top+Buttons.height)) then result:=Buttons.id;
 end;

end;

procedure TGButtons.Visible_butt(id:integer; vis:boolean);
var Buttons:pButtons; i:integer;
begin
  for i:=0 to FList.Count-1 do begin
   Buttons:=pButtons(FList.Items[i]);
   if(Buttons.id=id) then begin
    Buttons.visible:=vis;
    exit;
   end;
  end;
end;

procedure TGButtons.Setskin(bt1,bt2,bt3:tbitmap);
begin
  Copy32assing(bt1,Bback);
  Copy32assing(bt3,Bmask);
//  Bback.LoadFromFile(direc+'but_l.bmp');
//  Bmask.LoadFromFile(direc+'but_m.bmp');
  Bback.PixelFormat:=pf24bit;
  Bmask.PixelFormat:=pf24bit;
  bfill.set_widthheight(gui_button_w,gui_button_h);
  CopyRectIco_rect(Bback,Bmask,Bfill,16,16,16,16);

  Copy32assing(bt2,Bback);
//  Bback.LoadFromFile(direc+'but_ll.bmp');
  Bback.PixelFormat:=pf24bit;
  bfilli.set_widthheight(gui_button_w,gui_button_h);
  CopyRectIco_rect(Bback,Bmask,Bfilli,16,16,16,16);
 // bfill.SaveToFile(direc+'sd.bmp');
end;

procedure TGButtons.Draw_button(BT:tbt; GFont:TGFont; BB:pButtons; num,c:integer);
var xx,yy:integer;
begin
{if(InRect(xb,yb,BB.left,BB.top,BB.left+BB.width,BB.top+BB.height)) then begin
canvas.Pen.Color:=clsilver;
_Cursor_curent:=1;
end else
canvas.Pen.Color:=clgray;   }

{canvas.Brush.Color:=clgray;

canvas.Rectangle( bb.left,bb.top,bb.left+bb.width,bb.top+bb.height );
 xx:=canvas.TextWidth(bb.caption);
 yy:=canvas.TextHeight(bb.caption);
canvas.TextOut( bb.left+( (bb.width-xx) div 2 ), bb.top +((bb.height-yy) div 2), bb.caption );
   }

 if(bb.top=-1)and(c>0) then begin
  yy:=((bt.DIBHeight-(c*bb.height+(c-1)*gui_button_space)) div 2)+(c-num)*bb.height+(c-num)*gui_button_space;
   xx:=(bt.DIBWidth-bb.width) div 2;
 // CopyBitmapAlfa32to32(Bfill,bt, (bt.Width-bb.width) div 2 ,yy);
  if(current_butt=bb.id) then
    Bfilli.Draw_alpha_a(bt, xx ,yy)
  else
    Bfill.Draw_alpha_a(bt, xx ,yy);

   yy:=yy+((bb.height-7) div 2);
   xx:=xx+((bb.width-length(bb.caption)*7) div 2);


   GFont._sys_font_draw(bt,xx ,yy,bb.caption);

 end else begin
  if(current_butt=bb.id) then
   Bfilli.Draw_alpha_a(bt,bb.left,bb.top)
  else
   Bfill.Draw_alpha_a(bt,bb.left,bb.top);

 end;
 //CopyBitmapAlfa32to32(Bfill,bt,bb.left,bb.top);
end;

procedure TGButtons.Draw_buttons(BT:tbt; GFont:TGFont; disp:integer);
var Buttons:pButtons; i,num,numc:integer;
begin
 num:=0;
 for i:=0 to FList.Count-1 do
  if(pButtons(FList.Items[i]).display=disp)and(pButtons(FList.Items[i]).top=-1)and(pButtons(FList.Items[i]).visible) then
    inc(num);
 numc:=num;

 for i:=0 to FList.Count-1 do begin
   Buttons:=pButtons(FList.Items[i]);
   if(Buttons.display=disp)and(Buttons.visible) then begin
      Draw_button(bt,GFont,Buttons,num,numc);
     if(Buttons.top=-1) then
      dec(num);
   end;
 end;
end;

function TGButtons.Click_buttons(x,y,disp:integer; w,h:integer):integer;
var Buttons:pButtons; i,num,numc,xx,yy:integer;
begin
 result:=-1;
 num:=0;
 for i:=0 to FList.Count-1 do
  if(pButtons(FList.Items[i]).display=disp)and(pButtons(FList.Items[i]).top=-1)and(pButtons(FList.Items[i]).visible) then
    inc(num);
 numc:=num;

 for i:=0 to FList.Count-1 do begin
   Buttons:=pButtons(FList.Items[i]);
   if(Buttons.display=disp)and(Buttons.visible) then
    if(Buttons.top=-1) then begin
      xx:=(w-Buttons.width) div 2;
      yy:=((h-(numc*Buttons.height+(numc-1)*gui_button_space)) div 2)+(numc-num)*Buttons.height+(numc-num)*gui_button_space;
      if(InRect(x,y,xx,yy,xx+Buttons.width,yy+Buttons.height)) then result:=Buttons.id;
      dec(num);
    end else
      if(InRect(x,y,Buttons.left,Buttons.top,Buttons.left+Buttons.width,Buttons.top+Buttons.height)) then result:=Buttons.id;
 end;
end;

constructor TGUI.Create;
begin
 inherited;
 GButtons:=TGButtons.Create;
 GFont:=TGFont.Create;
 current_butt:=-1;

 language.rus.score:='очков';
 language.eng.score:='scores';

 language.rus.victory:='победа!';
 language.eng.victory:='victory!';

 language.rus.defeat:='поражение...';
 language.eng.defeat:='defeat...';
end;

destructor TGUI.Destroy;
begin
 GButtons.Free;
 GFont.Free;
 inherited;
end;

function TGUI.GetCoord(x,y:integer; bt:tbt):boolean;
var i:integer;
begin
i:=GButtons.SetXY(x,y,bt.DIBWidth,bt.DIBHeight);
if(current_butt<>i) then result:=true else result:=false;
current_butt:=i;
GButtons.current_butt:=i;
end;

function TGUI.GetClick(x,y:integer; bt:tbt):integer;
var ii:integer;
begin
 //муа-ха-ха, вот еще бред сумасшедшего )))
 result:=-1;
 ii:=GButtons.Click_buttons(x,y,_monitor,bt.DIBWidth,bt.DIBHeight);
 case ii of
   0: begin
     result:=0;
   end;
   1: begin
     result:=1;
   end;
   2: begin
     result:=2;
   end;
   3: result:=3;
   4: result:=4;
   5: result:=5;
   6: result:=6;
   7: result:=7;
 end;
end;

function TGUI.GetKey(Key: Word):integer;
begin
 result:=-1;
 case _monitor of
  1: begin
    case key of
         VK_ESCAPE: begin
                 result:=2;
         end;
    end;

  end;

 end;
end;

procedure TGUI.Draw(BT:tbt);
begin
 GButtons.Draw_buttons(bt,GFont,_monitor);
end;

constructor TGFont.Create;
begin
 inherited;
 _sys_font:=tbt.Create;
 //_sys_font.Loadbitmap2file( extractfilepath( application.ExeName ) + '_system_font.bmp' );
end;

destructor TGFont.Destroy;
begin
 _sys_font.Free;
 inherited;
end;

procedure TGFont.Load_font(bt:tbitmap);
begin
 _sys_font.load_from_bitmap(bt);
end;

function TGFont._sys_font_coord(b:char):tpoint;
var c:byte;
begin
c:=ord(b);
result.Y:=21;
result.X:=0;
if (c>47)and(c<58) then begin result.X:=(c-48)*7; result.Y:=14; exit; end;
if b=' ' then begin result.X:=0;result.Y:=21; exit; end;
if (c>64)and(c<91) then begin result.X:=(c-65)*7; result.Y:=0; exit; end;
if (c>191)and(c<224) then begin result.X:=(c-192)*7; result.Y:=7; exit; end;
if b=':' then result.X:=7 else
if b='/' then result.X:=14 else
if b='_' then result.X:=21 else
if b='(' then result.X:=28 else
if b=')' then result.X:=35 else
if b='-' then result.X:=42 else
if b='!' then result.X:=49 else
if b='+' then result.X:=56 else
if b='[' then result.X:=63 else
if b=']' then result.X:=70 else
if b='^' then result.X:=77 else
if b='&' then result.X:=84 else
if b='%' then result.X:=91 else
if b=',' then result.X:=98 else
if b='=' then result.X:=105 else
if b='$' then result.X:=112 else
if b='?' then result.X:=119 else
if b='#' then result.X:=126 else
if b='`' then result.X:=133 else
if b='"' then result.X:=140 else
if b=';' then result.X:=147 else
if b='~' then result.X:=154 else
if b='{' then result.X:=161 else
if b='}' then result.X:=168 else
if b='<' then result.X:=175 else
if b='>' then result.X:=182 else
if b='|' then result.X:=189 else
if b='*' then result.X:=196 else
if b='.' then result.X:=203 else
if b='\' then result.X:=210;
end;

procedure TGFont._sys_font_draw(BTDest:TBT; x,y:integer; s:string);
var i:integer; pp:tpoint;
begin
 s:=ansiuppercase(s);

 for i:=1 to length(s) do begin
  pp:=_sys_font_coord(s[i]);
  _sys_font.Draw_transcolor_rect( BTDest,x+(i-1)*7,y,pp.X,pp.Y,7,7,clFuchsia);
 end;
end;

function SpecialDir(Spec:integer):string;
var Allocator: IMalloc;
  SpecialDir: PItemIdList;
  FBuf: array[0..MAX_PATH] of Char;
begin
  if SHGetMalloc(Allocator) = NOERROR then
  begin
    SHGetSpecialFolderLocation(application.Handle,  spec , SpecialDir);
    SHGetPathFromIDList(SpecialDir, @FBuf[0]);
    Allocator.Free(SpecialDir);
    result:=string(FBuf);
  end;
end;

function PERSONAL:string;
begin
result:=SpecialDir(CSIDL_APPDATA);
end;


function NormalDir(const DirName: string): string;
begin
  Result:=DirName;
  if (Result<>'') and not (Result[Length(Result)] in [':','\']) then begin
    if (Length(Result)=1)and(UpCase(Result[1])in['A'..'Z']) then
      Result:=Result+':\'
    else Result:=Result+'\';
  end;
end;

procedure createdir_f(dir:string);
begin
if not(DirectoryExists(dir)) then
  CreateDir(dir);
end;

end.
