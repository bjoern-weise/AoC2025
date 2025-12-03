program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  { you can add units after this }
  sysutils, EpikTimer, StrUtils;


function ReadInput(ExampleData: boolean = false): TStringList;
begin
  Result:= TStringList.Create;
  if ExampleData then Result.LoadFromFile('./example') else Result.LoadFromFile('./input');
end;

function SolveP1(Data: TStringList): int64;
var
  s: string;
  i, value, max1_v, max2_v, max1_p: int64;
begin
  Result:= 0;

  for s in Data do begin
    max1_v:= 0;
    max2_v:= 0;
    max1_p:= 0;
    for i:= 1 to Length(s) - 1 do begin
      value:= StrToInt64(s[i]);
      if value > max1_v then begin
          max1_v:= value;
          max1_p:= i;
      end;
    end;

    for i:= max1_p + 1 to length(s) do begin
      value:= StrToInt64(s[i]);
      if value > max2_v then begin
          max2_v:= value;
      end;
    end;
    Result:= Result + (max1_v * 10 + max2_v);
  end;
end;


function SolveP2(Data: TStringList): Int64;
var
  s: string;
  i, j, value, BattsLeft, Start, multi: Int64;
  max_v, max_p: array[1..12] of Int64;
begin

  Result:= 0;

  for s in Data do begin
    BattsLeft:= 11;
    for i:= 1 to 12 do begin
      max_v[i]:= 0;
      max_p[i]:= 0;
    end;

    for i:= 1 to 12 do begin
      if i = 1 then start:= 1 else start:= max_p[i-1] + 1;
      for j:= start to Length(s) - BattsLeft do begin
        value:= StrToInt64(s[j]);
        if value > max_v[i] then begin
            max_v[i]:= value;
            max_p[i]:= j;
        end;
      end;
      BattsLeft:= BattsLeft - 1;
    end;

    value:= 0;
    for i:= 1 to 12 do begin
      multi:= 1;
      for j:= 1 to abs(i-12) do begin
        multi:= multi * 10;
      end;
      if multi = 0 then multi:= 1;
      value:= value + max_v[i] * multi;
    end;
    Result:= Result + value;
  end;

end;

var
  Data: TStringList;
  StartTick: Int64;
  prof: TEpikTimer;
  elapsed: Extended;

begin
  prof:= TEpikTimer.Create(nil);
  prof.Clear;
  prof.Start;
  StartTick:= GetTickCount64;
  Data:= ReadInput(false);
  WriteLn('Part1: ' + SolveP1(Data).ToString);
  WriteLn('Part2: ' + SolveP2(Data).ToString);
  elapsed:= prof.Elapsed;
  if elapsed > 10 then WriteLn('Time elapsed [s]: ' + FloatToStr(elapsed)) else WriteLn('Time elapsed [ms]: ' + FloatToStr(elapsed * 1000));
end.

