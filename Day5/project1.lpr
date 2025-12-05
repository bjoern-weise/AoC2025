program project1;

{$mode objfpc}{$H+}
{$modeSwitch advancedRecords}

uses
  {$IFDEF UNIX}
  cthreads, EpikTimer,
  {$ENDIF}
  Classes, sysutils, StrUtils
  { you can add units after this };


type

  { TRange }

  TRange = record
    Min: Int64;
    Max: Int64;
    function IsInRange(AValue: Int64): boolean;
  end;

  TIngred = record
    Value: Int64;
    isChecked: boolean;
  end;

  TIngredDB = array of TRange;
  TIngreds = array of TIngred;



function GetRange(s: string): TRange;
var
  tmp: string;
begin
  tmp:= LeftStr(s, Pos('-', s) - 1);
  Result.Min:= StrToInt64(tmp);
  tmp:= RightStr(s, length(s) - Pos('-', s));
  Result.Max:= StrToInt64(tmp);
end;

procedure ReadInput(var IngredDB: TIngredDB; var Ingreds: TIngreds; example: boolean = false);
var
  sl: TStringList;
  s: string;
  i, j: Int64;
begin
  sl:= TStringList.Create;
  try
    if example then sl.LoadFromFile('./example') else sl.LoadFromFile('./input');

    for i:= 0 to sl.Count - 1 do begin
      s:= sl[i];
      if s = '' then begin
        SetLength(IngredDB, i);
        Break;
      end;
    end;

    SetLength(Ingreds, sl.Count - i - 1);

    for i:= 0 to Length(IngredDB) - 1 do IngredDB[i]:= GetRange(sl[i]);

    i:= 0;
    for j:= Length(IngredDB) + 1 to sl.Count - 1 do begin
      Ingreds[i].Value:= StrToInt64(sl[j]);
      Ingreds[i].isChecked:= false;
      i:= i + 1;
    end;


  finally
    FreeAndNil(sl);
  end;
end;

procedure SortIngredDB(var IngredDB: TIngredDB);
var
  i, j: Int64;
  sorted: Boolean;
  tmp: TRange;
begin
  sorted:= true;
  j:= 2;
  while sorted do begin
    sorted:= false;
    for i:= 0 to length(IngredDB) - j do begin
      if IngredDB[i].Min > IngredDB[i+1].Min then begin
        tmp:= IngredDB[i];
        IngredDB[i]:= IngredDB[i+1];
        IngredDB[i+1]:= tmp;
        sorted:= true;
      end;
    end;
    j:= j + 1;
  end;
end;

function SolveP1(var IngredDB: TIngredDB; var Ingreds: TIngreds): Int64;
var
  i, j: Int64;
  r: TRange;
begin
  Result:= 0;
  for j:= 0 to Length(IngredDB) - 1 do begin
    for i:= 0 to Length(Ingreds) - 1 do begin
      if not Ingreds[i].isChecked then begin
        if IngredDB[j].IsInRange(Ingreds[i].Value) then begin
          Result:= Result + 1;
          Ingreds[i].isChecked:= true;
        end;
      end;
    end;
  end;
end;

function SolveP2(IngredDB: TIngredDB): Int64;
var
  i: Int64;
  actMax: Int64;
begin
  Result:= 0;
  actMax:= 0;
  SortIngredDB(IngredDB);

  for i:= 0 to High(IngredDB) do begin
    if IngredDB[i].Min > actMax then begin
      Result:= Result + (IngredDB[i].Max - IngredDB[i].Min) + 1;
      actMax:= IngredDB[i].Max;
    end else begin
      if IngredDB[i].Max > actMax then begin
        Result:= Result + (IngredDB[i].Max - actMax);
        actMax:= IngredDB[i].Max;
      end;
    end;
  end;
end;

{ TRange }

function TRange.IsInRange(AValue: Int64): boolean;
begin
  Result:= (AValue >= Min) and (AValue <= Max);
end;




var
  profiler: TEpikTimer;
  et_read, et_P1, et_P2: Extended;
  i: Int64;
  IngredDB: TIngredDB;
  Ingreds: TIngreds;



begin

  profiler:= TEpikTimer.Create(nil);
  profiler.Clear;
  profiler.Start;

  ReadInput(IngredDB, Ingreds, false);
  et_read:= profiler.Elapsed;

  i:= SolveP1(IngredDB, Ingreds);
  et_P1:= profiler.Elapsed;
  WriteLn('Part1: ' + i.ToString);


  i:= SolveP2(IngredDB);
  et_P2:= profiler.Elapsed;
  WriteLn('Part2: ' + i.ToString);
  profiler.Stop;


  WriteLn('Time Read: ' + FloatToStr(et_read * 1000));
  WriteLn('Time Part1: ' + FloatToStr((et_P1 - et_read) * 1000));
  WriteLn('Time Part2: ' + FloatToStr((et_P2 - et_P1) * 1000));


  FreeAndNil(profiler);

end.

