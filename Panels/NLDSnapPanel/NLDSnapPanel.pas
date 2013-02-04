{ *************************************************************************** }
{                                                                             }
{ NLDSnapPanel  -  www.nldelphi.com Open Source designtime component          }
{                                                                             }
{ Initiator: Albert de Weerd (aka NGLN)                                       }
{ License: Free to use, free to modify                                        }
{ SVN path: http://svn.nldelphi.com/nldelphi/opensource/ngln/NLDSnapPanel     }
{                                                                             }
{ *************************************************************************** }
{                                                                             }
{ Edit by: Albert de Weerd                                                    }
{ Date: May 23, 2008                                                          }
{ Version: 1.0.0.0                                                            }
{                                                                             }
{ *************************************************************************** }

unit NLDSnapPanel;

interface

uses
  LCLIntf
  ,LCLVersion
  ,LMessages
  ,LCLType
  ,Classes, types
  ,Graphics
  ,ExtCtrls
  ,Controls
  ,Buttons
  ,IntfGraphics
  ,FPImage
  ;

const
  DefMaxWidth = 105;
  DefMinWidth = 5;

type
  TMessage = TLMessage;

  TNLDSnapPanel = class(TCustomPanel)
  private
    FAutoHide: Boolean;
    FGhostWin: TWinControl;
    FMaxWidth: Integer;
    FMinWidth: Integer;
    FMouseCaptured: Boolean;
    FPinButton: TSpeedButton;
    FPinButtonDownHint: String;
    FPinButtonUpHint: String;
    FTimer: TTimer;
    FUnhiding: Boolean;
    function GetShowHint: Boolean;
    function GetWidth: Integer;
    function IsShowHintStored: Boolean;
    procedure PinButtonClick(Sender: TObject);
    procedure SetAutoHide(const Value: Boolean);
    procedure SetMinWidth(const Value: Integer);
    procedure SetPinButtonDownHint(const Value: String);
    procedure SetPinButtonUpHint(const Value: String);
    procedure SetShowHint(const Value: Boolean);
    procedure SetWidth(const Value: Integer);
    procedure Timer(Sender: TObject);
    procedure UpdatePinButtonHint;
    procedure CMControlListChange(var Message: TCMControlListChange);
      message CM_CONTROLLISTCHANGE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    {
    procedure Rotate(ABitmap: TBitmap; aCanvas : TCanvas; x, y, Angle: integer);
    }
    procedure DrawButtonPin;
  protected
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure Paint; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property AutoHide: Boolean read FAutoHide write SetAutoHide default False;
    property MinWidth: Integer read FMinWidth write SetMinWidth
      default DefMinWidth;
    property PinButtonDownHint: String read FPinButtonDownHint
      write SetPinButtonDownHint;
    property PinButtonUpHint: String read FPinButtonUpHint
      write SetPinButtonUpHint;
    property ShowHint: Boolean read GetShowHint write SetShowHint
      stored IsShowHintStored;
    property Width: Integer read GetWidth write SetWidth default DefMaxWidth;
  published
    property Alignment default taLeftJustify;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderWidth;
    property BorderStyle;
    property Caption;
    property Color;
    property Font;
    property Hint;
    {$IFNDEF LCL}
    property ParentBackground;
    {$ENDIF}
    property ParentColor;
    {$IFNDEF LCL}
    property ParentCtl3D;
    {$ENDIF}
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property TabOrder;
    property Visible;
  end;

procedure Register;

implementation

{$R *.res}

uses
  Math;

procedure Register;
begin
  RegisterComponents('NLDelphi', [TNLDSnapPanel]);
end;

{ TNLDSnapPanel }

//resourcestring
//  SPinButtonBmpResName = 'PINBUTTON';

const
  DefPinButtonSize = 20;
  DefPinButtonMargin = 3;
  DefResizeStep = 15;
  DefTimerInterval = 20;

procedure RotateBitmap90(const bitmap: TBitmap);
var
  tmp: TBitmap;
  src, dst: TLazIntfImage;
  ImgHandle, ImgMaskHandle: HBitmap;
  i, j, t, u, v: integer;
begin
  tmp := TBitmap.create;
  tmp.Width := Bitmap.Height;
  tmp.Height := Bitmap.Width;
  dst := TLazIntfImage.Create(0, 0);
  dst.LoadFromBitmap(tmp.Handle, tmp.MaskHandle);
  src := TLazIntfImage.Create(0, 0);
  src.LoadFromBitmap(bitmap.Handle, bitmap.MaskHandle);
  u := bitmap.width - 1;
  v := bitmap.height - 1;
  for i := 0 to u do begin
    t := u - i;
    for j := 0 to v do
      dst.Colors[j, t] := src.Colors[i, j];
  end;
  dst.CreateBitmaps(ImgHandle, ImgMaskHandle, false);
  tmp.Handle := ImgHandle;
  tmp.MaskHandle := ImgMaskHandle;
  dst.Free;
  bitmap.Assign(tmp);
  tmp.Free;
  src.Free;
end;

procedure RotateBitmap180(const bitmap: TBitmap);
var DestBitmap,SrcBitmap:TBitmap ;
  x: Integer;
  y: Integer;
begin
  //Open the source and create the destination bitmap
  SrcBitmap:=TBitmap.Create;
  DestBitmap:=TBitmap.Create;
  SrcBitmap.Assign(bitmap);
  //rotate by 180°
  DestBitmap.Width:=SrcBitmap.Width;
  DestBitmap.Height:=SrcBitmap.Height;

  //Rotate one pixel at a time
  for x:=0 to SrcBitmap.Width do
    for y:=0 to SrcBitmap.Height do
    begin
      //DestBitmap.Canvas.Pixels[x][SrcBitmap.Height-1-y]:= SrcBitmap.Canvas.Pixels[x][y];
      DestBitmap.Canvas.Pixels[x,SrcBitmap.Height-1-y]:= SrcBitmap.Canvas.Pixels[x,y];
    end;
  //for (int x=0;x<SrcBitmap->Width;x++)
  {
    for(int y=0;y<SrcBitmap->Height;y++)
    {
      DestBitmap->Canvas->Pixels[x][SrcBitmap->Height-1-y]=
        SrcBitmap->Canvas->Pixels[x][y];
    }
  }

  //Assign the Destination bitmap to a TImage
  //Image1->Picture->Bitmap=DestBitmap;
  bitmap.Assign(DestBitmap);
  DestBitmap.Free;
  SrcBitmap.Free;
end;

procedure RotateBitmapAngle(const bitmap: TBitmap;Angle:Integer);
var DestBitmap,SrcBitmap:TBitmap ;
  x: Integer;
  y: Integer;
  radians: float;
  cosine: ValReal;
  sine: ValReal;
  Point1x: Extended;
  Point1y: Extended;
  Point2x: Extended;
  Point2y: Extended;
  Point3x: Extended;
  minx: Extended;
  Point3y: Extended;
  miny: Extended;
  maxx: Extended;
  maxy: Extended;
  DestBitmapWidth: Integer;
  DestBitmapHeight: Integer;
  SrcBitmapx: Integer;
  SrcBitmapy: Integer;
begin
  //Open the source and create the destination bitmap
  SrcBitmap:=TBitmap.Create;
  DestBitmap:=TBitmap.Create;
  SrcBitmap.Assign(bitmap);

  radians:=(2*3.1416*angle)/360;

  cosine:=cos(radians);
  sine:=sin(radians);

  Point1x:=(-SrcBitmap.Height*sine);
  Point1y:=(SrcBitmap.Height*cosine);
  Point2x:=(SrcBitmap.Width*cosine-SrcBitmap.Height*sine);
  Point2y:=(SrcBitmap.Height*cosine+SrcBitmap.Width*sine);
  Point3x:=(SrcBitmap.Width*cosine);
  Point3y:=(SrcBitmap.Width*sine);

  minx:=min(0,min(Point1x,min(Point2x,Point3x)));
  miny:=min(0,min(Point1y,min(Point2y,Point3y)));
  maxx:=max(Point1x,max(Point2x,Point3x));
  maxy:=max(Point1y,max(Point2y,Point3y));

  DestBitmapWidth:=ceil(abs(maxx)-minx);
  DestBitmapHeight:=ceil(abs(maxy)-miny)-1;

  DestBitmap.Height:=DestBitmapHeight;
  DestBitmap.Width:=DestBitmapWidth;

  for x:=0 to DestBitmapWidth do
    for y:=0 to DestBitmapHeight do
    begin
      SrcBitmapx:=Round((x+minx)*cosine+(y+miny)*sine);
      SrcBitmapy:=Round((y+miny)*cosine-(x+minx)*sine);
      if((SrcBitmapx>=0) and (SrcBitmapx<SrcBitmap.Width) and (SrcBitmapy>=0) and (SrcBitmapy<SrcBitmap.Height))
      then begin
        DestBitmap.Canvas.Pixels[x,y]:= SrcBitmap.Canvas.Pixels[SrcBitmapx,SrcBitmapy];
      end;
    end;

  //Assign the Destination bitmap to a TImage
  //Image1->Picture->Bitmap=DestBitmap;
  //DestBitmap.SaveToFile('1.f');
  bitmap.Assign(DestBitmap);
  DestBitmap.Free;
  SrcBitmap.Free;
end;

procedure TNLDSnapPanel.AdjustClientRect(var Rect: TRect);
begin
  inherited AdjustClientRect(Rect);
  Inc(Rect.Top, DefPinButtonSize + 2 * DefPinButtonMargin);
end;

procedure TNLDSnapPanel.CMControlListChange(
  var Message: TCMControlListChange);
begin
  if Message.Inserting then
    with Message.Control do
      Anchors := Anchors - [akLeft] + [akRight];
end;

procedure TNLDSnapPanel.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if FAutoHide then
    if not FMouseCaptured then
    begin
      FMouseCaptured := True;
      FUnhiding := True;
      FTimer.Enabled := True;
    end;
end;

procedure TNLDSnapPanel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FAutoHide then
  begin
    FMouseCaptured := PtInRect(ClientRect, ScreenToClient(Mouse.CursorPos));
    if not FMouseCaptured then
    begin
      FUnhiding := False;
      FTimer.Enabled := True;
    end;
  end;
end;

constructor TNLDSnapPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMaxWidth := DefMaxWidth;
  FMinWidth := DefMinWidth;
  Alignment := taLeftJustify;
  Align := alLeft;
  Left := 0;
  Top := 0;
  inherited Width := FMaxWidth;
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := DefTimerInterval;
  FTimer.OnTimer := @Timer;
  FPinButton := TSpeedButton.Create(Self);
  FPinButton.Flat:=True;
  //FPinButton.Glyph.LoadFromResourceName(HInstance, SPinButtonBmpResName);
  FPinButton.GroupIndex := -1;
  FPinButton.AllowAllUp := True;
  FPinButton.Down := True;
  FPinButton.Anchors := [akTop, akRight];
  FPinButton.SetBounds(DefMaxWidth - DefPinButtonSize - FMinWidth, DefPinButtonMargin, DefPinButtonSize, DefPinButtonSize);
  FPinButton.OnClick := @PinButtonClick;
  FPinButton.Parent := Self;
  Self.DrawButtonPin;
end;

function TNLDSnapPanel.GetShowHint: Boolean;
begin
  Result := inherited ShowHint;
end;

function TNLDSnapPanel.GetWidth: Integer;
begin
  Result := inherited Width;
end;

function TNLDSnapPanel.IsShowHintStored: Boolean;
begin
  Result := not ParentShowHint;
end;

procedure TNLDSnapPanel.Paint;
const
  Alignments: array[TAlignment] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);
