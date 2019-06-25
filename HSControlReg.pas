unit HSControlReg;

interface

uses
  Classes,
  Vcl.ImgList, DesignIntf, VCLEditors,
  HSMovePanel, HSShadowControls, HSIPEdit, HSImageButton, HSCheckCombobox,
  HSPropertyEditor,
  HS.FMX.Objects;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('HSControls', [THSIPEdit, THSMovePanel, THSShadowLabel,
    THSImageButton, THSCheckComboBox, THSBrushText]);
  RegisterPropertyEditor(TypeInfo(TImageIndex), THSImageButton, 'ImageIndex',
    THSImageIndexPropertyEditor);
end;

end.
