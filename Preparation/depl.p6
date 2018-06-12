#!/home/jf/rakudo-star-2018.01/bin/perl6 -I.
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Programme de test pour le module Depl.pm6
#     Test program for Depl.pm6 module
#     Copyright (C) 2018 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib '.';
use Depl;

my Depl $depl;
my Depl $dep2;
my Depl $dep3;

$depl .= new(chemin => '00;1');
say $depl.perl;
$depl.dump;
$dep2.= new(chemin => '1;1');
$dep2.dump;
$depl.suit($dep2, 127);

$depl .= new(chemin => '02;0');
$dep2 .= new(chemin => '4;0');
say $depl.perl;
say $depl.suit($dep2, 127);
say $dep2.suit($depl, 127);

$depl .= new(chemin => '01;1');
$dep2 .= new(chemin => '1;1');
say $depl.suit($dep2, 127);
say $dep2.suit($depl, 127);

$depl .= new(chemin => '05;1');
$dep2 .= new(chemin => '0;1');
say $depl.suit($dep2, 127);
$dep3 = $depl → $dep2;
say join ' ', $depl.chemin, '→', $dep2.chemin, '=', $dep3.chemin;
say $dep2.suit($depl, 127);
say join ' ', $dep2.chemin, '→', $depl.chemin, '=', ($dep2 → $depl).chemin;
say join ' ', $dep2.chemin, '←', $depl.chemin, '=', ($dep2 ← $depl).chemin;

say $depl.perl, " ", $depl.arriere.perl;
say $dep2.perl, ' ', $dep2.arriere.perl;

$dep3 .= new(chemin => '2;1');
say $dep3.perl, ' ', $dep3.arriere.perl;
#say $depl;
#say $dep3;
#say $depl.suit($dep3);
#say $dep3.suit($depl);


=begin POD

=encoding utf8

=head1 NOM

depl.p6 -- programme testant le module Depl.pm6

=head1 DESCRIPTION

Ce programme contient les tests unitaires pour le module F<Depl.pm6>.

=head1 LANCEMENT

  perl6 depl.p6

=head2 Paramètres

Aucun paramètre

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
