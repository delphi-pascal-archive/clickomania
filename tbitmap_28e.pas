{******************************************************}
{                    TBT Class                         }
{                                                      }
{    Copyright © 2007, Naumenko Anton Aka antonn.      }
{                    v 1.0 Lite                        }
{                    07.01.2008                        }
{                                                      }
{                                                      }
{******************************************************}
unit tbitmap_28e;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics;

const
  MaxPixelCountA = MaxInt div SizeOf(TRGBQuad);
  MaxPixelCount = MaxInt div SizeOf(TRGBTriple);
  MaxBTCount = MaxInt div SizeOf(dword);
  
type
  PRGBArray = ^TRGBArray;
  TRGBArray = array[0..MaxPixelCount-1] of TRGBTriple;
  PRGBAArray = ^TRGBAArray;
  TRGBAArray = array[0..MaxPixelCountA-1] of TRGBQuad;

type
  BTElement = dword;
  TBTArray = array[0..MaxBTCount-1] of BTElement;

  pTBT = ^TBT;
  TBT = Class
    private
     procedure setarrays(x,y:integer);
     procedure FillZero;
     function ScanLineSize(BMP: TBitmap): Integer;
     function DIBBits(BMP: TBitmap): Pointer;
    public
     DIBWidth     : integer;
     DIBHeight    : integer;
     DIBSize      : integer;
     P: ^TBTArray;
     Compressed:boolean;
     constructor Create;
     destructor Destroy; override;

     procedure load_Stream(ms:Tmemorystream; w,h:integer);
     procedure set_widthheight(w,h:integer);
     procedure Assing_TBT(Sourc:TBT);
     procedure clear;

     //====== загрузка и сохранение ==========
     {загрузка и сохрание в собственном формате}
     {procedure load_Stream_ex(ms:Tmemorystream);
     procedure Save_Stream_ex(var ms:Tmemorystream);
     procedure load_from_file(filename:string);
     procedure Save_to_file(filename:string);
     }

     {загрузка и сохранение в битмап}
     procedure Loadbitmap2file(filename:string);
     procedure savebitmap2file(filename:string);
     procedure load_from_bitmap(bitmap:tbitmap);
     procedure Save_to_bitmap_slow(Bt:Tbitmap);  //scanline
     procedure Save_alpha_to_bitmap_slow(Bt:Tbitmap); //scanline

     procedure Save_to_bitmap(Bt:Tbitmap); //asm
     procedure load_from_bitmap33(Bt:tbitmap);

     //====== граф. обработка ==========
     //procedure Greyscale;
     //procedure Invert;
     //procedure Blur;
     //procedure Swap_TBT(Dest:TBT);
     //procedure SetLight(const value:double);

     {//============= GDI ===============
     function GD_GetPixel_unsafe( x, y: integer): TColor;
     procedure GD_SetPixel_unsafe(x, y: integer; col: TColor);
     function GD_GetPixel( x, y: integer): TColor;
     procedure GD_SetPixel(x, y: integer; col: TColor);

     function GD_HLine(x, y, x1: integer; col: TColor):integer;
     function GD_VLine(x, y, y1: integer; col: TColor):integer;
     function GD_RangeLine(x, y, x1, y1: integer; col: TColor):integer;
     function GD_Line( x, y, x1, y1: integer; col: TColor):integer;
     function GD_Rectangle( x0, y0, x1, y1: integer; col: TColor):integer;
     function GD_FillRectangle( x0, y0, x1, y1: integer; col: TColor):integer;
     function GD_Triangle( x1, y1, x2, y2, x3, y3: integer; col: TColor):integer;
     function GD_Circle( x, y, r: integer; col: TColor):integer;
     function GD_FillCircle( x, y, r: integer; col: TColor):integer;
     function GD_Ellipse( x1, y1, x2, y2: Integer; Col: TColor):integer;
     function GD_FillEllipse( x1, y1, x2, y2: Integer; col: TColor):integer;
     procedure GD_Outline( EdgeColor, BackgroundColor: TColor);
     procedure GD_FillColor(col: TColor);
     procedure GD_SmoothLine( x, y, x1, y1: integer; col: TColor; radius: single; precise: boolean);
     }

     //копирование с учетом альфаканала и с перерасчетом альфы фона
     procedure Draw_alpha_a(BTDest:TBT; x,y:integer);
     //копирование с учетом альфаканала
     //procedure Draw_alpha(BTDest:TBT; x,y:integer);
     //копирование с учетом альфаканала
     //procedure Draw_alpha_MMX(BTDest:TBT; x,y:integer);

     procedure Draw_transcolor(BTDest:TBT; _x,_y:integer; transcolor:TColor);
     procedure Draw_transcolor_rect(BTDest:TBT; x,y,_x,_y,_w,_h:integer; transcolor:TColor);
     //procedure Draw_transcolor_opacity_MMX(BTDest:TBT; _x,_y:integer; transcolor:TColor; opacity:double);

     //назначение из источника с уменьшением
     //procedure GD_Assign_Antialias2X(Sourc:TBT);
     //procedure GD_Assign_Antialias4X(Sourc:TBT);

     //procedure Draw_rotate(BTDest:TBT; _x,_y,centerX,centerY:integer; angle: double; TransColor:tcolor);
     //procedure Draw_rotate_opacity(BTDest:TBT; _x,_y,centerX,centerY:integer; angle: double; TransColor:tcolor; opacity: double);
     //procedure Draw_rotate_alpha(BTDest:TBT; _x,_y,centerX,centerY:integer; angle: double);
     //procedure Draw_rotate_alpha_colorized(BTDest:TBT; _x,_y,centerX,centerY:integer; angle,opacity: double; color:integer);

     //procedure Draw_resize(BTDest:TBT; _x,_y,w,h:integer; transcolor:tcolor);
     //procedure Draw_resize_00(BTDest:TBT; w,h:integer; transcolor:tcolor);

