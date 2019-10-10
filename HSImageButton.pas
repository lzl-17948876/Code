unit HSImageButton;

// ***************************************************************************
//
// 支持PNG的Graphicbutton
//
// 版本: 1.2
// 作者: 刘志林
// 修改日期: 2017-12-08
// QQ: 17948876
// E-mail: lzl_17948876@hotmail.com
// 博客: http://www.cnblogs.com/hs-kill/
//
// !!! 若有修改,请通知作者,谢谢合作 !!!
//
// ---------------------------------------------------------------------------
//
// 说明:
// 1.通过绑定ImageList来显示图标
// 2.通过Imagelist对PNG的支持来显示PNG图标
// 3.支持4种状态切换 (Normal/Hot/Pressed/Disabled)
// 4.支持图片位置排列 (ImageLayout)
// 5.支持SpeedButton的Group模式
// 6.版本兼容至D2010
// 7.支持按钮下拉菜单
// 8.支持下拉菜单自动关闭
//
// ***************************************************************************

interface

uses
  System.Classes, System.SysUtils, System.Types,
{$IF RTLVersion >= 29}
  System.ImageList,
{$ENDIF}
  Winapi.Messages, Winapi.Windows,
  Vcl.Controls, Vcl.Buttons, Vcl.Graphics, Vcl.Forms, Vcl.Menus,
  Vcl.Themes, Vcl.ImgList, Vcl.ActnList;

type
  TPopupAnchor = (paTopLeft, paTopCenter, paTopRight, paLeftTop, paLeftCenter, paLeftBottom, paRightTop, paRightCenter,
    paRightBottom, paBottomLeft, paBottomCenter, paBottomRight);

  TImageLayout = (ilLeft, ilRight, ilTop, ilBottom);
  THSImageButton = class;

  THSImageButtonActionLink = class(TControlActionLink)
  protected
    FClient: THSImageButton;
    procedure AssignClient(AClient: TObject); override;
    function IsCheckedLinked: Boolean; override;
    function IsGroupIndexLinked: Boolean; override;
    function IsImageIndexLinked: Boolean; override;
    procedure SetGroupIndex(Value: Integer); override;
    procedure SetChecked(Value: Boolean); override;
    procedure SetImageIndex(Value: Integer); override;
  public
    constructor Create(AClient: TObject); override;
  end;

  THSImageButtonActionLinkClass = class of THSImageButtonActionLink;

  TImageOffset = class(TPersistent)
  private
    FX: Integer;
    FY: Integer;
    FOnChange: TNotifyEvent;
    procedure SetOffset(Index, Value: Integer);
  protected
    procedure Change; virtual;
  public
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property X: Integer index 0 read FX write SetOffset default 0;
    property Y: Integer index 1 read FY write SetOffset default 0;
  end;

  THSImageButton = class(TGraphicControl)
  private
    FGroupIndex: Integer;
    FDown: Boolean;
    FDragging: Boolean;
    FAllowAllUp: Boolean;
    FSpacing: Integer;
    FTransparent: Boolean;
    FMargin: Integer;
    FFlat: Boolean;
    FMouseInControl: Boolean;
    FImageLayout: TImageLayout;
    FImages: TCustomImageList;
    FImageOffset: TImageOffset;

    FImageIndex: TImageIndex;
    FPressedImageIndex: TImageIndex;
    FDisabledImageIndex: TImageIndex;
    FHotImageIndex: TImageIndex;

    FImageChangeLink: TChangeLink;

    FOnBeforePopup: TNotifyEvent;
    FMeasureMenuItem: Boolean;
    FCharHalfHeight: Integer; { 字符半高 }
    FPopupAnchor: TPopupAnchor;
    FTrackButton: TTrackButton;
    FShowCaption: Boolean;
    FPopupAutoClose: Boolean;

    procedure GlyphChanged(Sender: TObject);
    procedure UpdateExclusive;
    procedure SetDown(Value: Boolean);
    procedure SetFlat(Value: Boolean);
    procedure SetAllowAllUp(Value: Boolean);
    procedure SetGroupIndex(Value: Integer);
    procedure SetSpacing(Value: Integer);
    procedure SetTransparent(Value: Boolean);
    procedure SetMargin(Value: Integer);
    procedure UpdateTracking;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMButtonPressed(var Message: TMessage); message CM_BUTTONPRESSED;
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
    procedure SetImageLayout(const Value: TImageLayout);
    procedure SetImageIndex(const Value: TImageIndex);
    procedure SetImageOffset(const Value: TImageOffset);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetDisabledImageIndex(const Value: TImageIndex);
    procedure SetHotImageIndex(const Value: TImageIndex);
    procedure SetPressedImageIndex(const Value: TImageIndex);
    procedure miMeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
    procedure miDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure ImageSizeChange(Sender: TObject);
    procedure SetShowCaption(const Value: Boolean);
  protected
    FState: TButtonState;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    function GetActionLinkClass: TControlActionLinkClass; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    property MouseInControl: Boolean read FMouseInControl;
    procedure ImageListChange(Sender: TObject);
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    procedure DoPopup;
  published
    property Action;
    property Align;
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property Down: Boolean read FDown write SetDown default False;
    property Caption;
    property Enabled;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Font;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageLayout: TImageLayout read FImageLayout write SetImageLayout default ilLeft;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default -1;
    property HotImageIndex: TImageIndex read FHotImageIndex write SetHotImageIndex default -1;
    property PressedImageIndex: TImageIndex read FPressedImageIndex write SetPressedImageIndex default -1;
    property DisabledImageIndex: TImageIndex read FDisabledImageIndex write SetDisabledImageIndex default -1;
    property ImageOffset: TImageOffset read FImageOffset write SetImageOffset;
    property Margin: Integer read FMargin write SetMargin default -1;
    property ParentFont;
    property ParentShowHint;
    property ParentBiDiMode;
    property PopupMenu;
    property ShowHint;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
    property Transparent: Boolean read FTransparent write SetTransparent default True;
    property Visible;
    property StyleElements;
    property OnClick;
    property OnDblClick;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnBeforePopup: TNotifyEvent read FOnBeforePopup write FOnBeforePopup;
    /// <summary>
    /// 是否限制菜单宽度和按钮保持一直
    /// </summary>
    property MeasureMenuItem: Boolean read FMeasureMenuItem write FMeasureMenuItem default True;
    /// <summary>
    /// 菜单弹出方向
    /// </summary>
    property PopupAnchor: TPopupAnchor read FPopupAnchor write FPopupAnchor default paBottomLeft;
    /// <summary>
    /// 菜单激活按键
    /// </summary>
    property PopupTrackButton: TTrackButton read FTrackButton write FTrackButton default tbLeftButton;
    /// <summary>
    /// 是否显示Caption
    /// </summary>
    property ShowCaption: Boolean read FShowCaption write SetShowCaption default True;
    /// <summary>
    /// 是否自动关闭菜单
    /// </summary>
    property PopupAutoClose: Boolean read FPopupAutoClose write FPopupAutoClose default False;
  end;

