# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#     Page décrivant une partie de la base de données, avec la liste des coups
#     Webpage showing a game from the database, with the list of turns
#     Copyright (C) 2021 Jean Forget, all rights reserved
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

unit package game-page;

use Template::Anti :one-off;

sub fill($at, :$lang, :$dh, :$game, :@list) {
  $at.('span.date-hour')».content($dh);

  my $tr-turn       = $at.at('tr.turn');
  my $label-attack  = $at.at('span.attack');
  my $label-flee    = $at.at('span.flee');
  my $label-end     = $at.at('span.end');
  my $label-left    = $at.at('span.left');
  my $label-center  = $at.at('span.center');
  my $label-right   = $at.at('span.right');
  my $label-tailing = $at.at('span.tailing');

  $at('tbody tr')».remove;
  $at('span.good')».content($game<good>);
  $at('span.bad' )».content($game<bad> );
  $at.at('a.redisplay').attr(href => "http://localhost:3000/$lang/list/$dh");

  # The collection Turns contains *player* turns, not *game* turns and
  # the "game" webpage displays *game* turns, not *player* turns.
  # So we must merge data from corresponding player turns to rebuild
  # the game turns. In addition, MongoDB does not sort the documents it retrieves.
  # (Or actually, I did not ask MongoDB to sort them). And the "Game" webpage
  # needs to display a sorted list of game turns. So, in addition to merging
  # two player turns into a game turn, the following loops executes a pigeonhole
  # sort. Pigeonhole sorting is very efficient, O(n), because it does not rely on
  # comparing two records. Each record is directly stored into its pigeonhole.
  my @game-turn = %( 'page2' => '', 'tail-g' => '', 'tail-b' => '' ) xx ($game<nb-turns> + 1);
  for @list -> $player-turn {
    my $turn-nb  = $player-turn<turn>;
    my $page     = $player-turn<page>;
    my $maneuver = $player-turn<maneuver>;

    given $maneuver {
      when 'Attack' { $maneuver = $label-attack; }
      when 'Flee'   { $maneuver = $label-flee;   }
      when 'End'    { $maneuver = $label-end;    }
    }
    if $page ~~ /<[LCR]>$/ {
      my $tail-friendly = $label-tailing;
      my $tail-enemy;
      given $page.substr(*-1, 1) {
        when 'L' { $tail-enemy = $label-left;   }
        when 'C' { $tail-enemy = $label-center; }
        when 'R' { $tail-enemy = $label-right;  }
      }
      if $player-turn<identity> eq $game<good> {
        @game-turn[$turn-nb]<tail-g> = $tail-friendly;
        @game-turn[$turn-nb]<tail-b> = $tail-enemy;
      }
      else {
        @game-turn[$turn-nb]<tail-b> = $tail-friendly;
        @game-turn[$turn-nb]<tail-g> = $tail-enemy;
      }
      $page = substr($page, 0, * -1);
    }
    @game-turn[$turn-nb    ]<page1> = $page;
    @game-turn[$turn-nb - 1]<page2> = $page;
    if $player-turn<identity> eq $game<good> {
      @game-turn[$turn-nb]<hits-g> = $player-turn<hits>;
      @game-turn[$turn-nb]<man-g>  = $maneuver;
    }
    else {
      @game-turn[$turn-nb]<hits-b> = $player-turn<hits>;
      @game-turn[$turn-nb]<man-b>  = $maneuver;
    }
    @game-turn[$turn-nb]<end> = $player-turn<end>;
  }

  for 1 .. $game<nb-turns> -> $n {
    my $game-turn = @game-turn[$n];
    my $target-turn = $n;
    if $game-turn<end> {
      -- $target-turn;
    }
    my $line = $tr-turn;
    $line.at('td.turn-number').content($n);
    $line.at('td.begin-page' ).content($game-turn<page1>);
    $line.at('td.hits-g'     ).content($game-turn<hits-g>);
    $line.at('td.hits-b'     ).content($game-turn<hits-b>);
    $line.at('a.man-g'       ).content($game-turn<tail-g> ~ ' ' ~ $game-turn<man-g>);
    $line.at('a.man-b'       ).content($game-turn<tail-b> ~ ' ' ~ $game-turn<man-b>);
    $line.at('td.end-page'   ).content($game-turn<page2>);
    $line.at('a.man-g').attr(href => "http://localhost:3000/$lang/turn/$dh/$target-turn/$game<good>");
    $line.at('a.man-b').attr(href => "http://localhost:3000/$lang/turn/$dh/$target-turn/$game<bad>");
    $at.at('tbody').append-content("$line\n");
  }
}

our sub render(Str $lang, Str $dh, $game, @list --> Str) {
  #my $content = slurp("html/game.$lang.html");
  my &filling = anti-template :source("html/game.$lang.html".IO.slurp), &fill;
  return filling(lang => $lang, dh => $dh, game => $game, list => @list);
}

=begin POD

=encoding utf8

=head1 NOM

game-page.rakumod -- displaying a game from the MongoDB base.

=head1 DESCRIPTION

This module  merges an HTML model  file with the attributes  of a game
and with the list of game turns, for the Bailador-powered website.

=head1 COPYRIGHT and LICENSE

Copyright 2021, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
