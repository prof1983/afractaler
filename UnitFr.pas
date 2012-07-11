{**
@Abstract(AFractaler unit)
@Author(Prof1983 prof1983@ya.ru)
@Created(11.07.2012)
@LastMod(11.07.2012)
@Version(0.0)
}
unit UnitFr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  tcol = record
   pos: Double;
   col: TColor;
   pan: TPanel;
  end;

  TFrameColor = class(TFrame)
    PaintBox1: TPaintBox;
    Panel0: TPanel;
    Panel2: TPanel;
    Image1: TImage;
    Panel1: TPanel;
    ColorDialog: TColorDialog;
    procedure PaintBox1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure PaintBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Image1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FrameResize(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FOnChange: TNotifyEvent;
  protected
      procedure Change(); dynamic;
  public
    nn: Integer;
    col: array[0..100] of TCol;
    colcount: Integer;
    constructor Create(AOwner: TComponent); override;
    procedure CreatePanel(x: Double; c: TColor);
    procedure DeletePanel(n: Integer);
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

{$R *.DFM}

{ TFrameColor }

constructor TFrameColor.Create(AOwner: TComponent);
begin
  inherited;
  colcount := 1;
  nn := 1;
  col[0].pan := Panel0;
  col[0].pos := 0;
  col[0].col := 0;
  col[1].pan := Panel1;
  col[1].pos := 1;
  col[1].col := $ffffff;
  PaintBox1.Height := 32;
end;

procedure TFrameColor.Change();
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TFrameColor.PaintBox1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TPanel;
end;

procedure TFrameColor.PaintBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  i: Integer;
  n: Integer;
  tmp: TCol;
begin
  if(Source is TPanel) then
  begin
    n := (Source as TPanel).Tag;
    tmp := col[n];
    tmp.pos := (x)/PaintBox1.Width;
    (Source as TPanel).Left := Round(tmp.pos*PaintBox1.Width);
    if (col[n].pos < tmp.pos) then
    begin
      i := n+1;
      while (col[i].pos < tmp.pos) do
      begin
        col[i-1] := col[i];
        col[i-1].pan.Tag := i-1;
        i := i+1;
      end;
      col[i-1] := tmp;
      col[i-1].pan.Tag := i-1;
    end
    else
    begin
      i := n-1;
      while (col[i].pos > tmp.pos) do
      begin
        col[i+1] := col[i];
        col[i+1].pan.Tag := i+1;
        i := i-1;
      end;
      col[i+1] := tmp;
      col[i+1].pan.Tag := i+1;
    end;
    PaintBox1Paint(Self);
    Change;
  end;
end;

procedure TFrameColor.Image1DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  i: Integer;
  n: Integer;
  tmp: TCol;
begin
  if (Source is TPanel) then
  begin
    while (Panel2.ControlCount > 1) do
      Panel2.Controls[1].Free();
    (Source as TPanel).Parent := Panel2;
    (Source as TPanel).Hide();
    n := (Source as TPanel).Tag;
    tmp := col[n];
    Dec(colcount);
    for i := n to ColCount do
    begin
      col[i] := col[i+1];
      col[i].pan.Tag := i;
    end;
    PaintBox1Paint(Self);
    Change();
  end;
end;

procedure TFrameColor.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := PaintBox1.Canvas.Pixels[x,y];
  if (mbRight = Button) and (ColorDialog.Execute) then
  begin
    CreatePanel(x/PaintBox1.Width, ColorDialog.Color);
    PaintBox1Paint(Self);
    Change();
  end;
end;

procedure TFrameColor.CreatePanel(x:double;c:tcolor);
var
  i: Integer;
  tmp: TCol;
begin
  Inc(Colcount);
  i := Colcount;
  while (col[i-1].pos > x) do
  begin
    col[i] := col[i-1];
    col[i].pan.Tag := i;
    i := i-1;
  end;
  col[i].pos := x;
  col[i].col := c;
  col[i].pan := tPanel.Create(Self);
  with col[i].pan do
  begin
    Top := 0;
    width := 6;
    height := PaintBox1.Height;
    Left := Round(x*PaintBox1.Width)-3;
    Parent := Self;
    Name := 'Pan'+IntToStr(nn);
    Inc(nn);
    Caption := '';
    DragMode := dmAutomatic;
    DragCursor := crHSplit;
    Cursor := crHandPoint;
    color := c;
    tag := i;
    OnMouseUp := PanelMouseUp;
  end;
end;

procedure TFrameColor.DeletePanel(n: Integer);
var
  i: Integer;
  tmp: TCol;
begin
  if (n < 1) or (n >= ColCount) then Exit;
  col[n].pan.Free();
  Dec(colcount);
  for i := n to colcount do
  begin
    col[i] := col[i+1];
    col[i].pan.Tag := i;
  end;
  PaintBox1Paint(Self);
  Change();
end;

procedure TFrameColor.PanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not(Sender is tPanel) then Exit;
  ColorDialog.Color := (Sender as tPanel).Color;
  if (mbRight = Button) and (ColorDialog.Execute) then
  begin
    (Sender as tPanel).Color := ColorDialog.Color;
    col[(Sender as tPanel).Tag].col := ColorDialog.Color;
    PaintBox1Paint(Self);
    Change();
  end;
end;

procedure TFrameColor.FrameResize(Sender: TObject);
var
  i: Integer;
begin
  PaintBox1.Width := Width-38;
  Panel2.Left := Width-32;
  for i := 1 to colCount do
    col[i].pan.Left := Round(col[i].pos*PaintBox1.Width);
end;

procedure TFrameColor.PaintBox1Paint(Sender: TObject);
var
  i: Integer;
  n: Integer;
  x: Double;
begin
  n := 1;
  with PaintBox1.Canvas do
  begin
    for i := 1 to PaintBox1.Width do
    begin
      MoveTo(i,0);
      if (i > col[n].Pos*PaintBox1.Width) then
        Inc(n);
      x := (i/PaintBox1.Width-col[n-1].pos)/(col[n].pos-col[n-1].pos);
      Pen.Color := Round(x*(col[n].col and$ff)+(1-x)*(col[n-1].col and$ff))+
          Round(x*(col[n].col shr 8 and$ff)+(1-x)*(col[n-1].col shr 8 and$ff))shl 8+
          Round(x*(col[n].col shr 16)+(1-x)*(col[n-1].col shr 16))shl 16;
      LineTo(i,32);
    end;
  end;
end;

end.