implementation

var
  FBMP_OBM_CHECK: TBitmap; { 系统对勾资源 }
  FBOCHalfHeight: Integer; { 系统对勾资源 半高 }
  FBOCHalfWidth: Integer; { 系统对勾资源 半宽 }

  { THSImageButton }

constructor THSImageButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMeasureMenuItem := True;
  FPopupAnchor := paBottomLeft;
  SetBounds(0, 0, 23, 22);
  ControlStyle := [csCaptureMouse, csDoubleClicks];
  ParentFont := True;
  Color := clBtnFace;
  FSpacing := 4;
  FMargin := -1;
  FTransparent := True;
  FImageIndex := -1;
  FDisabledImageIndex := -1;
  FPressedImageIndex := -1;
  FHotImageIndex := -1;
  FImageOffset := TImageOffset.Create;
  FImageOffset.OnChange := ImageSizeChange;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  FImageLayout := ilLeft;
  FTrackButton := tbLeftButton;
  FShowCaption := True;
end;

destructor THSImageButton.Destroy;
begin
  FreeAndNil(FImageChangeLink);
  FreeAndNil(FImageOffset);
  inherited Destroy;
end;

procedure THSImageButton.DoPopup;

  procedure _GetMenuSize(var AWidth, AHeight: Integer);
  var
    NonClientMetrics: TNonClientMetrics;
  begin
    NonClientMetrics.cbSize := sizeof(NonClientMetrics);
    if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
    begin
      AWidth := NonClientMetrics.iMenuWidth;
      AHeight := NonClientMetrics.iMenuHeight;
    end;
  end;

type
  _TDefPPMParam = record
    OwnerDraw: Boolean;
    MeasureItemEvens: array of TMenuMeasureItemEvent;
    DrawItemEvens: array of TMenuDrawItemEvent;
  end;

const
  MENU_CLASSNAME = #32768;
var
  nPT: TPoint;
  i, nWidth, nHeight: Integer;
  nDefParam: _TDefPPMParam;
  nPopFlg: DWORD;
  nMI: TMenuItem;
  nPopuped: Boolean;
  nAT: TThread;
  nBR: TRect;
