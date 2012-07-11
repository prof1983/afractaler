{**
@Abstract(AFractaler calc)
@Author(Prof1983 prof1983@ya.ru)
@Created(11.07.2012)
@LastMod(11.07.2012)
@Version(0.0)
}
unit FracCalc;

interface

uses
  Controls, Classes, Graphics, ExtCtrls, Forms;

type
  plong = ^Integer;
  pword = ^Word;

  TFractalThread = class(TThread)
  private
    FBit: TBitmap;
    FBuf: TMemoryStream;
    iw: Integer;
    ih: Integer;
    FCount: Integer;
    FMash: Double;
    FAlp: Double;
    X: Double;
    Y: Double;
  protected
    procedure Execute(); override;
    procedure Show();
  public
    constructor Create(Bit: TBitmap; ax, ay, Mash, Alp: Double; C: Integer);
    destructor Destroy(); override;
  end;

implementation

{ TFractalThread }

constructor TFractalThread.Create(bit: TBitmap; ax, ay, Mash, Alp: Double; C: Integer);
begin
  Screen.Cursor := crHourGlass;
  FBuf := TMemoryStream.Create;
  FBuf.Position := 0;
  FBit := Bit;
  FBit.SaveToStream(Fbuf);
  IW := bit.Width;
  IH := bit.Height;
  FMash := Mash/iw;
  FCount := c;
  Falp := alp;
  x := ax;
  y := ay;
  FreeOnTerminate := True;
  //Priority := tpHighest;
  inherited Create(True);
end;

destructor TFractalThread.Destroy();
begin
  fBuf.Position := 0;
  fbuf.Free();
  inherited;
  Screen.Cursor := crDefault;
end;

procedure TFractalThread.Execute();
label
  la,lb;
const
  one: Double = 2;
var
  i: Integer;
  j: Integer;
  Pos: Integer;
  cnt: Integer;
  FAlpC: Double;
  FAlpS: Double;
  Fx: Double;
  Fy: Double;
  xj: Double;
  yj: Double;
  r: Double;
begin
  pLong(Integer(Fbuf.Memory)+$2e)^ := 0;
  pos := Integer(Fbuf.Memory)+pLong(integer(Fbuf.Memory)+10)^-2;
  FAlpS := FAlp/180*Pi;
  FAlpC := FMash*Cos(FAlpS);
  FAlpS := FMash*sin(FAlpS);
  Fx := x-( iw*FAlpC+ih*FAlpS)/2;
  Fy := y-(-iw*FAlpS+ih*FAlpC)/2;
  cnt := fCount;
  for j := 0 to IH-1 do
  begin
    xj := Fx+j*FAlpS;
    yj := Fy+j*FAlpC;
    for i := 0 to IW-1 do
    asm
      mov ecx,dword ptr cnt
      Add dword ptr pos,2 {   pos:=pos+3;}
      fld qword ptr xj
      fadd qword ptr FAlpC {   Xj:=Xj+FAlpC;}
      fld qword ptr yj
      fsub qword ptr FAlpS {   Yj:=Yj-FAlpS;}
      fld st(1)
      fld st(1)              {re, im, r, i}
    la:
      fld st(1)
      fmul st(2),st(0)      {re, im, r*r, i, r}
      fld st(1)
      fmul st(0),st(2)      {re, im, r*r, i, r, i*i}
      fld st(3)
      fadd st(0),st(1)      {re, im, r*r, i, r, i*i,r*r+i*i}
      fstp qword ptr r
      cmp word ptr r+6,$4010    {re, im, r*r, i, r, i*i}
      fsub st(0),st(5)      {re, im, r*r, i, r,i*i-re}
      fsubp st(3),st        {re, im, r*r-i*i+re, i, r}
      fadd st(0),st(0)      {re, im, r*r-i*i+re, i, 2*r}
      fmulp st(1),st        {re, im, r*r-i*i+re, 2*r*i}
      fadd st(0),st(2)      {re, im, r*r-i*i+re, 2*r*i+im}
      jnl lb
      loop la
    lb:
      fstp qword ptr r
      fstp qword ptr r
      fstp qword ptr yj
      fstp qword ptr xj
      mov edx,[pos]
      mov [edx],cx
    end;
    if j and 10 = 0 then
      Self.Synchronize(Show);
    if Terminated then Exit;
  end;
  Self.Synchronize(Show);
end;

procedure TFractalThread.Show();
begin
  fBuf.Position := 0;
  fBit.LoadFromStream(fbuf);
  fBit.Canvas.Refresh();
end;

end.
