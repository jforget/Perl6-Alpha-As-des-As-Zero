#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Programme construisant le livret pour un engin volant ou une créature volante pour l'As des As
#     Program building the booklet for a flying machine or a flying creature for Ace of Aces
#     Copyright (C) 2018, 2020, 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib '.';
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use Depl;
use JSON::Class;

my MongoDB::Client     $client     .= new(:uri('mongodb://'));
my MongoDB::Database   $database    = $client.database('aoa_prep');
my MongoDB::Collection $pages       = $database.collection('Pages');
my MongoDB::Collection $manoeuvres  = $database.collection('Manoeuvres');

my %numéro_de_chemin; # cache des numéros de page par chemin GM

my $nom = @*ARGS[0];

class Caracteristiques does JSON::Class {
  has Str $.livret;
  has Str $.camp;
  has Str $.identité;
  has Str $.nom;
  has Int $.capacité;
  has     %.manoeuvres;
  has     %.tirs;
}
class Characteristics does JSON::Class {
  has Str $.booklet;
  has Str $.side;
  has Str $.identity;
  has Str $.name;
  has Int $.hits;
  has     %.maneuvers;
  has     %.shoots;
}
class Livret does JSON::Class {
  has Str $.livret;
  has Str $.camp;
  has Str $.identité;
  has Str $.nom;
  has Int $.capacité;
  has     @.pages;
  has     %.manoeuvres;
}
class Booklet does JSON::Class {
  has Str $.booklet;
  has Str $.side;
  has Str $.identity;
  has Str $.name;
  has Int $.hits;
  has     @.pages;
  has     %.maneuvers;
}

my Livret  $livret;
my Booklet $booklet;
my @pages_du_livret;
my @booklet-pages;

my Caracteristiques $car;
if "fr/{$nom}-init.json".IO.e {
  $car .= from-json(slurp "fr/{$nom}-init.json");
}
else {
  my Characteristics $car1 .= from-json(slurp "en/{$nom}-init.json");
  my %e2f-side = ( G => 'G', B => 'M' );
  my %e2f-turn = ( L => 'G', C => 'A', R => 'D' );
  $car .= new(livret     =>           $car1.booklet
            , camp       => %e2f-side{$car1.side}
            , identité   =>           $car1.identity
            , nom        =>           $car1.name
            , capacité   =>           $car1.hits
            , tirs       =>           $car1.shoots);
  for $car1.maneuvers.keys -> $man {
    $car.manoeuvres{$man}<chemin>  =           $car1.maneuvers{$man}<path>;
    $car.manoeuvres{$man}<virage>  = %e2f-turn{$car1.maneuvers{$man}<turn>};
    $car.manoeuvres{$man}<vitesse> =           $car1.maneuvers{$man}<speed>;
  }
}


#say $car.perl;
say DateTime.now.hh-mm-ss, ' début du traitement';

my @manv = $car.manoeuvres.keys;
my %tirs = $car.tirs;
my %manoeuvres;
my %maneuvers;
my %trans-turn = ( G => 'L', A => 'C', D => 'R' );
for @manv -> $manv {
  %manoeuvres{$manv} = { "vitesse" =>             $car.manoeuvres{$manv}<vitesse>,
                         "virage"  =>             $car.manoeuvres{$manv}<virage>   };
  %maneuvers{ $manv} = { "speed"   =>             $car.manoeuvres{$manv}<vitesse>,
                         "turn"    => %trans-turn{$car.manoeuvres{$manv}<virage> } };
}
say DateTime.now.hh-mm-ss, ' début du calcul des pages';

my $cle   = $car.camp eq 'G' ?? 'chemin_MG' !! 'chemin_GM' ;
my $cle-r = $car.camp eq 'G' ?? 'chemin_GM' !! 'chemin_MG' ;

