python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKCategoryTypeIdentifierSleepAnalysis >> devices
echo "sleep" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierBloodPressureDiastolic >> devices 
echo "bpdis" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierBloodPressureSystolic >> devices 
echo "bpsyst" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierBodyMass >> devices 
echo "bmass" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierDistanceCycling >> devices 
echo "distance cycling" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierDistanceWalkingRunning >> devices 
echo "distance walking running" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierFlightsClimbed >> devices 
echo "flights" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierHeartRate >> devices
echo "hr" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierHeight >> devices
echo "height" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierOxygenSaturation >> devices 

echo "oxygen" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierStepCount >> devices
echo "steps" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKWorkoutTypeIdentifier >> devices 
echo "type" 
python get_last_column.py ~/myheart/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierBloodGlucose >> devices
echo "glucose" 
