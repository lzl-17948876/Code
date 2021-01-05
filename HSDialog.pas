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
    MaxLength: Integer;
    PasswordChar: Char;
    CharCase: TEditCharCase;
  end;
  TInputBoxItemHelper = record helper for TInputBoxItem
    procedure Init(AID, APrompt, AValue: string);
  end;
  TInputCloseQueryFunc = reference to function (const ID, Value: string): Boolean;

function InputBox(const ACaption: string; AItems: TArray<TInputBoxItem>;
  ACloseQueryFunc: TInputCloseQueryFunc): Boolean; overload;
function InputBox(const ACaption: string; var AItem: TInputBoxItem): Boolean; overload;

function SelectBox(const ACaption: string; const AItems: TArray<string>): Integer;

implementation

uses
  System.UITypes, System.Generics.Collections, System.Types,
  Vcl.Forms, Vcl.Controls;

var
  FLastPoint: TPoint;

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
  lItemIndex: Integer;
  lForm: TInputQueryForm;
  lCE: TCustomEdit;
  lItemCount: Integer;
  lTop, lButtonTop, lButtonWidth, lButtonHeight: Integer;
  lEDTList: TArray<TCustomEdit>;
  lPI: PInputBoxItem;
  lBTNOK, lBTNCancel: TButton;
begin
  lItemCount := Length(AItems);
  if lItemCount < 1 then
    raise Exception.Create('元素为空');
  Result := False;
  lForm := TInputQueryForm.CreateNew(Application);
  try
    SetLength(lEDTList, lItemCount);
    with lForm do
    begin
      FCloseQueryFunc :=
        function: Boolean
        var
          lItemIndex: Integer;
          nCE: TCustomEdit;
          lPI: PInputBoxItem;
        begin
          Result := True;
          if not Assigned(ACloseQueryFunc) then
            Exit;
          for lItemIndex := Low(AItems) to High(AItems) do
          begin
            lPI := @AItems[lItemIndex];
            nCE := lEDTList[lItemIndex];
            Result := ACloseQueryFunc(lPI^.ID, nCE.Text);
            if not Result then
              Exit;
          end;
        end;
      Canvas.Font := Font;
      if TOSVersion.Major < 10 then
        BorderStyle := bsSizeToolWin
      else
        BorderIcons := [biSystemMenu];
      Caption := ACaption;
      ClientWidth := 256;
      PopupMode := pmAuto;
      lTop := C_B;
      for lItemIndex := 0 to lItemCount - 1 do
      begin
        lPI := @AItems[lItemIndex];

        if lPI^.MultiLine then
        begin
          lCE := TMemo.Create(lForm);
          with TMemo(lCE) do
          begin
            MaxLength := lPI^.MaxLength;
            CharCase := lPI^.CharCase;
            ScrollBars := ssVertical;
          end;
        end
        else
        begin
          lCE := TEdit.Create(lForm);
          with TEdit(lCE) do
          begin
            MaxLength := lPI^.MaxLength;
            PasswordChar := lPI.PasswordChar;
          end;
        end;

        with lCE do
        begin
          Parent := lForm;
          Left := C_B;
          Top := lTop;
          Width := lForm.ClientWidth - C_B * 2;
          TextHint := lPI^.Prompt;
          Text := lPI^.Value;
        end;
        Inc(lTop, lCE.Height + C_B);
        lEDTList[lItemIndex] := lCE;

        if lItemIndex = 0 then
          lCE.SelectAll;
      end;

      lButtonTop := lTop + C_B;
      lButtonWidth := 50;
      lButtonHeight := 25;
      lBTNOK := TButton.Create(lForm);
      with lBTNOK do
      begin
        Parent := lForm;
        Caption := '确定';
        ModalResult := mrOk;
        Default := True;
        SetBounds(lForm.ClientWidth - (lButtonWidth + C_B) * 2, lButtonTop, lButtonWidth, lButtonHeight);
      end;
      lBTNCancel := TButton.Create(lForm);
      with lBTNCancel do
      begin
        Parent := lForm;
        Caption := '取消';
        ModalResult := mrCancel;
        Cancel := True;
        SetBounds(lForm.ClientWidth - (lButtonWidth + C_B), lButtonTop, lButtonWidth, lButtonHeight);
      end;

      lForm.ClientHeight := lButtonTop + lButtonHeight + 13;
      for lItemIndex := 0 to lItemCount - 1 do
      begin
        lPI := @AItems[lItemIndex];
        if lPI^.MultiLine then
          lEDTList[lItemIndex].Anchors := [akLeft, akRight, akTop, akBottom]
        else
          lEDTList[lItemIndex].Anchors := [akLeft, akRight, akTop];
      end;
      lBTNOK.Anchors := [akRight, akBottom];
      lBTNCancel.Anchors := [akRight, akBottom];

      if FLastPoint.IsZero then
      begin
        Position := poScreenCenter;
      end
      else
      begin
        Position := poDesigned;
        SetBounds(FLastPoint.X, FLastPoint.Y, Width, Height);
      end;

      if ShowModal = mrOk then
      begin
        for lItemIndex := 0 to lItemCount - 1 do
        begin
          lPI := @AItems[lItemIndex];
          lPI^.Value := lEDTList[lItemIndex].Text;
        end;
        Result := True;
      end;

      FLastPoint := Point(Left, Top);
    end;
  finally
    lForm.Free;
  end;
