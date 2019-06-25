unit HSMovePanel;

(*
----THSMovePanel----
修改日志：
2008-10-24
  增加DisplayOnMoving属性 移动时显示窗口内容

*********************************
*    最后修改日期 2008-10-24    *
*          版本 1.1             *
*********************************
*)


interface

uses
  Vcl.ExtCtrls, Winapi.Windows, System.Classes, Winapi.Messages, PNGImage, Graphics, Controls, Types,
  Forms, Themes;

const
  MPBoundBevel = 6; {边缘宽度}
  MPCaptionHeight = 27; {标题分隔线高度}

type

  TCBImage = class(TGraphicControl)
  private
    FPicture: TPicture;
    FDrawing,
    FMouseIn,    {鼠标是否在图片内}
    MDown,         {鼠标是否被按下}
    FDown:boolean; {图片是否处于被按下状态}

    FDisableImage,FEnterImage,FLeaveImage,FClickImage:TPicture;
    FOnMouseEnter:TNotifyEvent;
    FOnMouseLeave:TNotifyEvent;

    procedure PictureChanged(Sender: TObject);
    procedure LPictureChanged(Sender: TObject);


    procedure CMMouseEnter(var msg:TMessage);message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg:TMessage);message CM_MOUSELEAVE;

    procedure SetDisableImage(const Value: TPicture);
    procedure SetEnterImage(const Value: TPicture);
    procedure SetLeaveImage(const Value: TPicture);
    procedure SetClickImage(const Value: TPicture);

    procedure SetDown(VALUE:boolean);
  protected
    { Protected declarations }
    procedure WndProc(var Message: TMessage); override;
    function DestRect: TRect;
    procedure SetEnabled(Value: Boolean); override;
    procedure Paint; override;
  public
    Data:pointer;
    Constructor Create(AOwner:TComponent);override;
    Destructor Destroy;override;
  published
    property DisableImage:TPicture read FDisableImage write SetDisableImage;
    property EnterImage:TPicture read FEnterImage write SetEnterImage;
    property LeaveImage:TPicture read FLeaveImage write SetLeaveImage;
    property ClickImage:TPicture read FClickImage write SetClickImage;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property Visible;
    property OnClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

