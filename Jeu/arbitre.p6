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
  has Str $.avion;
}

class Avion does JSON::Class {
  has @.pages;
}
sub MAIN (Str :$date-heure, Str :$gentil, Str :$méchant) {
  my Pilote $pilote_g .= from-json(slurp "$gentil.json");
  my Pilote $pilote_m .= from-json(slurp "$méchant.json");
  say "Combat de $gentil contre $méchant, ", $pilote_g.avion, " contre ", $pilote_m.avion;
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

  my $num = 0;
  for <abc def ghi 0.5pv> -> $ch-manv {
    my BSON::Document $coup;
    if $ch-manv ~~ /(.*)pv/ {
      my $résultat = $0;
      $coup .= new: (
           date-heure => $date-heure,
           identité   => $gentil,
           numéro     => ++ $num,
           fini       => 1,
      );

    }
    else {
      $coup .= new: (
           date-heure => $date-heure,
           identité   => $gentil,
           numéro     => ++ $num,
           choix      => [ $ch-manv.comb ],
           dh1        => DateTime.now.Str,
      );
    }
    écrire-coup($coup);
    sleep 10.rand;
  }
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
