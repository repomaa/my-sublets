# Example rules file

BatteryRule.new(:charging) do |r|
  # set the state to either :charging or :discharging. Obligatory value
  r.state = :charging
  # run_once sets the rule to trigger only once or until it is reactivated again by another rule
  r.run_once
  # define a ruby block to be called when the rule is triggered
  r.task do
    # notify calls the program notify-send on the machine
    notify("Battery charging")
    # enable_all enables all rules for which the given block evaluates as true
    enable_all {|rule| rule.state == :discharging}
  end
end

BatteryRule.new(:discharging) do |r|
  r.state = :discharging
  r.run_once
  r.task do
    notify("Battery discharging")
    enable_all {|rule| rule.state == :charging }
  end
end

BatteryRule.new(:full) do |r|
  r.state = :charging
  # trigger_at sets the rule to trigger at a certain percentage
  r.trigger_at 100
  r.run_once
  r.task do
    notify("Battery fully charged")
  end
end

BatteryRule.new(:low) do |r|
  r.state = :discharging
  # trigger_at also takes ranges. If nothing is set (like in :discharging or :charging above)
  # the default value 0..100 will be set
  r.trigger_at 6..10
  r.run_once
  r.task do |percent|
    notify("Battery is running low (#{percent}% left)\nBetter start looking for a power outlet.")
  end
end

BatteryRule.new(:critical) do |r|
  r.state = :discharging
  r.trigger_at 2..5
  r.task do |percent|
    # notify takes an optional parameter with the urgency level in a symbol. Can be one of:
    # :low, :normal (default) or :critical
    notify("Battery level is critical! (#{percent}% left)\nGoing to suspend when it reaches 1%", :critical)
  end
end

BatteryRule.new(:suspend) do |r|
  r.state = :discharging
  r.trigger_at 0..1
  r.task do
    notify("Going to suspend to prevent data loss", :critical)
    # execute executes a given command
    execute("sleep 5 && i3lock && sudo pm-hibernate")
  end
end