end;


  pPackListTBTE = ^TPackListTBTE;
  TPackListTBTE = record
   Bitmap:TBT;
   num:integer;
   w,h:integer;
  end;

  TPackListTBT = class
  private
   FList:TList;
  protected
  public
   constructor Create;
   destructor Destroy; override;

   procedure clear;
   function GetCountBitmaps:integer;
   function GetBitmap(num:integer):pPackListTBTE;

   procedure Add_bitmap(Bitmap:Tbitmap);
   procedure Add_bitmap_from_file(fi:string);
   procedure Delete_bitmap(num:integer);

  { procedure Save(filename:string);
   procedure Load(filename:string);
   procedure Save_num_bitmap(filename:string; num:integer); }
  end;



implementation

function Min( X, Y: Integer ): Integer;
asm
  {$IFDEF F_P}
  MOV EAX, [X]
  MOV EDX, [Y]
  {$ENDIF F_P}
  {$IFDEF USE_CMOV}
  CMP   EAX, EDX
  CMOVG EAX, EDX
  {$ELSE}
  CMP EAX, EDX
  JLE @@exit
  MOV EAX, EDX
@@exit:
  {$ENDIF}
end {$IFDEF F_P} [ 'EAX', 'EDX' ] {$ENDIF};

function Max( X, Y: Integer ): Integer;
asm
  {$IFDEF F_P}
  MOV EAX, [X]
  MOV EDX, [Y]
  {$ENDIF F_P}
  {$IFDEF USE_CMOV}
  CMP EAX, EDX
  CMOVL EAX, EDX
  {$ELSE}
  CMP EAX, EDX
  JGE @@exit
  MOV EAX, EDX
@@exit:
  {$ENDIF}
end {$IFDEF F_P} [ 'EAX', 'EDX' ] {$ENDIF};

constructor TBT.Create;
begin
 inherited;
 DIBWidth:=0;
 DIBHeight:=0;
 Compressed:=true;
end;

destructor TBT.Destroy;
begin
 FreeMem(P, DIBWidth*DIBHeight*SizeOf(BTElement));
 inherited;
end;

procedure TBT.setarrays(x,y:integer);
begin
 FreeMem(P, DIBWidth*DIBHeight*SizeOf(BTElement));

 DIBWidth:=x;
 DIBHeight:=y;
 DIBSize:=DIBWidth*SizeOf(BTElement);
 P:=AllocMem(DIBWidth*DIBHeight * SizeOf(BTElement));
 FillZero;
