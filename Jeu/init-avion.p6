#!/home/jf/rakudo-star-2018.01/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Insertion d'un nouvel avion dans la base MongoDB
#     Creating a new aircraft into the MongoDB database
#     Copyright (C) 2020 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use BSON::Document;
#use MongoDB::Client;
#use MongoDB::Database;
#use MongoDB::Collection;
use JSON::Class;
use acces-mongodb;


class Avion does JSON::Class {
  has     $.identité;
  has     $.nom;
  has     $.camp;
  has     @.pages;
  has     $.manoeuvres;
  has Int $.capacité;
}


sub MAIN (Str :$identité) {
  my Str $json = slurp "$identité.json";
  my Avion $avion .= from-json($json);
  my BSON::Document $doc .= new: (
       identité        => $avion.identité,
       nom             => $avion.nom,
       camp            => $avion.camp,
       capacité        => $avion.capacité,
       json            => $json,
       );
  acces-mongodb::écrire-avion($doc);
}

=begin POD

=encoding utf8

=head1 NOM

init-avion.p6 -- chargement d'un avion dans la base MongoDB

=head1 DESCRIPTION

Ce programme recopie  un fichier JSON décrivant un avion  dans la base
MongoDB, de  façon à simplifier  les programmes ultérieurs,  qui n'ont
plus besoin de lire le fichier JSON.

=head1 LANCEMENT

  perl6 init-avion.p6 --identité=Drone

=head2 Paramètre

=item identité

Nom  de  l'avion  simulé,  associé  à  un  fichier  JSON  donnant  les
caractéristiques de cet avion.

=head1 COPYRIGHT et LICENCE

Copyright 2020, Jean Forget

Ce programme est  diffusé avec les mêmes conditions que  Perl 5.16.3 :
la licence  publique GPL version 1  ou ultérieure, ou bien  la licence
artistique Perl.

Vous pouvez trouver le texte en anglais de ces licences dans le
fichier <LICENSE> joint ou bien aux adresses
L<http://www.perlfoundation.org/artistic_license_1_0>
et L<http://www.gnu.org/licenses/gpl-1.0.html>.

Résumé en anglais de la GPL :

This program is  free software; you can redistribute  it and/or modify
it under the  terms of the GNU General Public  License as published by
the Free  Software Foundation; either  version 1, or (at  your option)
any later version.

This program  is distributed in the  hope that it will  be useful, but
WITHOUT   ANY  WARRANTY;   without  even   the  implied   warranty  of
MERCHANTABILITY  or FITNESS  FOR  A PARTICULAR  PURPOSE.  See the  GNU
General Public License for more details.

You should  have received  a copy  of the  GNU General  Public License
along  with  this  program;  if   not,  write  to  the  Free  Software
Foundation, Inc., L<http://www.fsf.org/>.

=end POD
