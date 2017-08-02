unit ConvMainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Types, System.StrUtils,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm2 = class(TForm)
    OpenDialog1: TOpenDialog;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    EditEngine: TEdit;
    EditPropeller: TEdit;
    EditEngineWeight: TEdit;
    Label5: TLabel;
    ButtonOpen: TButton;
    EditAccumulator: TEdit;
    Memo1: TMemo;
    ButtonSave: TButton;
    SaveDialog1: TSaveDialog;
    procedure ButtonOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
  private
    engine_weight: integer;
    infilename: string;
    TmpList, OutList: TStringList;
    fs: TFormatSettings;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.ButtonOpenClick(Sender: TObject);
var
  TmpFile: TextFile;
  OneRow: TStringDynArray;
  tmpstr: string;
  i: integer;
  tmp_i: integer;
  tmp_thrust, tmp_power, tmp_eff: real;
begin
  ButtonSave.Enabled := false;

  if not trystrtoint(EditEngineWeight.Text, engine_weight) then
    exit;

  OpenDialog1.Title := 'Select csv file';
  OpenDialog1.Filter := 'CSV files (*.csv)|*.CSV';

  if not OpenDialog1.Execute then
    exit;

  infilename := OpenDialog1.FileName;
  if not FileExists(infilename) then
    exit;

  OneRow := SplitString(changefileext(ExtractFileName(infilename), ''), '_');
  if Length(OneRow) <> 3 then
    exit;

  EditEngine.Text := OneRow[0];
  EditPropeller.Text := OneRow[1];
  EditAccumulator.Text := OneRow[2];

  // reading csv file to StringList
  TmpList.Clear;
  OutList.Clear;
  AssignFile(TmpFile, infilename);
  Reset(TmpFile);
  while not EOF(TmpFile) do
  begin
    Readln(TmpFile, tmpstr);
    TmpList.Add(tmpstr);
  end;
  CloseFile(TmpFile);

  OutList.Append('Engine: ' + EditEngine.Text);
  OutList.Append('Engine weight (EW): ' + inttostr(engine_weight) + ' g');
  OutList.Append('Propeller: ' + EditPropeller.Text);
  OutList.Append('Accumulator: ' + EditAccumulator.Text);
  OutList.Append
    ('PWM;U (V);I (A);P (W);Thrust (g);E (g/W);T-EW (g);Eabs (g/W)');

  for i := 0 to TmpList.Count - 1 do
  begin
    OneRow := SplitString(TmpList.Strings[i], ';');
    if Length(OneRow) <> 6 then
      continue;
    if not trystrtoint(OneRow[0], tmp_i) then
      continue;
    tmpstr := TmpList.Strings[i];
    try
      tmp_power := strtofloat(OneRow[3], fs);
      tmp_thrust := strtofloat(OneRow[4], fs);
    except
      continue;
    end;
    if tmp_power > 1 then
      tmp_eff := (tmp_thrust - engine_weight) / tmp_power
    else
      tmp_eff := 0;

    tmpstr := tmpstr + format(';%.0f;%.1f', [tmp_thrust - engine_weight,
      tmp_eff], fs);

    OutList.Append(tmpstr);
  end;

  Memo1.Clear;
  Memo1.Lines.AddStrings(OutList);

  if OutList.Count = 16 then
    ButtonSave.Enabled := true;
end;

procedure TForm2.ButtonSaveClick(Sender: TObject);
begin
  SaveDialog1.Title := 'Save csv file';
  SaveDialog1.Filter := 'CSV files (*.csv)|*.CSV';
  SaveDialog1.FileName := infilename;
  if SaveDialog1.Execute then
  begin
    OutList.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  TmpList := TStringList.Create;
  OutList := TStringList.Create;
  fs := TFormatSettings.Create;
  fs.DecimalSeparator := ',';
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  TmpList.Free;
  OutList.Free;
end;

end.
