{**
@Abstract(AFractaler main form)
@Author(Prof1983 prof1983@ya.ru)
@Created(11.07.2012)
@LastMod(11.07.2012)
@Version(0.0)
}
unit AFractalerMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtDlgs, Mask, ExtCtrls,
  Buttons, Vcl.Samples.Spin,
  FracCalc, UnitFr;

type
  TAFractalerMainForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ImageFr: TImage;
    RunButton: TButton;
    SavePictureDialog1: TSavePictureDialog;
    SaveButton: TButton;
    ExitButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    FrameColor: TFrameColor;
    MashEdit: TSpinEdit;
    AlpEdit: TSpinEdit;
    XEdit: TSpinEdit;
    YEdit: TSpinEdit;
    CEdit: TSpinEdit;
    WEdit: TSpinEdit;
    HEdit: TSpinEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Bevel1: TBevel;
    procedure SaveButtonClick(Sender: TObject);
    procedure ImageFrMouseDown(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
    procedure ImageFrMouseUp(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
    procedure RunButtonClick(Sender: TObject);
  private
    MPX: Integer;
    MPY: Integer;
    FrTr: TFractalThread;
    bmp: TBitmap;
  private
    function GetEditAlpValue(): Double;
    function GetEditCValue(): Integer;
    function GetEditHValue(): Integer;
    function GetEditMashValue(): Double;
    function GetEditWValue(): Integer;
    function GetEditXValue(): Double;
    function GetEditYValue(): Double;
  public
    procedure OnTerm(Sender: TObject);
    procedure ChangePal(Sender: TObject);
  end;

implementation

{$R *.dfm}

{ TAFractalerMainForm }

procedure TAFractalerMainForm.ChangePal(Sender: TObject);
var
  arr: array[0..$ffff] of Integer;
  ii: Integer;
  pos: Integer;
  ih: Integer;
  iw: Integer;
  n: Integer;
  i: Integer;
  j: Integer;
  l: Integer;
  x: Double;
  FBuf: TMemoryStream;
begin
  FBuf := TMemoryStream.Create;
  Bmp.SaveToStream(Fbuf);
  IW := Bmp.Width;
  IH := Bmp.Height;
  pos := Integer(Fbuf.Memory) + pLong(Integer(Fbuf.Memory)+10)^;
  {сбор статистики}
  for i := 0 to $ffff do arr[i]:=0;
  begin
    for j := 0 to IH-1 do
    begin
      for i := 0 to IW-1 do
      begin
        arr[pword(pos)^]:=arr[pword(pos)^]+1;
        pos := pos+2;
      end;
    end;
  end;
  {объединение редких цветов}
  arr[0] := 0;
  j := 0;
  l := 1;
  ii := 1+round(sqrt(ih)*ih/5);
  for i := 1 to $ffff do
  begin
    j := j+arr[i];
    arr[i] := l;
    if (j > ii) then
    begin
      j := 0;
      inc(l);
    end;
  end;
  pos := Integer(Fbuf.Memory) + pLong(Integer(Fbuf.Memory)+10)^;
  with FrameColor do
  for j := 0 to IH-1 do
  for i := 0 to IW-1 do
  begin
    x := arr[pword(pos)^]/l;
    n := 1;
    while (x > col[n].Pos) do
      Inc(n);
    x := (x-col[n-1].pos)/(col[n].pos-col[n-1].pos);
    pword(pos)^ := Round(x*(col[n].col and$ff)+(1-x)*(col[n-1].col and$ff))div 8 shl 11+
        Round(x*(col[n].col shr 8 and$ff)+(1-x)*(col[n-1].col shr 8 and$ff))div 4 shl 5+
        Round(x*(col[n].col shr 16)+(1-x)*(col[n-1].col shr 16))div 8;
    pos := pos+2;
  end;
  {----------------------}
  fBuf.Position := 0;
  ImageFr.Picture.Bitmap.LoadFromStream(fbuf);
  ImageFr.Picture.Bitmap.Canvas.Refresh;
end;

procedure TAFractalerMainForm.ExitButtonClick(Sender: TObject);
begin
  Close();
end;

procedure TAFractalerMainForm.FormCreate(Sender: TObject);
begin
  FrTr := nil;
  ImageFr.Picture.Bitmap.PixelFormat := pf16bit;
  bmp := TBitmap.Create;
  FrameColor.OnChange := ChangePal;
end;

procedure TAFractalerMainForm.FormDestroy(Sender: TObject);
begin
  bmp.Free();
end;

function TAFractalerMainForm.GetEditAlpValue(): Double;
begin
  Result := AlpEdit.Value;
end;

function TAFractalerMainForm.GetEditCValue(): Integer;
begin
  Result := CEdit.Value;
end;

function TAFractalerMainForm.GetEditHValue(): Integer;
begin
  Result := HEdit.Value;
end;

function TAFractalerMainForm.GetEditMashValue(): Double;
begin
  Result := MashEdit.Value / 100;
end;

function TAFractalerMainForm.GetEditWValue(): Integer;
begin
  Result := WEdit.Value;
end;

function TAFractalerMainForm.GetEditXValue(): Double;
begin
  Result := XEdit.Value / 100;
end;

function TAFractalerMainForm.GetEditYValue(): Double;
begin
  Result := YEdit.Value / 100;
end;

procedure TAFractalerMainForm.ImageFrMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbRight) then
  begin
    MPX := x;
    MPY := y;
  end;
end;

procedure TAFractalerMainForm.ImageFrMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  m: Double;
  r1: Double;
  r2: Double;
  AlpS: Double;
  AlpC: Double;
  XValue: Double;
  YValue: Double;
  MashValue: Double;
begin
  if (Button = mbRight) then
  begin
    r1 := (Mpx+x-ImageFr.Width)/ImageFr.Width;
    r2 := (ImageFr.Height-Mpy-y)/ImageFr.Height*ImageFr.Picture.Bitmap.Height/ImageFr.Picture.Bitmap.Width;
    AlpS := GetEditAlpValue()/180*Pi;
    m := GetEditMashValue()/2;
    AlpC := Cos(AlpS);
    AlpS := Sin(AlpS);
    XValue := GetEditXValue() + (r1*AlpC+r2*AlpS)*M;
    YValue := GetEditYValue() - (r1*AlpS-r2*AlpC)*M;
    r1 := Abs(Mpx-x)/ImageFr.Width;
    r2 := Abs(Mpy-y)/ImageFr.Height;
    if (r1 < r2) then
      r1 := r2;
    MashValue := 2*m*r1;
    if (MashValue = 0) then
      MashValue := 1e-12;

    MashEdit.Value := Round(MashValue*1000);
    XEdit.Value := Round(XValue);
    YEdit.Value := Round(YValue);
  end;
end;

procedure TAFractalerMainForm.OnTerm(Sender: TObject);
begin
  bmp.Assign(ImageFr.Picture.Bitmap);
  ChangePal(Self);
end;

procedure TAFractalerMainForm.RunButtonClick(Sender: TObject);
begin
  if (FrTr <> nil) then
  begin
    FrTr.Terminate();
    FrTr := nil;
  end;
  ImageFr.Picture.Bitmap.Width := GetEditWValue();
  ImageFr.Picture.Bitmap.Height := GetEditHValue();
  FrTr := TFractalThread.Create(ImageFr.Picture.Bitmap, GetEditXValue(), GetEditYValue(),
    GetEditMashValue(), GetEditAlpValue(), GetEditCValue());
  FrTr.OnTerminate := OnTerm;
  FrTr.Resume();
end;

procedure TAFractalerMainForm.SaveButtonClick(Sender: TObject);
begin
  if SavePictureDialog1.Execute then
   ImageFr.Picture.Bitmap.SaveToFile(SavePictureDialog1.FileName);
end;

end.
