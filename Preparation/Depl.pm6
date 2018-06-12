#!/home/jf/rakudo-star-2018.01/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-

#
# Reconstituer la chaîne du chemin à partir de son histogramme
#
sub rec_chemin(@av, $vir) {
  my $av = [~] map { $_.Str x @av[$_] }, 0..5;
  return "$av;$vir";
}

class Depl {
  has $.chemin;
  has @.avance;
  has $.virage;

  submethod BUILD(:$chemin) {
    $!chemin = $chemin;
    $chemin ~~ /^ (\d*) \; (\d) $/;
    my ($depl, $virage) = ($0, $1);
    $!virage = $virage.Int;
    my @avance = (0) xx 6;
    for $depl.comb -> $x {
      @avance[$x]++;
    }
    @!avance = @avance;
  }

  method dump {
    my @avance = @.avance;
    my $avance = @avance.perl;
    say "Chemin = $.chemin, avance = $avance, virage = $.virage";
  }

  method suit(Depl $depl2, Int $opt_trace) {
    my $vir1 = $.virage;                      # virage du premier déplacement
    my @av1  = @.avance;                      # avance du premier déplacement
    my @av2  = $depl2.avance;                 # avance du second déplacement
    my @avt  = @av1 «+» @av2.rotate(6-$vir1); # avance du déplacement total
    my $virt = ($vir1 + $depl2.virage) % 6;   # virage du déplacement total

    # débug
    if $opt_trace +& 1 {
      say join ' ', $.chemin, '+', $depl2.chemin;
      say join ' ', '@av1', @av1.perl;
      say join ' ', '@av2', @av2.perl, '$vir1', $vir1.perl, '@av2 rot', @av2.rotate(6-$vir1).perl;
      say join ' ', '@avt', @avt.perl;
      say rec_chemin(@avt, ($vir1 + $depl2.virage) % 6);
    }

    # normalisation
    my $maj = 1;
    while $maj {
      $maj = 0;
      my @ar = @avt «min» @avt.rotate(3);
      my $debug_msg = join ' ', 'elim 180 ', '@avt', @avt, '@ar', @ar;
      @avt «-=» @ar;
      if $opt_trace +& 2 {
        say join ' ', $debug_msg, '@avt', @avt;
      }
      for 0..5 -> $v {
        for 1,5 -> $dv {
          my $v_a = ($v +     $dv) % 6;
          my $v_d = ($v + 2 × $dv) % 6;
          if 0 < @avt[$v] ≤ @avt[$v_d] {
            @avt[$v_d] -= @avt[$v];
            @avt[$v_a] += @avt[$v];
            @avt[$v]    = 0;
            $maj = 1;
            if $opt_trace +& 4 {
              say  'elim 120 ', @avt, ' ', rec_chemin(@avt, $virt);
            }
          }
        }
      }
    }
    my $chemint = rec_chemin(@avt, $virt);
    if $opt_trace +& 1 {
      say $chemint;
    }
    return Depl.new(chemin => $chemint);
  }

  method arriere {
    my @avance = @.avance;
    my $virage = $.virage;
    my $chemin = rec_chemin(@avance.rotate(3 + $virage), (6 - $virage) % 6);
    return Depl.new(chemin => $chemin);
  }

}

sub infix:<→> (Depl $dep1, Depl $dep2) is export {
  $dep1.suit($dep2, 0);
}

sub infix:<←> (Depl $dep1, Depl $dep2) is export {
  $dep1.suit($dep2.arriere, 0);
}


=begin POD

=encoding utf8

=head1 NOM

Depl.pm6 -- module définissant un déplacement dans une grille hexagonale.

=head1 DESCRIPTION

Ce programme permet de représenter un déplacement d'avion dans la grille hexagonale
de l'As des As ou bien la position relative de deux avions dans cette grille.

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