var
  Rect: TRect;
  TopColor, BottomColor: TColor;
  FontHeight: Integer;
  Flags: Longint;

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;

begin
  Rect := GetClientRect;
  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  Frame3D(Canvas, Rect, Color, Color, BorderWidth);
  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  with Canvas do
  begin
    //if not ThemeServices.ThemesEnabled or not ParentBackground then
    begin
      Brush.Color := Color;
      FillRect(Rect);
    end;
    Brush.Style := bsClear;
    Font := Self.Font;
    FontHeight := TextHeight('W');
    with Rect do
    begin
      Left := Width - FMaxWidth + FMinWidth;
      Top := 5;
      Bottom := Top + FontHeight;
      Right := Width - DefPinButtonSize - FMinWidth - 5;
    end;
    Flags := DT_EXPANDTABS or Alignments[Alignment];
    //Flags := DrawTextBiDiModeFlags(Flags);
    DrawText(Handle, PChar(Caption), -1, Rect, Flags);
    Pen.Color := clBtnShadow;
    MoveTo(Rect.Left, Rect.Bottom + DefPinButtonMargin);
    LineTo(Rect.Right, PenPos.Y);
  end;


end;

procedure TNLDSnapPanel.PinButtonClick(Sender: TObject);
begin


  {
  if FPinButton.Down then   begin
    FPinButton.Glyph.LoadFromResourceName(HInstance, SPinButtonBmpResName);
  end
  else begin
    RotateBitmapAngle(FPinButton.Glyph,90);
  end;
  }
   Self.DrawButtonPin;
   AutoHide := not FPinButton.Down;
