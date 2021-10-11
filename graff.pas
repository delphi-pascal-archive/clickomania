unit graff;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,Forms,Graphics,tbitmap_28e;

const
  MaxPixelCountA = MaxInt div SizeOf(TRGBQuad);
  MaxPixelCount = MaxInt div SizeOf(TRGBTriple);
type
  PRGBArray = ^TRGBArray;
  TRGBArray = array[0..MaxPixelCount-1] of TRGBTriple;
  PRGBAArray = ^TRGBAArray;
  TRGBAArray = array[0..MaxPixelCountA-1] of TRGBQuad;

  procedure CopyRectIco_rect(_B_in,_B_mask:TBitmap; _Bout:tbt; mW,mH,mR,mB:integer);
  procedure CopyBitmapAlfa32to24(_B_in,_B_out:Tbitmap; _x,_y:integer);
  procedure Copy32clear(var _B_in:TBitmap);
  procedure CopyBitmapAlfa32to32(_B_in,_B_out:Tbitmap; _x,_y:integer);
  procedure PrepareColorBitmap(BT:Tbitmap; Color:Tcolor);
  procedure Copy32clear_re(_B_in:TBitmap);
  procedure Set_alpha_render(_B_in:TBitmap);
  procedure Copy32assing(bt1,bt2:TBitmap);

  //можно было на асме, но не буду :)
  function ColorDarker(const OriginalColor: TColor; const Percent: Byte): TColor;
  function ColorLighter(const Color: TColor; const Percent: Byte):TColor;

implementation

uses main;

procedure CopyRectIco_rect(_B_in,_B_mask:TBitmap; _Bout:tbt; mW,mH,mR,mB:integer);
var x, y: Integer; RowOut: PRGBAArray; RowIn,RowInMask:PRGBArray;     //u11,u12,u21,u22,u31,u32,u41,u42:integer uL,dL,ll,rl,
    Btt,BttM,Bttr:TBitmap;