begin
  if PopupMenu = nil then
    Exit;

  if Assigned(FOnBeforePopup) then
    FOnBeforePopup(Self);

  _GetMenuSize(nWidth, nHeight);
  SetLength(nDefParam.DrawItemEvens, PopupMenu.Items.Count);
  if FMeasureMenuItem then
  begin
    SetLength(nDefParam.MeasureItemEvens, PopupMenu.Items.Count);
    nDefParam.OwnerDraw := PopupMenu.OwnerDraw;
    PopupMenu.OwnerDraw := True; { 只有OwnerDraw模式下才能自定义显示尺寸 }
  end;

  PopupMenu.PopupComponent := Self;
  for i := 0 to PopupMenu.Items.Count - 1 do
  begin
    if FMeasureMenuItem then
    begin
      nDefParam.MeasureItemEvens[i] := PopupMenu.Items[i].OnMeasureItem;
      PopupMenu.Items[i].OnMeasureItem := miMeasureItem;
    end;
    if not nDefParam.OwnerDraw then
    begin
      nDefParam.DrawItemEvens[i] := PopupMenu.Items[i].OnDrawItem;
      PopupMenu.Items[i].OnDrawItem := miDrawItem;
    end;
  end;

  try
    case FPopupAnchor of
      paTopLeft:
        begin
          nPopFlg := TPM_LEFTALIGN or TPM_BOTTOMALIGN;
          nPT := Self.ClientToScreen(Point(0, 0));
        end;
      paTopCenter:
        begin
          nPopFlg := TPM_CENTERALIGN or TPM_BOTTOMALIGN;
          nPT := Self.ClientToScreen(Point(Width div 2, 0));
        end;
      paTopRight:
        begin
          nPopFlg := TPM_RIGHTALIGN or TPM_BOTTOMALIGN;
          nPT := Self.ClientToScreen(Point(Width, 0));
        end;
      paLeftTop:
        begin
          nPopFlg := TPM_RIGHTALIGN or TPM_TOPALIGN;
          nPT := Self.ClientToScreen(Point(0, 0));
        end;
      paLeftCenter:
        begin
          nPopFlg := TPM_RIGHTALIGN or TPM_VCENTERALIGN;
          nPT := Self.ClientToScreen(Point(Width div 2, Height div 2));
        end;
      paLeftBottom:
        begin
          nPopFlg := TPM_RIGHTALIGN or TPM_BOTTOMALIGN;
          nPT := Self.ClientToScreen(Point(0, Height));
        end;
      paRightTop:
        begin
          nPopFlg := TPM_LEFTALIGN or TPM_TOPALIGN;
          nPT := Self.ClientToScreen(Point(Width, 0));
        end;
      paRightCenter:
        begin
          nPopFlg := TPM_LEFTALIGN or TPM_VCENTERALIGN;
          nPT := Self.ClientToScreen(Point(Width, Height div 2));
        end;
      paRightBottom:
        begin
          nPopFlg := TPM_LEFTALIGN or TPM_BOTTOMALIGN;
          nPT := Self.ClientToScreen(Point(Width, Height));
        end;
      (*
        paBottomLeft:
        begin
        nPopFlg := TPM_LEFTALIGN or TPM_TOPALIGN;
        nPT := Self.ClientToScreen(Point(0, Height));
        end;
      *)
      paBottomCenter:
        begin
          nPopFlg := TPM_CENTERALIGN or TPM_TOPALIGN;
          nPT := Self.ClientToScreen(Point(Width div 2, Height));
        end;
      paBottomRight:
        begin
          nPopFlg := TPM_RIGHTALIGN or TPM_TOPALIGN;
          nPT := Self.ClientToScreen(Point(Width, Height));
        end;
    else { paBottomLeft }
      nPopFlg := TPM_LEFTALIGN or TPM_TOPALIGN;
      nPT := Self.ClientToScreen(Point(0, Height));
    end;

    { 这3句是为了让PopupMenu.Items执行RebuildHandle
      因为使用TrackPopupMenu弹出菜单, 所以没有Items执行RebuildHandle可能会导致OwnerDraw不执行 }
    nMI := NewLine;
    PopupMenu.Items.Add(nMI);
    nMI.Free;

    { 如果自动关闭, 开个线程监视鼠标坐标 }
    nAT := nil;
    if FPopupAutoClose then
    begin
      nPopuped := True;
      nBR := Self.ClientRect;
      nBR.Offset(Self.ClientToScreen(Point(0, 0)));
      nAT := TThread.CreateAnonymousThread(
        procedure
        var
          xH: HWND;
          xR: TRect;
          xPT: TPoint;
          xDoClose: Boolean;
        begin
          while nPopuped do
          begin
            Sleep(10);

            xH := FindWindowEx(0, 0, PChar(MENU_CLASSNAME), nil);
            if xH = 0 then
              Continue;

            xDoClose := False;
            repeat
              GetCursorPos(xPT);
              if PtInRect(nBR, xPT) then
                Break;

              GetWindowRect(xH, xR);
              if PtInRect(xR, xPT) then
                Break;

              xH := FindWindowEx(0, xH, PChar(MENU_CLASSNAME), nil);
              xDoClose := xH = 0;
            until (xDoClose);

            if xDoClose then
            begin
              TThread.Synchronize(nAT, PopupMenu.CloseMenu);
              nAT := nil;
              Break;
            end;
          end;
        end);
      nAT.Start;
    end;
    TrackPopupMenu(PopupMenu.Items.Handle, nPopFlg, nPT.X, nPT.Y, 0, PopupList.Window, nil);
  finally
    if nAT <> nil then
    begin
      nAT.FreeOnTerminate := False;
      nPopuped := False;
      nAT.WaitFor;
      FreeAndNil(nAT);
    end;
    if FMeasureMenuItem then
      PopupMenu.OwnerDraw := nDefParam.OwnerDraw;
    for i := 0 to PopupMenu.Items.Count - 1 do
    begin
      if FMeasureMenuItem then
        PopupMenu.Items[i].OnMeasureItem := nDefParam.MeasureItemEvens[i];
      if not nDefParam.OwnerDraw then
        PopupMenu.Items[i].OnDrawItem := nDefParam.DrawItemEvens[i];
    end;
  end;
end;

const
  DownStyles: array [Boolean] of Integer = (BDR_RAISEDINNER, BDR_SUNKENOUTER);
  FillStyles: array [Boolean] of Integer = (BF_MIDDLE, 0);

procedure THSImageButton.Paint;

  function DoGlassPaint: Boolean;
  var
    nLParent: TWinControl;
  begin
    Result := csGlassPaint in ControlState;
    if Result then
    begin
      nLParent := Parent;
      while (nLParent <> nil) and not nLParent.DoubleBuffered do
        nLParent := nLParent.Parent;
      Result := (nLParent = nil) or not nLParent.DoubleBuffered or (nLParent is TCustomForm);
    end;
  end;