end;

procedure TNLDSnapPanel.SetAutoHide(const Value: Boolean);
begin
  if FAutoHide <> Value then
  begin
    FAutoHide := Value;
    FPinButton.Down := not FAutoHide;
    if FAutoHide then
    begin
      Align := alNone;
      Anchors := [akLeft, akTop, akBottom];
      FGhostWin := TWinControl.Create(Self);
      FGhostWin.Align := alLeft;
      FGhostWin.Width := FMinWidth;
      FGhostWin.Parent := Parent;
      FGhostWin.SendToBack;
    end
    else
    begin
      Align := alLeft;
      FGhostWin.Free;
      FGhostWin := nil;
    end;
    UpdatePinButtonHint;
  end;
end;

procedure TNLDSnapPanel.SetMinWidth(const Value: Integer);
begin
  if FMinWidth <> Value then
  begin
    FPinButton.Left := FPinButton.Left + FMinWidth - Value;
    FMinWidth := Value;
    if FAutoHide and not FUnhiding then
    begin
      inherited Width := FMinWidth;
      FGhostWin.Width := FMinWidth;
    end;
  end;
end;

procedure TNLDSnapPanel.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if FGhostWin <> nil then
  begin
    FGhostWin.Parent := AParent;
    FGhostWin.SendToBack;
  end;