{------------------------------------------------------------------------------}
  TMPWState=(MPW_MAX,MPW_NORMAL,MPW_MIN);
  TMPCloseEvent = procedure(Sender: TObject; var CanClose: Boolean) of object;
  TMPMovingEvent = procedure(Sender: TObject; var MX, MY:integer) of object;
  TMPBorderButton=(MBBClose, MBBMinimize, MBBMaximize);
  TMPBorderButtons=set of TMPBorderButton;

  THSMovePanel = class(TCustomControl)
  private
    FBevelSize:integer; {边缘宽度}
    FBorderButtons:TMPBorderButtons; {控制按钮}
    FPCBtPanel, {标题按钮panel}
    FPCaption:TPanel; {标题栏}
    FBevelTop:TBevel; {标题栏与Client区域分隔线}
    IBClose, {关闭按钮}
    IBMax, {最大化按钮}
    IBMin:TCBImage; {最小化按钮}

    FCPDPT:TPoint; {标题移动按下的点}
    FDisplayOnMoving, {移动时显示窗口内容}
    FCanSize:boolean; {是否可以改变大小}
    FState:TMPWState; {窗口状态}
    FOldRect:TRect;
    FFullRepaint: Boolean;

    FOnMouseEnter:TNotifyEvent;
    FOnMouseLeave:TNotifyEvent;
    FOnMoving:TMPMovingEvent; {只能用于随时拖拽模式}
    FOnShow:TNotifyEvent;
    FOnClose:TMPCloseEvent;

    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure CMBorderChanged(var Message: TMessage); message CM_BORDERCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMIsToolControl(var Message: TMessage); message CM_ISTOOLCONTROL;
    procedure CMCOLORCHANGED(var Message: TMessage); message CM_COLORCHANGED;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure CMMouseEnter(var msg:TMessage);message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg:TMessage);message CM_MOUSELEAVE;

    procedure IBCloseClick(Sender: TObject);
    procedure IBMinClick(Sender: TObject);
    procedure IBMaxClick(Sender: TObject);
    procedure CPMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CPDBClick(Sender: TObject);
    procedure CPMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);

    procedure SetState(Value:TMPWState);
    function GetCaption:string;
    procedure SetCaption(Value:String);
    function GetFont:TFont;
    procedure SetFont(Value:TFont);
    function GetAlignment:TAlignment;
    procedure SetAlignment(Value:TAlignment);
    procedure SetBorderButtons(const Value:TMPBorderButtons);

    function GetClientHeight: Integer;
    function GetClientWidth: Integer;

    procedure SetClientHeight(Value: Integer);
    procedure SetClientWidth(Value: Integer);
    function GetClientRectX: TRect;

  protected
    procedure WndProc(var Message: TMessage); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure AdjustIButtons;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    Destructor Destroy;override;
    procedure Show;
    procedure Close;
  published
    property BevelInner;
    property BevelOuter;
    property Ctl3D;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property BorderButtons:TMPBorderButtons read FBorderButtons write SetBorderButtons
      default [MBBClose, MBBMinimize, MBBMaximize];
    property WindowsState:TMPWState read FState write SetState;
    property CanSize: boolean read FCanSize write FCanSize;
    property Caption:string read GetCaption write SetCaption;
    property Font:TFont read GetFont write SetFont;
    property FullRepaint: Boolean read FFullRepaint write FFullRepaint default True;
    property Color default clBtnFace;
    property Alignment: TAlignment read GetAlignment write SetAlignment default taLeftJustify;
    property ClientHeight: Integer read GetClientHeight write SetClientHeight stored False;
    property ClientRect: TRect read GetClientRectX;
    property ClientWidth: Integer read GetClientWidth write SetClientWidth stored False;
    property DisplayOnMoving: boolean read FDisplayOnMoving write FDisplayOnMoving;
    property Constraints;
    property Enabled;
    property OnClick;
    property OnConstrainedResize;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMoving: TMPMovingEvent read FOnMoving write FOnMoving;
    property OnResize;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnClose: TMPCloseEvent read FOnClose write FOnClose;
  end;

  function ReleaseRESImg(img:TGraphic; ResName,ResType:string):boolean;

procedure Register;

implementation
{$R *.res}

procedure Register;
begin
  RegisterComponents('HSControls', [THSMovePanel]);
end;

{------------------------------------------------------------------------------}
function ReleaseRESImg(img:TGraphic; ResName,ResType:string):boolean;
var
  Res:TResourceStream;
begin
  result:=false;
  try
    Res:=TResourceStream.Create(Hinstance,ResName,pchar(ResType));
    try
      img.LoadFromStream(res);
    finally
      Res.Free;
    end;
    result:=true;
  except
  end;
end;

{----TCBImage------------------------------------------------------------------}
procedure TCBImage.CMMouseEnter(var msg: TMessage);
begin
  if (not (csDesigning in ComponentState)) and Enabled then
  begin
    if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
    if not FDown and (FEnterImage.Graphic<>nil) then
      FPicture.Assign(FEnterImage);
    FMouseIn:=true;
  end;
end;

procedure TCBImage.CMMouseLeave(var msg: TMessage);
begin
  if (not (csDesigning in ComponentState)) and Enabled then
  begin
    if Assigned(FOnMouseleave) then FOnMouseleave(Self);
    if not FDown and (FLeaveImage.Graphic<>nil) then
      FPicture.Assign(FLeaveImage);
    FMouseIn:=false;
  end;
end;

