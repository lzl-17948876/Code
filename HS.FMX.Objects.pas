unit HS.FMX.Objects;

interface

uses
  System.Classes,
  FMX.Objects, FMX.Graphics, FMX.TextLayout;

type
  THSBrushText = class(TText)
  private
    FBrush: TBrush;

    procedure SetBrush(const Value: TBrush);
    procedure BrushChanged(Sender: TObject);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Brush: TBrush read FBrush write SetBrush;
  end;

implementation

uses
  System.Math.Vectors;

{ TGradientText }

procedure THSBrushText.BrushChanged(Sender: TObject);
begin
  if FUpdating = 0 then
    Repaint;
end;

constructor THSBrushText.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBrush := TBrush.Create(TBrushKind.Gradient, $FF000000);
  FBrush.OnChanged := BrushChanged;
end;

destructor THSBrushText.Destroy;
begin
  FBrush.Free;
  inherited;
end;

procedure THSBrushText.Paint;
var
  lTextPath: TPathData;
begin
  Canvas.Fill.Assign(FBrush);
  Canvas.Stroke.Kind := TBrushKind.None;
  lTextPath := TPathData.Create;
  try
    Canvas.TextToPath(lTextPath, Self.BoundsRect, Self.Text, Layout.WordWrap, Layout.HorizontalAlign, Layout.VerticalAlign);
    Canvas.FillPath(lTextPath, 1);
    Canvas.DrawPath(lTextPath, 1);
  finally
    lTextPath.Free;
  end;
end;

procedure THSBrushText.SetBrush(const Value: TBrush);
begin
  FBrush.Assign(Value);
end;

end.
