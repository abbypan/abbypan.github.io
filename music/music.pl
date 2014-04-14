#!/usr/bin/perl
use File::Slurp qw/slurp/;
use Template;

system("perl ../../github/baidu_music/baidu_music.pl -i music_id.txt -t online -f mp3 -o music.json");
my $c = slurp('music.json');
my $tt = Template->new();
$tt->process('music.tt2', { data => $c }, 'music.html'); 
unlink('music.json');
