# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#     Page donnant la liste des parties de la base de données.
#     Webpage giving the list of games from the database
#     Copyright (C) 2021 Jean Forget, all rights reserved
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

unit package game-list-page;

use Template::Anti :one-off;

sub fill($at, :$lang, :$dh, :@list) {
  if $dh ne '' {
    my $criterion = $at.at('span.criterion');
    $criterion.content($dh);
  }
  else {
    $at('p.with-criterion')».remove;
  }
  my $li-draw = $at.at('ul.games li.draw');
  my $li-flee = $at.at('ul.games li.flee');
  my $li-shot = $at.at('ul.games li.shot');

  $at('ul.games li')».remove;
  for @list -> $game {
    my $line;
    if $game<vp-g>.abs == 1 {
      $line = $li-shot;
    }
    elsif $game<vp-g>.abs == 0.5 {
      $line = $li-flee;
    }
    else {
      $line = $li-draw;
    }
    my $loser  = $game<vp-g> < $game<vp-b> ?? $game<good> !! $game<bad>;
    my $winner = $game<vp-g> > $game<vp-b> ?? $game<good> !! $game<bad>;

    my $a = $line.at('a');
    $a.content($game<dh-begin>);
    $a.attr(href => "http://localhost:3000/$lang/list/$game<dh-begin>");

    $line.(  'span.good'    )».content($game<good>);
    $line.(  'span.bad'     )».content($game<bad>);
    $line.at('span.nb-turns' ).content($game<nb-turns>);
    $line.at('span.winner'   ).content($winner);
    $line.at('span.loser'    ).content($loser);
    $line.at('span.hits-g'   ).content($game<hits-g>);
    $line.at('span.hits-b'   ).content($game<hits-b>);

    $at.at('ul.games').append-content("$line\n");
  }
}

our sub render(Str $lang, Str $dh, @list --> Str) {
  #my $content = slurp("html/list-of-games.$lang.html");
  my &filling = anti-template :source("html/list-of-games.$lang.html".IO.slurp), &fill;
  return filling(lang => $lang, dh => $dh, list => @list);
}

=begin POD

=encoding utf8

=head1 NOM

game-list-page.rakumod -- displaying the list of games from the MongoDB base.

=head1 DESCRIPTION

This module merges an HTML model file with a list of games, to display
this list of games in the Bailador-powered website.

=head1 COPYRIGHT and LICENSE

Copyright 2021, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