constructor TCBImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csReplicatable];
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  FEnterImage:=TPicture.Create;
  FLeaveImage:=TPicture.Create;
  FLeaveImage.OnChange:=LPictureChanged;
  FClickImage:=TPicture.Create;
  FDisableImage:=Tpicture.Create;
  
  Height := 105;
  Width := 105;
end;

destructor TCBImage.Destroy;
begin
  FPicture.Free;
  FDisableImage.Free;
  FEnterImage.Free;
  FLeaveImage.Free;
  FClickImage.Free;
  inherited Destroy ;
end;

function TCBImage.DestRect: TRect;
begin
  with Result do
  begin
    Left := 0;
    Top := 0;
    Right := FPicture.Width;
    Bottom := FPicture.Height;
  end;
end;

procedure TCBImage.SetEnabled(Value: Boolean);
begin
  if GetEnabled<>Value then
    if not Value then
    begin
      if FDisableImage.Graphic<>nil then
        FPicture.Assign(FDisableImage);
    end
    else if FLeaveImage.Graphic<>nil then
      FPicture.Assign(FLeaveImage);
  inherited;
end;

procedure TCBImage.Paint;
var
  Save: Boolean;
begin
  if (csDesigning in ComponentState) and (FPicture.Graphic=nil) then
  begin
    with inherited Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;
  end
  else
  begin
    Save := FDrawing;
    FDrawing := True;
    try
      with inherited Canvas do
        StretchDraw(DestRect, FPicture.Graphic);
    finally
      FDrawing := Save;
    end;
  end;
end;

procedure TCBImage.PictureChanged(Sender: TObject);
begin
  if (FPicture.Width > 0) and (FPicture.Height > 0) then
  	SetBounds(Left, Top, FPicture.Width, FPicture.Height);
  if not FDrawing then
    Invalidate;
end;

procedure TCBImage.LPictureChanged(Sender: TObject);
begin
  FPicture.Assign(FLeaveImage);
end;

procedure TCBImage.WndProc(var Message: TMessage);
var
  tmpk:boolean;
begin
  if not (csDesigning in ComponentState) then
    case Message.Msg of
      WM_LBUTTONDOWN:
      begin
        MDown:=true;
        if (not FDown) then
          SetDown(true);
        inherited;
        if FMouseIn and (not FDown) and (FClickImage.Graphic<>nil) then
          FPicture.Assign(FClickImage);
      end;
      WM_LBUTTONUP: 
      begin
        {双击也会发出WM_LBUTTONUP消息,判断是否经过WM_LBUTTONDOWN消息后鼠标抬起}
        tmpk:=MDown;
        SetDown(not FDown);
        MDown:=false;
        inherited;
        if tmpk then
        begin
          if (not FDown) and FMouseIn then
          begin
            if FEnterImage.Graphic<>nil then
              FPicture.Assign(FEnterImage)
            else if FLeaveImage.Graphic<>nil then
              FPicture.Assign(FLeaveImage);
          end;
        end;
      end;
    else
      inherited ;
    end
  else
    inherited;
end;

procedure TCBImage.SetDisableImage(const Value: TPicture);
begin
  FDisableImage.Assign(Value);
  if not Enabled and (FDisableImage.Graphic<>nil) then
    FPicture.Assign(FDisableImage);
end;

procedure TCBImage.SetEnterImage(const Value: TPicture);
begin
  FEnterImage.Assign(Value);
end;

procedure TCBImage.SetLeaveImage(const Value: TPicture);
begin
  FLeaveImage.Assign(Value);
  if Enabled then
    FPicture.Assign(FLeaveImage);
end;

procedure TCBImage.SetClickImage(const Value: TPicture);
begin
  FClickImage.Assign(Value);
end;

procedure TCBImage.SetDown(VALUE:boolean);
begin
  if FDown<>value then
  begin
    if value then
    begin
      if Enabled and (FClickImage.Graphic<>nil) then
        FPicture.Assign(FClickImage);
    end
    else
    begin
      if Enabled and (FLeaveImage.Graphic<>nil) then
        FPicture.Assign(FLeaveImage);
    end;
    FDown:=value;
  end;