end;

procedure TBT.FillZero;
begin
 fillchar(P^, DIBWidth*DIBHeight * SizeOf(BTElement), 0);
end;

procedure TBT.set_widthheight(w,h:integer);
begin
 setarrays(w,h);
end;

procedure TBT.clear;
begin
 FillZero;
end;

function TBT.ScanLineSize(BMP: TBitmap): Integer;
var Section: TDIBSECTION;
begin
BMP.HandleType := bmDIB;
GetObject(BMP.Handle, sizeof(TDIBSECTION), @Section);
Result := ((Section.dsBmih.biBitCount * Section.dsBmih.biWidth + 31) shr 3) and $FFFFFFFC;;
end;

function TBT.DIBBits(BMP: TBitmap): Pointer;
var Section: TDIBSECTION;
begin
BMP.HandleType := bmDIB;
GetObject(BMP.Handle, sizeof(TDIBSECTION), @Section);
Result := Section.dsBm.bmBits;
end;

procedure TBT.load_from_bitmap(bitmap:tbitmap);
var x,y: Integer;  Row24:PRGBArray; Row32:PRGBAArray; b:byte;
begin
 setarrays(bitmap.Width,bitmap.Height);
 if(bitmap.PixelFormat=pf32bit) then begin
   for Y:=0 to bitmap.Height-1 do begin
    Row32:=bitmap.ScanLine[y];
     for x:=0 to bitmap.Width-1 do
        P^[ y*DIBWidth+x ]:=(Row32[x].rgbRed or (Row32[x].rgbGreen shl 8) or (Row32[x].rgbBlue shl 16) or (Row32[x].rgbReserved shl 24));
  end;
 end else begin
  bitmap.PixelFormat:=pf24bit;
  for Y:=0 to bitmap.Height-1 do begin
   Row24:=bitmap.ScanLine[y];
    for x:=0 to bitmap.Width-1 do begin
      if((Row24[x].rgbtRed=255) and (Row24[x].rgbtGreen=0) and (Row24[x].rgbtBlue=0)) then
        b:=0 else
        b:=255;
        P^[ y*DIBWidth+x ]:=(Row24[x].rgbtRed or (Row24[x].rgbtGreen shl 8) or (Row24[x].rgbtBlue shl 16) or (b shl 24));
    end;
  end;
 end;
end;

procedure TBT.load_from_bitmap33(Bt:tbitmap);
var  sx, sy, inc1, inc2: integer;
  p1, p2: pointer;
  xhead, xbody, xtail:integer;
begin
  if((DIBWidth<>Bt.Width) or (DIBHeight<>Bt.Height)) then begin
   FreeMem(P, DIBWidth*DIBHeight*SizeOf(BTElement));
   DIBWidth:=Bt.Width;
   DIBHeight:=Bt.Height;
   DIBSize:=DIBWidth*SizeOf(BTElement);
   P:=AllocMem(DIBWidth*DIBHeight * SizeOf(BTElement));
  end;
  sx:=DIBWidth;
  sy:=DIBHeight;

  inc2:=DIBSize;
  inc1:=ScanLineSize(Bt);
  p2:=@P^[0];

  p1:=DIBBits(Bt);
  inc( dword( p1), inc1*(sy-1));
  inc1:=-inc1;
  xbody:=DIBWidth*4-1;
  xtail:=0;
  xhead:=4;
         asm
          push  ebx
          push  edi
          push  esi

          mov   ebx, 8

        @outer_loop:
          mov   ecx, sx
          mov   esi, p2
          mov   edi, p1

          mov   ecx, xhead
          and   ecx, ecx
          jz    @body
          rep   movsb

        @body:
          mov   ecx, xbody
          shr   ecx, 3
          jz    @tail

        @inner_loop:
          mov   eax, [edi]
          mov   edx, [edi+4]
          bswap eax
          ror   eax, 8
          mov   [esi], eax
          bswap edx
          ror   edx, 8
          mov   [esi+4], edx
          add   esi, ebx
          add   edi, ebx
          dec   ecx
          jnz   @inner_loop

        @tail:
          mov   ecx, xtail
          and   ecx, ecx
          jz    @notail
          rep   movsb

        @notail:  
          mov   ecx, inc2
          mov   eax, inc1
          add   p2, ecx
          add   p1, eax
          dec   sy
          jnz   @outer_loop

          pop   esi
          pop   edi
          pop   ebx
        end;
