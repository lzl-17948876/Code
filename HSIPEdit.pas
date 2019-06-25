unit HSIPEdit;

//  ***************************************************************************
//
//  IPEdit
//
//  版本: 1.2
//  作者: 刘志林
//  修改日期: 2017-04-29
//  QQ: 17948876
//  E-mail: lzl_17948876@hotmail.com
//  博客: http://www.cnblogs.com/hs-kill/
//
//  !!! 若有修改,请通知作者,谢谢合作 !!!
//
//  ---------------------------------------------------------------------------
//
//  修改历史:
//    1.1
//      增加对IPV6的支持
//    1.2
//      修改未获得焦点时, 鼠标点击焦点定位的问题
//
//  ***************************************************************************

interface

uses
  Messages, Windows, SysUtils, Classes, Controls, Forms,
  Graphics, StdCtrls, ExtCtrls, Themes;

const
  {激活下一列, WParam: 列序号 LParam: 是否全选 0-不选 1-选}
  WM_IPFIELD_ACTIVE = WM_USER + $4;

type
  THSIPField = class(TCustomEdit)
  private
    { Private declarations }
    FMin, FMax: Word;
    FIndex: Byte;
    FIPV6: Boolean;
    FIsSetValue: Boolean;

    function GetError: Boolean;
    function GetValue: Word;
    procedure SetMin(AValue: Word);
    procedure SetMax(AValue: Word);
    procedure SetValue(AValue: Word);
    procedure SetIPV6(AValue: Boolean);
    function GetCurrentPosition: Integer;
    procedure SetCurrentPosition(Value: Integer);

    procedure WMKeyDown(var Message: TWMKey); message WM_KEYDOWN;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyPress(var Key: Char); override;
  protected
    { Protected declarations }
    procedure Change; override;

    procedure SetValueStr(AValue: string);
    procedure ActiveField(ANext, ASel: Boolean);

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property IPV6: Boolean read FIPV6 write SetIPV6;
    property CurrentPosition: Integer read GetCurrentPosition write SetCurrentPosition;
    property ReadOnly stored False;
    property Index: Byte read FIndex;
  published
    { Published declarations }
    property Min: Word read FMin write SetMin default 0;
    property Max: Word read FMax write SetMax default 255;
    property Value: Word read GetValue write SetValue default 0;
    property Error: Boolean read GetError;
  end;

  THSIPEdit = class(TCustomControl)
  private
    FUpdatting: Boolean;
    FIPV6: Boolean;
    {如果IPV4则使用后4位}
    FFields: array[0..7] of THSIPField;
    FFullRepaint: Boolean;
    FOnChange: TNotifyEvent;

    procedure CreateParams(var Params: TCreateParams); override;

    function GetMin(nIndex: Byte): Word;
    procedure SetMin(nIndex: Byte; Value: Word);
    function GetMax(nIndex: Byte): Word;
    procedure SetMax(nIndex: Byte; Value: Word);
    function GetIPString: string;
    procedure SetIPString(Value: string);
    function GetTabStop: Boolean;
    procedure SetTabStop(AValue: Boolean);
    procedure SetReadOnly(AValue: Boolean);
    function GetReadOnly: Boolean;
    function FocusIndex: Integer;
    function GetFields(AIndex: Integer): THSIPField;
    function GetCursor(): TCursor;
    procedure SetCursor(AValue: TCursor);
    procedure SetIPV6(const Value: Boolean);

    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMIPFIELDACTIVE(var Message: TMessage); message WM_IPFIELD_ACTIVE;
    procedure DoChange(Sender: TObject);
  protected
    procedure ArrangeFields;
    procedure Paint; override;
    property FullRepaint: Boolean read FFullRepaint write FFullRepaint default True;
    property Fields[index: Integer]: THSIPField read GetFields;
(*
    function GetAddr: integer;
    procedure SetAddr(value: integer);
*)
    {暂时不开放设置}
    property Min[index: Byte]: Word read GetMin write SetMin;
    property Max[index: Byte]: Word read GetMax write SetMax;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