end;

{----THSMovePanel--------------------------------------------------------------}
constructor THSMovePanel.Create(AOwner: TComponent);
var
  png:TPNGObject;
  tl:integer;
begin
  inherited Create(AOwner);
  FBorderButtons:=[MBBClose, MBBMinimize, MBBMaximize];
  ControlStyle := [csAcceptsControls, csCaptureMouse,
    csOpaque, csReplicatable];
  if ThemeServices.ThemesEnabled then
    ControlStyle := ControlStyle + [csParentBackground] - [csOpaque];
  Width := 185;
  Height := 41;

  Ctl3D := False;
  BevelInner:=bvRaised;
  BevelOuter:=bvLowered;
  FBevelSize:=2;

  FDisplayOnMoving:=True;
  DoubleBuffered:=true;
  FOldRect:=rect(left,top,width,height);
  FState:=MPW_NORMAL;
  FCanSize:=true;
  FFullRepaint:=False;

  FPCaption:=TPanel.Create(self);
  with FPCaption do
  begin
    Height:=MPCaptionHeight;
    BevelInner:=bvNone;
    BevelOuter:=bvNone;
    Caption:=self.Caption;
    Color:=self.Color;
    OnMouseDown:=CPMouseDown;
    OnDblClick:=CPDBClick;
    OnMouseMove:=CPMouseMove;
    Parent:=self;
  end;

  FPCBtPanel:=TPanel.Create(self);
  with FPCBtPanel do
  begin
    Align:=alRight;
    DoubleBuffered:=true;
    Width:=45;
    BevelInner:=bvNone;
    BevelOuter:=bvNone;
    Caption:='';
    Color:=self.Color;
    Parent:=FPCaption;
  end;

  FBevelTop:=TBevel.Create(self);
  with FBevelTop do
  begin
    Align:=alBottom;
    Height:=2;
    Shape:=bsBottomLine;
    Parent:=FPCaption;
  end;

  {图片尺寸 11*11}
  tl:=2;
  png:=TPNGObject.Create;
  IBMin:=TCBImage.Create(self);
  with IBMin do
  begin
    ReleaseRESImg(png,'MinL','PNGimage');  {阴影图片}
    LeaveImage.Assign(png);
    DisableImage.Assign(png);
    FPicture.Assign(png);
    ReleaseRESImg(png,'MinE','PNGimage');  {阴影图片}
    EnterImage.Assign(png);
    OnClick:=IBMinClick;
    AutoSize:=true;
    SetBounds(tl,3,Width,Height);
    Parent:=FPCBtPanel;
    inc(tl,Width+2);
  end;
  IBMax:=TCBImage.Create(self);
  with IBMax do
  begin
    ReleaseRESImg(png,'MaxL','PNGimage');  {阴影图片}
    LeaveImage.Assign(png);
    DisableImage.Assign(png);
    FPicture.Assign(png);
    ReleaseRESImg(png,'MaxE','PNGimage');  {阴影图片}
    EnterImage.Assign(png);
    OnClick:=IBMaxClick;
    AutoSize:=true;
    SetBounds(tl,3,Width,Height);
    Parent:=FPCBtPanel;
    inc(tl,Width+2);
  end;
  IBClose:=TCBImage.Create(self);
  with IBClose do
  begin
    ReleaseRESImg(png,'CloseL','PNGimage');  {阴影图片}
    LeaveImage.Assign(png);
    DisableImage.Assign(png);
    FPicture.Assign(png);
    ReleaseRESImg(png,'CloseE','PNGimage');  {阴影图片}
    EnterImage.Assign(png);
    OnClick:=IBCloseClick;
    AutoSize:=true;
    SetBounds(tl,3,Width,Height);
    Parent:=FPCBtPanel;
  end;
  png.Free;

  AdjustIButtons;

  Color:=clBtnFace;
  SetCaption(Name);
  SetAlignment(taLeftJustify);