var
  nPaintRect, nTextRect: TRect;
  nDrawFlags, nImageIndex, nFW, nFH: Integer;
  nOffset, nCenterPoint, nImagePoint: TPoint;
  nLGlassPaint: Boolean;
  nTMButton: TThemedButton;
  nTMToolBar: TThemedToolBar;
  nDetails: TThemedElementDetails;
  nLStyle: TCustomStyleServices;
  nLColor: TColor;
  nLFormats: TTextFormat;
  nTextFlg: DWORD;
  nHSize, nTextSize, nImageSize: TSize;
{$IF RTLVersion >= 27}
  nDefGrayscaleFactor: Byte;
{$ENDIF}
begin
  { Copy As TSpeedButton.Paint }
  if not Enabled then
  begin
    FState := bsDisabled;
    FDragging := False;
  end
  else if FState = bsDisabled then
    if FDown and (GroupIndex <> 0) then
      FState := bsExclusive
    else
      FState := bsUp;
  Canvas.Font := Self.Font;
  Canvas.Brush.Style := bsClear;

  { 画背景 }
  if ThemeControl(Self) then
  begin
    nLGlassPaint := DoGlassPaint;
    if not nLGlassPaint then
      if Transparent then
        StyleServices.DrawParentBackground(0, Canvas.Handle, nil, True)
      else
        PerformEraseBackground(Self, Canvas.Handle)
    else
      FillRect(Canvas.Handle, ClientRect, GetStockObject(BLACK_BRUSH));

    if not Enabled then
      nTMButton := tbPushButtonDisabled
    else if FState in [bsDown, bsExclusive] then
      nTMButton := tbPushButtonPressed
    else if MouseInControl then
      nTMButton := tbPushButtonHot
    else
      nTMButton := tbPushButtonNormal;

    nTMToolBar := ttbToolbarDontCare;
    if FFlat or TStyleManager.IsCustomStyleActive then
    begin
      case nTMButton of
        tbPushButtonDisabled:
          nTMToolBar := ttbButtonDisabled;
        tbPushButtonPressed:
          nTMToolBar := ttbButtonPressed;
        tbPushButtonHot:
          nTMToolBar := ttbButtonHot;
        tbPushButtonNormal:
          nTMToolBar := ttbButtonNormal;
      end;
    end;
    nPaintRect := ClientRect;
    if nTMToolBar = ttbToolbarDontCare then
    begin
      nDetails := StyleServices.GetElementDetails(nTMButton);
      StyleServices.DrawElement(Canvas.Handle, nDetails, nPaintRect);
      StyleServices.GetElementContentRect(Canvas.Handle, nDetails, nPaintRect, nPaintRect);
    end
    else
    begin
      nDetails := StyleServices.GetElementDetails(nTMToolBar);
      if not TStyleManager.IsCustomStyleActive then
      begin
        StyleServices.DrawElement(Canvas.Handle, nDetails, nPaintRect);
        // Windows theme services doesn't paint disabled toolbuttons
        // with grayed text (as it appears in an actual toolbar). To workaround,
        // retrieve nDetails for a disabled nTMButton for drawing the caption.
        if (nTMToolBar = ttbButtonDisabled) then
          nDetails := StyleServices.GetElementDetails(nTMButton);
      end
      else
      begin
        // Special case for flat speedbuttons with custom styles. The assumptions
        // made about the look of ToolBar buttons may not apply, so only paint
        // the hot and pressed states , leaving normal/disabled to appear flat.
        if not FFlat or ((nTMButton = tbPushButtonPressed) or (nTMButton = tbPushButtonHot)) then
          StyleServices.DrawElement(Canvas.Handle, nDetails, nPaintRect);
      end;
      StyleServices.GetElementContentRect(Canvas.Handle, nDetails, nPaintRect, nPaintRect);
    end;

    nOffset := Point(0, 0);
    if nTMButton = tbPushButtonPressed then
    begin
      // A pressed "flat" speed nTMButton has white text in XP, but the Themes
      // API won't render it as such, so we need to hack it.
      if (nTMToolBar <> ttbToolbarDontCare) and not CheckWin32Version(6) then
        Canvas.Font.Color := clHighlightText
      else if FFlat then
        nOffset := Point(1, 0);
    end;
  end
  else
  begin
    nPaintRect := Rect(1, 1, Width - 1, Height - 1);
    if not FFlat then
    begin
      nDrawFlags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;
      if FState in [bsDown, bsExclusive] then
        nDrawFlags := nDrawFlags or DFCS_PUSHED;
      DrawFrameControl(Canvas.Handle, nPaintRect, DFC_BUTTON, nDrawFlags);
    end
    else
    begin
      if (FState in [bsDown, bsExclusive]) or (FMouseInControl and (FState <> bsDisabled)) or
        (csDesigning in ComponentState) then
        DrawEdge(Canvas.Handle, nPaintRect, DownStyles[FState in [bsDown, bsExclusive]],
          FillStyles[Transparent] or BF_RECT)
      else if not Transparent then
      begin
        Canvas.Brush.Color := Color;
        Canvas.FillRect(nPaintRect);
      end;
      InflateRect(nPaintRect, -1, -1);
    end;
    if FState in [bsDown, bsExclusive] then
    begin
      if (FState = bsExclusive) and (not FFlat or not FMouseInControl) then
      begin
        Canvas.Brush.Bitmap := AllocPatternBitmap(clBtnFace, clBtnHighlight);
        Canvas.FillRect(nPaintRect);
      end;
      nOffset.X := 1;
      nOffset.Y := 1;
    end
    else
    begin
      nOffset.X := 0;
      nOffset.Y := 0;
    end;

    nLStyle := StyleServices;
  end;

  nPaintRect := ClientRect;
  nCenterPoint := nPaintRect.CenterPoint;

  { 计算文字显示宽高 }
  if FShowCaption and (Length(Caption) > 0) then
  begin
    nTextRect := nPaintRect;
    nTextFlg := DT_SINGLELINE or DT_CALCRECT;
    { Copy As TButtonGlyphc.DrawButtonText.DoDrawText }
    if ThemeControl(Self) then
    begin
      nLFormats := TTextFormatFlags(nTextFlg);
      if nLGlassPaint then
        Include(nLFormats, tfComposited);
      StyleServices.DrawText(Canvas.Handle, nDetails, Caption, nTextRect, nLFormats, clWindowText);
    end
    else
    begin
      { 计算显示位置 }
      Winapi.Windows.DrawText(Canvas.Handle, Caption, Length(Text), nTextRect, nTextFlg);
    end;
    nTextSize := nTextRect.Size;
    { 换算到中间位置 }
    nTextRect.Offset(nCenterPoint.X - nTextSize.cx div 2, nCenterPoint.Y - nTextSize.cy div 2);
  end
  else
  begin
    nTextSize.Create(0, 0);
  end;

  { 根据计算图像/文字位置, 并画图 }
  if (Images <> nil) and (FImageIndex > -1) then
  begin
{$IF RTLVersion >= 27}
    nDefGrayscaleFactor := Images.GrayscaleFactor;
    Images.GrayscaleFactor := $FF;
{$ENDIF}
    if nTextSize.IsZero then
    begin
      nImagePoint.Create(nCenterPoint.X - Images.Width div 2 + FImageOffset.X, nCenterPoint.Y - Images.Height div 2 +
        FImageOffset.Y);
    end
    else
    begin
      nFW := nTextSize.cx + Images.Width + 1;
      nFH := nTextSize.cy + Images.Height + 1;
      case FImageLayout of
        ilLeft:
          begin
            nImagePoint.Create(nCenterPoint.X - nFW div 2 + FImageOffset.X, nCenterPoint.Y - Images.Height div 2 +
              FImageOffset.Y);
            nTextRect.Offset(Images.Width div 2 + 1, 0);
          end;
        ilRight:
          begin
            nImagePoint.Create(nCenterPoint.X + nFW div 2 - Images.Width + FImageOffset.X,
              nCenterPoint.Y - Images.Height div 2 + FImageOffset.Y);
            nTextRect.Offset(-(Images.Width div 2 + 1), 0);
          end;
        ilTop:
          begin
            nImagePoint.Create(nCenterPoint.X - Images.Width div 2 + FImageOffset.X,
              nCenterPoint.Y - nFH div 2 + FImageOffset.Y);
            nTextRect.Offset(0, Images.Height div 2 + 1);
          end;
        ilBottom:
          begin
            nImagePoint.Create(nCenterPoint.X - Images.Width div 2 + FImageOffset.X,
              nCenterPoint.Y + nFH div 2 - Images.Height + FImageOffset.Y);
            nTextRect.Offset(0, -(Images.Height div 2 + 1));
          end;
      end;
    end;

    if not Enabled then
    begin
      if FDisabledImageIndex > -1 then
        Images.Draw(Canvas, nImagePoint.X, nImagePoint.Y, FDisabledImageIndex, True)
      else
        Images.Draw(Canvas, nImagePoint.X, nImagePoint.Y, FImageIndex, False);
    end
    else
    begin
      if FState in [bsDown, bsExclusive] then
        nImageIndex := FPressedImageIndex
      else if MouseInControl then
        nImageIndex := FHotImageIndex
      else
        nImageIndex := FImageIndex;
      if nImageIndex = -1 then
        nImageIndex := FImageIndex;
      Images.Draw(Canvas, nImagePoint.X, nImagePoint.Y, nImageIndex, True);
    end;
{$IF RTLVersion >= 27}
    Images.GrayscaleFactor := nDefGrayscaleFactor;
{$ENDIF}
  end;

  { 画文字 }
  if not nTextSize.IsZero then
  begin
    nTextFlg := DT_VCENTER or DT_SINGLELINE or DT_CENTER;
    { Copy As TButtonGlyphc.DrawButtonText.DoDrawText }
    if ThemeControl(Self) then
    begin
      if (FState = bsDisabled) or (not StyleServices.IsSystemStyle and (seFont in StyleElements)) then
      begin
        if not StyleServices.GetElementColor(nDetails, ecTextColor, nLColor) or (nLColor = clNone) then
          nLColor := Canvas.Font.Color;
      end
      else
        nLColor := Canvas.Font.Color;
      { 显示 }
      nLFormats := TTextFormatFlags(nTextFlg);
      if nLGlassPaint then
        Include(nLFormats, tfComposited);
      StyleServices.DrawText(Canvas.Handle, nDetails, Caption, nTextRect, nLFormats, nLColor);
    end
    else
    begin
      if FState = bsDisabled then
        Canvas.Font.Color := clGrayText
      else
        Canvas.Font.Color := clWindowText;
      { 显示 }
      Winapi.Windows.DrawText(Canvas.Handle, Caption, Length(Text), nTextRect, nTextFlg);
    end;
  end;
