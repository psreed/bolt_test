# Test plan

plan bolt_test::package_test (
  TargetSpec $targets,
  String $package = 'wget',
) {

  # Run apply_prep on targets to install the Puppet Agent
  # This will not activate the Puppet agent server or pxp_agent service if it's already installed
  # This will not modify any current Puppet Agent configuration if it's already present.
  # Allows us to gather facts and run Puppet "apply" blocks directly from this plan.
  $targets.apply_prep

  $results = apply($targets) {

    if ($facts['kernel']=='Linux') {

      package { $package:
        ensure => 'installed',
      }

    }

  }

#  out::message($results)


}
