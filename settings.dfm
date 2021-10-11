object FormSettings: TFormSettings
  Left = 432
  Top = 348
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormSettings'
  ClientHeight = 154
  ClientWidth = 234
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object l_wh: TLabel
    Left = 8
    Top = 20
    Width = 66
    Height = 13
    Caption = #1056#1072#1079#1084#1077#1088' '#1087#1086#1083#1103
  end
  object lcou: TLabel
    Left = 8
    Top = 52
    Width = 71
    Height = 13
    Caption = #1050#1086#1083'-'#1074#1086' '#1092#1080#1096#1077#1082
  end
  object llang: TLabel
    Left = 8
    Top = 76
    Width = 28
    Height = 13
    Caption = #1071#1079#1099#1082
  end
  object lui: TLabel
    Left = 8
    Top = 100
    Width = 10
    Height = 13
    Caption = 'lui'
  end
  object e_x: TEdit
    Left = 88
    Top = 16
    Width = 65
    Height = 21
    TabOrder = 0
    Text = '10'
    OnChange = e_xChange
    OnKeyPress = e_xKeyPress
  end
  object e_y: TEdit
    Left = 160
    Top = 16
    Width = 65
    Height = 21
    TabOrder = 1
    Text = '10'
    OnChange = e_xChange
    OnKeyPress = e_xKeyPress
  end
  object cb_lang: TComboBox
    Left = 88
    Top = 72
    Width = 137
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 2
    Text = 'English'
    Items.Strings = (
      'English'
      'Russian')
  end
  object BOK: TButton
    Tag = 1
    Left = 72
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 3
    OnClick = BNOClick
  end
  object BNO: TButton
    Left = 152
    Top = 120
    Width = 75
    Height = 25
    Caption = 'BNO'
    TabOrder = 4
    OnClick = BNOClick
  end
  object cb_cou: TComboBox
    Left = 88
    Top = 48
    Width = 137
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 5
    Text = '2'
    Items.Strings = (
      '2'
      '3'
      '4'
      '5'
      '6'
      '7')
  end
  object cb_ui: TComboBox
    Left = 88
    Top = 96
    Width = 137
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 6
    Text = 'use'
    Items.Strings = (
      'use'
      'dont use')
  end
end
