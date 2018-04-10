#!/home/jf/rakudo-star-2018.01/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Programme arbitre pour jouer à l'As des As
#     Program to act as an Ace of Aces umpire
#     Copyright (C) 2018 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use JSON::Class;

my MongoDB::Client     $client  .= new(:uri('mongodb://'));
my MongoDB::Database   $database = $client.database('Ace_of_Aces');
my MongoDB::Collection $coups    = $database.collection('Coups');

class Pilote does JSON::Class {
  has Str $.id;
  has Str $.avion           is rw;
  has Num $.perspicacité    is rw;
  has Num $.psycho-rigidité is rw;
}

class Avion does JSON::Class {
  has @.pages;
}
sub MAIN (Str :$date-heure, Str :$gentil, Str :$méchant) {
  my Pilote $pilote_g .= from-json(slurp "$gentil.json");
  my Pilote $pilote_m .= from-json(slurp "$méchant.json");
  say "Référence $date-heure";
  my Avion $avion_g;
  my Avion $avion_m;
  if $pilote_g.avion {
    # véritable pilote, il faut compléter en lisant les caractéristiques de l'avion
    $avion_g .= from-json(slurp "{$pilote_g.avion}.json");
  }
  else {
    # pilote anonyme, on ne connaît que l'avion
    # également, c'est pour l'entraînement
    $avion_g .= from-json(slurp "$gentil.json");
    $pilote_g.perspicacité    = 0.Num;
    $pilote_g.psycho-rigidité = 1.Num;
    $pilote_g.avion           = $gentil;
  }
  if $pilote_m.avion {
    # véritable pilote
    $avion_m .= from-json(slurp "{$pilote_m.avion}.json");
  }
  else {
    # pilote anonyme, on ne connaît que l'avion
    # également, c'est pour l'entraînement
    $avion_m .= from-json(slurp "$méchant.json");
    $pilote_m.perspicacité    = 0.Num;
    $pilote_m.psycho-rigidité = 1.Num;
    $pilote_m.avion           = $méchant;
  }
  say "Combat de $gentil contre $méchant, ", $pilote_g.avion, " contre ", $pilote_m.avion;

  my $num     =   0;
  my $on_joue =   1;
  my $page    = 170;
  while $on_joue {
    ++ $num;
    my BSON::Document $coup_g;
    $coup_g .= new: (
         date-heure => $date-heure,
         identité   => $gentil,
         numéro     => $num,
         page       => $page,
         choix      => [ $avion_g.pages[$page]<enchainement>.keys.sort ],
         dh1        => DateTime.now.Str,
    );
    écrire-coup($coup_g);
    my BSON::Document $coup_m;
    $coup_m .= new: (
         date-heure => $date-heure,
         identité   => $méchant,
         numéro     => $num,
         page       => $page,
         choix      => [ $avion_m.pages[$page]<enchainement>.keys.sort ],
         dh1        => DateTime.now.Str,
    );
    écrire-coup($coup_m);
    $coup_g     = lire_coup($date-heure, $gentil , $num);
    $coup_m     = lire_coup($date-heure, $méchant, $num);
    my $man_g   = $coup_g<manoeuvre>;
    my $man_m   = $coup_m<manoeuvre>;
    my $page_g  = $avion_g.pages[$page]<enchainement>{$man_g};
    my $page_m  = $avion_m.pages[$page]<enchainement>{$man_m};
    my $page_gf = $avion_g.pages[$page_m]<enchainement>{$man_g};
    my $page_mf = $avion_m.pages[$page_g]<enchainement>{$man_m};
say join ' ', $page, '->', $man_g, $page_g, $man_m, $page_m, '->', $page_gf, $page_mf;
    last;
  }
}

sub lire_coup ($dh, $id, $n) {
  my BSON::Document $coup;

  my $tentative_max = 50;
  my $tentative     =  0;
SONDER:
  while $tentative ≤ $tentative_max {
    ++ $tentative;
    my MongoDB::Cursor $cursor = $coups.find(
      criteria   => ( 'date-heure' => $dh,
                      'identité'   => $id,
                      'numéro'     => +$n, ),
      projection => ( _id => 0, )
    );
    while $cursor.fetch -> BSON::Document $d {
      #say $d.perl;
      if $d<numéro> == $n && ($d<manoeuvre> // '') ne '' {
        $coup = $d;
        last SONDER;
      }
    }
    $cursor.kill;
    sleep 1;
  }
  if $tentative ≥ $tentative_max {
    die "Plus de réponse du joueur $id, on arrête";
  }

  return $coup;
}

sub écrire-coup(BSON::Document $coup) {
  my BSON::Document $req .= new: (
    insert => 'Coups',
    documents => [ $coup ],
  );
  my BSON::Document $result = $database.run-command($req);
  say "Création coup ok : ", $result<ok>, " nb : ", $result<n>;

}

=begin POD

=encoding utf8

=head1 NOM

arbitre.p6 -- programme servant d'arbitre pour jouer à l'As des As

=head1 DESCRIPTION

Ce programme sert d'arbitre pour une partie de l'As des As entre deux
programmes joueurs.

=head1 LANCEMENT

  perl6 arbitre.p6 --date-heure=2018-04-04_21-42-10 --gentil=Plume-Noire --méchant=Kevin &

=head2 Paramètres

=item date-heure

Date et heure de début de la partie, sert de clé unique pour la partie et
pour tous les coups de cette partie.

=item gentil, méchant

Nom des joueurs simulés, associés à un fichier JSON donnant les caractéristiques de ces joueurs.


=head1 COPYRIGHT et LICENCE

Copyright 2018, Jean Forget

Ce programme est diffusé avec les mêmes conditions que Perl 5.16.3 :
la licence publique GPL version 1 ou ultérieure, ou bien la
licence artistique Perl.

Vous pouvez trouver le texte en anglais de ces licences dans le
fichier <LICENSE> joint ou bien aux adresses
L<http://www.perlfoundation.org/artistic_license_1_0>
et L<http://www.gnu.org/licenses/gpl-1.0.html>.

Résumé en anglais de la GPL :

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
