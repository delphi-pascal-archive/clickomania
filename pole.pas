unit pole;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,graff,tbitmap_28e,PackList_Bitmaps, gfx;

const
  MaxBTCount = MaxInt div SizeOf(dword);
  count_card=12;
  FloodFillBuffer = 4096;
  FloodFillDoubleLimit = 65536; //гребаный стек, переполнялся, сволочь))))
                                //пусть ужрется своими 16ю битами ))))

type
  TPESave = record
    sig:dword;
    w,h:byte;
  end;

  BPolelement = dword;  //ух, как я обожаю дворд, всегда выровнен по 4м байтам %))
  TPoleArray = array[0..MaxBTCount-1] of BPolelement;

  TStatus = record
   score:integer;
   wind:integer;
   status:integer; //0 - игра, 1-поражение, 2-победа
  end;

  TPole = class
   private
    
    animate:integer;
    procedure setarrays(x,y:integer);
    procedure FillZero;
    function Fill(x,y:integer; fillcol,edgecol:TColor; GFX_effect:TGFX_effect):integer;
    procedure Move_down;
    function Move_down_field(num,pos:integer):integer;
    
    function Check_point(x,y:integer):boolean;
   public
    Width     : integer;
    Height    : integer;
    Size      : integer;
    element_w,element_h:integer;
    P:^TPoleArray;

    PackListBitmapsTmp:TPackListBitmaps;
    PackListBitmaps:TPackListTBT;
    status:TStatus;
    constructor Create;
    destructor Destroy; override;
    procedure set_widthheight(w,h:integer);
    procedure Draw(bt:tbt);
    procedure Generate(Color_count:integer);

    procedure Click(x,y:integer; GFX_effect:TGFX_effect);

    procedure Animate_end;
    procedure Animate_start;
    function Animate_tick:integer;


    procedure SaveToFile(Filename:string);
    procedure LoadToFile(Filename:string);

    function Check_end_game:integer;
    procedure Load_pictures(Filename:string);
  end;

   function Get_color(b:dword):tcolor;
   function Set_color(a:dword; b:byte):dword;
   
   function Get_pos_X(b:dword):dword;
   function Set_pos_X(a:dword; b:byte):dword;
   function Get_pos_Y(b:dword):dword;
   function Set_pos_Y(a:dword; b:byte):dword;

implementation

uses main;

constructor TPole.Create;
begin
 inherited;
 Width:=0;
 Height:=0;
 status.score:=0;
 status.wind:=0;
 status.status:=0;
 animate:=-1;
 element_w:=16;
 element_h:=16;
 PackListBitmapsTmp:=TPackListBitmaps.Create;
 PackListBitmaps:=TPackListTBT.Create;

 Load_pictures(direc+'points_default.28e'); //читать в самом низу
end;

destructor TPole.Destroy;
begin
 PackListBitmaps.Free;
 FreeMem(P, Width*Height*SizeOf(BPolelement));
 inherited;
end;

procedure TPole.setarrays(x,y:integer);
begin
 FreeMem(P, Width*Height*SizeOf(BPolelement));
 Width:=x;
 Height:=y;
 Size:=Width*SizeOf(BPolelement);
 P:=AllocMem(Width*Height * SizeOf(BPolelement));
 FillZero;
end;

procedure TPole.FillZero;
begin
 fillchar(P^, Width*Height * SizeOf(BPolelement), 0);
end;

procedure TPole.set_widthheight(w,h:integer);
begin
 setarrays(w,h);
end;

//да, вот что значит неверное проектирование в начале! :)
//приходится делать костыли и разбирать dword по байтам раздельно
function Get_color(b:dword):tcolor;
begin
result:=byte(b);
end;

function Set_color(a:dword; b:byte):dword;
var i,ii,iii:byte;
begin
i:=a shr 8;
ii:=a shr 16;
iii:=a shr 24;
//не ржать! ))))
result:=b or (i shl 8) or (ii shl 16) or (iii shl 24);
end;