end;


procedure TBT.Save_to_bitmap(Bt:Tbitmap);
var  sx, sy, inc1, inc2: integer;
  p1, p2: pointer;
begin
  Bt.PixelFormat:=pf32bit;
  Bt.Width:=DIBWidth;
  Bt.Height:=DIBHeight;
  sx:= DIBWidth;
  sy:= DIBHeight;     // messagedlg(inttostr(x),mterror,[mbOK],0);
  inc1:=32;
  sx:= sx*4;
  inc2:=DIBSize;
  inc1:=ScanLineSize(Bt);
  p2:=@P^[0];
  p1:=DIBBits(Bt);
  inc( dword( p1), inc1*(sy-1));
  inc1:=-inc1;

         asm
          push  ebx
          push  edi
          push  esi

          mov   ebx, 8

        @outer_loop:
          mov   ecx, sx
          mov   esi, p2
          shr   ecx, 3
          mov   edi, p1
          jz    @tail

        @inner_loop:
          mov   eax, [esi]
          mov   edx, [esi+4]
          
          bswap eax
          ror   eax, 8
          mov   [edi], eax
          bswap edx
          ror   edx, 8
          mov   [edi+4], edx

          add   esi, ebx
          add   edi, ebx
          dec   ecx
          jnz   @inner_loop

        @tail:
          mov   ecx, sx
          and   ecx, 7
          rep   movsb

          mov   ecx, inc2
          mov   eax, inc1
          add   p2, ecx
          add   p1, eax
          dec   sy
          jnz   @outer_loop

          pop   esi
          pop   edi
          pop   ebx
        end;
end;

procedure TBT.Assing_TBT(Sourc:TBT);
var  sx, sy, inc1, inc2: integer;
  p1, p2: pointer;
begin

  if((DIBWidth<>Sourc.DIBWidth) or (DIBHeight<>Sourc.DIBHeight)) then begin
   FreeMem(P, DIBWidth*DIBHeight*SizeOf(BTElement));
   DIBWidth:=Sourc.DIBWidth;
   DIBHeight:=Sourc.DIBHeight;
   DIBSize:=DIBWidth*SizeOf(BTElement);
   P:=AllocMem(DIBWidth*DIBHeight * SizeOf(BTElement));
  end;

  sx:= DIBWidth;
  sy:= DIBHeight;     // messagedlg(inttostr(x),mterror,[mbOK],0);
  inc1:=32;
  sx:= sx*4;
  inc2:=DIBSize;
  inc1:=DIBSize;
  p1:=@P^[0];
  p2:=@Sourc.P^[0];

         asm
          push  ebx
          push  edi
          push  esi

          mov   ebx, 8

        @outer_loop:
          mov   ecx, sx
          mov   esi, p2
          shr   ecx, 3
          mov   edi, p1
          jz    @tail

        @inner_loop:
          mov   eax, [esi]
          mov   edx, [esi+4]
          
          mov   [edi], eax
          mov   [edi+4], edx

          add   esi, ebx
          add   edi, ebx
          dec   ecx
          jnz   @inner_loop

        @tail:
          mov   ecx, sx
          and   ecx, 7
          rep   movsb

          mov   ecx, inc2
          mov   eax, inc1
          add   p2, ecx
          add   p1, eax
          dec   sy
          jnz   @outer_loop

          pop   esi
          pop   edi
          pop   ebx
        end;
end;

procedure TBT.Save_to_bitmap_slow(Bt:Tbitmap);
var x,y:Integer; Row32:PRGBAArray; fd:dword;
begin
  Bt.PixelFormat:=pf32bit;
  Bt.Width:=DIBWidth;
  Bt.Height:=DIBHeight;
   for Y:=0 to Bt.Height-1 do begin
     Row32:=Bt.ScanLine[y];
     for x:=0 to Bt.Width-1 do begin
       fd:=P^[ y*DIBWidth+x ];
       Row32[x].rgbBlue:=Byte(fd shr 16);
       Row32[x].rgbGreen:=Byte(fd shr 8);
       Row32[x].rgbRed:=Byte(fd);
       Row32[x].rgbReserved:=Byte(fd shr 24);
     end;
   end;