end;

procedure THSImageButton.UpdateTracking;
var
  P: TPoint;
begin
  if FFlat then
  begin
    if Enabled then
    begin
      GetCursorPos(P);
      FMouseInControl := not(FindDragTarget(P, True) = Self);
      if FMouseInControl then
        Perform(CM_MOUSELEAVE, 0, 0)
      else
        Perform(CM_MOUSEENTER, 0, 0);
    end;
  end;
end;

procedure THSImageButton.Loaded;
var
  State: TButtonState;
begin
  inherited Loaded;
  if Enabled then
    State := bsUp
  else
    State := bsDisabled;
end;

procedure THSImageButton.miDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
var
  lCY, lImageIndex: Integer;
  lChecked, lImageExists: Boolean;
  lText: string;
  lOldBS: TBrushStyle;
  lOldBSCL: TColor;
  lDTL, lDTL_CK: TThemedElementDetails;
  lRC, lRC_CK: TRect;
  lSize: TSize;
  lStyle: TCustomStyleServices;
  lImages: TCustomImageList;
  lPT: TPoint;
begin
  lCY := ARect.CenterPoint.Y;
  with TMenuItem(Sender) do
  begin
    lChecked := Checked;
    lText := Caption;
    lImageIndex := ImageIndex;
  end;

  lImages := Self.PopupMenu.Images;

  lImageExists := (lImageIndex > -1) and (lImages <> nil) and (lImages.Count > lImageIndex);

  if (Win32MajorVersion >= 6) and ThemeControl(Self) then
  begin
    lStyle := StyleServices;

    ACanvas.Brush.Color := clMenu;
    ACanvas.FillRect(ARect);
    lRC := ARect;

    lDTL_CK := lStyle.GetElementDetails(TThemedMenu.tmPopupCheckNormal);
    lStyle.GetElementSize(ACanvas.Handle, lDTL_CK, esActual, lSize);
    lRC_CK := lRC;
    lRC_CK.Right := lRC.Left + lSize.cx + 6;

    lRC.Left := lRC_CK.Right + 2;

    if Selected then
      lDTL := lStyle.GetElementDetails(TThemedMenu.tmPopupItemHot)
    else
      lDTL := lStyle.GetElementDetails(TThemedMenu.tmPopupItemNormal);
    lStyle.DrawElement(ACanvas.Handle, lDTL, ARect);

    if lImageExists then
    begin
      lPT := lRC_CK.CenterPoint;
      if lChecked then
        LStyle.DrawElement(ACanvas.Handle, lStyle.GetElementDetails(tmPopupCheckBackgroundNormal), lRC_CK);
      lImages.Draw(ACanvas, lPT.X - lImages.Width div 2, lPT.Y - lImages.Height div 2, lImageIndex, dsNormal, itImage);
    end
    else if lChecked then
    begin
      lStyle.DrawElement(ACanvas.Handle, lStyle.GetElementDetails(TThemedMenu.tmPopupCheckBackgroundNormal), lRC_CK);
      lStyle.DrawElement(ACanvas.Handle, lDTL_CK, lRC_CK);
    end;

    if lText = cLineCaption then
    begin
      Inc(ARect.Top, 4);
      lDTL := lStyle.GetElementDetails(TThemedMenu.tmSeparator);
      lStyle.DrawEdge(ACanvas.Handle, lDTL, ARect, EDGE_ETCHED, BF_TOP);
    end
    else
    begin
      lDTL := lStyle.GetElementDetails(TThemedMenu.tmMenuBarItemNormal);
      lStyle.DrawText(ACanvas.Handle, lDTL, lText, lRC, [tfNoClip, tfVerticalCenter, tfSingleLine]);
    end;
  end
  else
  begin
    if Selected then
      ACanvas.Brush.Color := clHighlight
    else
      ACanvas.Brush.Color := clMenu;
    ACanvas.FillRect(ARect);
    if lChecked then
    begin
      lOldBS := ACanvas.Brush.Style;
      lOldBSCL := ACanvas.Brush.Color;
      ACanvas.Draw(ARect.Left + 3, lCY - FBOCHalfHeight - 1, FBMP_OBM_CHECK);
      ACanvas.Brush.Style := lOldBS;
      ACanvas.Brush.Color := lOldBSCL;
    end;

    if lText = cLineCaption then
    begin
      Inc(ARect.Top, 4);
      DrawEdge(ACanvas.Handle, ARect, EDGE_ETCHED, BF_TOP);
    end
    else
      ACanvas.TextOut(ARect.Left + FBMP_OBM_CHECK.Width + 6, lCY - FCharHalfHeight, lText);
  end;
