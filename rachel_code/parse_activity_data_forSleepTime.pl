# parse data, time
# determine the first or last time of motion to establish wake or sleep time
# for sleep, files must be read in upside down

#to run: cat $healthcodeID/t.tsv |  perl parse_activity_data_forSleepTime.pl $healthcodeID  1 > $file.out
#to run: tac $healthcodeID/t.tsv |  perl parse_activity_data_forSleepTime.pl $healthcodeID  2 > $file.out
# 1 == wake up
# # 2 == bed time
#

my $method = $ARGV[2];
my $filename = $ARGV[1];

open my $fh, "<", $filename;
print $ARGV[0]; # healthcode
my $old_date=0;
while(my $line = <$fh>){
my @a = split("\t", $line);
my @date = parseDate(@a);
my $activityType = $a[2];
if ($date[0] != $old_date){
        if ($activityType > 1 ){ # 0 is unknown, 1 is stationary
                if ( ($method == 1 && $date[1] > 210) || $method == 2){ # greater than 3:30
                        print "\t$date[1]";
                        $old_date = $date[0];
                }
        }
}
}
print "\n";






sub parseDate {
	my @dateCol = @_;
	my @dateTime = split("T", $dateCol[0]);

	my @d = split("\-", $dateTime[0]);
	my $date = $d[1] . "." . $d[2];

	my @t =split(":", $dateTime[1]);
	my $time = $t[0]*60 + $t[1]; # time in minutes

	my @dateArray = ($date, $time);
	return @dateArray;	
}
