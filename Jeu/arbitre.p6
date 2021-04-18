#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Programme arbitre pour jouer à l'As des As
#     Program to act as an Ace of Aces umpire
#     Copyright (C) 2018, 2020 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use JSON::Class;
use Pilote;
use Avion;

my MongoDB::Client     $client  .= new(:uri('mongodb://'));
my MongoDB::Database   $database = $client.database('Ace_of_Aces');
my MongoDB::Collection $coups    = $database.collection('Coups');
my MongoDB::Collection $pilotes  = $database.collection('Pilotes');
my MongoDB::Collection $avions   = $database.collection('Avions');

sub MAIN (Str :$date-heure, Str :$gentil, Str :$méchant, Bool :$à-outrance) {
  my Pilote $pilote_g = init-pilote($gentil);
  my Pilote $pilote_m = init-pilote($méchant);
  my Avion  $avion_g  = init-avion($pilote_g.avion);
  my Avion  $avion_m  = init-avion($pilote_m.avion);
  #say "Référence $date-heure";
  say "Combat de $gentil contre $méchant, ", $pilote_g.avion, " contre ", $pilote_m.avion, $à-outrance ?? ' à outrance' !! '';

  my Int $num          =   0;
  my Int $on_joue      =   1;
  my Int $num_page     = 170;
  my Num $pts_dégâts_g = $pilote_g.capacité;
  my Num $pts_dégâts_m = $pilote_m.capacité;
  while $on_joue {
    my (@choix_g, @choix_m, $poursuite_g, $poursuite_m, $man_g, $man_m);
    my (Int $num_page_g , Int $num_page_m );  # pages intermédiaires
    my (Int $num_page_gf, Int $num_page_mf);  # pages finales
    if $num_page == 223 {
      if $à-outrance {
        @choix_g     = <Attaque Attaque Attaque Attaque Attaque Fuite>;
      }
      else {
        @choix_g     = <Attaque Fuite>;
      }
      @choix_m     = @choix_g;
      $poursuite_g = '';
      $poursuite_m = '';
      #say join ' ', @choix_g, '/', @choix_m;
    }
    else {
      @choix_g     = $avion_g.pages[$num_page]<enchainement>.keys.sort;
      @choix_m     = $avion_m.pages[$num_page]<enchainement>.keys.sort;
      if $à-outrance {
        #say join ' ', @choix_g, '/', @choix_m;
        my @choix = grep { $avion_g.pages[$num_page]<enchainement>{$_} != 223 }, @choix_g;
        if @choix.elems > 0 {
          @choix_g = @choix;
        }
        @choix = grep { $avion_m.pages[$num_page]<enchainement>{$_} != 223 }, @choix_m;
        if @choix.elems > 0 {
          @choix_m = @choix;
        }
        #say join ' ', @choix_g, '/', @choix_m;
      }

      $poursuite_g = $avion_g.pages[$num_page]<poursuite>;
      $poursuite_m = $avion_m.pages[$num_page]<poursuite>;
      $pts_dégâts_m -= $avion_g.pages[$num_page]<tir>;
      $pts_dégâts_g -= $avion_m.pages[$num_page]<tir>;
      if $pts_dégâts_g ≤ 0 or $pts_dégâts_m ≤ 0 {
        # au moins un avion abattu
        $on_joue = 0;
      }
    }
    my BSON::Document $coup_g;
    my BSON::Document $coup_m;
    if $on_joue {
      ++ $num;
      if $poursuite_g eq 'T' {
        $coup_m .= new: (
             date-heure => $date-heure,
             identité   => $méchant,
             tour       => $num,
             page       => ~ $num_page,
             choix      => [ @choix_m ],
             potentiel  => $pts_dégâts_m,
             dh1        => DateTime.now.Str,
        );
        écrire-coup($coup_m);
        $coup_m  = lire_coup($date-heure, $méchant, $num);
        $man_m   = $coup_m<manoeuvre>;
        $coup_g .= new: (
             date-heure => $date-heure,
             identité   => $gentil,
             tour       => $num,
             page       => $num_page ~ $avion_m.manoeuvres{$man_m}<virage>,
             choix      => [ @choix_g ],
             potentiel  => $pts_dégâts_g,
             dh1        => DateTime.now.Str,
        );
        écrire-coup($coup_g);
        $coup_g     = lire_coup($date-heure, $gentil , $num);
      }
      elsif $poursuite_m eq 'T' {
        $coup_g .= new: (
             date-heure => $date-heure,
             identité   => $gentil,
             tour       => $num,
             page       => ~ $num_page,
             choix      => [ @choix_g ],
             potentiel  => $pts_dégâts_g,
             dh1        => DateTime.now.Str,
        );
        écrire-coup($coup_g);
        $coup_g  = lire_coup($date-heure, $gentil , $num);
        $man_g   = $coup_g<manoeuvre>;
        $coup_m .= new: (
             date-heure => $date-heure,
             identité   => $méchant,
             tour       => $num,
             page       => $num_page ~ $avion_g.manoeuvres{$man_g}<virage>,
             choix      => [ @choix_m ],
             potentiel  => $pts_dégâts_m,
             dh1        => DateTime.now.Str,
        );
        écrire-coup($coup_m);
        $coup_m     = lire_coup($date-heure, $méchant, $num);
      }
      else {
        $coup_g .= new: (
             date-heure => $date-heure,
             identité   => $gentil,
             tour       => $num,
             page       => ~ $num_page,
             choix      => [ @choix_g ],
             potentiel  => $pts_dégâts_g,
             dh1        => DateTime.now.Str,
        );
        $coup_m .= new: (
             date-heure => $date-heure,
             identité   => $méchant,
             tour       => $num,
             page       => ~ $num_page,
             choix      => [ @choix_m ],
             potentiel  => $pts_dégâts_m,
             dh1        => DateTime.now.Str,
        );
        écrire-coup($coup_g);
        écrire-coup($coup_m);
        $coup_g     = lire_coup($date-heure, $gentil , $num);
        $coup_m     = lire_coup($date-heure, $méchant, $num);
      }
      $man_g   = $coup_g<manoeuvre>;
      $man_m   = $coup_m<manoeuvre>;
      if $num_page == 223 {
        if $man_g eq 'Attaque' && $man_m eq 'Attaque' {
          $num_page_gf = 170;
          $num_page_mf = 170;
          $num_page_g  =   0; # pour faire passer un test numérique un peu plus bas
          $num_page_m  =   0; # idem
        }
        else {
          # au moins un avion en fuite
          $on_joue =   0;
          $num_page    = 223;
          $num_page_g  = 223;
          $num_page_m  = 223;
        }
      }
      else {
        $num_page_g  = $avion_g.pages[$num_page]<enchainement>{$man_g};
        $num_page_m  = $avion_m.pages[$num_page]<enchainement>{$man_m};
      }
      if $num_page_m == 223 {
        $num_page_gf = 223;
      }
      elsif $num_page != 223 {
        $num_page_gf = $avion_g.pages[$num_page_m]<enchainement>{$man_g};
      }
      if $num_page_g == 223 {
        $num_page_mf = 223;
      }
      elsif $num_page != 223 {
        $num_page_mf = $avion_m.pages[$num_page_g]<enchainement>{$man_m};
      }
    }
    if $on_joue == 0 {
      $coup_g .= new: (
           date-heure => $date-heure,
           identité   => $gentil,
           tour       => $num + 1,
           page       => ~ $num_page,
           fini       =>   1,
           dh1        => DateTime.now.Str,
      );
      $coup_m .= new: (
           date-heure => $date-heure,
           identité   => $méchant,
           tour       => $num + 1,
           page       => ~ $num_page,
           fini       =>   1,
           dh1        => DateTime.now.Str,
      );
      if $pts_dégâts_g ≤ 0 and $pts_dégâts_m ≤ 0 {
        say "Match nul, les deux pilotes se sont abattus simultanément";
        $coup_g<résultat> = 0e0;
        $coup_m<résultat> = 0e0;
      }
      elsif $pts_dégâts_m ≤ 0 {
        say "Une victoire pour $gentil !";
        $coup_g<résultat> =  1e0;
        $coup_m<résultat> = -1e0;
      }
      elsif $pts_dégâts_g ≤ 0 {
        say "Une victoire pour $méchant !";
        $coup_g<résultat> = -1e0;
        $coup_m<résultat> =  1e0;
      }
      elsif $man_g eq 'Attaque' {
        say "$gentil résiste, $méchant fuit";
        $coup_g<résultat> =  0.5e0;
        $coup_m<résultat> = -0.5e0;
      }
      elsif $man_m eq 'Attaque' {
        say "$méchant résiste, $gentil fuit";
        $coup_g<résultat> = -0.5e0;
        $coup_m<résultat> =  0.5e0;
      }
      else {
        say "Match nul, les deux pilotes fuient";
        $coup_g<résultat> = 0e0;
        $coup_m<résultat> = 0e0;
      }

      écrire-coup($coup_g);
      écrire-coup($coup_m);
      my BSON::Document $résumé;
      $résumé .= new: (
           date-heure => $date-heure,
           gentil     => $gentil,
           méchant    => $méchant,
           avion_g    => $pilote_g.avion,
           avion_m    => $pilote_m.avion,
           résultat_g => $coup_g<résultat>,
           résultat_m => $coup_m<résultat>,
           capacité_g => $pts_dégâts_g,
           capacité_m => $pts_dégâts_m,
           nb_coups   => $num + 1e0,
           dh_fin     => DateTime.now.Str,
      );
      écrire-partie($résumé);
      say "Terminé !";
      last;
    }
    say join ' ', $num_page, '->', $man_g, $num_page_g, $man_m, $num_page_m, '->', $num_page_gf, $num_page_mf, "($pts_dégâts_g $pts_dégâts_m)";
    $num_page = min($num_page_gf, $num_page_mf);
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
                      'tour'       => +$n, ),
      projection => ( _id => 0, )
    );
    while $cursor.fetch -> BSON::Document $d {
      #say $d.perl;
      if $d<tour> == $n && ($d<manoeuvre> // '') ne '' {
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

sub init-pilote(Str $id) {
  my Pilote $pilote;

  my MongoDB::Cursor $cursor = $pilotes.find(
    criteria   => ( 'identité' => $id, ),
    projection => ( _id => 0, )
    );
  while $cursor.fetch -> BSON::Document $d {
    #say $d.perl;
    $pilote .= from-json($d<json>);
    last;
  }
  $cursor.kill;

  #say $pilote.perl;
  return $pilote;
}

sub init-avion(Str $id) {
  my Avion $avion;

  my MongoDB::Cursor $cursor = $avions.find(
    criteria   => ( 'identité' => $id, ),
    projection => ( _id => 0, )
    );
  while $cursor.fetch -> BSON::Document $d {
    #say $d.perl;
    $avion .= from-json($d<json>);
    last;
  }
  $cursor.kill;

  #say $avion.perl;
  return $avion;
}

sub écrire-coup(BSON::Document $coup) {
  my BSON::Document $req .= new: (
    insert => 'Coups',
    documents => [ $coup ],
  );
  my BSON::Document $result = $database.run-command($req);
  #say "Création coup ok : ", $result<ok>, " nb : ", $result<n>;

}

sub écrire-partie(BSON::Document $partie) {
  my BSON::Document $req .= new: (
    insert => 'Parties',
    documents => [ $partie ],
  );
  my BSON::Document $result = $database.run-command($req);
  #say "Création partie ok : ", $result<ok>, " nb : ", $result<n>;
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

Nom des joueurs simulés, présents dans la collection C<Pilotes> de la base de données.

=item à-outrance

Booléen, utilisé pour les entraînements. S'il est à C<True>, alors les avions ne peuvent pas
choisir 223 comme page intermédiaire. Il peut arriver toutefois qu'ils se retrouvent en
page finale 223, mais dans ce cas, les probabilités sont ajustées pour favoriser
l'attaque.

Exception : si toutes les manœuvres disponibles pointent vers la page intermédiaire 223,
alors on ne tient pas compte du paramètre C<à-outrance> pour ce coup et cet avion.
Cela ne peut pas arriver avec les avions standards de l'As des As et des jeux dérivés,
mais cela peut arriver avec les livrets personnalisés. Cela arrive notamment avec
le livret Epervier.

=head1 COPYRIGHT et LICENCE

Copyright (c) 2018, 2020, Jean Forget

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