end;

procedure TBT.Save_alpha_to_bitmap_slow(Bt:Tbitmap);
var x,y:Integer; Row32:PRGBAArray; fd:dword;
begin
  Bt.PixelFormat:=pf32bit;
  Bt.Width:=DIBWidth;
  Bt.Height:=DIBHeight;
   for Y:=0 to Bt.Height-1 do begin
     Row32:=Bt.ScanLine[y];
     for x:=0 to Bt.Width-1 do begin
       fd:=P^[ y*DIBWidth+x ];
       Row32[x].rgbBlue:=Byte(fd shr 24);
       Row32[x].rgbGreen:=Byte(fd shr 24);
       Row32[x].rgbRed:=Byte(fd shr 24);
       Row32[x].rgbReserved:=255;//Byte(fd shr 24);
     end;
   end;
end;

procedure TBT.Loadbitmap2file(filename:string);
var bb:tbitmap;
begin
 bb:=tbitmap.Create;
 try
  bb.LoadFromFile(filename);
  load_from_bitmap(bb);
 finally
  bb.Free;
 end;
end;

procedure TBT.savebitmap2file(filename:string);
var bb:tbitmap; x,y: Integer;  Row2:PRGBAArray; fd:dword;
begin
 bb:=tbitmap.Create;
 try
  bb.PixelFormat:=pf32bit;
  bb.Width:=DIBWidth;
  bb.Height:=DIBHeight;
   for Y:=0 to bb.Height-1 do begin
     Row2:=bb.ScanLine[y];
     for x:=0 to bb.Width-1 do begin
       fd:=P^[ y*DIBWidth+x ];
       Row2[x].rgbBlue:=Byte(fd shr 16);
       Row2[x].rgbGreen:=Byte(fd shr 8);
       Row2[x].rgbRed:=Byte(fd);
       Row2[x].rgbReserved:=Byte(fd shr 24);
     end;
   end;
   bb.SaveToFile(filename);
 finally
  bb.Free;
 end;
end;

procedure TBT.load_Stream(ms:Tmemorystream; w,h:integer);
begin
 setarrays(w,h);

 ms.Position:=0;
 ms.Read(DWORD(P^[0]),ms.Size-1);
end;


//круто, да? :))
//у кого есть желание, пусть перепишет под Tbitmap, учитывая заголовок в 33
//байта и перевернутые строки. Работает чуть быстрее чем в 10 раз по сравнению
//со сканлайном из функции CopyBitmapAlfa32to32()
procedure TBT.Draw_alpha_a(BTDest:TBT; x,y:integer);
var SrcBits: DWORD; DstBits: DWORD;
    xTo, sx, YTo, ddx, ddy, sy, w, h, dstw, dsth: integer;
    inc1, inc2: integer;