(*
    property Addr: integer read GetAddr write SetAddr;
*)
    function FieldCount: Byte;
    function FieldValue(Index: Byte): Integer;
    function Error: Boolean;
    function IsEmpty: Boolean;
  published
    property Align;
    property Anchors;
    property IPString: string read GetIPString write SetIPString;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property Color;
    property Cursor: TCursor Read GetCursor write SetCursor;
    property Ctl3D;
    property Font;
    property Enabled;
    property ParentColor default False;
    property ParentFont default True;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property IPV6: Boolean read FIPV6 write SetIPV6 default False;
    property ShowHint;
    property TabOrder;
    property TabStop: Boolean read GetTabStop write SetTabStop default True;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnEnter;
    property OnExit;
  end;

implementation

const
  _DefWidthIPV4 = 161;
  _DefWidthIPV6 = 361;
  
{  TIPFieldEdit }

procedure THSIPField.SetMin(AValue: Word);
begin
  if (not FIPV6) and (AValue > 255) then
    AValue := 255;
  FMin := AValue;
  if FMax < FMin then
    FMax := FMin;
end;

procedure THSIPField.SetValueStr(AValue: string);
var
  nValue, nCode: Integer;
begin
  FIsSetValue := True;
  try
    if FIPV6 then
      AValue := '$' + AValue;

    Val(AValue, nValue, nCode);

    if (nCode <> 0) then
      AValue := ''
    else
    begin
      if (nValue < FMin) then
        nValue := FMin
      else if (nValue > FMax) then
        nValue := FMax;

      if FIPV6 then
        AValue := IntToHex(nValue, 2)
      else
        AValue := IntToStr(nValue);
    end;
    if AValue <> Text then
      Text := AValue;

    if (Length(Text) = MaxLength) and (CurrentPosition = MaxLength) then
      ActiveField(True, True);
  finally
    FIsSetValue := False;
  end;
end;

procedure THSIPField.SetMax(AValue: Word);
begin
  if (not FIPV6) and (AValue > 255) then
    AValue := 255;
  FMax := AValue;
  if FMin > FMax then
    FMin := FMax;
end;

procedure THSIPField.SetValue(AValue: Word);
begin
  if FIPV6 then
    SetValueStr(IntToHex(AValue, 2))
  else
    SetValueStr(IntToStr(AValue));
end;

procedure THSIPField.KeyPress(var Key: Char);
begin
  if FIPV6 and (Key in ['0'..'9', 'A'..'F']) then
  begin
    inherited;
  end
  else if (Key in ['0'..'9']) then
  begin
    inherited;
  end
  else
  begin
    if (Key = '.') and (SelLength = 0) and (Text <> '') then
      ActiveField(True, True);
    if Key <> #8 then
      Key := #0
    else if CurrentPosition = 0 then
      ActiveField(False, False);
  end;
end;

procedure THSIPField.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or (ES_CENTER);
end;

procedure THSIPField.ActiveField(ANext, ASel: Boolean);
begin
  if ANext then
    SendMessage(Parent.Handle, WM_IPFIELD_ACTIVE, FIndex + 1, MakeLParam(Byte(ASel), 0))
  else
    SendMessage(Parent.Handle, WM_IPFIELD_ACTIVE, FIndex - 1, MakeLParam(Byte(ASel), 1));
end;

procedure THSIPField.Change;
begin
  if not FIsSetValue then
    SetValueStr(Text);
  inherited Change;
end;

constructor THSIPField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Text := '0';
  FMin := 0;
  FMax := 255;
  FIPV6 := False;
  FIsSetValue := False;
  MaxLength := 3;
  ParentFont := True;
  ParentColor := True;
  BorderStyle := bsNone;
end;

destructor THSIPField.Destroy;
begin
  inherited Destroy;
end;

function THSIPField.GetCurrentPosition: Integer;
{Get character position of cursor within line}
begin
  Result := SelStart - SendMessage(Handle, EM_LINEINDEX,
   (SendMessage(Handle, EM_LINEFROMCHAR, SelStart, 0)), 0);
end;

function THSIPField.GetError: Boolean;
var
  nV: Integer;
