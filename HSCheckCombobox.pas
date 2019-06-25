unit HSCheckCombobox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type

  THSCheckComboBox = class(TCustomComboBox)
  private
    { Private declarations }
    FListInstance: Pointer;
    FDefListProc: Pointer;
    FListHandle: HWnd;
    FCheckedCount: Integer;
    FTextAsHint: Boolean;
    FOnCheckClick: TNotifyEvent;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure ListWndProc(var Message: TMessage);
  protected
    { Protected declarations }
    FText: string;
    FTextUpdated: Boolean;
    procedure WndProc(var Message: TMessage); override;
    procedure RecalcText;
    function GetText: string;
    function GetCheckedCount: Integer;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetCheck(nIndex: Integer; checked: Boolean);
    function AddChecked(Value: string; checked: Boolean): Integer;
    function IsChecked(nIndex: Integer): Boolean;
    procedure CheckAll(checked: Boolean);
    property Text: string read GetText;
    property CheckedCount: Integer read GetCheckedCount;
  published
    { Published declarations }
    property Anchors;
    property BiDiMode;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropDownCount;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ItemHeight;
    property Items;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint default False;
    property PopupMenu;
    property ShowHint default True;
    property ShowTextAsHint: Boolean read FTextAsHint write FTextAsHint
      default True;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnCheckClick: TNotifyEvent read FOnCheckClick write FOnCheckClick;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

var
  FCheckWidth, FCheckHeight: Integer;

procedure GetCheckSize;
begin
  with TBitmap.Create do
    try
      Handle := LoadBitmap(0, PChar(32759));
      FCheckWidth := Width div 4;
      FCheckHeight := Height div 3;
    finally
      Free;
    end;
end;

procedure THSCheckComboBox.SetCheck(nIndex: Integer; checked: Boolean);
begin
  if (nIndex > -1) and (nIndex < Items.count) then
  begin
    Items.Objects[nIndex] := TObject(checked);
    FTextUpdated := False;
    Invalidate;
    if Assigned(FOnCheckClick) then
      OnCheckClick(Self)
  end;
end;

function THSCheckComboBox.AddChecked(Value: string; checked: Boolean): Integer;
begin
  Result := Items.AddObject(Value, TObject(checked));
  if Result >= 0 then
  begin
    FTextUpdated := False;
    Invalidate;
  end;
end;

function THSCheckComboBox.IsChecked(nIndex: Integer): Boolean;
begin
  Result := False;
  if (nIndex > -1) and (nIndex < Items.count) then
    Result := Items.Objects[nIndex] = TObject(True)
end;

procedure THSCheckComboBox.CheckAll(checked: Boolean);
var
  i: Integer;
begin
  for i := 0 to Items.count - 1 do
    Items.Objects[i] := TObject(checked);
end;

function THSCheckComboBox.GetText: string;
begin
  RecalcText;
  Result := FText;
end;

function THSCheckComboBox.GetCheckedCount: Integer;
begin
  RecalcText;
  Result := FCheckedCount;
end;

procedure THSCheckComboBox.RecalcText;
var
  nCount, i: Integer;
  nItem, nText, nSeparator: string;
begin
  if (not FTextUpdated) then
  begin
    FCheckedCount := 0;
    nCount := Items.count;
    nSeparator := '; ';
    nText := '';
    for i := 0 to nCount - 1 do
      if IsChecked(i) then
      begin
        inc(FCheckedCount);
        nItem := Items[i];
        if (nText <> '') then
          nText := nText + nSeparator;
        nText := nText + nItem;
      end;
    // Set the text
    FText := nText;
    if FTextAsHint then
      Hint := FText;
    FTextUpdated := True;
  end;
end;

procedure THSCheckComboBox.CMEnter(var Message: TCMEnter);
begin
  Self.Color := clWindow;
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure THSCheckComboBox.CMExit(var Message: TCMExit);
begin
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure THSCheckComboBox.CNDrawItem(var Message: TWMDrawItem);
var
  nODState: TOwnerDrawState;
  nRCBmp, nRCText: TRect;
  nCheck: Integer; // 0 - No check, 1 - Empty check, 2 - Checked
  nState: Integer;
  nText: string;
  nItId: Integer;
  nHDC: HDC;