begin
  Btt:=Tbitmap.Create;
  BttM:=TBitmap.Create;
  Bttr:=TBitmap.Create;
  try
    Btt.Width:=_Bout.DIBWidth;
    btt.Height:=_Bout.DIBHeight;

    BttM.Assign(Btt);  Bttr.Assign(Btt);
    BttM.PixelFormat:=pf24bit; Btt.PixelFormat:=pf24bit;

    _B_in.PixelFormat:=pf24bit;
    _B_mask.PixelFormat:=pf24bit;
    Bttr.PixelFormat:=pf32bit;

    BttM.Canvas.Brush.Color:=clblack;
    BttM.Canvas.FillRect(BttM.Canvas.ClipRect);
    Btt.Canvas.Brush.Color:=clblack;
    Btt.Canvas.FillRect(Btt.Canvas.ClipRect);


    //upper
    {BTmp.Canvas.CopyRect( classes.rect(0,0,BTmp.Width,BTmp.Height), _B_mask.Canvas ,classes.rect(16,0,_B_mask.Width-16,BTmp.Height));
    Strecth(BTmp, BTmp2, MitchellFilter, 2);
    BttM.Canvas.CopyRect( classes.rect(16,0,BttM.Width-16,16), BTmp2.Canvas ,classes.rect(0,0,BTmp2.Width,BTmp2.Height));
    BTmp.Canvas.CopyRect( classes.rect(0,0,BTmp.Width,BTmp.Height), _B_in.Canvas ,classes.rect(16,0,_B_in.Width-16,BTmp.Height));
    Strecth(BTmp, BTmp2, MitchellFilter, 2);
    Btt.Canvas.CopyRect( classes.rect(16,0,Btt.Width-16,16), BTmp2.Canvas ,classes.rect(0,0,BTmp2.Width,BTmp2.Height));  }
    BttM.Canvas.CopyRect( classes.rect(mW,0,BttM.Width-mr,mh), _B_mask.Canvas ,classes.rect(mW,0,_B_mask.Width-mr,mh));
    Btt.Canvas.CopyRect( classes.rect(mW,0,Btt.Width-mr,mh), _B_in.Canvas ,classes.rect(mW,0,_B_in.Width-mr,mh));

    //bottomer
   { BTmp.Height:=16;
    BTmp2.Height:=16;
    BTmp.Canvas.CopyRect( classes.rect(0,0,BTmp.Width,BTmp.Height), _B_mask.Canvas ,classes.rect(16,_B_mask.Height-16,_B_mask.Width-16,_B_mask.Height));
    Strecth(BTmp, BTmp2, MitchellFilter, 2);
    BttM.Canvas.CopyRect( classes.rect(16,BttM.Height-16,BttM.Width-16,BttM.Height), BTmp2.Canvas ,classes.rect(0,0,BTmp2.Width,BTmp2.Height));
    BTmp.Canvas.CopyRect( classes.rect(0,0,BTmp.Width,BTmp.Height), _B_in.Canvas ,classes.rect(16,_B_in.Height-16,_B_in.Width-16,_B_in.Height));
    Strecth(BTmp, BTmp2, MitchellFilter, 2);
    Btt.Canvas.CopyRect( classes.rect(16,Btt.Height-16,Btt.Width-16,Btt.Height), BTmp2.Canvas ,classes.rect(0,0,BTmp2.Width,BTmp2.Height));
    }
    BttM.Canvas.CopyRect( classes.rect(mW,BttM.Height-mb,BttM.Width-mr,BttM.Height), _B_mask.Canvas ,classes.rect(mw,_B_mask.Height-mb,_B_mask.Width-mr,_B_mask.Height));
    Btt.Canvas.CopyRect( classes.rect(mW,Btt.Height-mb,Btt.Width-mr,Btt.Height), _B_in.Canvas ,classes.rect(mw,_B_in.Height-mb,_B_in.Width-mr,_B_in.Height));



  //lefter
   { BTmp.Canvas.CopyRect( classes.rect(0,0,BTmp.Width,BTmp.Height), _B_mask.Canvas ,classes.rect(0,16,16,_B_mask.Height-16));
    Strecth(BTmp, BTmp2, MitchellFilter, 2);
    BttM.Canvas.CopyRect( classes.rect(0,16,16,BttM.Height-16), BTmp2.Canvas ,classes.rect(0,0,BTmp2.Width,BTmp2.Height));
    BTmp.Canvas.CopyRect( classes.rect(0,0,BTmp.Width,BTmp.Height), _B_in.Canvas ,classes.rect(0,16,16,_B_in.Height-16));
    Strecth(BTmp, BTmp2, MitchellFilter, 2);
    Btt.Canvas.CopyRect( classes.rect(0,16,16,Btt.Height-16), BTmp2.Canvas ,classes.rect(0,0,BTmp2.Width,BTmp2.Height));
    }
    BttM.Canvas.CopyRect( classes.rect(0,mh,mw,BttM.Height-mb), _B_mask.Canvas ,classes.rect(0,mh,mw,_B_mask.Height-mb));
    Btt.Canvas.CopyRect( classes.rect(0,mh,mw,Btt.Height-mb), _B_in.Canvas ,classes.rect(0,mh,mw,_B_in.Height-mb));


    //righter
    {BTmp.Width:=16;
    BTmp2.Width:=16;
    BTmp.Canvas.CopyRect( classes.rect(0,0,BTmp.Width,BTmp.Height), _B_mask.Canvas ,classes.rect(_B_mask.Width-16,16,_B_mask.Width,_B_mask.Height-16));
    Strecth(BTmp, BTmp2, MitchellFilter, 2);
    BttM.Canvas.CopyRect( classes.rect(BttM.Width-16,16,BttM.Width,BttM.Height-16), BTmp2.Canvas ,classes.rect(0,0,BTmp2.Width,BTmp2.Height));
    BTmp.Canvas.CopyRect( classes.rect(0,0,BTmp.Width,BTmp.Height), _B_in.Canvas ,classes.rect(_B_in.Width-16,16,_B_in.Width,_B_in.Height-16));
    Strecth(BTmp, BTmp2, MitchellFilter, 2);
    Btt.Canvas.CopyRect( classes.rect(Btt.Width-16,16,Btt.Width,Btt.Height-16), BTmp2.Canvas ,classes.rect(0,0,BTmp2.Width,BTmp2.Height));
    }
    BttM.Canvas.CopyRect( classes.rect(BttM.Width-mw,mh,BttM.Width,BttM.Height-mb), _B_mask.Canvas ,classes.rect(_B_mask.Width-mw,mh,_B_mask.Width,_B_mask.Height-mb));
    Btt.Canvas.CopyRect( classes.rect(Btt.Width-mw,mh,Btt.Width,Btt.Height-mb), _B_in.Canvas ,classes.rect(_B_in.Width-mw,mh,_B_in.Width,_B_in.Height-mb));




    {BTmp.Width:=_B_mask.Width-16-16; BTmp.Height:=_B_mask.Height-16-16;
    BTmp2.Width:=BttM.Width-16-16; BTmp2.Height:=BttM.Height-16-16;
    //centered
    BTmp.Canvas.CopyRect( classes.rect(0,0,BTmp.Width,BTmp.Height), _B_mask.Canvas ,classes.rect(16,16,_B_mask.Width-16,_B_mask.Height-16));
    Strecth(BTmp, BTmp2, MitchellFilter, 2);
    BttM.Canvas.CopyRect( classes.rect(16,16,BttM.Width-16,BttM.Height-16), BTmp2.Canvas ,classes.rect(0,0,BTmp2.Width,BTmp2.Height));
    BTmp.Canvas.CopyRect( classes.rect(0,0,BTmp.Width,BTmp.Height), _B_in.Canvas ,classes.rect(16,16,_B_in.Width-16,_B_in.Height-16));
    Strecth(BTmp, BTmp2, MitchellFilter, 2);
    Btt.Canvas.CopyRect( classes.rect(16,16,Btt.Width-16,Btt.Height-16), BTmp2.Canvas ,classes.rect(0,0,BTmp2.Width,BTmp2.Height));
    }
    BttM.Canvas.CopyRect( classes.rect(mw,mh,BttM.Width-mr,BttM.Height-mb), _B_mask.Canvas ,classes.rect(mw,mh,_B_mask.Width-mr,_B_mask.Height-mb));
    Btt.Canvas.CopyRect( classes.rect(mw,mh,Btt.Width-mr,Btt.Height-mb), _B_in.Canvas ,classes.rect(mw,mh,_B_in.Width-mr,_B_in.Height-mb));


    Btt.Canvas.CopyRect( classes.rect(0,0,mw,mh), _B_in.Canvas ,classes.rect(0,0,mw,mh) );
    BttM.Canvas.CopyRect( classes.rect(0,0,mw,mh), _B_mask.Canvas ,classes.rect(0,0,mw,mh));
    Btt.Canvas.CopyRect( classes.rect(Btt.Width-mr,0,Btt.Width,mh), _B_in.Canvas ,classes.rect(_B_in.Width-mr,0,_B_in.Width,mh) );
    BttM.Canvas.CopyRect( classes.rect(BttM.Width-mr,0,BttM.Width,mh), _B_mask.Canvas ,classes.rect(_B_mask.Width-mr,0,_B_mask.Width,mh));
    Btt.Canvas.CopyRect( classes.rect(0, Btt.Height-mb,mh,Btt.Height), _B_in.Canvas ,classes.rect(0, _B_in.Height-mb,mh,_B_in.Height) );
    BttM.Canvas.CopyRect( classes.rect(0, BttM.Height-mb,mh,BttM.Height), _B_mask.Canvas ,classes.rect(0, _B_mask.Height-mb,mh,_B_mask.Height));
    Btt.Canvas.CopyRect( classes.rect(Btt.Width-mr,Btt.Height-mb,Btt.Width,Btt.Height), _B_in.Canvas ,classes.rect(_B_in.Width-mr,_B_in.Height-mb,_B_in.Width,_B_in.Height) );
    BttM.Canvas.CopyRect( classes.rect(BttM.Width-mr,BttM.Height-mb,BttM.Width,BttM.Height), _B_mask.Canvas ,classes.rect(_B_mask.Width-mr,_B_mask.Height-mb,_B_mask.Width,_B_mask.Height));



    for y:=0 to Btt.Height-1 do begin
     RowOut:= Bttr.ScanLine[y];
     RowIn:= Btt.ScanLine[y];
     RowInMask:= BttM.ScanLine[y];
       for x:=0 to Btt.Width-1 do begin
          RowOut[x].rgbReserved:=trunc((RowInMask[x].rgbtBlue+RowInMask[x].rgbtGreen+RowInMask[x].rgbtRed)/3);
          RowOut[x].rgbBlue:=byte(trunc(RowIn[x].rgbtBlue*RowOut[x].rgbReserved/255));
          RowOut[x].rgbGreen:=byte(trunc(RowIn[x].rgbtGreen*RowOut[x].rgbReserved/255));
          RowOut[x].rgbRed:=byte(trunc(RowIn[x].rgbtRed*RowOut[x].rgbReserved/255));
       end;
    end;

    _Bout.load_from_bitmap33(Bttr);

  finally
   btt.free;
   bttm.free;
   Bttr.Free;
  end;
