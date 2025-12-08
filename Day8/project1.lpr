program project1;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, EpikTimer;

type
  TVec = array[0..2] of Int64;
  TDataGrid = array of TVec;

  TData = record
    a: Int64;
    b: Int64;
    d: Int64; // Distanz^2
  end;

  TIntArray  = array of Int64;
  TDataArray = array of TData;

procedure ReadData(var Data: TDataGrid; example: boolean = false);
var
  sl: TStringList;
  sa: TStringArray;
  i: Int64;
begin
  sl:= TStringList.Create;
  try
    if example then
      sl.LoadFromFile('./example')
    else
      sl.LoadFromFile('./input');

    SetLength(Data, sl.Count);
    for i:= 0 to sl.Count - 1 do begin
      sa:= sl[i].Split(',');
      Data[i][0]:= sa[0].ToInt64; // X
      Data[i][1]:= sa[1].ToInt64; // Y
      Data[i][2]:= sa[2].ToInt64; // Z
    end;
  finally
    sl.Free;
  end;
end;

function Distance2(const p1, p2: TVec): Int64;
var
  x, y, z: Int64;
begin
  x:= p1[0] - p2[0];
  y:= p1[1] - p2[1];
  z:= p1[2] - p2[2];
  Result:= x*x + y*y + z*z;
end;

procedure SortByDistance(var dists: array of TData);

  procedure QSort(l, r: Int64);
  var
    i, j: Int64;
    p, t: TData;
  begin
    i:= l;
    j:= r;
    p:= dists[(l + r) div 2];

    while i <= j do begin
      while dists[i].d < p.d do Inc(i);
      while dists[j].d > p.d do Dec(j);
      if i <= j then begin
        t:= dists[i];
        dists[i]:= dists[j];
        dists[j]:= t;
        Inc(i);
        Dec(j);
      end;
    end;

    if l < j then QSort(l, j);
    if i < r then QSort(i, r);
  end;

begin
  if Length(dists) > 1 then
    QSort(Low(dists), High(dists));
end;

function FindEdge(var parent: TIntArray; x: Int64): Int64;
begin
  while parent[x] <> x do begin
    parent[x]:= parent[parent[x]]; // Path-Compression
    x:= parent[x];
  end;
  Result:= x;
end;

procedure Merge(var parent, compSize: TIntArray; a, b: Int64);
var
  ra, rb: Int64;
begin
  ra:= FindEdge(parent, a);
  rb:= FindEdge(parent, b);

  if ra = rb then Exit;

  // Union by size
  if compSize[ra] < compSize[rb] then begin
    parent[ra]:= rb;
    compSize[rb]:= compSize[rb] + compSize[ra];
  end else begin
    parent[rb]:= ra;
    compSize[ra]:= compSize[ra] + compSize[rb];
  end;
end;

function SolveP1(var Data: TDataGrid; dists: TDataArray): Int64;
var
  n: Int64;
  parent, compSize: TIntArray;
  i, j, t: Int64;
  components: Int64;
  tmpSizes: TIntArray;
  swapped: boolean;
  tmp: Int64;
  maxEdges: Int64;