function Get_pos_X(b:dword):dword;
begin
result:=byte(b shr 8);
end;

function Set_pos_X(a:dword; b:byte):dword;
var i,ii,iii:byte;
begin
i:=byte(a);
ii:=a shr 16;
iii:=a shr 24;
result:=i or (b shl 8) or (ii shl 16) or (iii shl 24);
end;

function Get_pos_Y(b:dword):dword;
begin
result:=byte(b shr 16);
end;

function Set_pos_Y(a:dword; b:byte):dword;
var i,ii,iii:byte;
begin
i:=byte(a);
ii:=a shr 8;
iii:=a shr 24;
result:=i or (ii shl 8) or (b shl 16)  or (iii shl 24);
end;

procedure TPole.Draw(bt:tbt);
var ww,hh,i,ii,xx,yy,xxt,yyt,xd,yd,col:integer;
begin
 ww:=element_w;
 hh:=element_h;

 for i:=0 to Width-1 do
  for ii:=0 to Height-1 do begin
   xx:=Get_pos_X(P^[(ii*Width)+i]);
   yy:=Get_pos_y(P^[(ii*Width)+i]);

   if(xx=0)and(yy=0) then begin
     col:= Get_color(P^[(ii*Width)+i]) ;
     if(col<>0) then
       PackListBitmaps.GetBitmap(col).Bitmap.Draw_alpha_a(bt,i*ww,ii*hh);

   end else begin
     xxt:=xx; yyt:=yy;
     if(xx=0) then xx:=i else xx:=xx-1;
     if(yy=0) then yy:=ii else yy:=yy-1;
     xd:=xx*ww;
     yd:=yy*hh;

     if(animate<>-1) then begin
      if(xxt<>0) then
      xd:=xx*ww+trunc((i-xx)*ww*(animate/count_card));
      if(yyt<>0) then
      yd:=yy*hh+trunc((ii-yy)*hh*(animate/count_card));
     end;
      col:= Get_color(P^[(ii*Width)+i]) ;
    if(col<>0) then
      PackListBitmaps.GetBitmap(col).Bitmap.Draw_alpha_a(bt,xd,yd);
   end;
  end;
end;

procedure TPole.Generate(Color_count:integer);
var i,ii:integer;
begin
  if(animate<>-1) then exit;

  randomize;
  for i:=0 to Width-1 do
  for ii:=0 to Height-1 do
    P^[(ii*Width)+i]:=1+random(Color_count);
  //ладно, не будет тут генератора выигрышной стратегии
  //будет все случайно :)

  status.status:=0;
  status.score:=0;
end;

procedure TPole.Click(x,y:integer; GFX_effect:TGFX_effect);
var ww,hh,i,ii,iii:integer;
begin
 if(animate<>-1) then exit;

 ww:=element_w;
 hh:=element_h;

 i:=x div ww;
 ii:=y div hh;
 if(i<Width) and (i>=0) and (ii<height) and (ii>=0) and (status.status=0) then begin
   if(Check_point(i,ii)) then begin
    iii:=Get_color(P^[(ii*Width)+i]);
    Fill(i,ii,0,iii,GFX_effect);
    Move_down;
    Animate_start;
    Check_end_game;
   end;
 end;
end;

function TPole.Fill(x,y:integer; fillcol,edgecol:TColor; GFX_effect:TGFX_effect):integer;
var buf: packed array of tsmallpoint;
  pp, pbase: pointer;
  xl, xr, pcount, incr, w, h,jj: integer;
  rgbedgecol, color: TColor;

  procedure add_point(x,y:integer);
  var color: integer;
  begin
    if (y<0) or (y>=h) then exit;
    if (x<0) or (x>=w) then exit;

    color:= dword( pointer( dword(@P^[0])+y*incr+x*4)^) and $FFFFFF;
    color:=Get_color(color);
    if color=fillcol then exit;
    if integer(color)<>rgbedgecol then exit;
    if pcount=length(buf)-1 then begin
        if length( buf)<floodfilldoublelimit then
          setlength(buf,length(buf)+floodfilldoublelimit)
        else
          setlength(buf,length(buf)*2);
     end;
    buf[pcount].x:=x;
    buf[pcount].y:=y;
    inc(pcount);
  end;
