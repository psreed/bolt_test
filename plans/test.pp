# Test plan

plan bolt_test::test (
  TargetSpec $targets,
  String $testmessage = 'Hello',
) {

  $targets.apply_prep

  $targets_windows = get_targets($targets).group_by |$target| { $target.facts['kernel'] }['windows']

  run_command('echo "Testing"',localhost)

  run_task('bolt_test::w32time',$targets_windows)

  apply($targets) {

    if $facts['kernel']=='Linux' {
      out::message("I am a Linux box: ${facts['hostname']}")
    }

  }

}
