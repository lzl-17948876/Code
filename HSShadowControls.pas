unit HSShadowControls;

interface
uses
  Windows, StdCtrls, Graphics, Classes, Types, SysUtils, Math, Messages,
  Controls;

type
  THSShadowLabel = class(TCustomLabel)
  private
    FMask : TBitmap;
    FMaskBits : Pointer;
    FMaskBitsSize : Integer;
    FNeedInvalidate : Boolean;
    OffsTopLeft, OffsRightBottom : Integer;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    {Shadow}
    sr, sg, sb : Integer;
    FUseShadow,
    FBuffered: Boolean;
    FBlurCount: Integer;
    FDistance: Integer;
    FSDColor: TColor;
    procedure SetBlurCount(const Value: Integer);
    procedure SetDistance(const Value: Integer);
    procedure SetShadowColor(const Value: TColor);
    procedure SetUseShadow(const Value: Boolean);

    procedure CMMouseEnter(var msg:TMessage);message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg:TMessage);message CM_MOUSELEAVE;
  public
    Data:pointer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoDrawText(var Rect: TRect; Flags: Longint); override;
  published
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property ShadowBuffered : Boolean read FBuffered write FBuffered default False;
    property Caption;
    property Font;
    property Color;
    property BlurCount : integer read FBlurCount write SetBlurCount;
    property Distance : integer read FDistance write SetDistance;
    property ShadowColor : TColor read FSDColor write SetShadowColor;
    property UseShadow : boolean read FUseShadow write SetUseShadow;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FocusControl;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
    property ShowHint;
    property Transparent Default true;
    property Layout;
    property Visible;
    property WordWrap;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  function CreateBitmap32(Width, Height : integer) : TBitmap;
  function WidthOf(rect:TRect):integer;
  function HeightOf(rect:TRect):integer;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('HSControls', [THSShadowLabel]);
end;

function CreateBitmap32(Width, Height : integer) : TBitmap;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf32bit;
  Result.HandleType := bmDIB;
  Result.Width  := Width;
  Result.Height := Height;
end;

function WidthOf(rect:TRect):integer;
begin
  result:=rect.Right-rect.Left;
end;

function HeightOf(rect:TRect):integer;
begin
  result:=rect.Bottom-rect.Top;
end;

{----THSShadowLabel------------------------------------------------------------}
procedure THSShadowLabel.SetBlurCount(const Value: Integer);
begin
  if FBlurCount <> Value then
  begin
    FBlurCount := Value;
    Invalidate;
  end;
end;

procedure THSShadowLabel.SetDistance(const Value: Integer);
begin
  if FDistance <> Value then begin
    FDistance := Value;
    Invalidate;
  end;
end;

procedure THSShadowLabel.SetShadowColor(const Value: TColor);
var
  rgb : Integer;
begin
  if FSDColor <> Value then
  begin
    FSDColor := Value;
    rgb := ColorToRGB(Value);
    sr := rgb and 255;
    sg := (rgb shr 8) and 255;
    sb := (rgb shr 16) and 255;
    Invalidate;
  end;
end;

procedure THSShadowLabel.SetUseShadow(const Value: boolean);
begin
  if FUseShadow <> Value then
  begin
    FUseShadow := Value;
    Invalidate;
  end;
end;

procedure THSShadowLabel.CMMouseEnter(var msg: TMessage);
begin
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure THSShadowLabel.CMMouseLeave(var msg: TMessage);
begin
  if Assigned(FOnMouseleave) then
    FOnMouseleave(Self);
end;

constructor THSShadowLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {shadow}
  FSDColor := clBlack;
  FBlurCount := 4;
  FDistance := 1;
  FUseShadow:=true;
  Font.Color:=clWhite;
  FMask := CreateBitmap32(0, 0);
  FMaskBits := nil;
  Transparent:=true;
  FNeedInvalidate := True;
end;

destructor THSShadowLabel.Destroy;
begin
  FreeAndNil(FMask);
  if FMaskBits <> nil then
    FreeMem(FMaskBits);
  inherited;