begin
  result:=-1;
  w:=width;
  h:=height;
  if(x<0)or(y<0)or(x>=w)or(y>=h) then exit; // "на всякий случай" (с) ыыыы )))
  result:=0;

  //messagedlg(inttostr(x),mterror,[mbOK],0);

  initialize(buf);
  setlength(buf,floodfillbuffer);
  pcount:=1;
  buf[pcount-1].x:=x;
  buf[pcount-1].y:=y;
  incr:=size;
  rgbedgecol:=edgecol and $FFFFFF;
  fillcol:=fillcol and $FFFFFF;

  repeat
    //ненавижу такие циклы, чтоб их...
    x:=buf[0].x;
    y:=buf[0].y;
    pbase:= pointer(dword(@P^[0])+incr*y+x*4);
    xl:=x;
    pp:=pbase;

     //вспышка слева...
     repeat
       color:=dword( pp^) and $FFFFFF;
       color:=Get_color(color);
       if color=fillcol then break;
       if(rgbedgecol=color) then begin
         dec(xl);
         if xl<0 then break;
         dec(integer(pp),4);
      end else break;
     until false;

      //вспышка справа...
       pp:=pointer(dword( pbase)+4);
       xr:=x+1;
         repeat
          color:= dword(pp^) and $FFFFFF;
          color:=Get_color(color);
          if color=fillcol then break;
           if color=rgbedgecol then begin
             inc(xr);
             if ((xr)>w-1) then break;
             inc(integer(pp),4);
        end else break;
       until false;

       //Умри, неверная!
        if pcount>1 then buf[0]:= buf[pcount-1];
          dec(pcount);

        if(xl<>x)or(xr<>x) then begin
            inc(xl);
            dec(xr);
            inc(result,xr-xl+1);
            jj:=0;
             for x:=xl to xr do 
               if(x>=0)and(x<width)and(y>=0)and(y<height) then begin
                if(Get_color(P^[y*width+x])=rgbedgecol) then
                  // Get_color(P^[y*width+x]):=fillcol;
                   P^[y*width+x]:=set_color(P^[y*width+x],fillcol);
                   GFX_effect.SetPointGFX((x)*element_w+(element_w div 2),(y)*element_h+(element_h div 2),1);
                   inc(jj);
               end;
            status.score:=status.score+trunc(jj*1.3);

                 //тише, Танечка, не плачь, купим тебе новый мяч! )))
                for x:=xl to xr do begin
                    add_point( x, y-1); // удар выше
                    add_point( x, y+1); // удар ниже
                 end;
       end;

        if pcount=0 then break; //Танечка уже не дышит...

        until false; //так ей и надо )))
        
  finalize(buf);
  //классное слово - финализе... :)
end;

function TPole.Move_down_field(num,pos:integer):integer;
var i,iii:integer;
begin
 result:=-1;
 iii:=height-1;
 for i:=height-1 downto 0 do begin
  if(Get_color(P^[i*width+num])<>0)then begin
   P^[iii*width+num]:=P^[i*width+num];
     if(iii<>i) then
        P^[iii*width+num]:=set_pos_Y(P^[i*width+num],i+1);
   dec(iii);
  end;
 end;
 for i:=iii downto 0 do
  P^[i*width+num]:=0;
end;