end;

destructor THSMovePanel.Destroy;
begin
  FBevelTop.Free;
  IBClose.Free;
  IBMax.Free;
  IBMin.Free;
  FPCBtPanel.Free;
  FPCaption.Free;
  inherited Destroy ;
end;

procedure THSMovePanel.Show;
begin
  if not Visible then
  begin
    Visible:=true;
    if assigned(FOnShow) then
      FOnShow(self);
  end;
end;

procedure THSMovePanel.Close;
var
  ACanClose:boolean;
begin
  if Visible then
  begin
    ACanClose:=true;
    if assigned(FOnClose) then
      FOnClose(self,ACanClose);
    if ACanClose then
      hide;
  end;
end;

procedure THSMovePanel.WndProc(var Message: TMessage);
var
  Pt: TPoint;
begin
  if not (csDesigning in ComponentState) then
    case Message.Msg of
      WM_NCHITTEST:
        if FCanSize and (FState=MPW_NORMAL) then
        begin
          Pt := ScreenToClient(Point(LOWORD(message.LParam), HIWORD(message.LParam)));
          if (Pt.x <= MPBoundBevel) then
          begin
            if (pt.y <= MPBoundBevel) then
              message.Result := htTopLeft
            else if (pt.y > Height - MPBoundBevel) then
              message.Result := htBottomLeft
            else
              message.Result := htLeft;
          end
          else if (Pt.x > Width - MPBoundBevel) then
          begin
            if (pt.y <= MPBoundBevel) then
              message.Result := htTopRight
            else if (pt.y > Height - MPBoundBevel) then
              message.Result := htBottomRight
            else
              message.Result := htRight;
          end
          else if (pt.y <= MPBoundBevel) then
            message.Result := htTop
          else if (pt.y > Height - MPBoundBevel) then
            message.Result := htBottom
          else
            inherited;
        end
        else
          inherited;
      else
        inherited; {WndProc(Message);}
    end
  else
    inherited;
end;

procedure THSMovePanel.WMMove(var Message: TWMMove);
var
  AX, AY:integer;
begin
  if not FDisplayOnMoving then
  begin
    AX:=Message.XPos;
    AY:=Message.YPos;
    if Assigned(FOnMoving) then
      FOnMoving(self, AX, AY);
    if (AX<>Message.XPos) or (AY<>Message.YPos) then
      SetBounds(AX, AY, Width, Height);
    Message.Result:=0;
  end;
end;

procedure THSMovePanel.WMSize(var Message: TWMSize);
begin
  inherited;
  FPCaption.SetBounds(FBevelSize,FBevelSize,
    message.Width-FBevelSize*2,MPCaptionHeight);
  Invalidate;
end;

procedure THSMovePanel.CMBorderChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure THSMovePanel.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure THSMovePanel.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
end;

procedure THSMovePanel.CMIsToolControl(var Message: TMessage);
begin
  Message.Result := 1;
end;

procedure THSMovePanel.CMCOLORCHANGED(var Message: TMessage);
begin
  inherited;
  FPCaption.Color:=Color;
  FPCBtPanel.Color:=Color;
end;

procedure THSMovePanel.WMWindowPosChanged(var Message: TWMWindowPosChanged);
var
  BevelPixels: Integer;
  Rect: TRect;
begin
  if FullRepaint then
    Invalidate
  else
  begin
    BevelPixels := BorderWidth;
    if BevelInner <> bvNone then Inc(BevelPixels, BevelWidth);
    if BevelOuter <> bvNone then Inc(BevelPixels, BevelWidth);
    if BevelPixels > 0 then
    begin
      Rect.Right := Width;
      Rect.Bottom := Height;
      if Message.WindowPos.cx <> Rect.Right then
      begin
        Rect.Top := 0;
        Rect.Left := Rect.Right - BevelPixels - 1;
        InvalidateRect(Handle, @Rect, True);
      end;
      if Message.WindowPos.cy <> Rect.Bottom then
      begin
        Rect.Left := 0;
        Rect.Top := Rect.Bottom - BevelPixels - 1;
        InvalidateRect(Handle, @Rect, True);
      end;
    end;
  end;
  inherited;