end;

procedure CopyBitmapAlfa32to24(_B_in,_B_out:Tbitmap; _x,_y:integer);
var x, y: Integer; _r,_b,_g:integer;
    w_in,h_in,w_out,h_out,tmp,x_cor,y_cor,x_corS,y_corS: Integer;
    RowOut:PRGBArray; RowIn:PRGBAArray;
    _d,_dd:double;
begin
 w_in:=_B_in.Width;
 h_in:=_B_in.Height;
 w_out:=_B_out.Width;
 h_out:=_B_out.Height;
 if (_x)>w_out-1 then exit; if (_x+w_out)<0 then exit;
 if (_y)>h_out-1 then exit; if (_y+h_out)<0 then exit;

 if _x<0 then x_corS:=abs(_x) else x_corS:=0;
 if _y<0 then y_corS:=abs(_y) else y_corS:=0;
 if (_x+w_in)>w_out then x_cor:=_x+w_in-w_out else x_cor:=0;
 if (_y+h_in)>h_out then y_cor:=_y+h_in-h_out else y_cor:=0;

  y_cor:=h_in-1-y_cor;
  tmp:=w_in-1-x_cor; _dd:=(100/255)/100;
  for y:=y_corS to y_cor do begin
     RowOut:= _B_out.ScanLine[y+_y];
     RowIn:= _B_in.ScanLine[y];
    for x:=x_corS to tmp do begin
         _d:=RowIn[x].rgbReserved*_dd;

          _r:= trunc(RowOut[x+_x].rgbtRed+(RowIn[x].rgbRed-RowOut[x+_x].rgbtRed)*_d);
         if _r>255 then _r:=255 else if _r<0 then _r:=0;

         _g:= trunc(RowOut[x+_x].rgbtGreen+(RowIn[x].rgbGreen-RowOut[x+_x].rgbtGreen)*_d);
         if _g>255 then _g:=255 else if _g<0 then _g:=0;

         _b:= trunc(RowOut[x+_x].rgbtBlue+(RowIn[x].rgbBlue-RowOut[x+_x].rgbtBlue)*_d);
         if _b>255 then _b:=255 else if _b<0 then _b:=0;

          RowOut[x+_x].rgbtRed:=_r;
          RowOut[x+_x].rgbtGreen:=_g;
          RowOut[x+_x].rgbtBlue:=_b;
  end; end;
