unit HSPropertyEditor;

interface

uses
  System.Classes, System.Types, System.SysUtils,
  Vcl.ImgList, Vcl.Graphics,
  DesignIntf, DesignEditors, VCLEditors,
  HSImageButton;

type
  THSImageIndexPropertyEditor = class(TIntegerProperty, ICustomPropertyListDrawing)
  private
    function GetImageListAt(AIndex: Integer): TCustomImageList;
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    { ICustomPropertyListDrawing }
    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas;
      var AHeight: Integer);
    procedure ListMeasureWidth(const Value: string;
      ACanvas: TCanvas; var AWidth: Integer);
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean);
  end;

implementation

uses
  Vcl.dialogs;

{ THSImageIndexPropertyEditor }

function THSImageIndexPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paRevertable];
end;

function THSImageIndexPropertyEditor.GetImageListAt(
  AIndex: Integer): TCustomImageList;
var
  nC: TPersistent;
begin
  Result := nil;
  nC := GetComponent(AIndex);
  if nC is THSImageButton then
    Result := THSImageButton(nC).Images;
end;

procedure THSImageIndexPropertyEditor.GetValues(Proc: TGetStrProc);
var
  nImgList: TCustomImageList;
  I: Integer;
begin
  nImgList := GetImageListAt(0);
  if nImgList <> nil then
    for I := 0 to nImgList.Count - 1 do
      Proc(IntToStr(I));
end;

procedure THSImageIndexPropertyEditor.ListDrawValue(const Value: string;
  ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  nImgList: TCustomImageList;
  nLeft: Integer;
begin
  nImgList := GetImageListAt(0);
  ACanvas.FillRect(ARect);
  nLeft := ARect.Left + 2;
  if nImgList <> nil then
  begin
    nImgList.Draw(ACanvas, nLeft, ARect.Top + 2, StrToInt(Value));
    Inc(nLeft, nImgList.Width);
  end;
  ACanvas.TextOut(nLeft + 3, ARect.Top + 1, Value);
end;

procedure THSImageIndexPropertyEditor.ListMeasureHeight(const Value: string;
  ACanvas: TCanvas; var AHeight: Integer);
var
  nImgList: TCustomImageList;
begin
  nImgList := GetImageListAt(0);
  AHeight := ACanvas.TextHeight(Value) + 2;
  if (nImgList <> nil) and (nImgList.Height + 4 > AHeight) then
    AHeight := nImgList.Height + 4;
end;

procedure THSImageIndexPropertyEditor.ListMeasureWidth(const Value: string;
  ACanvas: TCanvas; var AWidth: Integer);
var
  nImgList: TCustomImageList;
begin
  nImgList := GetImageListAt(0);
  AWidth := ACanvas.TextWidth(Value) + 4;
  if nImgList <> nil then
    Inc(AWidth, nImgList. Width);
end;

end.