end;

function SelectBox(const ACaption: string; const AItems: TArray<string>): Integer;
const
  C_B = 8;
var
  lItemIndex: Integer;
  lForm: TForm;
  lRBList: TArray<TRadioButton>;
  lItemCount: Integer;
  lTop, lButtonTop, lButtonWidth, lButtonHeight: Integer;
  lBTNOK, lBTNCancel: TButton;
begin
  Result := -1;
  lItemCount := Length(AItems);
  if lItemCount < 1 then
    Exit;
  if lItemCount = 1 then
    Exit(0);

  lForm := TForm.CreateNew(Application);
  try
    with lForm do
    begin
      Canvas.Font := Font;
      BorderStyle := bsSizeToolWin;
      Caption := ACaption;
      ClientWidth := 128;
      PopupMode := pmAuto;

      lTop := C_B;
      SetLength(lRBList, Length(AItems));
      for lItemIndex := 0 to lItemCount - 1 do
      begin
        lRBList[lItemIndex] := TRadioButton.Create(lForm);
        with lRBList[lItemIndex] do
        begin
          Caption := AItems[lItemIndex];
          Tag := lItemIndex;
          Parent := lForm;
          Left := C_B;
          Top := lTop;
          Width := lForm.ClientWidth - C_B * 2;
          Inc(lTop, Height + C_B);
        end;
      end;

      lRBList[0].Checked := True;
      lButtonTop := lTop + C_B;
      lButtonWidth := 50;
      lButtonHeight := 25;
      lBTNOK := TButton.Create(lForm);
      with lBTNOK do
      begin
        Parent := lForm;
        Caption := '确定';
        ModalResult := mrOk;
        Default := True;
        SetBounds(lForm.ClientWidth - (lButtonWidth + C_B) * 2, lButtonTop, lButtonWidth, lButtonHeight);
      end;
      lBTNCancel := TButton.Create(lForm);
      with lBTNCancel do
      begin
        Parent := lForm;
        Caption := '取消';
        ModalResult := mrCancel;
        Cancel := True;
        SetBounds(lForm.ClientWidth - (lButtonWidth + C_B), lButtonTop, lButtonWidth, lButtonHeight);
      end;

      lForm.ClientHeight := lButtonTop + lButtonHeight + 13;
      lBTNOK.Anchors := [akRight, akBottom];
      lBTNCancel.Anchors := [akRight, akBottom];

      if FLastPoint.IsZero then
      begin
        Position := poScreenCenter;
      end
      else
      begin
        Position := poDesigned;
        SetBounds(FLastPoint.X, FLastPoint.Y, Width, Height);
      end;

      if ShowModal = mrOk then
      begin
        Result := -1;
        for lItemIndex := Low(lRBList) to High(lRBList) do
        begin
          if not lRBList[lItemIndex].Checked then
            Continue;
          Result := lItemIndex;
          Break;
        end;
      end;
      FLastPoint := Point(Left, Top);
    end;
  finally
    lForm.Free;
  end;
end;

{ TInputQueryForm }

function TInputQueryForm.CloseQuery: Boolean;
begin
  Result := (ModalResult = mrCancel) or (not Assigned(FCloseQueryFunc)) or FCloseQueryFunc();
end;

{ TInputBoxItemHelper }

procedure TInputBoxItemHelper.Init(AID, APrompt, AValue: string);
begin
  ID := AID;
  Prompt := APrompt;
  Value := AValue;
  MultiLine := False;
  MaxLength := 0;
  PasswordChar := #0;
  CharCase := ecNormal;
end;

initialization
  FLastPoint := TPoint.Zero;

end.
