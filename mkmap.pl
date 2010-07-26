#!/usr/bin/perl

# generated from http://openstreetmap.gryph.de/bigmap.cgi/
# permalink for this map: http://openstreetmap.gryph.de/bigmap.cgi?xmin=78924&xmax=78937&ymin=66010&ymax=66017&zoom=17&scale=256&baseurl=http%3A%2F%2Fb.tile.openstreetmap.org
#
use strict;
use LWP;
use GD;

my $img = GD::Image->new(3584, 2048, 1);
my $white = $img->colorAllocate(248,248,248);
$img->filledRectangle(0,0,3584,2048,$white);
my $ua = LWP::UserAgent->new();
$ua->env_proxy;
for (my $x=0;$x<14;$x++)
{
    for (my $y=0;$y<8;$y++)
    {
        foreach my $base(split(/\|/, "http://b.tile.openstreetmap.org"))
	{
		my $url = sprintf("%s/17/%d/%d.png", $base,
		    $x+78924,$y+66010);
		print STDERR "$url... ";
		my $resp = $ua->get($url);
		print STDERR $resp->status_line;
		print STDERR "\n";
		next unless $resp->is_success;
		my $tile = GD::Image->new($resp->content);
		next if ($tile->width == 1);
		$img->copy($tile, $x*256,$y*256,0,0,256,256);
	}
    }
}
binmode STDOUT;
print $img->png();
