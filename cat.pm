#!/usr/bin/perl -w


package cat;
use Exporter;

@ISA=('Exporter');
@EXPORT=('hello');

sub hello{
  print "Hello\n";
}

sub perlcat{
 FILE:foreach(@_){
    open(FILE, $_) or ((warn "Can't open file $_\n"), next FILE);
    while(<FILE>){
      print;
    }
    close(FILE);
  }
}
1;
