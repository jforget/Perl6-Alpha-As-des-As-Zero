#!/home/jf/rakudo-star-2018.01/bin/perl6 -I.
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Programme mettant à jour la cartographie de l'As des As
#     Program updating the partial map of Ace of Aces
#     Copyright (C) 2018 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib '.';
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use Depl;

my MongoDB::Client     $client     .= new(:uri('mongodb://'));
my MongoDB::Database   $database    = $client.database('aoa_prep');
my MongoDB::Collection $pages       = $database.collection('Pages');
my MongoDB::Collection $manoeuvres  = $database.collection('Manoeuvres');

my @cache;            # cache des documents-pages indexés par numéro
my %numéro_de_chemin; # cache des numéros de page par chemin GM
my @action;           # action (CRUD) effectuée sur chaque page
my %chemin_mnv;       # table des chemins de manœuvre indexée par le code de manœuvre
my $recalc = 0;       # indicateur pour recalculer tous les enchaînements

my %opt;
for @*ARGS -> $arg {
  if $arg ~~ /\- (page) \= (\d+) / {
    %opt<page> = 0 + $1;
  }
  elsif $arg ~~ /\- (\w) \= (\d+) / {
    %opt{$0.uc} = 0 + $1;
  }
  elsif $arg eq '-recalc' {
    $recalc = 1;
  }
  else {
    die "Erreur avec l'option ", $arg;
  }
}

my $page_début = + %opt<page>;
if $page_début == 223 {
  die "Impossible de mettre à jour la page 223";
} 

unless page_existe($page_début) {
  die "Page $page_début inconnue";
}

my $opt_trace = %opt<T> // 0;


my MongoDB::Cursor $cursor = $manoeuvres.find(
  projection => ( _id => 0, )
);
while $cursor.fetch -> BSON::Document $d {
  %chemin_mnv{$d<code>} = $d<chemin>;
}
$cursor.kill;
my @codes_man = %chemin_mnv.keys.sort;

my BSON::Document $départ = recherche_page($page_début);
my Str $chemin_d = $départ<chemin_GM>;

my BSON::Document $req;
my BSON::Document $doc;

for @codes_man -> $manv {
  my $arrivée = %opt{$manv};
  next unless $arrivée;

  my $ancien = @cache[$page_début]{$manv}<numero>;
  $ancien //= 0;
  if $ancien && $ancien ≠ $arrivée {
    say "+++++ Incohérence $page_début $manv -> $ancien ou $arrivée ?";
    @action[$page_début] = 'E';
    next;
  }

  if $ancien == 0 or @cache[$page_début]{$manv}<certain> ≠ 2 {
    @action[$page_début] = 'U';
    @cache[ $page_début]{$manv} =  ( certain => 2, numero => $arrivée );
  }
  if page_existe($arrivée) == 0 {
    my Depl $départ .= new(chemin => $chemin_d);
    my Depl $mouvmt .= new(chemin => %chemin_mnv{$manv});
    my Depl $arriv = $départ → $mouvmt;
    if $opt_trace +& 2 {
      say "création de $arrivée ", $chemin_d, ' → ', %chemin_mnv{$manv}, " = ", $arriv.chemin;
    }
    my BSON::Document $page .= new( (
                    numero    => $arrivée,
                    chemin_GM => $arriv.chemin,
                    chemin_MG => $arriv.arriere.chemin,
                    ));
    @cache[ $arrivée] = $page;
    @action[$arrivée] = 'C';
    %numéro_de_chemin{$arriv.chemin} = $arrivée;
  }
}

# Ajouter les enchaînements que l'on peut deviner
for 1..222 -> $pg {
  if 'C' eq (@action[$pg] // '') {
    my BSON::Document $page_départ = @cache[$pg];
    for @codes_man -> $manv {
      my Depl $départ .= new(chemin => $page_départ<chemin_GM>);
      my Depl $mouvmt .= new(chemin => %chemin_mnv{$manv});
      my Depl $arriv   = $départ → $mouvmt;
      my $pg_arr = recherche_chemin_GM($arriv.chemin);
      if $opt_trace +& 8 {
        say "$pg → $manv → $pg_arr";
      }
      if $pg_arr ≠ 0 and (@cache[$pg]{$manv}<numero> // 0) == 0 {
        @cache[$pg]{$manv} = ( certain=> 1, numero => $pg_arr );
      }
    }
  }
}

