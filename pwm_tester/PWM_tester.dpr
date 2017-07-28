program PWM_tester;

uses
  Vcl.Forms,
  PWM_Tester_Unit in 'PWM_Tester_Unit.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