end;

procedure THSImageButton.miMeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
begin
  Width := Self.Width - 20;
end;

procedure THSImageButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    if not FDown then
    begin
      FState := bsDown;
      Invalidate;
    end;
    FDragging := True;
  end;
end;

procedure THSImageButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewState: TButtonState;
begin
  inherited MouseMove(Shift, X, Y);
  if FDragging then
  begin
    if not FDown then
      NewState := bsUp
    else
      NewState := bsExclusive;
    if (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
      if FDown then
        NewState := bsExclusive
      else
        NewState := bsDown;
    if NewState <> FState then
    begin
      FState := NewState;
      Invalidate;
    end;
  end
  else if not FMouseInControl then
    UpdateTracking;
end;

procedure THSImageButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lDoClick: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FDragging then
  begin
    FDragging := False;
    lDoClick := (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight);
    if FGroupIndex = 0 then
    begin
      { Redraw face in-case mouse is captured }
      FState := bsUp;
      FMouseInControl := False;
      if lDoClick and not(FState in [bsExclusive, bsDown]) then
        Invalidate;
    end
    else if lDoClick then
    begin
      SetDown(not FDown);
      if FDown then
        Repaint;
    end
    else
    begin
      if FDown then
        FState := bsExclusive;
      Repaint;
    end;
    if lDoClick then
      Click;
    UpdateTracking;
  end;
end;

procedure THSImageButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FImages then
    begin
      FImages := nil;
    end;
  end;
end;

procedure THSImageButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  if Sender is TCustomAction then
    with TCustomAction(Sender) do
    begin
      if not CheckDefaults or (Self.ImageIndex = -1) then
        Self.ImageIndex := ImageIndex;
    end;
end;

procedure THSImageButton.Click;
begin
  inherited Click;
  if (PopupMenu <> nil) and (FTrackButton = tbLeftButton) then
  begin
    DoPopup;
  end;
end;

function THSImageButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := THSImageButtonActionLink;
end;

procedure THSImageButton.GlyphChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure THSImageButton.ImageListChange(Sender: TObject);
begin
  Invalidate;
end;

procedure THSImageButton.ImageSizeChange(Sender: TObject);
begin
  Invalidate;
end;

procedure THSImageButton.UpdateExclusive;
var
  Msg: TMessage;
begin
  if (FGroupIndex <> 0) and (Parent <> nil) then
  begin
    Msg.Msg := CM_BUTTONPRESSED;
    Msg.WParam := FGroupIndex;
    Msg.LParam := LParam(Self);
    Msg.Result := 0;
    Parent.Broadcast(Msg);
  end;
end;

procedure THSImageButton.SetDisabledImageIndex(const Value: TImageIndex);
begin
  FDisabledImageIndex := Value;
  Invalidate;
end;

procedure THSImageButton.SetDown(Value: Boolean);
begin
  if FGroupIndex = 0 then
    Value := False;
  if Value <> FDown then
  begin
    if FDown and (not FAllowAllUp) then
      Exit;
    FDown := Value;
    if Value then
    begin
      if FState = bsUp then
        Invalidate;
      FState := bsExclusive
    end
    else
    begin
      FState := bsUp;
      Repaint;
    end;
    if Value then
      UpdateExclusive;
  end;
end;

procedure THSImageButton.SetFlat(Value: Boolean);
begin
  if Value <> FFlat then
  begin
    FFlat := Value;
    Invalidate;
  end;
end;

procedure THSImageButton.SetGroupIndex(Value: Integer);
begin
  if FGroupIndex <> Value then
  begin
    FGroupIndex := Value;
    UpdateExclusive;
  end;
end;

procedure THSImageButton.SetHotImageIndex(const Value: TImageIndex);
begin
  FHotImageIndex := Value;
  Invalidate;
end;

procedure THSImageButton.SetImageLayout(const Value: TImageLayout);
begin
  FImageLayout := Value;
  Invalidate;
end;

procedure THSImageButton.SetImageIndex(const Value: TImageIndex);
begin
  FImageIndex := Value;
  Invalidate;
end;

procedure THSImageButton.SetImageOffset(const Value: TImageOffset);
begin
  FImageOffset := Value;
  Invalidate;
end;

procedure THSImageButton.SetImages(const Value: TCustomImageList);
begin
  if Value <> FImages then
  begin
    if Images <> nil then
      Images.UnRegisterChanges(FImageChangeLink);
    FImages := Value;
    if Images <> nil then
    begin
      Images.RegisterChanges(FImageChangeLink);
      Images.FreeNotification(Self);
    end;
    Invalidate;
  end;
end;

procedure THSImageButton.SetMargin(Value: Integer);
begin
  if (Value <> FMargin) and (Value >= -1) then
  begin
    FMargin := Value;
    Invalidate;
  end;
end;

procedure THSImageButton.SetParent(AParent: TWinControl);
begin
  inherited;
  if Parent <> nil then
    FCharHalfHeight := Canvas.TextHeight('测') div 2;
end;

procedure THSImageButton.SetPressedImageIndex(const Value: TImageIndex);
begin
  FPressedImageIndex := Value;
  Invalidate;
end;

procedure THSImageButton.SetShowCaption(const Value: Boolean);
begin
  if FShowCaption <> Value then
  begin
    FShowCaption := Value;
    Invalidate;
  end;
end;

procedure THSImageButton.SetSpacing(Value: Integer);
begin
  if Value <> FSpacing then
  begin
    FSpacing := Value;
    Invalidate;
  end;
end;

procedure THSImageButton.SetTransparent(Value: Boolean);
begin
  if Value <> FTransparent then
  begin
    FTransparent := Value;
    if Value then
      ControlStyle := ControlStyle - [csOpaque]
    else
      ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
end;

procedure THSImageButton.SetAllowAllUp(Value: Boolean);
begin
  if FAllowAllUp <> Value then
  begin
    FAllowAllUp := Value;
    UpdateExclusive;
  end;
end;

procedure THSImageButton.WMContextMenu(var Message: TWMContextMenu);
begin
  Message.Result := 1;
  if (PopupMenu <> nil) and (FTrackButton = tbRightButton) then
    DoPopup;
end;

procedure THSImageButton.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  inherited;
  if FDown then
    DblClick;
end;

procedure THSImageButton.CMButtonPressed(var Message: TMessage);
var
  Sender: THSImageButton;
begin
  if Message.WParam = WParam(FGroupIndex) then
  begin
    Sender := THSImageButton(Message.LParam);
    if Sender <> Self then
    begin
      if Sender.Down and FDown then
      begin
        FDown := False;
        FState := bsUp;
        if (Action is TCustomAction) then
          TCustomAction(Action).Checked := False;
        Invalidate;
      end;
      FAllowAllUp := Sender.AllowAllUp;
    end;
  end;
end;

procedure THSImageButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, Caption) and Enabled and Visible and (Parent <> nil) and Parent.Showing then
    begin
      Click;
      Result := 1;
    end
    else
      inherited;