end;

procedure Copy32clear(var _B_in:TBitmap);
var x, y: Integer; RowOut: PRGBAArray;
begin
  for y:=0 to _B_in.Height-1 do begin
    RowOut:= _B_in.ScanLine[y];
    for x:=0 to _B_in.Width-1 do begin
     RowOut[x].rgbReserved:=0;
     RowOut[x].rgbBlue:=0;
     RowOut[x].rgbGreen:=0; RowOut[x].rgbRed:=0;
     end;
  end;
end;

procedure Copy32clear_re(_B_in:TBitmap);
var x, y: Integer; RowOut: PRGBAArray;
begin
  for y:=0 to _B_in.Height-1 do begin
    RowOut:= _B_in.ScanLine[y];
    for x:=0 to _B_in.Width-1 do begin
     RowOut[x].rgbReserved:=255;

     end;
  end;
end;

procedure Set_alpha_render(_B_in:TBitmap);
var x, y ,rr,r,g,b: Integer; RowOut: PRGBAArray;
begin
  for y:=0 to _B_in.Height-1 do begin
    RowOut:= _B_in.ScanLine[y];
    for x:=0 to _B_in.Width-1 do begin
     r:=RowOut[x].rgbRed;
     g:=RowOut[x].rgbGreen;
     b:=RowOut[x].rgbBlue;

     rr:=trunc((r+g+b)/3);
     if(rr<0) then rr:=0 else if(rr>255) then rr:=255;

     RowOut[x].rgbReserved:=rr;
     RowOut[x].rgbBlue:=255;
     RowOut[x].rgbGreen:=255;
     RowOut[x].rgbRed:=255;
     end;
  end;
