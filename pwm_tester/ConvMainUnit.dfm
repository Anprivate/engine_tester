object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 434
  ClientWidth = 773
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
  object Label2: TLabel
    Left = 19
    Top = 81
    Width = 36
    Height = 13
    Caption = 'Engine:'
  end
  object Label3: TLabel
    Left = 192
    Top = 81
    Width = 46
    Height = 13
    Caption = 'Propeller:'
  end
  object Label4: TLabel
    Left = 368
    Top = 79
    Width = 35
    Height = 13
    Caption = 'Accum:'
  end
  object Label5: TLabel
    Left = 105
    Top = 15
    Width = 71
    Height = 13
    Caption = 'Engine weight:'
  end
  object EditEngine: TEdit
    Left = 19
    Top = 100
    Width = 157
    Height = 21
    TabOrder = 0
    Text = 'EditEngine'
  end
  object EditPropeller: TEdit
    Left = 192
    Top = 100
    Width = 161
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object EditEngineWeight: TEdit
    Left = 105
    Top = 34
    Width = 71
    Height = 21
    TabOrder = 2
    Text = '0'
  end
  object ButtonOpen: TButton
    Left = 19
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Open CSV'
    TabOrder = 3
    OnClick = ButtonOpenClick
  end
  object EditAccumulator: TEdit
    Left = 368
    Top = 98
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'EditAccumulator'
  end
  object Memo1: TMemo
    Left = 19
    Top = 144
    Width = 746
    Height = 273
    Lines.Strings = (
      'Memo1')
    TabOrder = 5
  end
  object ButtonSave: TButton
    Left = 248
    Top = 32
    Width = 75
    Height = 25
    Caption = 'SaveCSV'
    Enabled = False
    TabOrder = 6
    OnClick = ButtonSaveClick
  end
  object OpenDialog1: TOpenDialog
    Left = 568
    Top = 16
  end
  object SaveDialog1: TSaveDialog
    Left = 568
    Top = 64
  end
end
