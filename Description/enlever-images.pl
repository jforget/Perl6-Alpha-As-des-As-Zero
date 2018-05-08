#!/usr/bin/perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#     Enlever les images d'un fichier HTML
#     Remove the images from an HTML file
#     Copyright (C) 2017 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v5.10;
use strict;
use warnings;
use HTML::TokeParser;
use YAML qw/Dump/;
use experimental qw/switch/;

my ($fichier_e, $fichier_s) = @ARGV;
my $lexer = HTML::TokeParser->new($fichier_e);

open my $f, '>', $fichier_s
  or die "ouverture $fichier_s : $!";
while (my $t = $lexer->get_token) {
  given ($t->[0]) {
    when ('T') {
      print $f $t->[1];
    }
    when ('D') {
      print $f $t->[1];
    }
    when ('E') {
      print $f $t->[2];
    }
    when ('PI') {
      print $f $t->[2];
    }
    when ('S') {
      given (lc($t->[1])) {
        when ('img') {
          say $f "<p>IMAGE $t->[2]{alt} </p>";
        }
        default {
          print $f $t->[4];
        }
      }
    }
    default {
      say YAML::Dump($t)
    }
  }
}

close $f
  or die "fermeture $fichier_s : $!";
