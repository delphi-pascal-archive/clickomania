unit settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, main;

type
  TFormSettings = class(TForm)
    e_x: TEdit;
    e_y: TEdit;
    cb_lang: TComboBox;
    l_wh: TLabel;
    BOK: TButton;
    BNO: TButton;
    cb_cou: TComboBox;
    lcou: TLabel;
    llang: TLabel;
    cb_ui: TComboBox;
    lui: TLabel;
    procedure e_xKeyPress(Sender: TObject; var Key: Char);
    procedure e_xChange(Sender: TObject);
    procedure BNOClick(Sender: TObject);
  private
    { Private declarations }
  public
    function GetSettings(var default_settings:tdefault_settings):integer;
  end;

var
  FormSettings: TFormSettings;

implementation

{$R *.dfm}

function TFormSettings.GetSettings(var default_settings:tdefault_settings):integer;
var i,ii:integer;
begin
 tag:=0;
 result:=-1;
 e_x.Text:=inttostr(default_settings.w);
 e_y.Text:=inttostr(default_settings.h);
 cb_cou.ItemIndex:=default_settings.cou-2;

 //ну да, глупо, но что поделаешь :)
 if(default_settings.lang) then begin
  cb_lang.ItemIndex:=0;
  caption:='Settings';
  BNO.Caption:='Cancel';
  l_wh.Caption:='Size';
  lcou.Caption:='Color count';
  llang.Caption:='Language';
  lui.Caption:='Use Icons';
  cb_ui.Clear;
  cb_ui.Items.Add('Yes');
  cb_ui.Items.Add('No');
 end else begin
  cb_lang.ItemIndex:=1;
  caption:='Настройки';
  BNO.Caption:='Отмена';
  l_wh.Caption:='Размер поля';
  lcou.Caption:='Кол-во фишек';
  llang.Caption:='Язык';
  lui.Caption:='Иконки';
  cb_ui.Clear;
  cb_ui.Items.Add('Да');
  cb_ui.Items.Add('Нет');
 end;

 if(default_settings.use_icon) then cb_ui.ItemIndex:=0 else cb_ui.ItemIndex:=1;

 showmodal;
 if(tag=1) then begin
  result:=1;

 default_settings.cou:=cb_cou.ItemIndex+2;
  if(default_settings.cou<2) then default_settings.cou:=2 else
    if(default_settings.cou>7) then default_settings.cou:=7;

 if(cb_lang.ItemIndex=1) then default_settings.lang:=false else default_settings.lang:=true;
 if(cb_ui.ItemIndex=1) then default_settings.use_icon:=false else default_settings.use_icon:=true;

 i:=default_settings.w;
  if(length(e_x.Text)>0) then
   if(strtoint(e_x.Text)<7) then
    default_settings.w:=7 else
     if(strtoint(e_x.Text)>255) then
      default_settings.w:=255 else
      default_settings.w:=strtoint(e_x.Text);

 ii:=default_settings.h;
  if(length(e_y.Text)>0) then
   if(strtoint(e_y.Text)<7) then
    default_settings.h:=7 else
     if(strtoint(e_y.Text)>255) then
      default_settings.h:=255 else
      default_settings.h:=strtoint(e_y.Text);

  if(i<>default_settings.w)or(ii<>default_settings.h) then begin
    result:=2;
  end;
 end;
end;

procedure TFormSettings.e_xKeyPress(Sender: TObject; var Key: Char);
begin
 if not(Key in ['0'..'9']) then Key:=#0;
end;

procedure TFormSettings.e_xChange(Sender: TObject);
begin
 if(length((sender as TEdit).Text)>0) then begin
    if(strtoint((sender as TEdit).Text)>255) then
     (sender as TEdit).Text:='255'; //издержки байта :)
 end;
end;

procedure TFormSettings.BNOClick(Sender: TObject);
begin
tag:=(sender as tbutton).Tag;
close;
end;

end.
