object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 485
  ClientWidth = 630
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ComLed1: TComLed
    Left = 416
    Top = 4
    Width = 25
    Height = 25
    Hint = 'TX'
    ComPort = ComPort1
    LedSignal = lsTx
    Kind = lkGreenLight
    ParentShowHint = False
    ShowHint = True
  end
  object ComLed2: TComLed
    Left = 447
    Top = 4
    Width = 25
    Height = 25
    Hint = 'RX'
    ComPort = ComPort1
    LedSignal = lsRx
    Kind = lkGreenLight
    ParentShowHint = False
    ShowHint = True
  end
  object Label1: TLabel
    Left = 8
    Top = 48
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object LabelU: TLabel
    Left = 8
    Top = 67
    Width = 7
    Height = 13
    Caption = 'U'
  end
  object LabelI: TLabel
    Left = 96
    Top = 67
    Width = 4
    Height = 13
    Caption = 'I'
  end
  object LabelPWM: TLabel
    Left = 188
    Top = 67
    Width = 24
    Height = 13
    Caption = 'PWM'
  end
  object LabelT: TLabel
    Left = 284
    Top = 67
    Width = 6
    Height = 13
    Caption = 'T'
  end
  object Label2: TLabel
    Left = 155
    Top = 101
    Width = 36
    Height = 13
    Caption = 'Engine:'
  end
  object Label3: TLabel
    Left = 339
    Top = 101
    Width = 26
    Height = 13
    Caption = 'Prop:'
  end
  object Label4: TLabel
    Left = 515
    Top = 101
    Width = 35
    Height = 13
    Caption = 'Accum:'
  end
  object LabelPWMAct: TLabel
    Left = 8
    Top = 144
    Width = 24
    Height = 13
    Caption = '1000'
  end
  object ComComboBox1: TComComboBox
    Left = 8
    Top = 8
    Width = 145
    Height = 21
    ComPort = ComPort1
    Text = ''
    Style = csDropDownList
    ItemIndex = -1
    TabOrder = 0
    OnChange = ComComboBox1Change
  end
  object ButtonConnect: TButton
    Left = 176
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 1
    OnClick = ButtonConnectClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 178
    Width = 614
    Height = 281
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
  end
  object ButtonStartTest: TButton
    Left = 8
    Top = 96
    Width = 113
    Height = 25
    Caption = #1053#1072#1095#1072#1090#1100' '#1080#1089#1087#1099#1090#1072#1085#1080#1077
    Enabled = False
    TabOrder = 3
    OnClick = ButtonStartTestClick
  end
  object EditEngine: TEdit
    Left = 197
    Top = 98
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'EditEngine'
  end
  object EditPropeller: TEdit
    Left = 371
    Top = 98
    Width = 121
    Height = 21
    TabOrder = 5
    Text = 'Edit1'
  end
  object ComboBoxAccum: TComboBox
    Left = 552
    Top = 98
    Width = 70
    Height = 21
    Style = csDropDownList
    TabOrder = 6
    Items.Strings = (
      '2S'
      '3S'
      '4S'
      '5S'
      '6S')
  end
  object TrackBarPWM: TTrackBar
    Left = 80
    Top = 127
    Width = 542
    Height = 45
    LineSize = 5
    Max = 2000
    Min = 900
    ParentShowHint = False
    PageSize = 100
    Frequency = 20
    Position = 900
    PositionToolTip = ptTop
    ShowHint = False
    ShowSelRange = False
    TabOrder = 7
    TickMarks = tmTopLeft
    OnChange = TrackBarPWMChange
  end
  object ButtonCSVtoPNG: TButton
    Left = 335
    Top = 8
    Width = 75
    Height = 25
    Caption = 'CSV to PNG'
    TabOrder = 8
    OnClick = ButtonCSVtoPNGClick
  end
  object ComPort1: TComPort
    BaudRate = br115200
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evRxFlag]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    StoredProps = [spBasic]
    TriggersOnRxChar = True
    OnRxChar = ComPort1RxChar
    Left = 600
    Top = 8
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 280
    Top = 8
  end
  object OpenDialog1: TOpenDialog
    Left = 488
    Top = 8
  end
end
