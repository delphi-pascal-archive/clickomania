unit th_ti;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes;

type
  TThread_timer = class;
  TCounterThread = class(TThread)
  private
    FOwner: TThread_timer;
    FStop:  THandle;
    PacingCounter,lPacingCounter,rPacingCounter:LongInt;
    Finterval:LongInt;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean);
    destructor Destroy; override;
    procedure SetInterval(const Value: cardinal);
  end;

  TThread_timer = class
  private
    FOnTimer:TNotifyEvent;
    FThread:TCounterThread;
    FEnabled:boolean;
    FInterval:cardinal;
    procedure DoTimer;
    procedure SetEnabled(const Value: boolean);
    procedure SetInterval(const Value: cardinal);
  public
   constructor Create;
   destructor Destroy; override;

  published
    property OnTimer: TNotifyEvent Read FOnTimer Write FOnTimer;
    property Enabled: boolean Read FEnabled Write SetEnabled;
    property Interval: cardinal Read FInterval Write SetInterval;
  end;



implementation

//=========================== Timer =====================================

constructor TThread_timer.Create;
begin
  inherited;
  FEnabled:=False;
  FInterval:=1000;
  FThread:=TCounterThread.Create(True);
  FThread.FOwner:=Self;
  FThread.Priority:=tpNormal;
end;

destructor TThread_timer.Destroy;
begin
  Enabled:=False;
  FThread.Terminate;
  if FThread.Suspended then FThread.Resume;
  FThread.Free;
  inherited Destroy;
end;

procedure TThread_timer.DoTimer;
begin
  if Enabled and Assigned(FOnTimer) then
    try
      FOnTimer(Self);
    except
    end;
end;

procedure TThread_timer.SetEnabled(const Value: boolean);
begin
  if Value<>FEnabled then begin
    FEnabled:=Value;

    if FEnabled then begin
      if (FInterval>0) then begin
        FThread.Resume;
      end;
    end else FThread.Suspend;

  end;
end;


procedure TThread_timer.SetInterval(const Value: cardinal);
var tmpEnabled:boolean; tmpInterval:cardinal;
begin
  if Value<>FInterval then begin
    tmpEnabled:=FEnabled;
    tmpInterval:=FInterval;
    Enabled:=False;

    if (FInterval=0) then
      FInterval:=tmpInterval
    else
      FInterval:=Value;

    FThread.SetInterval(FInterval);

    Enabled:=tmpEnabled;
  end;
end;

constructor TCounterThread.Create(CreateSuspennded: Boolean);
begin
  inherited Create(CreateSuspennded);
  PacingCounter:=0;
  lPacingCounter:=0;
  rPacingCounter:=0;
  Finterval:=1000;
end;

destructor TCounterThread.Destroy;
begin
 Terminate;
 inherited;
end;

procedure TCounterThread.Execute;
begin
 while not(terminated) do begin
        if not(PacingCounter-rPacingCounter<Finterval) then begin
              rPacingCounter:=PacingCounter;
              Synchronize(FOwner.DoTimer);
        end;
        PacingCounter:=GetTickCount;
        sleep(2);
 end;
end;

procedure TCounterThread.SetInterval(const Value: cardinal);
begin
  if (Value<>FInterval)and(Value>0) then begin
    Finterval:=Value;
  end;
end;


end.