procedure TPole.Move_down;
var i,ii,iii:integer; b:boolean;
begin
  for i:=0 to Width-1 do
   Move_down_field(i,width);

  iii:=0;
  b:=false;
  for i:=0 to Width-1 do begin
    b:=true;
    for ii:=0 to height-1 do begin
     if(Get_color(P^[ii*width+i])<>0) then b:=false;
    end;
    if not(b) then begin
      iii:=iii+1;
    end;
    if not(b) then begin
      for ii:=0 to height-1 do
       if(iii-1<>i) then begin
       P^[ii*width+iii-1]:=P^[ii*width+i];
       P^[ii*width+iii-1]:=set_pos_X(P^[ii*width+iii-1],i+1);
      end;
    end;
  end;
  if(iii<>0) then
   for i:=Width-1 downto iii do
     for ii:=0 to height-1 do
      P^[ii*width+i]:=0;
end;

function TPole.Check_end_game:integer;
var i,ii:integer; b:boolean;
begin
 result:=0; b:=false;  status.status:=1;
 for i:=0 to Width-1 do begin
  for ii:=0 to height-1 do begin
    if Get_color(P^[ii*Width+i])<>0 then b:=true;
    if(ii<height-1) then begin
      if(Get_color(P^[ii*Width+i])=Get_color(P^[(ii+1)*Width+i]))and(Get_color(P^[ii*Width+i])<>0) then begin
        status.status:=0;
        exit;
      end;
    end;
  end;
 end;
 for ii:=0 to height-1 do begin
  for i:=0 to Width-1 do begin
    if(i<Width-1) then begin
      if(Get_color(P^[ii*Width+i])=Get_color(P^[ii*Width+i+1]))and(Get_color(P^[ii*Width+i])<>0) then begin
        status.status:=0;
        exit;
      end;
    end;
  end;
 end;
 if not(b) then status.status:=2;
end;

function TPole.Check_point(x,y:integer):boolean;
begin
 result:=false;
 if(x>0)then
  if(Get_color(P^[y*width+x-1])=Get_color(P^[y*width+x]))and(Get_color(P^[y*width+x])<>0) then begin
    result:=true;
    exit;
 end;
 if(x<width-1)then
  if(Get_color(P^[y*width+x+1])=Get_color(P^[y*width+x]))and(Get_color(P^[y*width+x])<>0) then begin
    result:=true;
    exit;
 end;
 if(y>0)then
  if(Get_color(P^[(y-1)*width+x])=Get_color(P^[y*width+x]))and(Get_color(P^[y*width+x])<>0) then begin
    result:=true;
    exit;
 end;
 if(y<height-1)then
  if(Get_color(P^[(y+1)*width+x])=Get_color(P^[y*width+x]))and(Get_color(P^[y*width+x])<>0) then begin
    result:=true;
    exit;
 end;
end;


procedure TPole.Animate_end;
var i,ii:integer;
begin
   for i:=Width-1 downto 0 do
     for ii:=0 to height-1 do begin
      P^[ii*width+i]:=Set_pos_x(P^[ii*width+i],0);
      P^[ii*width+i]:=Set_pos_y(P^[ii*width+i],0);
     end;
  animate:=-1;
end;

function TPole.Animate_tick:integer;
begin
 result:=-1;
 if(animate<>-1) then begin
  //к чему бы это? :)
 end else exit;

  inc(animate);
  if(animate>count_card) then Animate_end;
  result:=1;
end;

procedure TPole.Animate_start;
begin
  animate:=0;
end;

procedure TPole.SaveToFile(Filename:string);
var MIn: TMemoryStream; PE:TPESave;
    i:integer;
begin
   MIn := TMemoryStream.Create;
   Try
    PE.sig:=1296257860; //сигнатуре, в натуре :)
    PE.w:=Width;
    PE.h:=height;
    min.Write(PE,sizeof(PE));
  for i:=0 to Width*Height-1 do
    min.Write( P^[i] ,sizeof(dword));

  MIn.SaveToFile(Filename);
   finally
     MIn.Free;
   end;
end;

