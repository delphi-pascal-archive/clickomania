unit graff_asm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,Forms,Graphics,dialogs;


  procedure GD_Draw_alpha_MMX(BTSource,BTDest:TBitmap; x,y:integer);



implementation

uses main;

function DIBBits(BMP: TBitmap): Pointer;
var Section:TDIBSECTION;
begin
BMP.HandleType:=bmDIB;
GetObject(BMP.Handle,sizeof(TDIBSECTION),@Section);
Result:=Section.dsBm.bmBits;
end;

function ScanLineSize(BMP: TBitmap): Integer;
var Section:TDIBSECTION;
begin
BMP.HandleType:=bmDIB;
GetObject(BMP.Handle,sizeof(TDIBSECTION),@Section);
Result:=((Section.dsBmih.biBitCount * Section.dsBmih.biWidth + 31) shr 3) and $FFFFFFFC;;
end;

procedure GD_Draw_alpha_MMX(BTSource,BTDest:TBitmap; x,y:integer);
var SrcBits: DWORD; DstBits: DWORD;
    xTo, sx, YTo, ddx, ddy, sy, w, h, dstw, dsth: integer;
    inc1, inc2: integer;
begin
 { SrcBits:=DWORD(@P^);
  DstBits:=DWORD(@P^);}
  w:=BTSource.Width; h:=BTSource.Height;
  dstw:=BTDest.Width; dsth:=BTDest.Height;
  XTo:=x+W-1;  YTo:=y+H-1;
  if(y>=dstH)or(x>=dstW)or(YTo<0)or(XTo<0) then exit;
  asm
    xor  eax, eax
    mov  ddx, eax
    mov  ddy, eax
  end;
  sx:=W; sy:=H;
  if X<0 then begin
      ddx:=-X;
      inc(sx,X);
      x:=0;
  end;
  if Y<0 then begin
      ddy:=-Y;
      inc(sy,Y);
      y:=0;
  end;
  if XTo>=dstw then dec( sx, XTo-dstw+1);
  if YTo>=dsth then dec( sy, YTo-dsth+1);
  if (sx<=0) or (sy<=0) then exit;

    inc1:=ScanLineSize(BTDest);
    inc2:=ScanLineSize(BTSource);

    {SrcBits:=pointer( integer(BTSource.scanline[0]));
    DstBits:=pointer( integer(BTDest.scanline[0]));    }
    SrcBits :=DWORD( DWORD( DIBBits(BTSource))+ ddy*inc2 + ddx*4);
    DstBits :=DWORD( DWORD( DIBBits(BTDest)) + y*inc1 + x*4 );

   // messagedlg('fuck: '+inttostr(SrcBits),mterror,[mbOK],0);

  //  SrcBits :=DWORD( integer( BTSource.ScanLine[ddy])+ddx*4);
  //  messagedlg('fuck: '+inttostr(SrcBits),mterror,[mbOK],0);

    

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

   // mov   al, [esi+3]
    mov   al, [edi+3]
    cmp bl,al
    jb @set_al
    mov [edi+3],bl
    @set_al:

  //  mov [edi+3],bh

   // mov [edi+3],$000000FF

   { cmp  al, dl
    jge @set_al
    mov [edi+3],dl
    jmp @set_ok
    @set_al:
    mov [edi+3],al
    @set_ok: }

 //   mov   [edi+3], dl

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

end.