begin
  with Message.DrawItemStruct^ do
  begin
    nODState := TOwnerDrawState(LongRec(itemState).Lo);
    nHDC := HDC;
    nRCBmp := rcItem;
    nRCText := rcItem;
    nItId := itemID;
  end;
  // Check if we are drawing the static portion of the combobox
  if (nItId < 0) then
  begin
    RecalcText();
    nText := FText;
    nCheck := 0;
  end
  else
  begin
    nText := Items[nItId];
    nRCBmp.Left := 2;
    nRCBmp.Top := nRCText.Top +
      (nRCText.Bottom - nRCText.Top - FCheckWidth) div 2;
    nRCBmp.Right := nRCBmp.Left + FCheckWidth;
    nRCBmp.Bottom := nRCBmp.Top + FCheckHeight;

    nRCText.Left := nRCBmp.Right;
    nCheck := 1;
    if IsChecked(nItId) then
      inc(nCheck);
  end;
  if (nCheck > 0) then
  begin
    SetBkColor(nHDC, GetSysColor(COLOR_WINDOW));
    SetTextColor(nHDC, GetSysColor(COLOR_WINDOWTEXT));
    nState := DFCS_BUTTONCHECK;
    if (nCheck > 1) then
      nState := nState or DFCS_CHECKED;
    DrawFrameControl(nHDC, nRCBmp, DFC_BUTTON, nState);
  end;
  if (odSelected in nODState) then
  begin
    SetBkColor(nHDC, ColorToRGB(clHotLight));
    SetTextColor(nHDC, GetSysColor(COLOR_HIGHLIGHTTEXT));
  end
  else
  begin
    if (nCheck = 0) then
    begin
      SetTextColor(nHDC, ColorToRGB(Font.Color));
      SetBkColor(nHDC, ColorToRGB(Self.Color));
    end
    else
    begin
      SetTextColor(nHDC, ColorToRGB(Font.Color));
      SetBkColor(nHDC, ColorToRGB(Brush.Color));
    end;
  end;

  if nItId >= 0 then
    nText := ' ' + nText;
  ExtTextOut(nHDC, 0, 0, ETO_OPAQUE, @nRCText, Nil, 0, Nil);
  DrawText(nHDC, PChar(nText), length(nText), nRCText, DT_SINGLELINE or
    DT_VCENTER or DT_END_ELLIPSIS);
  if odFocused in nODState then
    DrawFocusRect(nHDC, nRCText);
end;

procedure THSCheckComboBox.ListWndProc(var Message: TMessage);
var
  nItemHeight, nTopIndex, nIndex: Integer;
  nRCItem, nRCClient: TRect;
  nPT: TPoint;
begin
  case Message.Msg of
    LB_GETCURSEL: // this is for to not draw the selected in the text area
    begin
      Message.Result := -1;
      Exit;
    end;
    WM_CHAR: // pressing space toggles the checked
    begin
      if (TWMKey(Message).CharCode = VK_SPACE) then
      begin
        // Get the current selection
        nIndex := CallWindowProcA(FDefListProc, FListHandle, LB_GETCURSEL,
          Message.wParam, Message.lParam);
        SendMessage(FListHandle, LB_GETITEMRECT, nIndex, LongInt(@nRCItem));
        InvalidateRect(FListHandle, @nRCItem, False);
        SetCheck(nIndex, not IsChecked(nIndex));
        SendMessage(WM_COMMAND, Handle, CBN_SELCHANGE, Handle);
        Message.Result := 0;
        Exit;
      end
    end;
    WM_LBUTTONDOWN:
    begin
      Windows.GetClientRect(FListHandle, nRCClient);
      nPT.x := TWMMouse(Message).XPos; // LOWORD(Message.lParam);
      nPT.y := TWMMouse(Message).YPos; // HIWORD(Message.lParam);
      if (PtInRect(nRCClient, nPT)) then
      begin
        nItemHeight := SendMessage(FListHandle, LB_GETITEMHEIGHT, 0, 0);
        nTopIndex := SendMessage(FListHandle, LB_GETTOPINDEX, 0, 0);
        // Compute which index to check/uncheck
        nIndex := trunc(nTopIndex + nPT.y / nItemHeight);
        SendMessage(FListHandle, LB_GETITEMRECT, nIndex, LongInt(@nRCItem));
        if (PtInRect(nRCItem, nPT)) then
        begin
          InvalidateRect(FListHandle, @nRCItem, False);
          SetCheck(nIndex, not IsChecked(nIndex));
          SendMessage(WM_COMMAND, Handle, CBN_SELCHANGE, Handle);
        end
      end
    end;
    WM_LBUTTONUP:
    begin
      Message.Result := 0;
      Exit;
    end;
  end;
  ComboWndProc(Message, FListHandle, FDefListProc);
end;

constructor THSCheckComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ShowHint := True;
  FTextAsHint := True;
  ParentShowHint := False;
  FListHandle := 0;
  Style := csOwnerDrawVariable;
  FTextUpdated := False;
  FListInstance := MakeObjectInstance(ListWndProc);
end;

destructor THSCheckComboBox.Destroy;
begin
  FreeObjectInstance(FListInstance);
  inherited Destroy;
end;

procedure THSCheckComboBox.WndProc(var Message: TMessage);
var
  nHWnd: HWnd;
begin
  if message.Msg = WM_CTLCOLORLISTBOX then
  begin
    if FListHandle = 0 then
    begin
      nHWnd := message.lParam;
      if (nHWnd <> 0) and (nHWnd <> FDropHandle) then
      begin
        FListHandle := nHWnd;
        FDefListProc := Pointer(GetWindowLong(FListHandle, GWL_WNDPROC));
        SetWindowLong(FListHandle, GWL_WNDPROC, LongInt(FListInstance));
      end;
    end;
  end;
  inherited;
end;

initialization
  GetCheckSize;

end.
