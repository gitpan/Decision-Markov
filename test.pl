# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use Decision::Markov;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use FileHandle;
no strict;

print STDOUT "Creating a model...\n";
$model = new Decision::Markov;
print ref($model) ? "ok 2" : "not ok 2";
print "\n";
print STDOUT "Creating some states...\n";
$well = $model->AddState("Well", 1);
$disabled = $model->AddState("Disabled", .5);
$dead = $model->AddState("Dead", 0);
print ((ref($well) and ref($disabled) and ref($dead)) ? "ok 3" : "not ok 3");
print "\n";
print STDOUT "Creating transitions...\n";
$error = $model->AddPath($well,$disabled,.2);
$error = $model->AddPath($well,$dead,.05) || $error;
$error = $model->AddPath($well,$well,.75) || $error;
$error = $model->AddPath($disabled,$dead,.25) || $error; 
$error = $model->AddPath($disabled,$disabled,.75) || $error;
$error = $model->AddPath($dead,$dead,1) || $error;
print $error ? "not ok 4" : "ok 4";
print "\n";
print STDOUT "Trying a redundant transition...\n";
$error = $model->AddPath($well,$disabled,.7);
print $error ? "ok 5\n" : "not ok 5\n";

print STDOUT "Checking the model...\n";
$error = $model->Check;
print $error ? "not ok 6" : "ok 6";
print "\n";

#$stderr = new FileHandle ">&STDOUT";
#die "$!" unless defined ($stderr);

#$model->PrintMatrix($stderr);
print STDOUT "Testing cohort simulation...\n";
$model->Reset($well,1000);
$patients_left = $model->PatientsLeft;
$cycle = 0;
#$model->PrintCycle($stderr,$cycle);
while ($patients_left) {
  $patients_left = $model->EvalCohStep($cycle);
  $cycle++;
  #$model->PrintCycle($stderr,$cycle);
}
$avg_util_cohort = $model->CumUtility / 1000;
#$stderr->print($avg_util_cohort);
#$stderr->print("\n");
print ((abs($avg_util_cohort - 5.096) < .001) ? "ok 7" : "not ok 7");
print "\n";

print STDOUT "Testing monte carlo simulation...\n";
$numruns = 2;
foreach (1..$numruns) {
  $model->Reset($well);
  $cycle = 0;
  #$model->PrintCycle($stderr,$cycle);
  $state = $model->CurrentState;
  while (not $state->FinalState) {
    $state = $model->EvalMCStep($cycle);
    $cycle++;
    #$model->PrintCycle($stderr,$cycle);
  }
  $avg_util_mc += $model->CumUtility;
}
$avg_util_mc /= $numruns;
print "ok 8";
print "\n";