my MongoDB::Cursor $cursor = $pages.find();
while $cursor.fetch -> BSON::Document $d {
  my $numéro = $d<numero>;
  next
    if $numéro == 223;
  my $chemin_1 = $d{$cle};
  my $chemin_R = $d{$cle-r};

  my ($tir, $poursuite) = ('', '');
  if %tirs{~$numéro} {
    $tir = %tirs{~$numéro};
  }
  #elsif $chemin_R ~~ /^ [0]+ \;/ {
  #  $tir = 'Tir';
  #}
  if   ($chemin_R ~~ /^ [0|1]+ \; [0|1] /)
    || ($chemin_R ~~ /^ [0|5]+ \; [0|5] /) {
    $poursuite = 'T';
  }

  my Depl $départ .= new(chemin => $chemin_1 );
  my %enchaînement;
  for @manv -> $manv {
    my $chemin_2      = $car.manoeuvres{$manv}<chemin>;
    my Depl $déplac  .= new(chemin => $chemin_2 );
    my Depl $arrivée  = $départ → $déplac;
    my $pg_arr =  recherche_chemin_GM($arrivée.chemin, $cle);
    %enchaînement{$manv} = $pg_arr;
  }
  @pages_du_livret[$numéro] =  { numero => $numéro, tir   => $tir, poursuite => $poursuite, enchainement => %enchaînement };
  @booklet-pages[  $numéro] =  { number => $numéro, shoot => $tir, pursuit   => $poursuite, transition   => %enchaînement };
}
$cursor.kill;

say DateTime.now.hh-mm-ss, ' fin du calcul des pages';
@pages_du_livret[223] = { numero => 223, };
@booklet-pages[  223] = { number => 223, };

$livret .= new(livret     => $car.livret
             , camp       => $car.camp
             , identité   => $car.identité
             , nom        => $car.nom
             , capacité   => $car.capacité
             , manoeuvres => %manoeuvres
             , pages      => @pages_du_livret);
my $fhj = open("fr/$nom.json", :w);
$fhj.say($livret.to-json());
$fhj.close();

my %translate = ( G => 'G', M => 'B' ); # Gentil → Good guy, Méchant → Bad Guy
$booklet .= new(booklet   => $car.livret
             , side       => %translate{$car.camp}
             , identity   => $car.identité
             , name       => $car.nom
             , hits       => $car.capacité
             , maneuvers  => %maneuvers
             , pages      => @booklet-pages);
$fhj = open("en/$nom.json", :w);
$fhj.say($booklet.to-json());
$fhj.close();

my Str $ligne1 = "<tr align='center'><td>Page</td><td>Poursuite</td><td>Tir</td><td>Man</td>" ~ [~] map { "<td>{$_}</td>" }, @manv.sort;
$ligne1 ~= "</tr>";
my Str $ligne2 = "<tr align='center'><td></td><td></td><td></td><td>Vit</td>" ~ [~] map { "<td>{$car.manoeuvres{$_}<vitesse>}</td>" }, @manv.sort;
$ligne2 ~= "</tr>";
my Str $ligne3 = "<tr align='center'><td></td><td></td><td></td><td>Dir</td>" ~ [~] map { "<td>{$car.manoeuvres{$_}<virage>}</td>" }, @manv.sort;
$ligne3 ~= "</tr>";

prt-html('fr', $ligne1, $ligne2, $ligne3);

my %f2e-turn = ( G => 'L', A => 'C', D => 'R' );
$ligne1 = "<tr align='center'><td>Page</td><td>Tailing</td><td>Shoot</td><td>Man</td>" ~ [~] map { "<td>{$_}</td>" }, @manv.sort;
$ligne1 ~= "</tr>";
$ligne2 = "<tr align='center'><td></td><td></td><td></td><td>Spd</td>" ~ [~] map { "<td>{$car.manoeuvres{$_}<vitesse>}</td>" }, @manv.sort;
$ligne2 ~= "</tr>";
$ligne3 = "<tr align='center'><td></td><td></td><td></td><td>Dir</td>" ~ [~] map { "<td>{%f2e-turn{$car.manoeuvres{$_}<virage>}}</td>" }, @manv.sort;
$ligne3 ~= "</tr>";

prt-html('en', $ligne1, $ligne2, $ligne3);