end;

procedure THSMovePanel.CMMouseEnter(var msg: TMessage);
begin
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure THSMovePanel.CMMouseLeave(var msg: TMessage);
begin
  if Assigned(FOnMouseleave) then
    FOnMouseleave(Self);
end;

procedure THSMovePanel.IBCloseClick(Sender: TObject);
begin
  Close;
end;

procedure THSMovePanel.IBMinClick(Sender: TObject);
begin
  if not (csDesigning in ComponentState) then
  begin
    if FState=MPW_MIN then
      SetState(MPW_NORMAL)
    else
      SetState(MPW_MIN);
  end;
end;

procedure THSMovePanel.IBMaxClick(Sender: TObject);
begin
  if not (csDesigning in ComponentState) then
  begin
    if FState=MPW_MAX then
      SetState(MPW_NORMAL)
    else
      SetState(MPW_MAX);
  end;
end;

procedure THSMovePanel.CPMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not (csDesigning in ComponentState) then
  begin
    if (Button=mbLeft) and (FState=MPW_NORMAL) then
    begin
      if FDisplayOnMoving then
        FCPDPT:=point(x,y)
      else
      begin
        ReleaseCapture;
        Perform(WM_SYSCOMMAND, $F012,0);
      end;
    end;
  end;
end;

procedure THSMovePanel.CPDBClick(Sender: TObject);
begin
  if not (csDesigning in ComponentState) then
  begin
    if FState=MPW_MAX then
      SetState(MPW_NORMAL)
    else
      SetState(MPW_MAX);
  end;
end;

procedure THSMovePanel.CPMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  AX, AY:integer;
begin
  if FDisplayOnMoving and (ssLeft in Shift) and (FState=MPW_NORMAL) then
  begin
    AX:=Left+x-FCPDPT.X;
    AY:=Top+y-FCPDPT.Y;
    if Assigned(FOnMoving) then
      FOnMoving(self, AX, AY);
    SetBounds(AX, AY, Width, Height);
  end;
end;

procedure THSMovePanel.SetState(Value:TMPWState);
begin
  if assigned(parent) and (Value<>FState) then
  begin
    case Value of
      MPW_MAX:
        if IBMax.Visible then
        begin
          if FState=MPW_NORMAL then
            FOldRect:=rect(left,top,width,height);
          Align:=alClient;
          FState:=Value;
        end;
      MPW_NORMAL:
      begin
        Align:=alNone;
        SetBounds(FOldRect.Left, FOldRect.Top, FOldRect.Right, FOldRect.Bottom);
        FState:=Value;
      end;
      MPW_MIN:
        if IBMin.Visible then
        begin
          if FState=MPW_NORMAL then
            FOldRect:=rect(left,top,width,height);
          Align:=alNone;
          SetBounds(0, parent.ClientHeight-FPCaption.Height-2, 100, FPCaption.Height+2);
          FState:=Value;
        end;
    end;
  end;
end;

function THSMovePanel.GetCaption:string;
begin
  result:=FPCaption.Caption;
end;

procedure THSMovePanel.SetCaption(Value:String);
begin
  FPCaption.Caption:=Value;
end;

function THSMovePanel.GetFont:TFont;
begin
  result:=FPCaption.Font;
end;

procedure THSMovePanel.SetFont(Value:TFont);
begin
  FPCaption.Font:=Value;
end;

function THSMovePanel.GetAlignment:TAlignment;
begin
  result:=FPCaption.Alignment;
end;

procedure THSMovePanel.SetAlignment(Value:TAlignment);
begin
  FPCaption.Alignment:=Value;
end;

