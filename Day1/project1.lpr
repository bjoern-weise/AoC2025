program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes
  { you can add units after this },
  sysutils, StrUtils;

var
  Steps: array of integer;
  sl: TStringList;
  i: integer;

function Modulo(a, b: integer): integer;
begin
  Result:= (b + (a mod b)) mod b;
end;

function Calculate(part: integer; start: integer): integer;
var
  i: integer;
  j, k, r: integer;
begin
  j:= start;
  k:= j;
  Result:= 0;
  for i in steps do begin
    j:= Modulo((j + i), 100);
    if j = 0 then Result:= Result + 1;
    if part = 1 then Continue;


    r:= abs(i div 100);

    if (((j <> 0) and (k <> 0))
       and (((j > k) and (i < 0))
       or ((j < k) and (i > 0)))) then Result:= Result + 1;

    Result:= Result + r;
    k:= j;
  end;
end;


begin
  sl:= TStringList.Create;
  sl.LoadFromFile('./input');
  //sl.LoadFromFile('./example');
  SetLength(steps, sl.Count);

  for i:= 0 to sl.Count - 1 do begin
    steps[i]:= StrToInt(ReplaceStr(ReplaceStr(sl[i], 'L', '-'), 'R', ''));
  end;
  WriteLn('Part1: ' + Calculate(1, 50).ToString);
  WriteLn('Part2 :' + Calculate(2, 50).ToString);

  FreeAndNil(sl);
end.