end;

procedure CopyBitmapAlfa32to32(_B_in,_B_out:Tbitmap; _x,_y:integer);
var x, y: Integer; _r,_b,_g:integer;
    w_in,h_in,w_out,h_out,tmp,x_cor,y_cor,x_corS,y_corS: Integer;
    RowOut,RowIn:PRGBAArray;
    _d,_dd:double;
begin
 try
 w_in:=_B_in.Width;
 h_in:=_B_in.Height;
 w_out:=_B_out.Width;
 h_out:=_B_out.Height;
 if (_x)>w_out-1 then exit; if (_x+w_out)<0 then exit;
 if (_y)>h_out-1 then exit; if (_y+h_out)<0 then exit;

 if _x<0 then x_corS:=abs(_x) else x_corS:=0;
 if _y<0 then y_corS:=abs(_y) else y_corS:=0;
 if (_x+w_in)>w_out then x_cor:=_x+w_in-w_out else x_cor:=0;
 if (_y+h_in)>h_out then y_cor:=_y+h_in-h_out else y_cor:=0;

  y_cor:=h_in-1-y_cor;
  tmp:=w_in-1-x_cor; _dd:=(100/255)/100;
  for y:=y_corS to y_cor do begin
     RowOut:= _B_out.ScanLine[y+_y];
     RowIn:= _B_in.ScanLine[y];
    for x:=x_corS to tmp do begin
         _d:=RowIn[x].rgbReserved*_dd;

          _r:= trunc(RowOut[x+_x].rgbRed+(RowIn[x].rgbRed-RowOut[x+_x].rgbRed)*_d);
         if _r>255 then _r:=255 else if _r<0 then _r:=0;

         _g:= trunc(RowOut[x+_x].rgbGreen+(RowIn[x].rgbGreen-RowOut[x+_x].rgbGreen)*_d);
         if _g>255 then _g:=255 else if _g<0 then _g:=0;

         _b:= trunc(RowOut[x+_x].rgbBlue+(RowIn[x].rgbBlue-RowOut[x+_x].rgbBlue)*_d);
         if _b>255 then _b:=255 else if _b<0 then _b:=0;

          RowOut[x+_x].rgbRed:=_r;
          RowOut[x+_x].rgbGreen:=_g;
          RowOut[x+_x].rgbBlue:=_b;
        if RowOut[x+_x].rgbReserved<(RowIn[x].rgbReserved-4) then RowOut[x+_x].rgbReserved:=RowIn[x].rgbReserved-4;

  end; end;
  except

  end;
