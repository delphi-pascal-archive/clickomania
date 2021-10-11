unit p_u;

interface

uses
  Windows, Messages, SysUtils, Classes, zlib;

procedure Pack_Memory2(var _in,_out:TMemoryStream);
procedure Pack_Memory(var _in:TMemoryStream);
procedure UnPack_Memory2(var _in,_out:TMemoryStream);
procedure UnPack_Memory(var _in:TMemoryStream);

implementation


procedure Pack_Memory2(var _in,_out:TMemoryStream);
var
  TmpStream : TMemoryStream; CmpStream : TCompressionStream;
begin
  TmpStream := TMemoryStream.Create;
  CmpStream := TCompressionStream.Create (clMax, TmpStream);
 // application.ProcessMessages;
  _in.Seek (0, 0);
  CmpStream.CopyFrom (_in, _in.Size);
  CmpStream.Free;
//  FCompressionRate := 100 - TmpStream.Size / _in.Size * 100;
  TmpStream.Position:=0;
  _out.Position:=0;
  _out.SetSize(TmpStream.Size);
  _out.CopyFrom (TmpStream, TmpStream.Size);
  TmpStream.Free;
end;

procedure CompressStream(inpStream, outStream: TStream); 
var 
  InpBuf, OutBuf: Pointer; 
  InpBytes, OutBytes: Integer; 
begin 
  InpBuf := nil; 
  OutBuf := nil; 
  try 
    GetMem(InpBuf, inpStream.Size); 
    inpStream.Position := 0; 
    InpBytes := inpStream.Read(InpBuf^, inpStream.Size); 
    CompressBuf(InpBuf, InpBytes, OutBuf, OutBytes); 
    outStream.Write(OutBuf^, OutBytes); 
  finally 
    if InpBuf <> nil then FreeMem(InpBuf); 
    if OutBuf <> nil then FreeMem(OutBuf); 
  end; 
end; 


procedure Pack_Memory(var _in:TMemoryStream);
var
  TmpStream : TMemoryStream; CmpStream : TCompressionStream;
begin
  TmpStream := TMemoryStream.Create;
  CmpStream := TCompressionStream.Create (clMax, TmpStream);
//  application.ProcessMessages;
  _in.Seek (0, 0);
  CmpStream.CopyFrom (_in, _in.Size);
  CmpStream.Free;
  TmpStream.Position:=0;
  _in.Position:=0;
  _in.SetSize(TmpStream.Size);
  _in.CopyFrom (TmpStream, TmpStream.Size);
  TmpStream.Free;
end;

procedure UnPack_Memory2(var _in,_out:TMemoryStream);
const
  BufSize = 1024;
var
  Buf : pointer;
  Readed : Integer;
  FDecompressedStream:TMemoryStream;
  DecompStream : TDecompressionStream;
begin
      _in.Seek (0, 0);

        DecompStream := TDecompressionStream.Create(_in);
        try

            FDecompressedStream := TMemoryStream.Create;
            GetMem (Buf, BufSize);
            try
              repeat
                Readed := DecompStream.read (Buf^, BufSize);
                if Readed > 0
                  then FDecompressedStream.Write (Buf^, Readed);
              until Readed <= 0;
            finally
              FreeMem (Buf, BufSize);
            end;

        finally
          DecompStream.Free;
        end;

        FDecompressedStream.Seek (0, 0);

        _out.Seek (0, 0);
        _out.CopyFrom(FDecompressedStream, FDecompressedStream.Size);

end;

procedure DecompressStream(inpStream, outStream: TMemoryStream);
var 
  InpBuf, OutBuf: Pointer; 
  OutBytes, sz: Integer; 
begin 
  InpBuf := nil; 
  OutBuf := nil; 
  sz     := inpStream.Size - inpStream.Position; 
  if sz > 0 then  
    try 
      GetMem(InpBuf, sz); 
      inpStream.Read(InpBuf^, sz); 
      DecompressBuf(InpBuf, sz, 0, OutBuf, OutBytes); 
      outStream.Write(OutBuf^, OutBytes); 
    finally 
      if InpBuf <> nil then FreeMem(InpBuf); 
      if OutBuf <> nil then FreeMem(OutBuf);
    end;
  outStream.Position := 0;
end;

procedure UnPack_Memory(var _in:TMemoryStream);
var _out:TMemoryStream;
begin
   _out := TMemoryStream.Create;
   _in.Position:=0;
   DecompressStream(_in, _out);
  _in.Seek(0,0);
  _in.CopyFrom(_out, _out.Size);
   _out.Free;
end;









end.
