program project1;

{$mode objfpc}{$H+}
{$ModeSwitch nestedprocvars}

uses
  {$IFDEF UNIX}
  cthreads,

  {$ENDIF}
  Classes, MTProcs, etpackage
  { you can add units after this },

  sysutils, StrUtils, EpikTimer;


type
  TGrid = array of array of UInt8;
  TPuzzleData = record
    Grid: TGrid;
    Input: TStringList;
  end;

var
  P1: Int64;


function Has4Neighbours(var Grid: TGrid; X, Y: Int64): boolean;
var
  i, j, n: Int64;
  x_from, x_to, y_from, y_to: Int64;
begin

  Grid[Y][X]:= 2;

  x_from:= X - 1;
  x_to:= X + 1;
  y_from:= Y - 1;
  y_to:= Y + 1;

  if x_from < 0 then x_from:= 0;
  if y_from < 0 then y_from:= 0;

  if x_to > Length(Grid[y]) - 1 then x_to:= Length(Grid[Y]) - 1;
  if y_to > Length(Grid) - 1 then y_to:= Length(Grid) - 1;

  n:= 0;
  for j:= y_from to y_to do begin
    for i:= x_from to x_to do begin
      if (i=x) and (j=y) then continue;
      if Grid[j][i] > 0 then begin
        n:= n + 1;
      end;
      if n >= 4 then begin
        Result:= true;
        Grid[Y][X]:= 1;
        exit;
      end;
    end;
  end;
  Result:= false;
end;

procedure Neighbours(Index: Int64;var Data: TPuzzleData);
var
  i: Int64;
begin
  for i:= 0 to length(Data.Grid[Index]) - 1 do begin
    if Data.Grid[Index][i] > 0 then if not Has4Neighbours(Data.Grid, i, Index) then P1:= P1 + 1;
  end;
end;

procedure LineToGrid(Index: Int64; var Data: TPuzzleData);
var
  i: int64;
begin
  for i:= 0 to Length(Data.Grid[Index]) - 1 do begin
    if Data.Input[index][i+1] = '@' then Data.Grid[Index][i]:= 1 else Data.Grid[Index][i]:= 0;
  end;
end;

procedure FillGrid(var Data: TPuzzleData);
var
  i: Int64;
begin
  for i:= 0 to Data.Input.Count - 1 do LineToGrid(i, Data);
end;

function ReadInput(exampleData: boolean): TPuzzleData;
var
  i: Int64;
begin
  Result.Input:= TStringList.Create;
  if exampleData then Result.Input.LoadFromFile('./example') else Result.Input.LoadFromFile('./input');
  SetLength(Result.Grid, Result.Input.Count);
  for i:= 0 to Result.Input.Count -1 do SetLength(Result.Grid[i], Result.Input[i].Length);
  FillGrid(Result);
end;


function SolveP1(var Puzzle: TPuzzleData): Int64;
var
  i: int64;
begin
  P1:= 0;
  for i:= 0 to Puzzle.Input.Count - 1 do begin
    Neighbours(i, Puzzle);
  end;
  Result:= P1;
end;

function RemoveRolls(var Puzzle: TPuzzleData): Int64;
var
  y, x: Int64;
begin
  Result:= 0;
  for y:= 0 to length(Puzzle.Grid) - 1 do begin
    for x:= 0 to length(Puzzle.Grid[y]) - 1 do begin
      if Puzzle.Grid[y][x] = 2 then begin
        Result:= Result + 1;
        Puzzle.Grid[y][x]:= 0;
      end;
    end;
  end;
end;

function SolveP2(var Puzzle: TPuzzleData): Int64;
var
  i, j, RemovedRolls: Int64;
begin
  P1:= 0;
  Result:= 0;
  RemovedRolls:= -1;

  for j:= 0 to length(Puzzle.Grid) -1 do begin
    for i:= 0 to Length(Puzzle.Grid[j]) -1 do begin
      if Puzzle.Grid[j][i] >= 2 then Puzzle.Grid[j][i]:= 1;
    end;
  end;

  while RemovedRolls <> 0 do begin
    for i:= 0 to Puzzle.Input.Count - 1 do begin
      Neighbours(i, Puzzle);
    end;
    RemovedRolls:= RemoveRolls(Puzzle);
    Result:= Result + RemovedRolls;
  end;

end;

var
  PuzzleData: TPuzzleData;
  i: Int64;
  prof: TEpikTimer;
  e_load, e1, e2, e_ges: Extended;
  Res1, Res2: Int64;

begin
  prof:= TEpikTimer.Create(nil);
  prof.Clear;
  prof.Start;

  PuzzleData:= ReadInput(false);
  e_load:= prof.Elapsed;

  Res1:= SolveP1(PuzzleData);
  e1:= prof.Elapsed;

  Res2:= SolveP2(PuzzleData);
  e2:= prof.Elapsed;

  WriteLn('Part1: ' + Res1.ToString);
  WriteLn('Part2: ' + Res2.ToString);

  prof.Stop;
  e_ges:= prof.Elapsed;

  WriteLn('Dauer Load: ' + FloatToStr(e_load * 1000));
  WriteLn('Dauer Part1: ' + FloatToStr((e1 - e_load) * 1000));
  WriteLn('Dauer Part2: ' + FloatToStr((e2 - e1) * 1000));
  WriteLn('Dauer Total: ' + FloatToStr(e_ges * 1000));

  FreeAndNil(PuzzleData.Input);
  FreeAndNil(prof);


end.