procedure THSMovePanel.SetBorderButtons(const Value:TMPBorderButtons);
begin
  if Value <> FBorderButtons then
  begin
    FBorderButtons:=Value;
    IBMin.Visible:=MBBMinimize in FBorderButtons;
    IBMax.Visible:=MBBMaximize in FBorderButtons;
    IBClose.Visible:=MBBClose in FBorderButtons;
    AdjustIButtons;
  end;
end;

function THSMovePanel.GetClientHeight: Integer;
var
  Rect:TRect;
begin
  rect:=GetClientRect;
  AdjustClientRect(rect);
  result:=rect.Bottom-rect.Top;
end;

function THSMovePanel.GetClientRectX: TRect;
begin
  AdjustClientRect(result);
end;

function THSMovePanel.GetClientWidth: Integer;
var
  Rect:TRect;
begin
  rect:=GetClientRect;
  AdjustClientRect(rect);
  result:=rect.Right-rect.Left;
end;

procedure THSMovePanel.SetClientHeight(Value: Integer);
var
  Rect:TRect;
begin
  rect:=GetClientRect;
  AdjustClientRect(rect);
  Height:=Height+Value-(rect.Bottom-rect.Top);
end;

procedure THSMovePanel.SetClientWidth(Value: Integer);
var
  Rect:TRect;
begin
  rect:=GetClientRect;
  AdjustClientRect(rect);
  Width:=Width+Value-(rect.Right-rect.Left);
end;

//function THSMovePanel.CanMove:boolean;
//begin
//
//end;
//
procedure THSMovePanel.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or DWORD(bsNone);
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure THSMovePanel.AdjustClientRect(var Rect: TRect);
begin
  inherited AdjustClientRect(Rect);
  InflateRect(Rect, -BorderWidth, -BorderWidth);
  InflateRect(Rect, -MPBoundBevel, 0);
  Rect.Top:=Rect.Top+MPCaptionHeight+FBevelSize;
  rect.Bottom:=rect.Bottom-MPBoundBevel;
end;

procedure THSMovePanel.AdjustIButtons;
var
  ct,tl:integer;
begin
  ct:=0;
  tl:=2;
  with IBMin do
    if Visible then
    begin
      Left:=tl;
      inc(tl,13);
      inc(ct);
    end;
  with IBMax do
    if Visible then
    begin
      Left:=tl;
      inc(tl,13);
      inc(ct);
    end;
  with IBClose do
    if Visible then
    begin
      Left:=tl;
      inc(tl,13);
      inc(ct);
    end;

  FPCBtPanel.Width:=ct*11+4+(ct-1)*2;
end;

procedure THSMovePanel.Paint;
const
  Alignments: array[TAlignment] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);
//  VerticalAlignments: array[TVerticalAlignment] of Longint = (DT_TOP, DT_BOTTOM, DT_VCENTER);
var
  Rect: TRect;
  TopColor, BottomColor: TColor;
  Flags: Longint;

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    if Ctl3D then
    begin
      TopColor := clBtnHighlight;
      if Bevel = bvLowered then TopColor := clBtnShadow;
      BottomColor := clBtnShadow;
      if Bevel = bvLowered then BottomColor := clBtnHighlight;
    end
    else
    begin
      TopColor := clBlack;
      BottomColor := clBlack;
    end;
  end;

begin
  Rect := GetClientRect;

  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  if not (ThemeServices.ThemesEnabled and (csParentBackground in ControlStyle)) then
    Frame3D(Canvas, Rect, Color, Color, BorderWidth)
  else
    InflateRect(Rect, -Integer(BorderWidth), -Integer(BorderWidth));
  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  with Canvas do
  begin
    if not ThemeServices.ThemesEnabled or not ParentBackground then
    begin
      Brush.Color := Color;
      FillRect(Rect);
    end;
    Brush.Style := bsClear;
  end;
end;

{------------------------------------------------------------------------------}
initialization

finalization

end.