end;

procedure THSImageButton.CMEnabledChanged(var Message: TMessage);
const
  NewState: array [Boolean] of TButtonState = (bsDisabled, bsUp);
begin
  UpdateTracking;
  Repaint;
end;

procedure THSImageButton.CMFontChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure THSImageButton.CMMouseEnter(var Message: TMessage);
var
  NeedRepaint: Boolean;
begin
  inherited;
  { Don't draw a border if DragMode <> dmAutomatic since this button is meant to
    be used as a dock client. }
  NeedRepaint := FFlat and not FMouseInControl and Enabled and (DragMode <> dmAutomatic) and (GetCapture = 0);

  { Windows XP introduced hot states also for non-flat buttons. }
  if (NeedRepaint or StyleServices.Enabled) and not(csDesigning in ComponentState) then
  begin
    FMouseInControl := True;
    if Enabled then
      Repaint;
  end;
end;

procedure THSImageButton.CMMouseLeave(var Message: TMessage);
var
  NeedRepaint: Boolean;
begin
  inherited;
  NeedRepaint := FFlat and FMouseInControl and Enabled and not FDragging;
  { Windows XP introduced hot states also for non-flat buttons. }
  if NeedRepaint or StyleServices.Enabled then
  begin
    FMouseInControl := False;
    if Enabled then
      Repaint;
  end;
