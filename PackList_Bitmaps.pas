{******************************************************}
{                PackList_Bitmaps                      }
{                                                      }
{    Copyright © 2007, Naumenko Anton Aka antonn.      }
{                     v 1.0                            }
{                   04.11.2007                         }
{                                                      }
{  example:                                            }
{                                                      }
{  var PackListBitmaps:TPackListBitmaps;               }
{  begin                                               }
{    PackListBitmaps:=TPackListBitmaps.Create;         }
{    PackListBitmaps.Add_bitmap_from_file('12.bmp');   }
{    PackListBitmaps.Add_bitmap_from_file('13.bmp')    }
{    PackListBitmaps.Save('11.txt');                   }
{                                                      }
{    PackListBitmaps.Load('11.txt');                   }
{                                                      }
{******************************************************}
unit PackList_Bitmaps;

interface

uses
  Windows,Classes,Graphics,sysutils,p_u;

type
  TElement_PackListBitmaps = record
   pos:integer;
   size:integer;
  end;

  TPE_PackListBitmaps = record
    _sing:dword;
    Count:integer;
    pack:boolean;
  end;

  pPackListBitmapsE = ^TPackListBitmapsE;
  TPackListBitmapsE = record
   Bitmap:TBitmap;
   num:integer;
   w,h:integer;
  end;

  TPackListBitmaps = class
  private
   FList:TList;
  protected
  public
   constructor Create;
   destructor Destroy; override;

   procedure clear;
   function GetCountBitmaps:integer;
   function GetBitmap(num:integer):pPackListBitmapsE;

   procedure Add_bitmap(Bitmap:Tbitmap);
   procedure Add_bitmap_from_file(fi:string);
   procedure Delete_bitmap(num:integer);

   procedure Save(filename:string);
   procedure Load(filename:string);
   procedure Save_num_bitmap(filename:string; num:integer);
  end;

implementation

constructor TPackListBitmaps.Create;
begin
 inherited;
  FList:=TList.Create;
end;

destructor TPackListBitmaps.Destroy;
var i:integer; Cadr:pPackListBitmapsE;
begin
  for i:=0 to FList.Count-1 do begin
   Cadr:=pPackListBitmapsE(FList.Items[i]);
   Cadr.Bitmap.Free;
   Dispose(Cadr);
  end;
  FList.Free;
 inherited;
end;

procedure TPackListBitmaps.Add_bitmap(Bitmap:Tbitmap);
var Cadr:pPackListBitmapsE;
begin
 New(Cadr);
 Cadr.Bitmap:=TBitmap.Create;
 Cadr.Bitmap.Assign(Bitmap);
 Cadr.w:=Bitmap.Width;
 Cadr.h:=Bitmap.Height;
 Cadr.num:=0;
 Flist.Add(TObject(Cadr));
end;

procedure TPackListBitmaps.Add_bitmap_from_file(fi:string);
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

procedure TPackListBitmaps.Delete_bitmap(num:integer);
var Cadr:pPackListBitmapsE;
begin
if num>=FList.Count then exit;
 Cadr:= pPackListBitmapsE(FList.Items[num]);
 Cadr.Bitmap.Free;
 Dispose(Cadr);
 FList.Delete(num);
end;

procedure TPackListBitmaps.clear;
var Cadr:pPackListBitmapsE; i:integer;
begin
 for i:=FList.Count-1 downto 0 do begin
   Cadr:=pPackListBitmapsE(FList.Items[i]);
   Cadr.Bitmap.Free;
   Dispose(Cadr);
   FList.Delete(i);
 end;
end;

procedure TPackListBitmaps.Save(filename:string);
var _MIn,_MBit:TMemoryStream; i:integer;  PE:TPE_PackListBitmaps; BE:TElement_PackListBitmaps; Cadr:pPackListBitmapsE;
    summPos:integer;
begin
 _MIn:=TMemoryStream.Create;
 _MBit:=TMemoryStream.Create;
 try
   PE.Count:=GetCountBitmaps;
   PE.pack:=false;
   PE._sing:=1396853840;
  _MIn.Write(PE,sizeof(TPE_PackListBitmaps));
   BE.pos:=0;
   BE.size:=0;

  for i:=0 to PE.Count-1 do
   _MIn.Write(BE,sizeof(TElement_PackListBitmaps));

  summPos:=0;
  for i:=0 to PE.Count-1 do begin
   Cadr:=GetBitmap(i);
   _MBit.Clear;
   _MBit.SetSize(0);
   Cadr.Bitmap.SaveToStream(_MBit);
   p_u.Pack_Memory(_MBit);
   _MIn.SetSize(sizeof(TPE_PackListBitmaps)+sizeof(TElement_PackListBitmaps)*(PE.Count)+summPos+_MBit.Size);
   BE.size:=_MBit.Size;
   BE.pos:=summPos;
   _MIn.Position:=sizeof(TPE_PackListBitmaps)+i*sizeof(TElement_PackListBitmaps);
   _MIn.Write(BE,sizeof(TElement_PackListBitmaps));
   _MBit.Position:=0;
   _MIn.Position:=sizeof(TPE_PackListBitmaps)+sizeof(TElement_PackListBitmaps)*(PE.Count)+summPos;
   summPos:=summPos+BE.size;
   _MIn.CopyFrom(_MBit,_MBit.Size);
   _MBit.Clear;
  end;

   _MIn.SaveToFile(filename);
 finally
  _MIn.Free;
  _MBit.Free;
 end;
end;

procedure TPackListBitmaps.Load(filename:string);
var _MIn,_MBit:TMemoryStream; i:integer;  PE:TPE_PackListBitmaps; BE:TElement_PackListBitmaps;
    summPos:integer; _b:Tbitmap;
begin
 _MIn:=TMemoryStream.Create;
 _MBit:=TMemoryStream.Create;
 _b:=TBitmap.Create;
 try
  _MIn.LoadFromFile(filename);
  _MIn.Read(PE,sizeof(TPE_PackListBitmaps));
  summPos:=0;

  for i:=0 to pe.Count-1 do begin
   _MIn.Position:=sizeof(TPE_PackListBitmaps)+i*sizeof(TElement_PackListBitmaps);
   _MIn.ReadBuffer(BE,sizeof(TElement_PackListBitmaps));
   _MIn.Position:=sizeof(TPE_PackListBitmaps)+sizeof(TElement_PackListBitmaps)*(PE.Count)+summPos;
   summPos:=summPos+BE.size;
   _MBit.SetSize(BE.size);
   _MBit.Position:=0;
   _MBit.CopyFrom(_MIn,_MBit.size);
   _MBit.Position:=0;
   p_u.UnPack_Memory(_MBit);
   _MBit.Position:=0;
   _b.LoadFromStream(_MBit);
   Add_bitmap(_b);
  end;
 finally
  _MBit.Free;
  _MIn.Free;
  _b.Free;
 end;
end;

procedure TPackListBitmaps.Save_num_bitmap(filename:string; num:integer);
begin
 pPackListBitmapsE(FList.Items[num]).Bitmap.SaveToFile(filename);
end;

function TPackListBitmaps.GetCountBitmaps:integer;
begin
 result:=FList.Count;
end;

function TPackListBitmaps.GetBitmap(num:integer):pPackListBitmapsE;
begin
 result:=pPackListBitmapsE(FList.Items[num]);
end;

end.