begin
  n:= Length(Data);
  if n = 0 then begin
    Result:= 0;
    Exit;
  end;

  // DSU initialisieren
  SetLength(parent, n);
  SetLength(compSize, n);
  for i:= 0 to n - 1 do begin
    parent[i]:= i;
    compSize[i]:= 1;
  end;
  components:= n;

  // Nur die ersten 1000 Kanten (oder weniger, falls es weniger gibt)
  maxEdges:= 1000;
  if maxEdges > Length(dists) then
    maxEdges:= Length(dists);

  for t:= 0 to maxEdges - 1 do begin
    Merge(parent, compSize, dists[t].a, dists[t].b);
  end;

  // Komponentengrößen einsammeln (nur Repräsentanten)
  SetLength(tmpSizes, 0);
  for i:= 0 to n - 1 do begin
    if parent[i] = i then begin
      SetLength(tmpSizes, Length(tmpSizes) + 1);
      tmpSizes[High(tmpSizes)]:= compSize[i];
    end;
  end;

  // Größen absteigend sortieren
  if Length(tmpSizes) > 1 then begin
    swapped:= true;
    while swapped do begin
      swapped:= false;
      for i:= 0 to High(tmpSizes) - 1 do begin
        if tmpSizes[i] < tmpSizes[i+1] then begin
          tmp:= tmpSizes[i];
          tmpSizes[i]:= tmpSizes[i+1];
          tmpSizes[i+1]:= tmp;
          swapped:= true;
        end;
      end;
    end;
  end;

  // Produkt der drei größten Komponenten
  Result:= 1;
  for i:= 0 to 2 do begin
    if i > High(tmpSizes) then Break;
    Result:= Result * tmpSizes[i];
  end;
end;

function SolveP2(var Data: TDataGrid; var dists: TDataArray): Int64;
var
  n: Int64;
  parent, compSize: TIntArray;
  i, j, t: Int64;
  components: Int64;
  lastEdge: TData;
begin
  n:= Length(Data);
  if n = 0 then begin
    Result:= 0;
    Exit;
  end;

  // DSU initialisieren
  SetLength(parent, n);
  SetLength(compSize, n);
  for i:= 0 to n - 1 do begin
    parent[i]:= i;
    compSize[i]:= 1;
  end;
  components:= n;

  // Kanten in aufsteigender Distanz verbinden, bis alle in einer Komponente sind
  for t:= 0 to High(dists) do begin
    i:= FindEdge(parent, dists[t].a);
    j:= FindEdge(parent, dists[t].b);

    if i <> j then begin
      Merge(parent, compSize, i, j);
      lastEdge:= dists[t];
      Dec(components);
      if components = 1 then Break;
    end;
  end;

  // X-Koordinaten der beiden letzten verbundenen Junction-Boxen multiplizieren
  Result:= Data[lastEdge.a][0] * Data[lastEdge.b][0];
end;


procedure BuildDists(const Data: TDataGrid; out dists: TDataArray);
var
  n: Int64;
  i, j, t: Int64;
  x, y, z: Int64;
begin
  n:= Length(Data);
  SetLength(dists, (n * (n - 1)) div 2);
  t:= 0;

  for i:= 0 to n - 2 do begin
    for j:= i + 1 to n - 1 do begin
      x:= Data[i][0] - Data[j][0];
      y:= Data[i][1] - Data[j][1];
      z:= Data[i][2] - Data[j][2];

      dists[t].a:= i;
      dists[t].b:= j;
      dists[t].d:= Sqr(x) + sqr(y) + sqr(z); // Distanz^2
      Inc(t);
    end;
  end;
  SortByDistance(dists)
end;


var
  prof: TEpikTimer;
  er, e1, e2: Extended;

  data, data2: TDataGrid;
  dists: TDataArray;

  p1, p2: Int64;
  sl: TStringList;

begin

  prof:= TEpikTimer.Create(nil);
  prof.Clear;
  prof.Start;

  ReadData(data, false);
  BuildDists(Data, dists);

  er:= prof.Elapsed;

  p1:= SolveP1(data, dists);
  e1:= prof.Elapsed;

  p2:= SolveP2(data, dists);
  e2:= prof.Elapsed;
  prof.Stop;

  WriteLn('P1: ' + p1.ToString);
  WriteLn('P2: ' + p2.ToString);

  WriteLn('Part Read: ' + FloatToStr(er * 1000));
  WriteLn('Part 1: ' + FloatToStr((e1 - er) * 1000));
  WriteLn('Part 2: ' + FloatToStr((e2 - e1) * 1000));

  WriteLn(4 xor 4  xor 4);

  FreeAndNil(prof);

end.

