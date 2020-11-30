#!/home/jf/rakudo/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Serveur web permettant de consulter la base MongoDB des parties de l'As des As
#     Web server to display the MongoDB database where Ace of Aces games are stored
#     Copyright (C) 2018, 2020 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6.c;
use lib 'lib';
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use JSON::Class;
use Bailador;

use acces-mongodb;
use site-liste-parties;
use site-partie;
use site-coup;
use Pilote;

get '/' => sub {
  my @liste = acces-mongodb::liste-parties('');
  return site-liste-parties::affichage('', @liste);
}

get '/liste/:dh' => sub ($dh) {
  my @liste = acces-mongodb::liste-parties(~ $dh);
  return site-liste-parties::affichage($dh, @liste);
}

get '/partie/:dh' => sub ($dh) {
  my $partie = acces-mongodb::partie(~ $dh);
  my @coups  = acces-mongodb::coups-parties(~ $dh);
  return site-partie::affichage($dh, $partie, @coups);
}

get '/coup/:dh/:num/:id' => sub ($dh, $num, $id) {
  my BSON::Document $partie  = acces-mongodb::partie(~ $dh);
  my BSON::Document $doc-p   = acces-mongodb::pilote(~ $id);
  my Pilote         $pilote .= from-json($doc-p<json>);
  my @coup4  = acces-mongodb::coup4(~ $dh, + $num, ~ $id);
  my $page;
  for @coup4 -> BSON::Document $coup {
    if $coup<tour> == $num &&$coup<identité> eq $id {
      $page = $coup<page>;
      last;
    }
  }
  my @similaires; # coups similaires, à partir de la même page
  my @id = ~ $id;
  if $id ne $partie<avion_g> && $id ne $partie<avion_m> {
    if $id eq $partie<gentil> {
      @id.push($partie<avion_g>);
    }
    if $id eq $partie<méchant> {
      @id.push($partie<avion_m>);
    }
  }
  @similaires = acces-mongodb::coups-page(~ $page, @id, ~ $dh);
  return site-coup::affichage(~ $dh, + $num, ~ $id, $partie, @coup4, @similaires, $pilote);
}

baile();


=begin POD

=encoding utf8

=head1 NOM

site.p6 -- serveur web permettant de consulter la base de données des parties de l'As des As

=head1 DESCRIPTION

Ce programme anime un site web permettant de consulter les parties de l'As des As.

=head1 LANCEMENT

Sur un xterm :

  perl6 site.p6

Sur un navigateur web

  http://localhost:3000

Arrêter le serveur  en tapant Ctrl-C sur le xterm où il a été lancé.

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
