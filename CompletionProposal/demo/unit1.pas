unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, windows, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, SynEdit, SynCompletionProposal;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    SynEdit1: TSynEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure SynEdit1KeyPress(Sender: TObject; var Key: char);
    procedure SynEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    SynCompletionProposal1: TSynCompletionProposal;
    insertList: TStrings;
    itemList: TStrings;
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

  itemList:=TStringList.Create;
  insertList:=TStringList.Create;

  SynCompletionProposal1:= TSynCompletionProposal.Create(Self);
  SynCompletionProposal1.Editor:=SynEdit1;
  with SynCompletionProposal1 do begin
    //Options := [scoLimitToMatchedText, scoUseInsertList, scoEndCharCompletion, scoCompleteWithTab, scoCompleteWithEnter];
    EndOfTokenChr := '()[]. ';
    TriggerChars := '.';
    Title := 'Completion Proposal Demo';
    Options := [scoLimitToMatchedText, scoUseInsertList, scoUsePrettyText, scoUseBuiltInTimer, scoEndCharCompletion, scoCompleteWithTab, scoCompleteWithEnter];
    Font.Color := clWindowText;
    Font.Height := -11;
//    Font.Name := 'MS Sans Serif';
    Font.Style := [];
    Columns.Add;
    Columns.Items[0].BiggestWord:='constructor';

  end;

  with insertList do
  begin
    Clear;
    Add('Create');
    Add('Destroy');
    Add('Add');
    Add('ClearLine');
    Add('Delete');
    Add('First');
    Add('GetMarksForLine');
    Add('Insert');
    Add('Last');
    Add('Place');
    Add('Remove');
    Add('WMCaptureChanged');
    Add('WMCopy');
    Add('WMCut');
    Add('WMDropFiles');
    Add('WMEraseBkgnd');
    Add('WMGetDlgCode');
    Add('WMHScroll');
    Add('WMPaste');
  end;

  with itemList do
  begin
    Clear;
    Add('constructor \column{}\style{+B}Create\style{-B}(AOwner: TCustomSynEdit)');
    Add('destructor \column{}\style{+B}Destroy\style{-B}');
    Add('function \column{}\style{+B}Add\style{-B}(Item: TSynEditMark): Integer');
    Add('procedure \column{}\style{+B}ClearLine\style{-B}(line: integer)');
    Add('procedure \column{}\style{+B}Delete\style{-B}(Index: Integer)');
    Add('function \column{}\style{+B}First\style{-B}: TSynEditMark');
    Add('procedure \column{}\style{+B}GetMarksForLine\style{-B}(line: integer; var Marks: TSynEditMarks)');
    Add('procedure \column{}\style{+B}Insert\style{-B}(Index: Integer; Item: TSynEditMark)');
    Add('function \column{}\style{+B}Last\style{-B}: TSynEditMark');
    Add('procedure \column{}\style{+B}Place\style{-B}(mark: TSynEditMark)');
    Add('function \column{}\style{+B}Remove\style{-B}(Item: TSynEditMark): Integer');
    Add('procedure \column{}\style{+B}WMCaptureChanged\style{-B}(var Msg: TMessage); message WM_CAPTURECHANGED');
    Add('procedure \column{}\style{+B}WMCopy\style{-B}(var Message: TMessage); message WM_COPY');
    Add('procedure \column{}\style{+B}WMCut\style{-B}(var Message: TMessage); message WM_CUT');
    Add('procedure \column{}\style{+B}WMDropFiles\style{-B}(var Msg: TMessage); message WM_DROPFILES');
    Add('procedure \column{}\style{+B}WMEraseBkgnd\style{-B}(var Msg: TMessage); message WM_ERASEBKGND');
    Add('procedure \column{}\style{+B}WMGetDlgCode\style{-B}(var Msg: TWMGetDlgCode); message WM_GETDLGCODE');
    Add('procedure \column{}\style{+B}WMHScroll\style{-B}(var Msg: TWMScroll); message WM_HSCROLL');
    Add('procedure \column{}\style{+B}WMPaste\style{-B}(var Message: TMessage); message WM_PASTE');
  end;

  SynCompletionProposal1.InsertList.AddStrings(insertList);
  SynCompletionProposal1.ItemList.AddStrings(itemList);

end;

procedure TForm1.SynEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Caption:='SynEdit1KeyDown';
end;

procedure TForm1.SynEdit1KeyPress(Sender: TObject; var Key: char);
begin
  Caption:='SynEdit1KeyPress';
end;

procedure TForm1.SynEdit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    Caption:='SynEdit1KeyUp';
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  p,p1: TPoint;
begin
  SynEdit1.SetFocus;
  //SynCompletionProposal1.Execute('First',10,10);
  p1.x:=SynEdit1.CaretXPix;
  p1.y:=SynEdit1.CaretYPix + SynEdit1.LineHeight + 1;
  p := ClientToScreen(p1);
  SynCompletionProposal1.Execute('',p.x,p.y);
end;

end.