end;

procedure THSImageButton.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

{ THSImageButtonActionLink }

procedure THSImageButtonActionLink.AssignClient(AClient: TObject);
begin
  inherited AssignClient(AClient);
  FClient := AClient as THSImageButton;
end;

constructor THSImageButtonActionLink.Create(AClient: TObject);
begin
  inherited Create(AClient);
end;

function THSImageButtonActionLink.IsCheckedLinked: Boolean;
begin
  Result := inherited IsCheckedLinked and (FClient.GroupIndex <> 0) and FClient.AllowAllUp and
    (FClient.Down = TCustomAction(Action).Checked);
end;

function THSImageButtonActionLink.IsGroupIndexLinked: Boolean;
begin
  Result := inherited IsGroupIndexLinked and (FClient is THSImageButton) and
    (FClient.GroupIndex = TCustomAction(Action).GroupIndex);
end;

function THSImageButtonActionLink.IsImageIndexLinked: Boolean;
begin
  Result := inherited IsImageIndexLinked and (FClient.ImageIndex = TCustomAction(Action).ImageIndex);
end;

procedure THSImageButtonActionLink.SetChecked(Value: Boolean);
begin
  if IsCheckedLinked then
    THSImageButton(FClient).Down := Value;
end;

procedure THSImageButtonActionLink.SetGroupIndex(Value: Integer);
begin
  if IsGroupIndexLinked then
    THSImageButton(FClient).GroupIndex := Value;
end;

procedure THSImageButtonActionLink.SetImageIndex(Value: Integer);
begin
  if IsImageIndexLinked then
    THSImageButton(FClient).ImageIndex := Value;
end;

{ TImageOffset }

procedure TImageOffset.Assign(Source: TPersistent);
begin
  if Source is TImageOffset then
  begin
    FX := TImageOffset(Source).X;
    FY := TImageOffset(Source).Y;
    Change;
  end
  else
    inherited Assign(Source);
end;

procedure TImageOffset.Change;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TImageOffset.SetOffset(Index, Value: Integer);
begin
  case Index of
    0:
      if Value <> FX then
      begin
        FX := Value;
        Change;
      end;
    1:
      if Value <> FY then
      begin
        FY := Value;
        Change;
      end;
  end;
end;

initialization

FBMP_OBM_CHECK := TBitmap.Create;
FBMP_OBM_CHECK.Handle := LoadBitmap(0, PChar(OBM_CHECK));
FBOCHalfHeight := FBMP_OBM_CHECK.Height div 2;
FBOCHalfWidth := FBMP_OBM_CHECK.Width div 2;

finalization

FBMP_OBM_CHECK.Free;

end.
