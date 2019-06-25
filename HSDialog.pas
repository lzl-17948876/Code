unit HSDialog;

interface

uses
  System.Classes, System.SysUtils,
  Vcl.StdCtrls;

type
  TInputBoxItem = record
    ID: string;
    Prompt: string;
    Value: string;
    MultiLine: Boolean;
    PasswordChar: Char;
    CharCase: TEditCharCase;
  end;
  TInputBoxItemHelper = record helper for TInputBoxItem
    class function Create: TInputBoxItem; static;
  end;
  TInputCloseQueryFunc = reference to function (const ID, Value: string): Boolean;

function InputBox(const ACaption: string; AItems: TArray<TInputBoxItem>;
  ACloseQueryFunc: TInputCloseQueryFunc): Boolean; overload;
function InputBox(const ACaption: string; var AItem: TInputBoxItem): Boolean; overload;

implementation

uses
  System.UITypes, System.Generics.Collections, System.Types,
  Vcl.Forms, Vcl.Controls;

var
  FLastRect: TRect;

type
  PInputBoxItem = ^TInputBoxItem;
  TInputQueryForm = class(TForm)
  public
    FCloseQueryFunc: TFunc<Boolean>;
    function CloseQuery: Boolean; override;
  end;

function InputBox(const ACaption: string; var AItem: TInputBoxItem): Boolean;
var
  nItems: TArray<TInputBoxItem>;
begin
  SetLength(nItems, 1);
  nItems[0] := AItem;
  Result := InputBox(ACaption, nItems, nil);
  if Result then
    AItem := nItems[0];
end;

function InputBox(const ACaption: string; AItems: TArray<TInputBoxItem>;
  ACloseQueryFunc: TInputCloseQueryFunc): Boolean;

  function GetPasswordChar(const ACaption: string): Char;
  begin
    if (Length(ACaption) > 1) and (ACaption[1] < #32) then
      Result := '*'
    else
      Result := #0;
  end;

const
  C_B = 8;
var
  nItemIndex, J: Integer;
  nForm: TInputQueryForm;
  lCE: TCustomEdit;
  nLabel: TLabel;
  nItemCount: Integer;
  nTop, nButtonTop, nButtonWidth, nButtonHeight: Integer;
  nEIDic: TDictionary<string, TCustomEdit>;
  nPI: PInputBoxItem;
  lBTNOK, lBTNCancel: TButton;
begin
  nItemCount := Length(AItems);
  if nItemCount < 1 then
    raise Exception.Create('元素为空');
  Result := False;
  nForm := TInputQueryForm.CreateNew(Application);
  nEIDic := TDictionary<string, TCustomEdit>.Create;
  try
    with nForm do
    begin
      FCloseQueryFunc :=
        function: Boolean
        var
          nItemIndex: Integer;
          nCE: TCustomEdit;
          nPI: PInputBoxItem;
        begin
          Result := True;
          if not Assigned(ACloseQueryFunc) then
            Exit;
          for nItemIndex := Low(AItems) to High(AItems) do
          begin
            nPI := @AItems[nItemIndex];
            nCE := nEIDic.Items[nPI^.ID];
            Result := ACloseQueryFunc(nPI^.ID, nCE.Text);
            if not Result then
              Exit;
          end;
        end;
      Canvas.Font := Font;
      BorderStyle := bsSizeToolWin;
      Caption := ACaption;
      ClientWidth := 256;
      PopupMode := pmAuto;
      nTop := C_B;
      for nItemIndex := 0 to nItemCount - 1 do
      begin
        nPI := @AItems[nItemIndex];

        if nPI^.MultiLine then
        begin
          lCE := TMemo.Create(nForm);
          with TMemo(lCE) do
          begin
            CharCase := nPI^.CharCase;
            ScrollBars := ssVertical;
          end;
        end
        else
        begin
          lCE := TEdit.Create(nForm);
          with TEdit(lCE) do
          begin
            MaxLength := 255;
            PasswordChar := nPI.PasswordChar;
          end;
        end;

        with lCE do
        begin
          Parent := nForm;
          Left := C_B;
          Top := nTop;
          Width := nForm.ClientWidth - C_B * 2;
          TextHint := nPI^.Prompt;
          Text := nPI^.Value;
        end;
        Inc(nTop, lCE.Height + C_B);
        nEIDic.Add(nPI^.ID, lCE);

        if nItemIndex = 0 then
          lCE.SelectAll;
      end;

      nButtonTop := nTop + C_B;
      nButtonWidth := 50;
      nButtonHeight := 25;
      lBTNOK := TButton.Create(nForm);
      with lBTNOK do
      begin
        Parent := nForm;
        Caption := '确定';
        ModalResult := mrOk;
        Default := True;
        SetBounds(nForm.ClientWidth - (nButtonWidth + C_B) * 2, nButtonTop, nButtonWidth, nButtonHeight);
      end;
      lBTNCancel := TButton.Create(nForm);
      with lBTNCancel do
      begin
        Parent := nForm;
        Caption := '取消';
        ModalResult := mrCancel;
        Cancel := True;
        SetBounds(nForm.ClientWidth - (nButtonWidth + C_B), nButtonTop, nButtonWidth, nButtonHeight);
      end;

      nForm.ClientHeight := nButtonTop + nButtonHeight + 13;
      if nPI^.MultiLine then
        lCE.Anchors := [akLeft, akRight, akTop, akBottom]
      else
        lCE.Anchors := [akLeft, akRight, akTop];
      lBTNOK.Anchors := [akRight, akBottom];
      lBTNCancel.Anchors := [akRight, akBottom];

      if FLastRect.IsEmpty then
      begin
        Position := poScreenCenter;
      end
      else
      begin
        Position := poDesigned;
        BoundsRect := FLastRect;
      end;

      if ShowModal = mrOk then
      begin
        for nItemIndex := 0 to nItemCount - 1 do
        begin
          nPI := @AItems[nItemIndex];
          nPI^.Value := nEIDic.Items[nPI^.ID].Text;
        end;
        Result := True;
      end;

      FLastRect := BoundsRect;
    end;
  finally
    nEIDic.Free;
    nForm.Free;
  end;
end;

{ TInputQueryForm }

function TInputQueryForm.CloseQuery: Boolean;
begin
  Result := (ModalResult = mrCancel) or (not Assigned(FCloseQueryFunc)) or FCloseQueryFunc();
end;

{ TInputBoxItemHelper }

class function TInputBoxItemHelper.Create: TInputBoxItem;
begin
  with Result do
  begin
    ID := TGUID.NewGuid.ToString;
    Prompt := '';
    Value := '';
    MultiLine := False;
    PasswordChar := #0;
    CharCase := ecNormal;
  end;
end;

initialization
  FLastRect := TRect.Empty;

end.
