
while(my $line = <>){
my ($healthCode, @array) = split("\t", $line);
if($#array +1 > 2) { # require at least 3 datapoints
	my $m = median(@array);
	print "$healthCode\t$m\n";
}
}


sub median
{
    my @vals = sort {$a <=> $b} @_;
    my $len = @vals;
    if($len%2) #odd?
    {
        return $vals[int($len/2)];
    }
    else #even
    {
        return ($vals[int($len/2)-1] + $vals[int($len/2)])/2;
    }
}