begin
  if FIPV6 then
    Result := not TryStrToInt('$' + Text, nV)
  else
    Result := not TryStrToInt(Text, nV);
end;

function THSIPField.GetValue: Word;
begin
  if FIPV6 then
    Result := StrToIntDef('$' + Text, 0)
  else
    Result := StrToIntDef(Text, 0);
end;

procedure THSIPField.SetCurrentPosition(Value: Integer);
var
  nPos: Integer;
begin
 {Value must be within range}
 nPos := Value;
 if nPos < 0 then
   nPos := 0;
 if nPos > Length(Text) then
   nPos := Length(Text);
 {Put cursor in selected position}
 SelStart := SendMessage(Handle, EM_LINEINDEX, 0, 0) + nPos;
end;

procedure THSIPField.SetIPV6(AValue: Boolean);
var
  nV: string;
begin
  if FIPV6 <> AValue then
  begin
    FIPV6 := AValue;
    if FIPV6 then
    begin
      MaxLength := 4;
      FMax := $FFFF;
      nV := IntToHex(StrToIntDef(Text, 0), 2);
    end
    else
    begin
      MaxLength := 3;
      FMax := 255;
      nV := IntToStr(StrToIntDef('$' + Text, 0));
    end;
    SetMax(FMax);
    SetMin(FMin);
    SetValueStr(nV);
  end;
  Visible := False;//FIPV6 or (FIndex > 3);
end;

procedure THSIPField.WMKeyDown(var Message: TWMKey);
begin
  with Message do
  if (CharCode = VK_RIGHT) and (CurrentPosition >= Length(Text)) then
  begin
    SelLength := 0;
    ActiveField(True, False);
    Result := 1;
  end
  else if (CharCode = VK_LEFT) and (CurrentPosition = 0) then
  begin
    SelLength := 0;
    ActiveField(False, False);
    Result := 1;
  end
  else
    inherited;
end;

{ TIPEdit }

constructor THSIPEdit.Create(AOwner: TComponent);
var
  i: integer;
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csOpaque, csDoubleClicks, csReplicatable];
  if NewStyleControls then
    ControlStyle := ControlStyle else
    ControlStyle := ControlStyle + [csFramed];
  ParentFont := True;
  FUpdatting := True;
  FIPV6 := False;
  for i := 0 to 7 do
  begin
    FFields[i] := THSIPField.Create(Self);
    with FFields[i] do
    begin
      FIndex := i;
      Parent := Self;
      FIPV6 := Self.FIPV6;
      Visible := i > 3;
      OnChange := DoChange;
    end;
  end;
//  Cursor := crIBeam;
  Width := 161;
  Height := 21;
  BevelKind := bkFlat;
  inherited TabStop := False;
  ParentColor := False;
  ArrangeFields;
  FUpdatting := False;
end;

destructor THSIPEdit.Destroy;
var
  i: integer;
begin
  for i := 0 to 7 do
    FFields[i].Free;
  inherited;
end;

