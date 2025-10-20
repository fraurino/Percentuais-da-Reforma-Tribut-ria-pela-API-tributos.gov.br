object frmCalculadoraRT: TfrmCalculadoraRT
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Calculatora RT'
  ClientHeight = 404
  ClientWidth = 874
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnClose = FormClose
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 874
    Height = 404
    Cursor = crHandPoint
    ActivePage = tsAliquotas
    Align = alClient
    TabOrder = 0
    ExplicitTop = 41
    ExplicitWidth = 892
    ExplicitHeight = 673
    object tsAliquotas: TTabSheet
      Caption = 'Aliquotas RT'
      object SpeedButton1: TSpeedButton
        Left = 0
        Top = 0
        Width = 866
        Height = 33
        Align = alTop
        Caption = 'Obter Al'#237'quotas da Reforma'
        OnClick = SpeedButton1Click
        ExplicitWidth = 884
      end
      object mAliquotas: TMemo
        Left = 0
        Top = 33
        Width = 866
        Height = 341
        Align = alClient
        TabOrder = 0
        ExplicitTop = 0
        ExplicitWidth = 365
        ExplicitHeight = 180
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Arquivo Json'
      ImageIndex = 1
      DesignSize = (
        866
        374)
      object SpeedButton4: TSpeedButton
        Left = 135
        Top = 61
        Width = 248
        Height = 22
        Cursor = crHandPoint
        Caption = 'BUSCAR CST PELA CLASSIFICA'#199#195'O'
        OnClick = SpeedButton4Click
      end
      object SpeedButton5: TSpeedButton
        Left = 135
        Top = 108
        Width = 248
        Height = 22
        Cursor = crHandPoint
        Caption = 'BUSCAR CLASSIFICA'#199#213'ES PELO CST'
        OnClick = SpeedButton5Click
      end
      object SpeedButton6: TSpeedButton
        Left = 16
        Top = 16
        Width = 105
        Height = 22
        Cursor = crHandPoint
        Caption = 'Carregar arquivo'
        OnClick = SpeedButton6Click
      end
      object SpeedButton7: TSpeedButton
        Left = 135
        Top = 16
        Width = 248
        Height = 22
        Cursor = crHandPoint
        Caption = 'Lista completa'
        OnClick = SpeedButton7Click
      end
      object StringGrid1: TStringGrid
        AlignWithMargins = True
        Left = 0
        Top = 137
        Width = 866
        Height = 533
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
        ExplicitWidth = 905
        ExplicitHeight = 572
      end
      object cClassTrib: TLabeledEdit
        Left = 16
        Top = 60
        Width = 105
        Height = 23
        EditLabel.Width = 52
        EditLabel.Height = 15
        EditLabel.Caption = 'cClassTrib'
        TabOrder = 1
        Text = '000001'
        TextHint = '000001'
      end
      object CSTtocClassTrib: TLabeledEdit
        Left = 16
        Top = 108
        Width = 105
        Height = 23
        EditLabel.Width = 95
        EditLabel.Height = 15
        EditLabel.Caption = 'CST ref. cClassTrib'
        TabOrder = 2
        Text = ''
      end
      object lista: TMemo
        Left = 416
        Top = 16
        Width = 450
        Height = 114
        Anchors = [akLeft, akTop, akRight]
        ScrollBars = ssVertical
        TabOrder = 3
        ExplicitWidth = 489
      end
    end
  end
end
