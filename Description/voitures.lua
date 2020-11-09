--[[
     Utility script to draw the "cars in parking" version of the
     game turn example for Ace of Aces
     Utilitaire pour dessiner la métaphore "voitures dans un parc
     de supermarché" pour l'exemple de tour de jeu de l'As des As.
     Copyright (C) 2018 Jean Forget

     This program is distributed under the same terms as Perl 5.16.3:
     GNU Public License version 1 or later and Perl Artistic License.

    Here is the summary of GPL:

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 1, or (at your option)
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software Foundation,
    Inc., https://www.fsf.org/.
]]

local substr = string.sub;
local floor  = math.floor;
local dq = string.char(34); -- double-quote

function voiture1(x, y, angle, motif, legende, echelle)
   local forme = { {0,0},
                          { 0, 1}, {-1, 1}, {-1, 5}, {0, 5},
		          { 0,15}, {-1,15}, {-1,19}, {0,19},
                   {0, 20}, {10, 20},
		          {10,19}, {11,19}, {11,15}, {10,15},
		          {10, 5}, {11, 5}, {11, 1}, {10, 1},
                   {10, 0}};
  tex.print("path voiture;");
  tex.print("voiture = ");
  for i = 1, #forme do
    local dx = forme[i][1];
    local dy = forme[i][2];
    tex.print("(" .. dx .. "," .. dy .. ")--");
  end;
  tex.print("cycle;");
  tex.print("draw voiture rotated " .. angle .. " shifted (" .. x .. "," .. y .. ")" .. " scaled " .. echelle .. motif .. " ;")
  tex.print("label.rt(" .. legende .. ", (" .. echelle * (x + 10) .. "," .. echelle * (y + 10) .. "));");
end

function dessin(pos1, pos2, mvt1, mvt2)
  tex.print("\\begin{mplibcode}\n");
  tex.print("beginfig(1);\n");
  local motif;
  local echelle = 3;

  -- VW au début
  if pos1 == "D" then
    motif   = "";
    legende = dq .. "VW" .. dq;
  else
    motif   = "dashed evenly";
    legende = dq .. dq;
  end
  voiture1(100,  0,  0, motif, legende, echelle);
  -- mouvement de la VW
  if mvt1 == "O" then
    motif = "";
  else
    motif = "dashed evenly";
  end
  tex.print("drawarrow (" .. 105 * echelle .. "," .. 22 * echelle .. "){up} .. (" .. 100 * echelle .. "," .. 30 * echelle .. ") " .. motif .. ";");
  -- VW à la fin
  if pos1 == "F" then
    motif   = "";
    legende = dq .. "VW" .. dq;
  else
    motif   = "dashed evenly";
    legende = dq .. dq;
  end
  voiture1(95, 27, 60, motif, legende, echelle);

  -- Mini au début
  if pos2 == "D" then
    motif   = "";
    legende = dq .. "Mini" .. dq;
  else
    motif   = "dashed evenly";
    legende = dq .. dq;
  end
  voiture1(50, 40,  0, motif, legende, echelle);
  -- mouvement de la Mini
  if mvt2 == "O" then
    motif = "";
  else
    motif = "dashed evenly";
  end
  tex.print("drawarrow (" .. 55 * echelle .. "," .. 62 * echelle .. "){up} .. (" .. 10 * echelle .. "," .. 100 * echelle .. "){dir 140} " .. motif .. ";");
  -- Mini à la fin
  if pos2 == "F" then
    motif = "";
    legende = dq .. "Mini" .. dq;
  else
    motif = "dashed evenly";
    legende = dq  .. dq;
  end
  voiture1( 0, 100, 60, motif, legende, echelle);

  tex.print("endfig;\n");
  tex.print("\\end{mplibcode}\n");
  tex.print("\\eject\n");
end
