program Clicks;

uses
  Forms,
  main in 'main.pas' {mainform},
  settings in 'settings.pas' {FormSettings};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'DS_Clickomania';
  Application.CreateForm(Tmainform, mainform);
  Application.CreateForm(TFormSettings, FormSettings);
  Application.Run;
end.
