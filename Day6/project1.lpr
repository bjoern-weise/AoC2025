program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads, EpikTimer, StrUtils, sysutils,
  {$ENDIF}
  Classes, etpackage
  { you can add units after this };


type
  TDataGrid = array of array of Int64;
  TOps = array of Char;


function ReadData(var Data: TDataGrid; var Ops: TOps; example: boolean = false): TStringList;
var
  sl: TStringList;
  sa: array of TStringArray;
  i, j: Int64;
  s: string;
begin
  sl:= TStringList.Create;
  try
    if example then sl.LoadFromFile('./example') else sl.LoadFromFile('./input');
    SetLength(sa, sl.Count - 1);
    for i:= 0 to sl.Count - 2 do begin
      sa[i]:= sl[i].Split(' ', TStringSplitOptions.ExcludeEmpty);
    end;
    j:= sl.Count - 1;
    s:= sl[j];
    s:= ReplaceStr(sl[j], ' ', '');
    SetLength(Ops, Length(s));
    for i:= 1 to Length(s) do begin
      case s[i] of
           '+', '-', '*', '/': Ops[i-1]:= s[i];
      end;
    end;

    SetLength(Data, j);
    for i:= 0 to Length(Data) - 1 do begin
      SetLength(Data[i], Length(sa[i]));
      for j:= 0 to Length(sa[i]) - 1 do Data[i][j]:= StrToInt64(sa[i][j]);
    end;

    Result:= TStringList.Create;
    Result.Assign(sl);
  finally
    FreeAndNil(sl);
  end;

end;

function SolveP1(var Data: TDataGrid; var Ops: TOps): Int64;
var
  i, j, t: Int64;
begin
  Result:= 0;

  for j:= 0 to Length(Data[0]) do begin
    t:= Data[0][j];
    case Ops[j] of
      '+': for i:= 1 to Length(Data) - 1 do t:= t + Data[i][j];
      '-': for i:= 1 to Length(Data) - 1 do t:= t - Data[i][j];
      '*': for i:= 1 to Length(Data) - 1 do t:= t * Data[i][j];
      '/': for i:= 1 to Length(Data) - 1 do t:= t div Data[i][j];
    end;
    Result:= Result + t;
  end;

end;


function SolveP2(var Data: TDataGrid; var Ops: TOps; var sl: TStringList): Int64;
var
  i, j, k, t: Int64;
  val: array of Int64;
  calc: boolean;
begin
  Result:= 0;
  SetLength(val, 6);
  k:= 0;
  for i:= Length(sl[0]) - 1 downto 0 do begin
    t:= 0;
    calc:= true;
    for j:= 0 to sl.Count - 1 do begin
      case sl[j][i+1] of
        '*': begin
          for k:= k - 1 downto 0 do t:= t * val[k];
          Result:= Result + t;
          k:= 0;
          calc:= true;
        end;
        '+': begin
          for k:= k - 1 downto 0 do t:= t + val[k];
          Result:= Result + t;
          k:= 0;
          calc:= true;
        end;
        '0'..'9': begin
          t:= t * 10 + strtoint(sl[j][i+1]);
          calc:= false;
        end;
      end;
    end;
    if calc then Continue;
    val[k]:= t;
    k:= k + 1;

  end;


end;

var
  prof: TEpikTimer;
  er, e1, e2: Extended;

  data: TDataGrid;
  ops: TOps;

  p1, p2: Int64;
  sl: TStringList;

begin

  prof:= TEpikTimer.Create(nil);
  prof.Clear;
  prof.Start;

  sl:= ReadData(data, ops, false);
  er:= prof.Elapsed;

  p1:= SolveP1(data, ops);
  e1:= prof.Elapsed;

  p2:= SolveP2(data, ops, sl);
  e2:= prof.Elapsed;
  prof.Stop;

  WriteLn('P1: ' + p1.ToString);
  WriteLn('P2: ' + p2.ToString);

  WriteLn('Part Read: ' + FloatToStr(er * 1000));
  WriteLn('Part 1: ' + FloatToStr((e1 - er) * 1000));
  WriteLn('Part 2: ' + FloatToStr((e2 - e1) * 1000));

  FreeAndNil(prof);
  FreeAndNil(sl);

end.