end;

procedure TNLDSnapPanel.SetPinButtonDownHint(const Value: String);
begin
  if FPinButtonDownHint <> Value then
  begin
    FPinButtonDownHint := Value;
    UpdatePinButtonHint;
  end;
end;

procedure TNLDSnapPanel.SetPinButtonUpHint(const Value: String);
begin
  if FPinButtonUpHint <> Value then
  begin
    FPinButtonUpHint := Value;
    UpdatePinButtonHint;
  end;
end;

procedure TNLDSnapPanel.SetShowHint(const Value: Boolean);
begin
  inherited ShowHint := Value;
  FPinButton.ShowHint := Value;
end;

procedure TNLDSnapPanel.SetWidth(const Value: Integer);
begin
  if FMaxWidth <> Value then
  begin
    FMaxWidth := Value;
    if not FAutoHide then
      inherited Width := FMaxWidth;
  end;
end;

procedure TNLDSnapPanel.Timer(Sender: TObject);
var
  CalcWidth: Integer;
begin
  if FUnhiding then
    CalcWidth := Width + DefResizeStep
  else
    CalcWidth := Width - DefResizeStep;
  inherited Width := Max(FMinWidth, Min(CalcWidth, FMaxWidth));
  if (Width = FMinWidth) or (Width = FMaxWidth) then
    FTimer.Enabled := False;
end;

procedure TNLDSnapPanel.UpdatePinButtonHint;
begin
  if FPinButton.Down then
    FPinButton.Hint := FPinButtonDownHint
  else
    FPinButton.Hint := FPinButtonUpHint;
end;


procedure TNLDSnapPanel.DrawButtonPin;
var
  b:TBitmap;
  ARect: TRect;
  //CenterW: Integer;
  CenterH: Integer;
begin
  b:=TBitmap.Create;
  b.Width:=FPinButton.Width;
  b.Height:=FPinButton.Height;

  b.Canvas.Pen.Color:=clBlack;
  b.Canvas.Brush.Color:=clBtnFace;
  ARect:=GetClientRect;
  b.Canvas.FillRect(ARect);

  //b.Canvas.MoveTo(FPinButton.Width div 2,FPinButton.Height div 2);

  //CenterW:=FPinButton.Width div 2 ;
  CenterH:=FPinButton.Height div FPinButton.Width+4;

  if(FPinButton.Down) then
  begin
    b.Canvas.MoveTo(CenterH+2, CenterH+1);
    b.Canvas.LineTo(CenterH+2, CenterH+7);
    b.Canvas.MoveTo(CenterH+5, CenterH+1);
    b.Canvas.LineTo(CenterH+5, CenterH+7);
    b.Canvas.MoveTo(CenterH+6, CenterH+1);
    b.Canvas.LineTo(CenterH+6, CenterH+7);
    b.Canvas.MoveTo(CenterH+4, CenterH+6);
    b.Canvas.LineTo(CenterH+4, CenterH+9);
    b.Canvas.MoveTo(CenterH+2, CenterH+1);
    b.Canvas.LineTo(CenterH+7, CenterH+1);
    b.Canvas.MoveTo(CenterH+1, CenterH+6);
    b.Canvas.LineTo(CenterH+8, CenterH+6);
  end
  else
  begin
    b.Canvas.MoveTo(CenterH+3, CenterH+1);
    b.Canvas.LineTo(CenterH+3, CenterH+8);
    b.Canvas.MoveTo(CenterH+8, CenterH+2);
    b.Canvas.LineTo(CenterH+8, CenterH+7);
    b.Canvas.MoveTo(CenterH+3, CenterH+2);
    b.Canvas.LineTo(CenterH+8, CenterH+2);
    b.Canvas.MoveTo(CenterH+3, CenterH+5);
    b.Canvas.LineTo(CenterH+8, CenterH+5);
    b.Canvas.MoveTo(CenterH+3, CenterH+6);
    b.Canvas.LineTo(CenterH+8, CenterH+6);
    b.Canvas.MoveTo(CenterH+0, CenterH+4);
    b.Canvas.LineTo(CenterH+4, CenterH+4);
  end;

   //Canvas.Draw(25,25,b);
   //b.SaveToFile('b');
   FPinButton.Glyph.Assign(b);
   b.Free;
end;

end.