begin
  w:= DIBWidth;
  h:= DIBHeight;
  dstw:= BTDest.DIBWidth;
  dsth:= BTDest.DIBHeight;
  XTo:= x+W-1;
  YTo:= y+H-1;
  if (y>=dstH) or (x>=dstW) or (YTo<0) or (XTo<0) then exit;
  asm
    xor  eax, eax
    mov  ddx, eax
    mov  ddy, eax
  end;
  sx:= W;
  sy:= H;

  if X<0 then
    begin
      ddx:= -X;
      inc( sx, X);
      x:= 0;
    end;

  if Y<0 then
    begin
      ddy:= -Y;
      inc( sy, Y);
      y:= 0;
    end;

  if XTo>=dstw then
    dec( sx, XTo-dstw+1);

  if YTo>=dsth then
    dec( sy, YTo-dsth+1);

  if (sx<=0) or (sy<=0) then exit;
      SrcBits := DWORD(@P^[ (ddy*DIBWidth)+ddx ]);
      DstBits := DWORD(@BTDest.P^[(y*BTDest.DIBWidth)+x ]);
      inc1:=BTDest.DIBSize;
      inc2:=DIBSize;
  asm
    push  ebx
    push  edi
    push  esi

  @outer_loop:
    mov   ecx, sx
    mov   edi, DstBits
    mov   esi, SrcBits
  @loop:
    mov   bl, byte ptr [esi+3]
    mov   bh, byte ptr [esi+3]
    and   bl, bl
    je    @skiptransparent

    mov   al, [esi]
    not   bh

    mul   al, bl
    mov   dl, ah
    mov   al, [edi]
    mul   al, bh
    add   dl, ah
    mov   [edi], dl

    mov   al, [esi+1]
    mul   al, bl
    mov   dl, ah
    mov   al, [edi+1]
    mul   al, bh
    add   dl, ah
    mov   [edi+1], dl

    mov   al, [esi+2]
    mul   al, bl
    mov   dl, ah
    mov   al, [edi+2]
    mul   al, bh
    add   dl, ah
    mov   [edi+2], dl

    mov   al, [edi+3]

    cmp bl,al
    jb @set_al
    mov [edi+3],bl
    @set_al:

  @skiptransparent:
    add   esi, 4
    add   edi, 4
    dec   ecx
    jnz   @loop

  @l1:
    mov   ecx, inc1
    mov   eax, inc2
    add   DstBits, ecx
    add   SrcBits, eax
    dec   sy
    jnz   @outer_loop

    pop   esi
    pop   edi
    pop   ebx
  end;
end;

procedure TBT.Draw_transcolor(BTDest:TBT; _x,_y:integer; transcolor:TColor);
var SrcBits: DWORD; DstBits: DWORD;
    xTo, sx, YTo, ddx, ddy, sy, w, h, dstw, dsth: integer;
    inc1, inc2: integer;
begin
  w:=DIBWidth;  h:=DIBHeight;
  dstw:= BTDest.DIBWidth;  dsth:= BTDest.DIBHeight;
  XTo:= _x+W-1; YTo:= _y+H-1;
  if (_y>=dstH) or (_x>=dstW) or (YTo<0) or (XTo<0) then exit;
  asm
    xor  eax, eax
    mov  ddx, eax
    mov  ddy, eax
  end;
  sx:=W;
  sy:=H;
  if _x<0 then begin
      ddx:=-_x;
      inc( sx, _x);
      _x:=0;
  end;
  if _y<0 then begin
      ddy:=-_y;
      inc( sy, _y);
      _y:=0;
  end;
  if XTo>=dstw then dec(sx,XTo-dstw+1);
  if YTo>=dsth then dec(sy,YTo-dsth+1);

  if (sx<=0) or (sy<=0) then exit;



  SrcBits := DWORD(@P^[ (ddy*DIBWidth)+ddx ]);
  DstBits := DWORD(@BTDest.P^[(_y*BTDest.DIBWidth)+_x ]);
  inc1:=BTDest.DIBSize;
  inc2:=DIBSize;

  asm
          push  ebx
          push  edi
          push  esi

          mov   ebx, TransColor
          and   ebx, $FFFFFF
        @outer_loop:
          mov   edi, DstBits
          mov   ecx, sx
          mov   esi, SrcBits
        @loop:
          mov   eax, [esi]
          mov   edx, [esi]
          and   eax, $FFFFFF
          add   esi, 4
          cmp   eax, ebx
          jz    @next


          mov   al, [edi+3]
          mov   [edi], edx
          mov   [edi+3], al


        @next:
          add   edi, 4
          dec   ecx
          jnz   @loop
        @end:
          mov   ecx, inc1
          mov   eax, inc2
          add   DstBits, ecx
          add   SrcBits, eax

          dec   sy
          jnz   @outer_loop
          pop   esi
          pop   edi
          pop   ebx
        end;
end;

procedure TBT.Draw_transcolor_rect(BTDest:TBT; x,y,_x,_y,_w,_h:integer; transcolor:TColor);
var SrcBits: DWORD; DstBits: DWORD;
    xTo, sx, YTo, ddx, ddy, sy, w, h, dstw, dsth: integer;
    inc1, inc2: integer;