sub prt-html(Str $dir, Str $line1, Str $line2, Str $line3) {
  my $fhh = open("$dir/$nom.html", :w);
  $fhh.print(qq:to/EOF/);
  <html>
  <head>
  <title>{$nom}</title>
  </head>
  <body>
  <table border='1'>
  EOF

  for $livret.pages -> $page {
    my $n = $page<numero> // 0;
    if $n {
      if $n % 10 == 1 {
        $fhh.say($line1);
        $fhh.say($line2);
        $fhh.say($line3);
      }
      $fhh.print("<tr align='right'><td>{$n}</td>");
      if $n ≠ 223 {
        $fhh.print("<td align='center'>{$page<poursuite>}</td><td>{$page<tir>}</td><td></td>");
        my %ench = $page<enchainement>;
        for %ench.keys.sort -> $code {
          $fhh.print("<td>{%ench{$code}}</td>");
        }
      }
      $fhh.say("</tr>");
    }
  }

  $fhh.print(q:to/EOF/);
  </table>
  </body>
  </html>
  EOF
  $fhh.close();
}

sub recherche_chemin_GM(Str $chemin, Str $clé) {
  if $chemin.chars ≥ 6 {
    # quatre hexagones ou plus, plus le point-virgule et le changement d'orientation
    return 223;
  }
  my $numero = %numéro_de_chemin{$chemin} // 0;
  unless $numero {
    my MongoDB::Cursor $cursor = $pages.find(
      criteria   => ( $clé => $chemin, ),
    );
    while $cursor.fetch -> BSON::Document $d {
      if $d{$clé} eq $chemin {
        $numero = $d<numero>;
        last;
      }
    }
    $cursor.kill;
  }

  return $numero;
}

=begin POD

=encoding utf8

=head1 NOM

livret.p6 -- programme construisant le livret pour un engin volant de l'As des As

livret.p6 -- program generating the booklet describing a flying object for Ace of Aces

=head1 DESCRIPTION

Ce programme construit le livret décrivant les caractéristiques d'un engin volant de l'As des As,
c'est-à-dire les enchaînements (page de départ, manœuvre) → page d'arrivée, ainsi que les pages
de poursuite et les pages de tir.

This program generates the booklet describing the characteristics of a
flying vehicle  (or a flying creature)  for Ace of Aces,  that is, the
transitions (start page, maneuver) → end  page, as well as the tailing
pages and the shoot pages.

=head1 LANCEMENT

  perl6 livret.p6 DR1

=head2 Paramètres

Le nom de l'engin volant. Ce nom, par exemple C<DR1>, doit correspondre à un
fichier F<DR1-init.json>, donnant les caractéristiques résumées de l'engin volant.
En sortie, le programme génère un fichier F<DR1.json> contenant les caractéristiques
complètes de l'engin volant, ainsi qu'un fichier F<DR1.html> donnant les mêmes
caractéristiques sous une forme plus agréable.

There  is only  one  parameter,  the name  of  the  flying vehicle  or
creature. This name, e.g. C<DR1>, is used to obtain the name of a text
file F<en/DR1-init.json>  or F<fr/DR1-init.json>, which  specifies the
complete characteristics of the flying object. The program generates a
JSON file with French keywords  F<fr/DR1.json>, another JSON file with
English keywords F<en/DR1.json>, and two HTML files F<en/DR1.html> and
F<fr/DR1.html> which  give the same data  as the JSON files,  yet in a
more readable way.

=head1 COPYRIGHT et LICENCE

Copyright (c) 2018, 2020, 2021 Jean Forget

Ce programme est diffusé avec les mêmes conditions que Perl 5.16.3 :
la licence publique GPL version 1 ou ultérieure, ou bien la
licence artistique Perl.

The program  is published  under the  same terms  as Perl  5.16.3: GPL
version 1 or later or the Perl Artistic License.

Vous pouvez trouver le texte en anglais de ces licences dans le
fichier F<LICENSE> joint ou bien aux adresses
L<http://www.perlfoundation.org/artistic_license_1_0>
et L<http://www.gnu.org/licenses/gpl-1.0.html>.

You can find the text of the licenses in the F<LICENSE> file in this
repository or you can read them at
L<http://www.perlfoundation.org/artistic_license_1_0>
and L<http://www.gnu.org/licenses/gpl-1.0.html>.

Résumé en anglais de la GPL :

Summary of GPL:

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
Inc., L<http://www.fsf.org/>.

=end POD
