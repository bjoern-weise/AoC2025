program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads, EpikTimer, StrUtils, sysutils,
  {$ENDIF}
  Classes, etpackage
  { you can add units after this };


type
  TData = record
    c: char;
    v: Int64;
  end;

  //TDataGrid = array of array of string;
  TDataGrid = array of array of TData;

function ReadData(var Data: TDataGrid; example: boolean = false): TDataGrid;
var
  sl: TStringList;
  sa: array of TStringArray;
  i, j, k: Int64;
  s: string;
begin
  sl:= TStringList.Create;
  if example then sl.LoadFromFile('./example') else sl.LoadFromFile('./input');
  SetLength(Data, sl.Count);
  SetLength(Result, sl.Count);
  k:= Length(sl[0]);
  for i:= Low(Data) to High(Data) do begin
    SetLength(Data[i], k);
    for j:= 1 to length(data[i]) do begin
      data[i][j-1].c:= sl[i][j];
    end;
    Result[i]:= copy(data[i]);
  end;
end;

function SolveP1(var Data: TDataGrid): Int64;
var
  i, j, t: Int64;
begin
  Result:= 0;


  for i:= Low(Data) + 1 to High(Data) do begin
    for j:= Low(Data[i]) to High(Data[i]) do begin
      case Data[i-1][j].c of
      'S': if data[i][j].c = '.' then data[i][j].c:= '|';
      '|': if data[i][j].c = '.' then data[i][j].c:= '|';
      '^': if data[i][j].c = '.' then data[i][j].c:= '.';
      end;
      if (Data[i][j].c = '^') and (Data[i-1][j].c = '|' )then begin
        if j > 0 then Data[i][j-1].c:= '|';
        if j < High(Data[i]) then Data[i][j+1].c:= '|';
        Result:= Result + 1;
      end;
    end;
  end;

end;

function GoDeeper(var Data: TDataGrid; StartX, StartY: Int64): Int64; inline;
begin
  Result:= 0;
  if StartY = Length(Data) - 1 then begin
     Result:= 1;
     exit;
  end;
  if Data[StartY][StartX].c <> '^' then begin
    if Data[StartY][StartX].c= '.' then begin
      if Data[StartY][StartX].v = 0 then Data[StartY][StartX].v:= (Result + GoDeeper(Data, StartX, StartY + 1));
      Result:= Result + (Data[StartY][StartX].v);//.ToInt64;
    end;
  end else begin
    if (StartX) >= 1 then Result:= Result + GoDeeper(Data, StartX - 1, StartY + 1);
    if (StartX) < Length(Data[StartY]) then Result:= Result + GoDeeper(Data, StartX + 1, StartY + 1);
  end;
end;

function SolveP2(var Data: TDataGrid): Int64;
var
  i, j, k, t: Int64;
  val: array of Int64;
  calc: boolean;
begin
  for i:= 0 to Length(Data[0]) - 1 do begin
    if Data[0][i].c = 'S' then Begin
      Result:= GoDeeper(Data, i, 1);
      exit;
    end;
  end;
end;

var
  prof: TEpikTimer;
  er, e1, e2: Extended;

  data, data2: TDataGrid;

  p1, p2: Int64;
  sl: TStringList;

begin

  prof:= TEpikTimer.Create(nil);
  prof.Clear;
  prof.Start;

  data2:= ReadData(data, false);
  //data2:= copy(data);

  er:= prof.Elapsed;

  p1:= SolveP1(data);
  e1:= prof.Elapsed;

  p2:= SolveP2(data2);
  e2:= prof.Elapsed;
  prof.Stop;

  WriteLn('P1: ' + p1.ToString);
  WriteLn('P2: ' + p2.ToString);

  WriteLn('Part Read: ' + FloatToStr(er * 1000));
  WriteLn('Part 1: ' + FloatToStr((e1 - er) * 1000));
  WriteLn('Part 2: ' + FloatToStr((e2 - e1) * 1000));

  FreeAndNil(prof);

  SetLength(data, 0);
  SetLength(data2, 0);


end.

