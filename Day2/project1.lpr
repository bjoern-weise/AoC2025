program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, sysutils
  { you can add units after this };


type
  TRange = record
    RangeStart: int64;
    RangeEnd: int64;
  end;

var
  Ranges: array of TRange;

procedure ReadInput;
var
  sl: TStringList;
  sa1, sa2: TStringArray;
  s: string;
  i: int64;
begin
  sl:= TStringList.Create;
  //sl.LoadFromFile('./example');
  sl.LoadFromFile('./input');
  for s in sl do begin
    sa1:= s.Split(',');
    SetLength(Ranges, Length(sa1));
    for i:= 0 to Length(sa1) - 1 do begin
      sa2:= sa1[i].Split('-');
      Ranges[i].RangeStart:= sa2[0].ToInt64;
      Ranges[i].RangeEnd:= sa2[1].ToInt64;
    end;
  end;
end;

function solveP1: int64;
var
  i, j: int64;
  s, s_left, s_right: string;
begin
  Result:= 0;
  for i:= 0 to length(Ranges) - 1 do begin
    for j:= Ranges[i].RangeStart to Ranges[i].RangeEnd do begin
      s:= j.ToString;
      if Length(s) mod 2 <> 0 then Continue;
      s_left:= LeftStr(s, Length(s) div 2);
      s_right:= RightStr(s, Length(s) div 2);
      if s_left = s_right then Result:= Result + j;
    end;
  end;
end;

function solveP2: int64;
var
  i, j, k, l, p: int64;
  s, s_left, s_right, s_tmp: string;

begin
  Result:= 0;
  for i:= 0 to length(Ranges) - 1 do begin
    for j:= Ranges[i].RangeStart to Ranges[i].RangeEnd do begin
      s:= j.ToString;
      for k:= (length(s) div 2) downto 1 do begin
        s_left:= LeftStr(s, k);
        s_right:= RightStr(s, Length(s) - k);
        if (Length(s_right) mod Length(s_left)) <> 0 then Continue;
        l:= 0;
        s_tmp:= s_right;
        while (l + Length(s_left) - 1) < Length(s_right) do begin
          p:= 0;
          if s_left = LeftStr(s_tmp, Length(s_left)) then begin
            p:= p + 1;
            s_tmp:= RightStr(s_tmp, Length(s_tmp) - Length(s_left));
            l:= l + Length(s_left);
          end else begin
            p:= 0;
            Break;
          end;
        end;
        if p > 0 then begin
          Result:= Result + j;
          Break;
        end;
      end;
    end;
  end;
end;

begin
  ReadInput;
  WriteLn('Part1: ' + solveP1.ToString);
  WriteLn('Part2: ' + solveP2.ToString);
end.

