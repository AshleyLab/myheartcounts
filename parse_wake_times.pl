
my %hash;
while(my $line = <>){

	chomp($line);
	my @a = split("\t",$line);
	my $s;
	for (my $i =1; $i<=$#a; $i++){
		$s+=$a[$i];	
	}
	
	my $time;
	if($#a!=0){
		$time = $s/$#a;
	#dropping anything with no data.
	$hash{$a[0]}=$time;
	}
}
for my $k (keys %hash){
	print "$k\t$hash{$k}\n";
}
