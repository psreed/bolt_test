# Test plan

plan bolt_test::test (
  TargetSpec $targets,
  String $testmessage = 'Hello, This is the default test message.',
  Boolean $run_w32time_task = true,
  Boolean $run_apply_block = false,
) {

  # Run apply_prep on targets to install the Puppet Agent
  # This will not activate the Puppet agent server or pxp_agent service if it's already installed
  # This will not modify any current Puppet Agent configuration if it's already present.
  # Allows us to gather facts and run Puppet "apply" blocks directly from this plan.
  $targets.apply_prep

  # Using the facts from the apply_prep, we create a sub-group that has only our windows nodes
  $targets_windows = get_targets($targets).group_by |$target| { $target.facts['kernel'] }['windows']

  # We can also run commands/tasks/other plans against the node we are running bolt on to gather data
  # to be used in the rest of the plan.
  # testmessage can be changed by adding "testmessage='The new message'" to the bolt command line
  $result_set=run_command("echo \'${testmessage}\'",localhost)

  # Since we are running on only 1 target, there is only 1 ResultSet, $results_set[0] is the actual Result object.
  # Bolt data type reference is located here: https://puppet.com/docs/bolt/latest/bolt_types_reference.html
  # Using 'rstrip' puppet function to remove newline character
  out::message("Output    : '${rstrip($result_set[0].value['stdout'])}'")
  out::message("Error     : '${result_set[0].value['stderr']}'")
  out::message("Exit Code : '${result_set[0].value['exit_code']}'")

  # This simply runs a task on our Windows sub-group and outputs the result for each node.
  # Task checks the W32Time service status.
  if $run_w32time_task {

    $result_set2=run_task('bolt_test::w32time',$targets_windows)

    $result_set2.each |Result $result| {
      # Using 'rstrip' puppet function to remove newline character
      out::message("W32Time - Node: '${result.target.name}', Status: '${rstrip($result.message)}'")
    }

  }

  # This runs a Puppet "apply" block on all targets.
  if $run_apply_block {

    $results = apply($targets) {
      if ($facts['kernel']=='Linux') {
        notice("I am a Linux box: ${facts['hostname']}")
      }
    }
    return $results
  }

}
