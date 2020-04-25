use List::Util;

# cols are inds
# create a hash_sleep_start {ind}{date}= start # this is way harder to get.
#create a hash_wake{ind}{date} = time

my %hash_wake;
my $codes=<>;
chomp($codes);
my @healthCodes = split("\t", $codes);
my $test;
my %dates;
while(my $line  = <>){
	chomp($line);
# for each date, save for each ind the first time you see any number besides 0, NA, or 1
	my @a = split("\t", $line);
	my @date = split('\ ', $a[0]);
	my $time = (60 * $a[4]) + $a[5] ; #in minutes 
	for (my $ind=6; $ind<15000; $ind++){
		my $name = "x" . $ind;
		if(!defined($hash_wake{$name}{$date[0]}) && $time > 180 &&  $a[$ind]ne "NA" &&  $a[$ind] != 0 && $a[$ind] !=1){
			$hash_wake{$name}{$date[0]} = $time;
			$dates{$date[0]} =1;
		}
	}
	$test = $date[0];
}

for my $k (keys %hash_wake){
# for each ind, average wake time and print with health code
	my @k_name = split('x',$k);
	print "$healthCodes[$k_name[1]]";
#	print "$k_name[1]\t";
	for my $kk (keys %dates){
		if(defined($hash_wake{$k}{$kk})){
			print "\t$hash_wake{$k}{$kk}";
		}
	}
	print "\n";
}


# use a sep script to look at dist and determine early vs not