for 1..222 -> $pg_arr {
  if 'C' eq (@action[$pg_arr] // '') {
    my BSON::Document $page_arrivée = @cache[$pg_arr];
    for @codes_man -> $manv {
      my Depl $arriv  .= new(chemin => $page_arrivée<chemin_GM>);
      my Depl $mouvmt .= new(chemin => %chemin_mnv{$manv});
      my Depl $départ  = $arriv ← $mouvmt;
      my $pg_dep = recherche_chemin_GM($départ.chemin);
      if $opt_trace +& 8 {
        say "$pg_arr ← $manv ← $pg_dep";
      }
      if $pg_dep ≠ 0 and (@cache[$pg_dep]{$manv}<numero> // 0) == 0 {
        @cache[$pg_dep]{$manv} = ( certain=> 1, numero => $pg_arr );
      }
    }
  }
}

if $opt_trace +& 4 {
  say @cache.perl;
  say %numéro_de_chemin;
  for 1..@action.elems -> $i {
    if @action[$i] {
      print "$i -> @action[$i], ";
    }
  }
  say '';
}

# Mise à jour de la base de données, maintenant que l'on a tout calculé
for 1..222 -> $pg {
  given @action[$pg] {
    when 'C' {
      my BSON::Document $req .= new: (
        insert    => 'Pages',
        documents => [ @cache[$pg], ],
        );
      my BSON::Document $result = $database.run-command($req);
      say "Création page $pg ok : ", $result<ok>, " nb : ", $result<n>;
    }
    when 'U' {
      my BSON::Document $req .= new: (
        update => 'Pages',
        updates => [ (
            q => ( numero => $pg,),
            u => ( @cache[$pg] ),
         ),
       ],
      );
      my BSON::Document $doc = $database.run-command($req);
      say "update page $pg ok : ", $doc<ok>, " nb : ", $doc<n>;
    }
  }
}
exit;


sub page_existe(Int $n) {

  # recherche en cache
  if @cache[$n] {
    return 1;
  }

  # recherche en base de données
  my MongoDB::Cursor $cursor = $pages.find(
    criteria   => ( numero => $n, ),
    projection => ( _id => 0, )
  );
  my $ok = 0;
  while $cursor.fetch -> BSON::Document $d {
    #say $d<numero>;
    if $d<numero> == $n {
      $ok = 1;
      last;
    }
  }
  $cursor.kill;

  return $ok;
}

sub recherche_page(Int $n) {
  my $ok = @cache[$n];

  unless $ok {
    my MongoDB::Cursor $cursor = $pages.find(
      criteria   => ( numero => $n, ),
      projection => ( _id => 0, )
    );
    while $cursor.fetch -> BSON::Document $d {
      #say $d<numero>;
      if $d<numero> == $n {
        $ok         = $d;
        @cache[$n]  = $d;
        @action[$n] = 'R';
        %numéro_de_chemin{$d<chemin_GM>} = $n;
        last;
      }
    }
    $cursor.kill;
  }

  return $ok;
}

sub recherche_chemin_GM(Str $chemin) {
  if $chemin.chars >= 6 {
    # quatre hexagones ou plus, plus le point-virgule et le changement d'orientation
    return 223;
  }
  my $numero = %numéro_de_chemin{$chemin} // 0;
  unless $numero {
    my MongoDB::Cursor $cursor = $pages.find(
      criteria   => ( chemin_GM => $chemin, ),
      projection => ( _id => 0, )
    );
    while $cursor.fetch -> BSON::Document $d {
      if $d<chemin_GM> eq $chemin {
        $numero = $d<numero>;
        last;
      }
    }
    $cursor.kill;
  }

  return $numero;
}

#
# Reconstituer la chaîne du chemin à partir de son histogramme
#
sub rec_chemin(@av, $vir) {
  my $av = [~] map { $_.Str x @av[$_] }, 0..5;
  return "$av;$vir";
}



=begin POD

=encoding utf8

=head1 NOM

maj.p6 -- programme mettant à jour la cartographie de l'As des As

=head1 DESCRIPTION

Ce programme met à jour la cartographie de l'As des As en spécifiant pour une page
existante quelles sont les pages que l'on peut rejoindre en appliquant les diverses
manœuvres.

=head1 LANCEMENT

  perl6 maj.p6 -page=n -a=n -b=n ...

=head2 Paramètres

=head3 page

Donne le numéro de la page de départ des manœuvres. Cette page doit exister
dans la base de données et, bien sûr, il ne peut s'agir de la page 223.

=head3 a, b, c, etc

Sous la forme C<->I<manœuvre>C<=>I<numéro>, par exemple C<-a=123>, donne l'association
entre une manœuvre et la page d'arrivée. Dans l'exemple ci-dessus, la maœuvre A fait
aboutif à la page 123.

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
