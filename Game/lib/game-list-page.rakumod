# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#     Accès à MongoDB pour l'As des As
#     Access to the Ace of Aces MongoDB database
#     Copyright (C) 2018, 2020, 2021 Jean Forget, all rights reserved
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

unit package game-list-page;

use Template::Anti :one-off;

sub fill($at, :$dh, :@list) {
  if $dh ne '' {
    my $criterion = $at.at('span.criterion');
    $criterion.content($dh);
  }
  else {
    $at('p.with-criterion')».remove;
  }
}

our sub render(Str $lang, Str $dh, @list --> Str) {
  #my $content = slurp("html/list-of-games.$lang.html");
  my &filling = anti-template :source("html/list-of-games.$lang.html".IO.slurp), &fill;
  return filling(dh => $dh, list => @list);
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
