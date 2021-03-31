# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#     Page décrivant le coup d'un joueur lors d'une partie 
#     Webpage showing a player turn from the database
#     Copyright (C) 2021 Jean Forget, all rights reserved
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

unit package player-turn-page;

use Template::Anti :one-off;

my $label-attack ;
my $label-flee   ;
my $label-end    ;
my %label-tailed ;
my $label-tailing;

sub fill($at, :$lang, :$dh, :$game, :$turn-nb, :@turn4, :@similar, :$pilot) {
  my $player-turn;
  my $enemy-turn;
  my $next-turn;
  my $next-enemy-turn;
  for @turn4 -> $p-turn {
    if $p-turn<turn> == $turn-nb && $p-turn<identity> eq $pilot.identity {
      $player-turn = $p-turn;
    }
    if $p-turn<turn> == $turn-nb && $p-turn<identity> ne $pilot.identity {
      $enemy-turn = $p-turn;
    }
    if $p-turn<turn> != $turn-nb && $p-turn<identity> eq $pilot.identity {
      $next-turn = $p-turn;
    }
    if $p-turn<turn> != $turn-nb && $p-turn<identity> ne $pilot.identity {
      $next-enemy-turn = $p-turn;
    }
  }

  my $tr-choice     = $at.at('tr.choice-line');
  my $tr-criteria   = $at.at('tr.criteria-line');
  $label-attack     = ~ $at.at('span.attack');
  $label-flee       = ~ $at.at('span.flee');
  $label-end        = ~ $at.at('span.end');
  %label-tailed<L>  = ~ $at.at('span.left');
  %label-tailed<C>  = ~ $at.at('span.center');
  %label-tailed<R>  = ~ $at.at('span.right');
  $label-tailing    = ~ $at.at('span.tailing');

  $at('tbody.choice-table'  )».remove;
  $at('tbody.criteria-table')».remove;
  $at('p.dummy'             )».remove;

  my $start-page = $player-turn<page>;
  my $end-page   = $next-turn<page>;
  $start-page ~~ s/(<[LCR]>)/%label-tailed{$0}/;
  $end-page   ~~ s/<[LCR]>//;

  $at.at('a.redisplay'   ).attr(href => "http://localhost:3000/$lang/list/$dh");
  $at.at('a.current-game').attr(href => "http://localhost:3000/$lang/game/$dh");
  $at.('span.game'        )».content($dh);
  $at.('span.turn'        )».content($turn-nb);
  $at.('span.identity'    )».content($pilot.identity);
  $at.('span.enemy'       )».content($enemy-turn<identity>);
  $at.('span.maneuver'    )».content(translate-man(~ $player-turn<maneuver>));
  $at.('span.man-enemy'   )».content(translate-man(~  $enemy-turn<maneuver>));
  $at.('span.start-page'  )».content($start-page);
  $at.('span.end-page'    )».content($end-page);
  $at.('span.stiffness'   )».content($pilot.stiffness);
  $at.('span.perspicacity')».content($pilot.perspicacity);

  my $h0 = $player-turn<hits>;
  my $h2 =   $next-turn<hits>;
  $at.('span.hits0')».content($h0);
  $at.('span.hits1')».content($h0 - $h2);
  $at.('span.hits2')».content($h2);

  $h0 =      $enemy-turn<hits>;
  $h2 = $next-enemy-turn<hits>;
  $at.('span.hits0-enemy')».content($h0);
  $at.('span.hits1-enemy')».content($h0 - $h2);
  $at.('span.hits2-enemy')».content($h2);
}

sub translate-man(Str $maneuver --> Str) {
  given $maneuver {
    when 'Attack' { return $label-attack; }
    when 'Flee'   { return $label-flee;   }
    when 'End'    { return $label-end;    }
    default       { return $maneuver;     }
  }
}

our sub render(Str $lang, Str $dh, Int $turn-nb, $game, @turn4, @similar, $pilot --> Str) {
  #my $content = slurp("html/player-turn.$lang.html");
  my &filling = anti-template :source("html/player-turn.$lang.html".IO.slurp), &fill;
  return filling(lang => $lang, dh => $dh, game => $game, turn-nb => $turn-nb, turn4 => @turn4, similar => @similar, pilot => $pilot);
}

=begin POD

=encoding utf8

=head1 NOM

player-turn-page.rakumod -- displaying a player turn from the MongoDB base.

=head1 DESCRIPTION

This module merges an HTML model  file with the attributes of a player
turn for the Bailador-powered website.

=head1 COPYRIGHT and LICENSE

Copyright 2021, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
