unit PWM_Tester_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Types, System.Math,
  System.IniFiles, System.StrUtils, System.DateUtils,
  Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Controls,
  Vcl.Graphics, Vcl.Forms,
  CPort, CPortCtl, Vcl.imaging.pngimage;

const
  pwm_step = 100;
  time_per_step = 6000;
  time_accel = 1000;

type
  TForm1 = class(TForm)
    ComPort1: TComPort;
    ComComboBox1: TComComboBox;
    ComLed1: TComLed;
    ComLed2: TComLed;
    ButtonConnect: TButton;
    Label1: TLabel;
    LabelU: TLabel;
    LabelI: TLabel;
    LabelPWM: TLabel;
    LabelT: TLabel;
    Memo1: TMemo;
    ButtonStartTest: TButton;
    Timer1: TTimer;
    EditEngine: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    EditPropeller: TEdit;
    Label4: TLabel;
    ComboBoxAccum: TComboBox;
    TrackBarPWM: TTrackBar;
    LabelPWMAct: TLabel;
    ButtonCSVtoPNG: TButton;
    OpenDialog1: TOpenDialog;
    EditEngineWeight: TEdit;
    Label5: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComComboBox1Change(Sender: TObject);
    procedure ButtonConnectClick(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure ButtonStartTestClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure finishtest;
    procedure TrackBarPWMChange(Sender: TObject);
    procedure ButtonCSVtoPNGClick(Sender: TObject);
    procedure CSVtoPNG(infilename: string);
  private
    ini_filename: string;
    rxed_string: string;
    fs: TFormatSettings;
    //
    LastEventTime: TDateTime;
    curr_pwm, actual_pwm: Integer;
    test_started: boolean;
    //
    summ_u, summ_i, summ_t: real;
    sample_counter: Integer;
    engine_weight: Integer;
    //
    csv_file: TextFile;
    csv_filename: string;
    font_size: Integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.ButtonConnectClick(Sender: TObject);
begin
  ComPort1.Connected := not ComPort1.Connected;

  if ComPort1.Connected then
  begin
    ButtonConnect.Caption := 'Disconnnect';
    ButtonConnect.Tag := 1;
    ButtonStartTest.Enabled := true;
  end
  else
  begin
    ButtonConnect.Caption := 'Connnect';
    ButtonConnect.Tag := 0;
    ButtonStartTest.Enabled := false;
  end;
end;

procedure TForm1.ButtonCSVtoPNGClick(Sender: TObject);
var
  tmpstr: string;
begin
  OpenDialog1.Title := 'Select csv file';
  OpenDialog1.Filter := 'CSV files (*.csv)|*.CSV';

  if OpenDialog1.Execute then
  begin
    tmpstr := OpenDialog1.FileName;
    if FileExists(tmpstr) then
      CSVtoPNG(tmpstr);
  end;
end;

procedure TForm1.ButtonStartTestClick(Sender: TObject);
begin
  if not trystrtoint(EditEngineWeight.Text, engine_weight) then
    Exit;

  curr_pwm := 1000;
  ComPort1.WriteStr('1000'#$0D);

  summ_u := 0;
  summ_i := 0;
  summ_t := 0;
  sample_counter := 0;

  ButtonStartTest.Enabled := false;
  ButtonConnect.Enabled := false;
  TrackBarPWM.Enabled := false;

  test_started := true;
  LastEventTime := Now();
  Timer1.Enabled := true;

  Memo1.Clear;
  Memo1.Lines.Append('Test started');
  csv_filename := EditEngine.Text + '_' + EditPropeller.Text + '_' +
    ComboBoxAccum.Items[ComboBoxAccum.ItemIndex] + '.csv';
  AssignFile(csv_file, csv_filename);
  Rewrite(csv_file);
  Writeln(csv_file, 'Engine: ' + EditEngine.Text);
  Writeln(csv_file, 'Engine weight (EW): ' + inttostr(engine_weight) + ' g');
  Writeln(csv_file, 'Propeller: ' + EditPropeller.Text);
  Writeln(csv_file, 'Accumulator: ' + ComboBoxAccum.Items
    [ComboBoxAccum.ItemIndex]);
  Writeln(csv_file,
    'PWM;U (V);I (A);P (W);Thrust (g);E (g/W);T-EW (g);Eabs (g/W)');
end;

procedure TForm1.ComComboBox1Change(Sender: TObject);
begin
  if ComPort1.Connected then
    ComPort1.Connected := false;

  ComPort1.Port := ComComboBox1.Items[ComComboBox1.ItemIndex];

  if ButtonConnect.Tag = 1 then
  begin
    ComPort1.Connected := true;

    if ComPort1.Connected then
    begin
      ButtonConnect.Caption := 'Disconnnect';
      ButtonConnect.Tag := 1;
    end
    else
    begin
      ButtonConnect.Caption := 'Connnect';
      ButtonConnect.Tag := 0;
    end;
  end;
end;

procedure TForm1.ComPort1RxChar(Sender: TObject; Count: Integer);
var
  tmpstr: ansistring;
  eol_pos: Integer;
  one_line: string;
  out_u, out_i, out_w, out_pwm, out_t: real;
  tmp_pwm: Integer;

  function GetValueFrom(st_str: string; end_str: string; instring: string;
    var outvalue: real): boolean;
  var
    pos1, pos2: Integer;
    substr: string;
  begin
    Result := false;
    pos1 := Pos(st_str, instring);
    if pos1 <= 0 then
      Exit;
    substr := TrimLeft(MidStr(instring, pos1 + Length(st_str), 1000));

    if end_str <> '' then
    begin
      pos2 := Pos(end_str, substr);
      if pos2 <= 0 then
        Exit;
      substr := LeftStr(substr, pos2 - 1);
    end;
    substr := Trim(substr);

    try
      outvalue := strtofloat(substr, fs);
      Result := true;
    finally
    end;
  end;

begin
  ComPort1.ReadStr(tmpstr, Count);
  rxed_string := rxed_string + tmpstr;

  while true do
  begin
    eol_pos := Pos(#$0D#$0A, rxed_string);
    if eol_pos <= 0 then
      break;
    one_line := LeftStr(rxed_string, eol_pos - 1);
    rxed_string := MidStr(rxed_string, eol_pos + 2, 10000);

    Label1.Caption := one_line;

    if GetValueFrom('U=', 'V', one_line, out_u) then
      LabelU.Caption := format('U=%fV', [out_u]);
    if GetValueFrom('I=', 'A', one_line, out_i) then
      LabelI.Caption := format('I=%fA', [out_i]);
    if GetValueFrom('PWM=', 'T', one_line, out_pwm) then
    begin
      LabelPWM.Caption := format('PWM=%f', [out_pwm]);
      tmp_pwm := round(out_pwm);
      LabelPWMAct.Caption := format('%d', [tmp_pwm]);
      if actual_pwm <> tmp_pwm then
      begin
        actual_pwm := tmp_pwm;
        TrackBarPWM.Position := tmp_pwm;
      end;
    end;
    if GetValueFrom('T=', 'g', one_line, out_t) then
      LabelT.Caption := format('Thrust=%fg', [out_t]);

    if test_started and (Millisecondsbetween(Now(), LastEventTime) > time_accel)
    then
    begin
      summ_u := summ_u + out_u;
      summ_i := summ_i + out_i;
      summ_t := summ_t + out_t;
      inc(sample_counter);
    end;

    if Pos('STOP', one_line) > 0 then
    begin
      if test_started then
      begin
        finishtest();
      end;
    end;
  end;
end;

procedure TForm1.CSVtoPNG(infilename: string);
var
  OutBitmap: TBitmap;
  png: TpngImage;
  TmpList: TStringList;
  TmpFile: TextFile;
  tmpstr: string;
  i, j: Integer;
  OneRow: TStringDynArray;
  rownum: Integer;
  tw: Integer;
  RowCount, ColumnCount: Integer;
  ColumnWidth: array of Integer;
  RowHeight: Integer;
  tmp_colw, tmp_rowh: Integer;
  w_inc: Integer;
  x_off: Integer;
begin
  // reading csv file to StringList
  TmpList := TStringList.Create;

  AssignFile(TmpFile, infilename);
  Reset(TmpFile);
  while not EOF(TmpFile) do
  begin
    Readln(TmpFile, tmpstr);
    TmpList.Add(tmpstr);
  end;
  CloseFile(TmpFile);

  // calculating counts of rows and columns
  ColumnCount := 0;
  for i := 0 to TmpList.Count - 1 do
  begin
    OneRow := SplitString(TmpList.Strings[i], ';');
    if Length(OneRow) > ColumnCount then
      ColumnCount := Length(OneRow);
  end;

  // initialyzing
  SetLength(ColumnWidth, ColumnCount);
  for i := 0 to ColumnCount - 1 do
    ColumnWidth[i] := 0;
  RowHeight := 0;

  // calculating width for each column
  OutBitmap := TBitmap.Create;
  OutBitmap.PixelFormat := pf24bit;
  OutBitmap.SetSize(500, 500);
  OutBitmap.Canvas.Font.Size := font_size;
  for i := 0 to TmpList.Count - 1 do
  begin
    OneRow := SplitString(TmpList.Strings[i], ';');
    // processing only normal strings, not titles
    if (Length(OneRow) > 1) and (OneRow[1] <> '') then
    begin
      for j := 0 to Length(OneRow) - 1 do
      begin
        tmp_rowh := OutBitmap.Canvas.TextHeight(OneRow[j]);
        tmp_colw := OutBitmap.Canvas.TextWidth(OneRow[j]);
        if tmp_rowh > RowHeight then
          RowHeight := tmp_rowh;
        if tmp_colw > ColumnWidth[j] then
          ColumnWidth[j] := tmp_colw;
      end;
    end;
  end;

  // total table size calculation
  tmp_rowh := (RowHeight + 2 * (RowHeight div 4) + 1) + 1;

  tmp_colw := 1;
  for i := 0 to Length(ColumnWidth) - 1 do
  begin
    ColumnWidth[i] := ColumnWidth[i] + 2 * (RowHeight div 4) + 1;
    tmp_colw := tmp_colw + ColumnWidth[i];
  end;
  tw := OutBitmap.Canvas.TextWidth(StringReplace(TmpList.Strings[0], ';', '',
    [rfReplaceAll])) + 2 * (RowHeight div 4) + 2;
  // title is too large - proportional increment for all columns
  if tmp_colw < tw then
  begin
    SetRoundMode(rmUp);
    w_inc := round((tw - tmp_colw) / Length(ColumnWidth));
    tmp_colw := 1;
    for i := 0 to Length(ColumnWidth) - 1 do
    begin
      ColumnWidth[i] := ColumnWidth[i] + w_inc;
      tmp_colw := tmp_colw + ColumnWidth[i];
    end;
  end;
  OutBitmap.SetSize(tmp_colw, tmp_rowh * TmpList.Count + 1);

  // drawing rows separators
  OutBitmap.Canvas.Pen.Color := RGB(128, 128, 128);
  for i := 0 to TmpList.Count do
  begin
    OutBitmap.Canvas.MoveTo(0, i * tmp_rowh);
    OutBitmap.Canvas.LineTo(OutBitmap.Width, i * tmp_rowh);
  end;

  // drawing columns separators
  OutBitmap.Canvas.MoveTo(0, 0);
  OutBitmap.Canvas.LineTo(0, OutBitmap.Height);
  OutBitmap.Canvas.MoveTo(OutBitmap.Width - 1, 0);
  OutBitmap.Canvas.LineTo(OutBitmap.Width - 1, OutBitmap.Height);

  // text in cells
  OutBitmap.Canvas.Font.Size := font_size;

  for rownum := 0 to TmpList.Count - 1 do
  begin
    OneRow := SplitString(TmpList.Strings[rownum], ';');
    if (Length(OneRow) < Length(ColumnWidth)) or
      ((Length(OneRow) > 1) and (OneRow[1] = '')) then
    begin
      OutBitmap.Canvas.TextOut(RowHeight div 4 + 1, RowHeight div 4 + 1 +
        tmp_rowh * rownum, StringReplace(TmpList.Strings[rownum], ';', '',
        [rfReplaceAll]));
    end
    else
    begin
      x_off := 1;
      for i := 0 to Length(OneRow) - 1 do
      begin
        tw := OutBitmap.Canvas.TextWidth(OneRow[i]);
        OutBitmap.Canvas.TextOut(x_off + (ColumnWidth[i] - tw) div 2,
          RowHeight div 4 + 1 + tmp_rowh * rownum, OneRow[i]);
        OutBitmap.Canvas.MoveTo(x_off - 1, tmp_rowh * rownum);
        OutBitmap.Canvas.LineTo(x_off - 1, tmp_rowh * (rownum + 1));
        inc(x_off, ColumnWidth[i]);
      end;
    end;
  end;

  png := TpngImage.Create;
  png.Assign(OutBitmap);
  png.SaveToFile(ChangeFileExt(infilename, '.png'));
  png.Free;

  OutBitmap.Free;
  TmpList.Free;
end;

procedure TForm1.finishtest;
begin
  Memo1.Lines.Append('Test stopped');
  test_started := false;

  ButtonStartTest.Enabled := true;
  ButtonConnect.Enabled := true;
  TrackBarPWM.Enabled := true;

  ComPort1.WriteStr('1000'#$0D);
  Timer1.Enabled := false;
  CloseFile(csv_file);
  CSVtoPNG(csv_filename);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ini: TIniFile;
  tmpstr: string;
  idx: Integer;
begin
  ini_filename := extractfilepath(paramstr(0)) + paramstr(1);
  if not FileExists(ini_filename) then
    ini_filename := extractfilepath(paramstr(0)) + 'settings.ini';

  EnumComPorts(ComComboBox1.Items);

  ini := TIniFile.Create(ini_filename);
  try
    tmpstr := ini.ReadString('common', 'port', 'com1');
    idx := ComComboBox1.Items.IndexOf(tmpstr);
    if idx >= 0 then
      ComComboBox1.ItemIndex := idx
    else
      ComComboBox1.ItemIndex := 0;

    ComPort1.Port := ComComboBox1.Items[ComComboBox1.ItemIndex];

    EditEngine.Text := ini.ReadString('common', 'engine', '');
    EditPropeller.Text := ini.ReadString('common', 'propeller', '');
    ComboBoxAccum.ItemIndex := ini.ReadInteger('common', 'accum', 0);
    font_size := ini.ReadInteger('common', 'font_size', 12);
  finally
    ini.Free;
  end;

  test_started := false;
  fs := TFormatSettings.Create;
  fs.DecimalSeparator := '.';
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  ini: TIniFile;
begin
  ComPort1.Close;

  ini := TIniFile.Create(ini_filename);
  try
    ini.WriteString('common', 'port', ComPort1.Port);

    ini.WriteString('common', 'engine', EditEngine.Text);
    ini.WriteString('common', 'propeller', EditPropeller.Text);
    ini.WriteInteger('common', 'accum', ComboBoxAccum.ItemIndex);
  finally
    ini.Free;
  end;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  m_u, m_i, m_p, m_t, m_t_abs, m_e, m_e_abs: real;
begin
  if not test_started then
    Exit;

  if Millisecondsbetween(LastEventTime, Now()) > time_per_step then
  begin
    m_u := summ_u / sample_counter;
    m_i := summ_i / sample_counter;
    m_p := m_u * m_i;
    m_t := summ_t / sample_counter;
    m_t_abs := m_t - engine_weight;
    if m_p > 1 then
    begin
      m_e := m_t / m_p;
      m_e_abs := m_t_abs / m_p;
    end
    else
    begin
      m_e := 0;
      m_e_abs := 0;
    end;
    Memo1.Lines.Append
      (format('PWM=%d Samples=%d U=%.1fV I=%.1fA P=%.1fW T=%.0fg E=%.1fg/W Tabs=%.0fg Eabs=%.1fg/W',
      [curr_pwm, sample_counter, m_u, m_i, m_p, m_t, m_e, m_t_abs,
      m_e_abs], fs));
    Writeln(csv_file, format('%d;%.1f;%.1f;%.1f;%.0f;%.1f;%.0f;%.1f',
      [curr_pwm, m_u, m_i, m_p, m_t, m_e, m_t_abs, m_e_abs]));

    summ_u := 0;
    summ_i := 0;
    summ_t := 0;
    sample_counter := 0;

    curr_pwm := curr_pwm + pwm_step;
    if curr_pwm > 2000 then
    begin
      finishtest();
    end
    else
    begin
      ComPort1.WriteStr(inttostr(curr_pwm) + #$0D);
      LastEventTime := Now();
    end;
  end;
end;

procedure TForm1.TrackBarPWMChange(Sender: TObject);
begin
  if TrackBarPWM.Position = actual_pwm then
    Exit;

  actual_pwm := TrackBarPWM.Position;
  if ComPort1.Connected then
    ComPort1.WriteStr(inttostr(actual_pwm) + #$0D);
end;

end.