end;

procedure THSShadowLabel.DoDrawText(var Rect: TRect; Flags: Integer);
const
  LB_BORDER = 3;
var
  Text: string;
  x, y :Integer;
  i : Integer;
  oRect : TRect;
  MaskOffs, pb : PByte;
  W, H : Integer;
  offs_North, offs_South, offs_West, offs_East : PByte;
  invert : byte;
  cr, cg, cb : Integer;
  ShColor, ShOffset, ShBlur : integer;
  rgb : Integer;

  procedure AddMask;
  var
    y, x : Integer;
    MaskOffs, pb : PByte;
  begin // Fill mask
    Integer(MaskOffs) := Integer(FMaskBits) + W + 1;
    for y := 0 to FMask.Height - 1 do
    begin
      pb := FMask.ScanLine[y];
      for x := 0 to FMask.Width - 1 do
      begin
        if pb^ <> 0 then MaskOffs^ := 255;
        Integer(pb) := Integer(pb) + 4;
        Integer(MaskOffs) := Integer(MaskOffs) + 1;
      end;
      Integer(MaskOffs) := Integer(MaskOffs) + 2;
    end;             
  end;
begin
  if UseShadow then
  begin
    ShColor := FSDColor;
    ShBlur := FBlurCount;
    ShOffset := FDistance;
    Text := GetLabelText;
    if (Flags and DT_CALCRECT <> 0) and
      ((Text = '') or ShowAccelChar and (Text[1] = '&') and (Text[2] = #0)) then
      Text := Text + ' ';
    if not ShowAccelChar then
      Flags := Flags or DT_NOPREFIX;
    Flags := DrawTextBiDiModeFlags(Flags);
    Canvas.Font.Assign(Font);
    if not Enabled then
    begin
      OffsetRect(Rect, 1, 1);
      Canvas.Font.Color := clBtnHighlight;
      DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect, Flags);
      OffsetRect(Rect, -1, -1);
      Canvas.Font.Color := clBtnShadow;
      DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect, Flags);
    end
    else
    begin
      Canvas.Font.Color :=Font.Color;

      if (Flags and DT_CALCRECT <> DT_CALCRECT) and (ShColor <> clNone) and (ShBlur <> 0) then
      begin
        if (FNeedInvalidate) or (not FBuffered) then
        begin
          FMask.Width := WidthOf(Rect);
          FMask.Height := HeightOf(Rect);
          FMask.Canvas.Brush.Color := 0;
          FMask.Canvas.FillRect(Classes.Rect(0, 0, FMask.Width, FMask.Height));
          FMask.Canvas.Font := Canvas.Font;
          FMask.Canvas.Font.Color := clWhite;
          oRect := Rect;
          dec(Rect.Left, OffsTopLeft);
          dec(Rect.Top, OffsTopLeft);
          dec(Rect.Right, OffsRightBottom);
          dec(Rect.Bottom, OffsRightBottom);

          OffsetRect(Rect, ShOffset, ShOffset);
          DrawText(FMask.Canvas.Handle, PChar(Text), Length(Text), Rect, Flags);
          Rect := oRect;

          W := FMask.Width + 2;
          H := FMask.Height + 2;
          if FMaskBitsSize < W * H * 2 then
          begin
            FMaskBitsSize := W * H * 2;
            ReallocMem(FMaskBits, FMaskBitsSize);
          end;
          FillChar(PChar(FMaskBits)^, W * H * 2, 0);

          //Blur Mask
          for i := 1 to ShBlur do
          begin
            Integer(MaskOffs) := Integer(FMaskBits) + W + 1;

            AddMask;
            Integer(offs_North) := Integer(MaskOffs) - W;
            Integer(offs_South) := Integer(MaskOffs) + W;
            Integer(offs_West) := Integer(MaskOffs) - 1;
            Integer(offs_East) := Integer(MaskOffs) + 1;

            for y := 0 to H - 3 do
            begin
              for x := 0 to W - 3 do
              begin
                MaskOffs^ := (offs_North^ + offs_South^ + offs_West^ + offs_East^)shr 2;
                Integer(MaskOffs) := Integer(MaskOffs) + 1;
                Integer(offs_North) := Integer(offs_North) + 1;
                Integer(offs_South) := Integer(offs_South) + 1;
                Integer(offs_West) := Integer(offs_West) + 1;
                Integer(offs_East) := Integer(offs_East) + 1;
              end;
              Integer(MaskOffs) := Integer(MaskOffs) + 2;
              Integer(offs_North) := Integer(offs_North) + 2;
              Integer(offs_South) := Integer(offs_South) + 2;
              Integer(offs_West) := Integer(offs_West) + 2;
              Integer(offs_East) := Integer(offs_East) + 2;
            end;       
          end;

          Integer(MaskOffs) := Integer(FMaskBits) + FMask.Width + 3;

          if Transparent then
          begin
            BitBlt(FMask.Canvas.Handle, 0, 0, FMask.Width, FMask.Height, Canvas.Handle, 0, 0, SRCCOPY);
            for y := 0 to FMask.Height - 1  do
            begin
              pb := FMask.ScanLine[y];
              for x := 0 to FMask.Width - 1 do
              begin
                invert := not MaskOffs^; // 255 - MaskOffs^
                pb^ := (pb^ * invert + sb * MaskOffs^) shr 8;
                Integer(pb) := Integer(pb) + 1;
                pb^ := (pb^ * invert + sg * MaskOffs^) shr 8;
                Integer(pb) := Integer(pb) + 1;
                pb^ := (pb^ * invert + sr * MaskOffs^) shr 8;
                Integer(pb) := Integer(pb) + 2;
                Integer(MaskOffs) := Integer(MaskOffs) + 1;
              end;
              Integer(MaskOffs) := Integer(MaskOffs) + 2;
            end;
          end
          else begin
            i := ColorToRGB(Color);

            cr := i and 255;
            cg := (i shr 8) and 255;
            cb := (i shr 16) and 255;

            for y := 0 to FMask.Height - 1  do
            begin
              pb := FMask.ScanLine[y];
              for x := 0 to FMask.Width - 1 do
              begin
                invert := not MaskOffs^; // 255 - MaskOffs^
                pb^ := (cb * invert + sb * MaskOffs^) shr 8;
                Integer(pb) := Integer(pb) + 1;
                pb^ := (cg * invert + sg * MaskOffs^) shr 8;
                Integer(pb) := Integer(pb) + 1;
                pb^ := (cr * invert + sr * MaskOffs^) shr 8;
                Integer(pb) := Integer(pb) + 2;
                Integer(MaskOffs) := Integer(MaskOffs) + 1;
              end;
              Integer(MaskOffs) := Integer(MaskOffs) + 2;
            end;
          end;//*)
          FNeedInvalidate := False;
        end; // Need Invalidate

        BitBlt(Canvas.Handle, 0{Rect.Left}, 0{Rect.Top v5.11}, FMask.Width, FMask.Height, FMask.Canvas.Handle, 0, 0, SRCCOPY);
        oRect := Rect;
        dec(Rect.Left, OffsTopLeft);
        dec(Rect.Top, OffsTopLeft);
        dec(Rect.Right, OffsRightBottom);
        dec(Rect.Bottom, OffsRightBottom);

        DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect, Flags);

        Rect := oRect;
      end
      else
        DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect, Flags);

      if (Flags and DT_CALCRECT = DT_CALCRECT) and (ShColor <> clNone) and (ShBlur <> 0) then
      begin
        OffsTopLeft := Min(0, ShOffset - ShBlur);
        OffsRightBottom := Max(0, ShOffset + ShBlur);
        inc(Rect.Right, OffsRightBottom - OffsTopLeft);
        inc(Rect.Bottom, OffsRightBottom - OffsTopLeft);
      end;
    end;
  end
  else
    inherited;
end;
end.
 