procedure TPole.LoadToFile(Filename:string);
var MIn: TMemoryStream; PE:TPESave;
    i:integer;   _countS:integer; d:dword;
begin
 if not(fileexists(Filename)) then exit;
   MIn := TMemoryStream.Create;
   Try
    MIn.LoadFromFile(Filename);
    _countS:=((min.Size-sizeof(PE)) div sizeof(dword));
    min.Position:=0;
    min.Read(PE,sizeof(PE));
    if(pe.sig=1296257860) then begin
      set_widthheight(pe.w,pe.h);
      for i:=0 to _countS-1 do begin
        min.Position:=sizeof(dword)*i+sizeof(PE);
        min.Read(d,sizeof(dword));
        P^[i]:=d;
      end;
    end;
   finally
     MIn.Free;
   end;
end;

procedure TPole.Load_pictures(Filename:string);
begin
if( not fileexists(filename)) then exit;
 //загрузка ресурса, упакованного, в своем формате.
 PackListBitmapsTmp.clear;
 PackListBitmapsTmp.Load(Filename);
 if(PackListBitmapsTmp.GetCountBitmaps<>8) then exit;
 {
 Так как ресурсы поставляются сжатыми, то вот пример как они упаковывались:
 PackListBitmapsTmp.Add_bitmap_from_file(direc+'bmp\crisss_5.bmp');
 PackListBitmapsTmp.Add_bitmap_from_file(direc+'bmp\crisss_5.bmp');
 PackListBitmapsTmp.Add_bitmap_from_file(direc+'bmp\crisss_2.bmp');
 PackListBitmapsTmp.Add_bitmap_from_file(direc+'bmp\crisss_6.bmp');
 PackListBitmapsTmp.Add_bitmap_from_file(direc+'bmp\crisss_0.bmp');
 PackListBitmapsTmp.Add_bitmap_from_file(direc+'bmp\crisss_3.bmp');
 PackListBitmapsTmp.Add_bitmap_from_file(direc+'bmp\crisss_4.bmp');
 PackListBitmapsTmp.Add_bitmap_from_file(direc+'bmp\crisss_1.bmp');
 PackListBitmapsTmp.Save(direc+'points_default.28');

 для распаковки (ну, например, чтобы потырить иконки:)) можно воспользоваться
 PackListBitmapsTmp.GetBitmap().Bitmap.SaveToFile();
 всего иконок на поле 7 штук. до семи штук.
 }

 PackListBitmaps.clear;
 PackListBitmaps.Add_bitmap(PackListBitmapsTmp.GetBitmap(0).Bitmap);
 PackListBitmaps.Add_bitmap(PackListBitmapsTmp.GetBitmap(1).Bitmap);
 PackListBitmaps.Add_bitmap(PackListBitmapsTmp.GetBitmap(2).Bitmap);
 PackListBitmaps.Add_bitmap(PackListBitmapsTmp.GetBitmap(3).Bitmap);
 PackListBitmaps.Add_bitmap(PackListBitmapsTmp.GetBitmap(4).Bitmap);
 PackListBitmaps.Add_bitmap(PackListBitmapsTmp.GetBitmap(5).Bitmap);
 PackListBitmaps.Add_bitmap(PackListBitmapsTmp.GetBitmap(6).Bitmap);
 PackListBitmaps.Add_bitmap(PackListBitmapsTmp.GetBitmap(7).Bitmap);
 //но добавляем здесь на одеу больше. Я где то забыл перепроверку сделать,
 //и картинки рисуются +1 в списке :)
 //точнее не +1, а номер в массиве, а 0й номер - отсутствие элемента

 element_w:=PackListBitmapsTmp.GetBitmap(0).Bitmap.Width;
 element_h:=PackListBitmapsTmp.GetBitmap(0).Bitmap.Height;

 PackListBitmapsTmp.clear; //разгрузим немножко памяти :)
end;


end.
