unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  FileUtil,
  Forms,
  Controls,
  Graphics,
  Dialogs, Buttons, StdCtrls, ExtCtrls, SpkRollPanel, SpkExpandPanel,
  NLDSnapPanel
  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    NLDSnapPanel:TNLDSnapPanel;
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  NLDSnapPanel:=TNLDSnapPanel.Create(Self);
  NLDSnapPanel.Width:=121;
  NLDSnapPanel.Height:=453;
  NLDSnapPanel.Caption := 'nldsnpnl1';
  NLDSnapPanel.Left:=0;
  NLDSnapPanel.Top:=0;
  NLDSnapPanel.Parent:=Self;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin

end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin

end;

end.

