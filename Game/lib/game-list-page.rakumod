
unit package game-list-page;

our sub render(Str $lang, Str $dh, @list --> Str) {
  my $content = slurp("html/list-of-games.$lang.html");
  return $content;
}