end;


procedure PrepareColorBitmap(BT:Tbitmap; Color:Tcolor);
var x, y: Integer; ras:double; RowOut: PRGBAArray;
    _r,_b,_g:integer; rc1,bc1,gc1:byte;
begin
  rc1:=GetRValue(Color); gc1:=GetGValue(Color); bc1:=GetBValue(Color);
  for y:=0 to BT.Height-1 do begin
     RowOut:= BT.ScanLine[y];
    for x:=0 to BT.Width-1 do begin
      ras:=RowOut[x].rgbReserved/255;
      _r:=trunc( rc1*RowOut[x].rgbRed/255+ RowOut[x].rgbRed*((rc1)/255)  );
      if _r>255 then _r:=255; if _r<0 then _r:=0;

      _g:=trunc( gc1*RowOut[x].rgbGreen/255+ RowOut[x].rgbGreen*((gc1)/255) );
      if _g>255 then _g:=255; if _g<0 then _g:=0;

      _b:=trunc( bc1*RowOut[x].rgbBlue/255+ RowOut[x].rgbBlue*((bc1)/255) );
      if _b>255 then _b:=255; if _b<0 then _b:=0;

      RowOut[x].rgbRed:=_r;
      RowOut[x].rgbGreen:=_g;
      RowOut[x].rgbBlue:=_b;
    end;
  end
end;

procedure Copy32assing(bt1,bt2:TBitmap);
var x, y: Integer; R1,R2:PRGBAArray;  R3,R4:PRGBArray;
begin
//млять, пол часа потерял чтобы понять, какого фига после assign старое изображение остается,
//менеджер памяти сволочь прикалывается, до любого изменения указывает на старый объект в памяти
//пришлось написать этот велосипед
  if(bt1.PixelFormat=pf24bit) then begin
   bt2.PixelFormat:=pf24bit;
   bt2.Width:=bt1.Width;
   bt2.Height:=bt1.Height;
     for y:=0 to bt1.Height-1 do begin
      R3:=bt1.ScanLine[y];
      R4:=bt2.ScanLine[y];
      for x:=0 to bt1.Width-1 do begin
        R4[x]:=R3[x];
      end;
     end;
  end else begin
   bt1.PixelFormat:=pf32bit;
   bt2.PixelFormat:=pf32bit;
   bt2.Width:=bt1.Width;
   bt2.Height:=bt1.Height;
    for y:=0 to bt1.Height-1 do begin
      R1:=bt1.ScanLine[y];
      R2:=bt2.ScanLine[y];
      for x:=0 to bt1.Width-1 do begin
        R2[x]:=R1[x];
      end;
     end;
  end;
end;

function ColorLighter(const Color: TColor; const Percent: Byte):TColor;
var R,G,B:Byte; FColor:TColorRef;
begin
  FColor:=ColorToRGB(Color);

  R:=GetRValue(FColor);
  G:=GetGValue(FColor);
  B:=GetBValue(FColor);

  R:=R+(((255-r)*Percent) div 100);
  G:=G+(((255-g)*Percent) div 100);
  B:=B+(((255-b)*Percent) div 100);

  Result:=TColor(RGB(R,G,B));
end;

function ColorDarker(const OriginalColor: TColor; const Percent: Byte): TColor;
var R,G,B:Integer; WinColor:Integer;
begin
  WinColor:=ColorToRGB(OriginalColor);

  R:=GetRValue(WinColor);
  G:=GetGValue(WinColor);
  B:=GetBValue(WinColor);

  R:=R-Percent;
  G:=G-Percent;
  B:=B-Percent;

  if R<0 then R:=0;
  if G<0 then G:=0;
  if B<0 then B:=0;

  Result:=TColor(RGB(R,G,B));
end;

end.