begin
  w:=_w; h:=_h;
  dstw:=BTDest.DIBWidth;  dsth:=BTDest.DIBHeight;
  XTo:=x+W-1; YTo:=y+H-1;
  if (y+_h>=dstH) or (x+_w>=dstW) or (YTo<0) or (XTo<0) then exit;
  asm
    xor  eax, eax
    mov  ddx, eax
    mov  ddy, eax
  end;  
  ddx:=_x;
  ddy:=_y;
  sx:=w;
  sy:=h;
  if x<0 then begin
      ddx:=-x;
      inc( sx, x);
      x:=0;
  end;
  if y<0 then begin
      ddy:=-y;
      inc( sy, y);
      y:=0;
  end;
  if XTo>=dstw then dec(sx,XTo-dstw+1);
  if YTo>=dsth then dec(sy,YTo-dsth+1);
  if (sx<=0) or (sy<=0) then exit;


  SrcBits:=DWORD(@P^[ (ddy*DIBWidth)+ddx ]);
  DstBits:=DWORD(@BTDest.P^[((y)*BTDest.DIBWidth)+(x) ]);
  inc1:=BTDest.DIBSize;
  inc2:=DIBSize;

     asm
          push  ebx
          push  edi
          push  esi

          mov   ebx, TransColor
          and   ebx, $FFFFFF
        @outer_loop:
          mov   edi, DstBits
          mov   ecx, sx
          mov   esi, SrcBits
        @loop:
          mov   eax, [esi]
          mov   edx, [esi]
          and   eax, $FFFFFF
          add   esi, 4
          cmp   eax, ebx
          jz    @next
          mov   [edi], edx
        @next:
          add   edi, 4
          dec   ecx
          jnz   @loop
        @end:
          mov   ecx, inc1
          mov   eax, inc2
          add   DstBits, ecx
          add   SrcBits, eax

          dec   sy
          jnz   @outer_loop
          pop   esi
          pop   edi
          pop   ebx
     end;
end;


//===================== TPackListTBT ========================================

constructor TPackListTBT.Create;
begin
 inherited;
  FList:=TList.Create;
end;

destructor TPackListTBT.Destroy;
var i:integer; Cadr:pPackListTBTE;
begin
  for i:=0 to FList.Count-1 do begin
   Cadr:=pPackListTBTE(FList.Items[i]);
   Cadr.Bitmap.Free;
   Dispose(Cadr);
  end;
  FList.Free;
 inherited;
end;

procedure TPackListTBT.Add_bitmap(Bitmap:Tbitmap);
var Cadr:pPackListTBTE;
begin
 New(Cadr);
 Cadr.Bitmap:=TBT.Create;
 Cadr.Bitmap.load_from_bitmap33(bitmap);
 Cadr.w:=Bitmap.Width;
 Cadr.h:=Bitmap.Height;
 Cadr.num:=0;
 Flist.Add(TObject(Cadr));
end;

procedure TPackListTBT.Add_bitmap_from_file(fi:string);
var bt:tbitmap;
begin
 bt:=tbitmap.Create;
 try
  bt.LoadFromFile(fi);
  Add_bitmap(bt);
 finally
  bt.Free;
 end;
end;

procedure TPackListTBT.Delete_bitmap(num:integer);
var Cadr:pPackListTBTE;
begin
if num>=FList.Count then exit;
 Cadr:= pPackListTBTE(FList.Items[num]);
 Cadr.Bitmap.Free;
 Dispose(Cadr);
 FList.Delete(num);
end;

procedure TPackListTBT.clear;
var Cadr:pPackListTBTE; i:integer;
begin
 for i:=FList.Count-1 downto 0 do begin
   Cadr:=pPackListTBTE(FList.Items[i]);
   Cadr.Bitmap.Free;
   Dispose(Cadr);
   FList.Delete(i);
 end;
end;

function TPackListTBT.GetCountBitmaps:integer;
begin
 result:=FList.Count;
end;

function TPackListTBT.GetBitmap(num:integer):pPackListTBTE;
begin
 result:=pPackListTBTE(FList.Items[num]);
end;

end.