procedure THSIPEdit.DoChange(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function THSIPEdit.Error: Boolean;
var
  i, m: Integer;
begin
  Result := False;
  if FIPV6 then
    m := 0
  else
    m := 4;

  for i := m to 7 do
    if FFields[i].Error then
    begin
      Result := True;
      Break;
    end;
end;

procedure THSIPEdit.CreateParams(var Params: TCreateParams);
const
  ReadOnlys: array[Boolean] of DWORD = (0, ES_READONLY);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or ReadOnlys[ReadOnly];
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure THSIPEdit.CMColorChanged(var Message: TMessage);
begin //
  inherited;
  Invalidate;
end;

procedure THSIPEdit.CMFontChanged(var Message: TMessage);
begin //
  inherited;
  if not FUpdatting then
    ArrangeFields;
  Invalidate;
end;

procedure THSIPEdit.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
end;

procedure THSIPEdit.Paint;
var
  nRect: TRect;
  nTop, i: Integer;
  nFSize: TSize;
begin
//  inherited;
  nRect := GetClientRect;

  Canvas.Brush.Color := Color;
  Canvas.FillRect(nRect);

  nFSize := Canvas.TextExtent('a');
  nTop := nRect.Top + (nRect.Bottom - nRect.Top - nFSize.cy) div 2;
  if FIPV6 then
  begin
    for i := 1 to 7 do
      Canvas.TextOut(FFields[i].Left - nFSize.cx - 2, nTop, ':');
  end
  else
  begin
    for i := 5 to 7 do
      Canvas.TextOut(FFields[i].Left - nFSize.cx - 2, nTop, '.');
  end;
end;

function THSIPEdit.GetCursor(): TCursor;
begin
  Result := inherited Cursor;
end;

procedure THSIPEdit.SetCursor(AValue: TCursor);
var
  i: integer;
begin
  inherited Cursor := AValue;
  for i := 0 to 7 do
    FFields[i].Cursor := AValue;
end;

procedure THSIPEdit.ArrangeFields;
var
  i: integer;
  nW, nH, nL, nT, nB: Integer;
  nFSize: TSize;
  nRC: TRect;
begin
  if not Assigned(Parent) then
    Exit;
  nRC := ClientRect;
  nFSize := Canvas.TextExtent('a');
  nL := nRC.Left + 2;
  nH := nFSize.cy + 2;
  nT := nRc.Top + (nRC.Bottom - nRC.Top - nH) div 2 + 1;

  nB := nFSize.cx + 4;
  if FIPV6 then
  begin
    nW := (ClientWidth - 4 - nB * 7) div 8;
    for i := 0 to 7 do
    begin
      with FFields[i] do
      begin
        Enabled := True;
        Visible := True;
        SetBounds(nL, nT, nW, nH);
      end;
      Inc(nL, nW + nB);
    end;
  end
  else
  begin
    nW := (ClientWidth - 4 - nB * 3) div 4;
    for i := 0 to 3 do
    begin
      with FFields[i] do
      begin
        Visible := False;
        Enabled := False;
        SetBounds(-10, 0, 1, 1);
      end;
    end;
    for i := 4 to 7 do
    begin
      FFields[i].SetBounds(nL, nT, nW, nH);
      Inc(nL, nW + nB);
    end;
  end;
end;

function THSIPEdit.GetMin(nIndex: Byte): Word;
begin
  Result := FFields[nIndex].Min;
end;

procedure THSIPEdit.SetMin(nIndex: Byte; Value: Word);
begin
  FFields[nIndex].Min := Value;
end;

function THSIPEdit.GetMax(nIndex: Byte): Word;
begin
  Result := FFields[nIndex].Max;
end;

procedure THSIPEdit.SetMax(nIndex: Byte; Value: Word);
begin
  FFields[nIndex].Max := Value;
end;

function THSIPEdit.GetIPString: string;
begin
  if Error then
    Result := ''
  else if FIPV6 then
    Result := Format('%.4x:%.4x:%.4x:%.4x:%.4x:%.4x:%.4x:%.4x',
      [FFields[0].Value, FFields[1].Value, FFields[2].Value, FFields[3].Value,
      FFields[4].Value, FFields[5].Value, FFields[6].Value, FFields[7].Value])
  else
    Result := Format('%d.%d.%d.%d',
      [FFields[4].Value, FFields[5].Value, FFields[6].Value, FFields[7].Value]);
end;

procedure THSIPEdit.SetIPString(Value: string);
var
  i, nF: integer;
begin
  if FIPV6 then
    nF := 0
  else
    nF := 4;

  with TStringList.Create do
  try
    if FIPV6 then
      Delimiter := ':'
    else
      Delimiter := '.';

    DelimitedText := Value;
    {暂不支持IPV6缩写模式 如: 0::FF:0}
    if Count <> (8 - nF) then
      for i := nF to 7 do
        FFields[i].SetValueStr('')
    else
      for i := nF to 7 do
        FFields[i].SetValueStr(Strings[i - nF]);
  finally
    Free;
  end;
end;

procedure THSIPEdit.SetIPV6(const Value: Boolean);
var
  i: Integer;
begin
  if FIPV6 <> Value then
  begin
    FUpdatting := True;
    FIPV6 := Value;
    for i := 0 to 7 do
      FFields[i].IPV6 := FIPV6;
    if FIPV6 then
    begin
      if Width = _DefWidthIPV4 then
        Width := _DefWidthIPV6;
    end
    else
    begin
      if Width = _DefWidthIPV6 then
        Width := _DefWidthIPV4;
    end;
    FUpdatting := False;
    ArrangeFields;
    Invalidate;
  end;
end;

(*
function THSIPEdit.GetAddr: integer;
type
  DWORDSTRUCT = Record
    case integer of
      0: (b: array [0..3] of Byte);
      1: (w: array [0..1] of word);
      2: (d: Integer);
  end;
var
  v: DWORDSTRUCT;
  i: integer;
begin
  if Error then
    Result := 0
  else
  begin
    for i := 0 to 3 do
      v.b[i] := FFields[i].Value;
    Result := v.d;
  end;
end;

procedure THSIPEdit.SetAddr(value: integer);
type
  DWORDSTRUCT = Record
    case integer of
      0: (b: array [0..3] of Byte);
      1: (w: array [0..1] of word);
      2: (d: integer);
  end;
var
  v: DWORDSTRUCT;
  i: integer;
begin
  v.d := value;
  for i := 0 to 3 do
  begin
    FFields[i].Value := v.b[i];
  end;
end;
*)

function THSIPEdit.FieldCount: Byte;
begin
  if FIPV6 then
    Result := 8
  else
    Result := 4;
end;

function THSIPEdit.FieldValue(Index: Byte): Integer;
begin
  Result := 0;
  if FIPV6 then
  begin
    if Index > 7 then
      Exit;
    if FFields[Index].Error then
      Exit;
    Result := FFields[Index].Value;
  end
  else
  begin
    if Index > 3 then
      Exit;
    if FFields[Index + 4].Error then
      Exit;
    Result := FFields[Index + 4].Value;
  end;
end;

function THSIPEdit.FocusIndex: Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to 7 do
    if FFields[i].Focused then
      Result := i;
end;

procedure THSIPEdit.WMSize(var Message: TWMSize);
begin
  inherited;
  if not FUpdatting then
    ArrangeFields;
  Invalidate;
end;

procedure THSIPEdit.WMIPFIELDACTIVE(var Message: TMessage);
var
  nF: integer;
  nSel: Boolean;
begin
  if FIPV6 then
    nF := 0
  else
    nF := 4;
  with Message do
  begin
    if (WParam < nF) or (WParam > 7) then
      Exit;

    nSel := Boolean(Byte(LParamLo));
    if nSel then
      FFields[WParam].SelectAll
    else if LParamHi = 0 then
      FFields[WParam].CurrentPosition := 0
    else
      FFields[WParam].CurrentPosition := Length(FFields[WParam].Text);
    FFields[WParam].SetFocus;
  end;
end;

function THSIPEdit.GetFields(AIndex: Integer): THSIPField;
begin
  Result := FFields[AIndex];
end;

function THSIPEdit.GetTabStop: Boolean;
begin
  Result := FFields[0].TabStop;
end;

function THSIPEdit.IsEmpty: Boolean;
var
  nIndex, nM: Integer;
begin
  Result := True;
  if FIPV6 then
    nM := 0
  else
    nM := 4;
  for nIndex := nM to 7 do
  begin
    if FFields[nIndex].Text = '0' then
      Continue;
    Result := False;
    Break;
  end;
end;

procedure THSIPEdit.SetTabStop(AValue: Boolean);
var
  i: integer;
begin
  if AValue <> TabStop then
  begin
    for i := 0 to 7 do
      FFields[i].TabStop := AValue;
  end;
end;

procedure THSIPEdit.SetReadOnly(AValue: Boolean);
var
  i: integer;
begin
  if ReadOnly <> AValue then
    for i := 0 to 7 do
      FFields[i].ReadOnly := AValue;
end;

function THSIPEdit.GetReadOnly: Boolean;
begin
  Result := FFields[0].ReadOnly;
end;

end.
