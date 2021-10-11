{******************************************************}
{                                                      }
{    Copyright © 2007, Naumenko Anton Aka antonn.      }
{                     v 1.0                            }
{                   06.01.2008                         }
{                                                      }
{                                                      }
{******************************************************}
unit gfx;

interface

uses
  Windows,Classes,Graphics,sysutils,PackList_Bitmaps,graff,tbitmap_28e,graff_asm;

type
  pGFX_effectE = ^TGFX_effectE;
  TGFX_effectE = record
   ty:integer;
   x,y:double;
   timer:integer;
   max_timer:integer;
   angle:double;
   speed:double;
  end;

  TGFX_effect = class
  private
   FList:TList;
   btgfx:tbitmap;
   PackListBitmaps:TPackListTBT;
   PackListBitmapsIco:TPackListBitmaps;
  protected
  public
   constructor Create;
   destructor Destroy; override;

   procedure Add_E(x,y,ty:integer);

   procedure clear;
   function GetCountE:integer;
   function GetE(num:integer):pGFX_effectE;

   procedure Delete_E(num:integer);

   function Timer:integer;
   procedure Draw(bt:TBT; sx,sy:integer);
   procedure SetPointGFX(x,y,ty:integer);
  end;

implementation

uses main;

constructor TGFX_effect.Create;
var i:integer;
begin
 inherited;
  FList:=TList.Create;

  PackListBitmapsIco:=TPackListBitmaps.Create;
  PackListBitmapsIco.Load(direc+'gfx.28e');
  PackListBitmaps:=TPackListTBT.Create;
  for i:=0 to PackListBitmapsIco.GetCountBitmaps-1 do
    PackListBitmaps.Add_bitmap(PackListBitmapsIco.GetBitmap(i).Bitmap);
  PackListBitmapsIco.clear;

  {PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfx_1.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfx_2.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfx_3.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfx_4.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfx_5.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfx_6.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfx_7.bmp');

  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfxs_1.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfxs_2.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfxs_3.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfxs_4.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfxs_5.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfxs_6.bmp');
  PackListBitmapsIco.Add_bitmap_from_file(direc+'gfx/_gfxs_7.bmp');
  PackListBitmapsIco.Save(direc+'gfx.28e');   }


  for i:=0 to 50-1 do
   Add_E(0,0,-1);
end;

destructor TGFX_effect.Destroy;
var i:integer; Cadr:pGFX_effectE;
begin
  for i:=0 to FList.Count-1 do begin
   Cadr:=pGFX_effectE(FList.Items[i]);
   Dispose(Cadr);
  end;
  btgfx.Free;
  FList.Free;
  PackListBitmaps.Free;
 inherited;
end;

procedure TGFX_effect.Add_E(x,y,ty:integer);
var Cadr:pGFX_effectE;
begin
 New(Cadr);
 Cadr.ty:=ty;
 cadr.x:=x;
 cadr.y:=y;
 cadr.timer:=0;
 cadr.max_timer:=21;
 cadr.angle:=(random(314)/314)*pi*2;
 cadr.speed:=0.7;
 Flist.Add(TObject(Cadr));
end;

procedure TGFX_effect.Delete_E(num:integer);
var Cadr:pGFX_effectE;
begin
if num>=FList.Count then exit;
 Cadr:= pGFX_effectE(FList.Items[num]);
 Dispose(Cadr);
 FList.Delete(num);
end;

procedure TGFX_effect.clear;
var Cadr:pGFX_effectE; i:integer;
begin
 for i:=FList.Count-1 downto 0 do begin
   Cadr:=pGFX_effectE(FList.Items[i]);
   Dispose(Cadr);
   FList.Delete(i);
 end;
end;

function TGFX_effect.GetCountE:integer;
begin
 result:=FList.Count;
end;

function TGFX_effect.GetE(num:integer):pGFX_effectE;
begin
 result:=pGFX_effectE(FList.Items[num]);
end;

function TGFX_effect.Timer:integer;
var Cadr:pGFX_effectE; i:integer;
begin
 result:=-1;
 for i:=FList.Count-1 downto 0 do begin
   Cadr:=pGFX_effectE(FList.Items[i]);
   if(cadr.ty<>-1) then begin
     cadr.x:=cadr.x+cos(cadr.angle)*cadr.speed;
     cadr.y:=cadr.y+sin(cadr.angle)*cadr.speed;
     inc(cadr.timer);
     if(cadr.timer>cadr.max_timer) then cadr.ty:=-1;
    result:=1;
   end;
 end;
end;


procedure TGFX_effect.Draw(bt:TBT; sx,sy:integer);
var Cadr:pGFX_effectE; i,num,xx,yy:integer;
begin
 for i:=FList.Count-1 downto 0 do begin
   Cadr:=pGFX_effectE(FList.Items[i]);
   if(cadr.ty<>-1) then begin
     num:=(cadr.timer div 3);
     num:=num-1;
     if num>6 then num:=6 else if(num<0) then num:=0;

     num:=cadr.ty*num;
     if(num>FList.Count-1) then num:=FList.Count-1;

     xx:=trunc(cadr.x)-(PackListBitmaps.GetBitmap(num).Bitmap.DIBWidth div 2);
     yy:=trunc(cadr.y)-(PackListBitmaps.GetBitmap(num).Bitmap.DIBHeight div 2);

    // GD_Draw_alpha_MMX(PackListBitmaps.GetBitmap(num).Bitmap ,bt, xx, yy);
     PackListBitmaps.GetBitmap(num).Bitmap.Draw_alpha_a(bt, xx+sx, yy+sy);

   end;
 end;
end;

procedure TGFX_effect.SetPointGFX(x,y,ty:integer);
var Cadr:pGFX_effectE; i,cou,couc:integer;
begin
 cou:=3-1;
 couc:=0;
 for i:=FList.Count-1 downto 0 do begin
   Cadr:=pGFX_effectE(FList.Items[i]);
   if(cou<0) then begin
     exit;
   end else begin
     if(cadr.ty=-1) then begin
       dec(cou);
        
       if(couc=0) then begin
         cadr.ty:=1;
         couc:=1;
         cadr.x:=x+random(4)-2;
         cadr.y:=y+random(4)-2;
         cadr.speed:=0.2;
       end else begin
         cadr.ty:=2;
         cadr.x:=x;
         cadr.y:=y;
         cadr.speed:=1.7;
       end;
       cadr.timer:=0;
       cadr.angle:=(random(314)/314)*pi*2;
     end;
   end;
 end;
end;

end.
