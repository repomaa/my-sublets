module Battery

  class BatteryRule # {{{

    @@rules = {}

    def initialize name
      @name = name
      yield self
      if @trigger.nil?
        @trigger = 0..100
      end
      if @run_once.nil?
        @run_once = false
      end
      if @enabled.nil?
        @enabled = true
      end
      if @task.nil? or @state.nil?
        raise ArgumentError("task and state must be defined")
      end
      @@rules[name] = self
    end

    def self.load_rules path
      eval(IO.readlines(path).join("; "))
    end

    def run_once
      @run_once = true
    end

    def trigger_at value
      @trigger = value
    end

    def state
      @state
    end

    def state= state
      @state = state
    end

    def task &task
      @task = task
    end

    def disable!
      @enabled = false
    end

    def enable!
      @enabled = true
    end

    def enabled?
      @enabled
    end

    def self.enable_all &selection
      self.apply_to_all(lambda {|rule| rule.enable!}, &selection)
    end

    def self.disable_all &selection
      self.apply_to_all(lambda {|rule| rule.disable!}, &selection)
    end

    def self.apply_to_all a_proc, &selection
      @@rules.select {|name, rule| selection.call(rule, name)}.each do |name, rule|
        a_proc.call(rule)
      end
    end

    def self.trigger_all state, percentage
      @@state = state
      @@percentage = percentage
      @@rules.each do |rule_name, rule|
        rule.run_task if rule.should_trigger?
      end
    end

    def self.execute command
      Process.spawn command
    end

    def self.notify message, urgency=:normal
      command = "notify-send -u #{urgency} "
      command << shellescape(message)
      execute command
    end

    def should_trigger?
      enabled? && state == @@state && @trigger === @@percentage
    end

    def run_task
      if @run_once
        disable!
      end
      @task.call(@@percentage, @@rules)
    end

  def self.shellescape string
    # An empty argument will be skipped, so return empty quotes.
    return "''" if string.empty?

    string = string.dup

    # Process as a single byte sequence because not all shell
    # implementations are multibyte aware.
    string.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

    # A LF cannot be escaped with a backslash because a backslash + LF
    # combo is regarded as line continuation and simply ignored.
    string.gsub!(/\n/, "'\n'")

    return string
  end

  end # }}}

end
# Battery sublet file
# Created with sur-0.1
configure :battery do |s| # {{{
  s.interval = 60
  s.full     = 0
  s.color    = ""

  # Path
  s.now      = ""
  s.status   = ""

  # Notifications
  s.low_sent = false
  s.critical_sent = false

  # Icons
  s.icons = {
    :ac      => Subtlext::Icon.new("ac.xbm"),
    :full    => Subtlext::Icon.new("bat_full_02.xbm"),
    :low     => Subtlext::Icon.new("bat_low_02.xbm"),
    :empty   => Subtlext::Icon.new("bat_empty_02.xbm"),
    :unknown => Subtlext::Icon.new("ac.xbm")
  }

  # Options
  s.color_text = true  == s.config[:color_text]
  s.color_icon = false == s.config[:color_icon] ? false : true
  s.color_def  = Subtlext::Subtle.colors[:sublets_fg]

  # Collect colors
  if(s.config[:colors].is_a?(Hash))
    s.colors = {}

    s.config[:colors].each do |k, v|
      s.colors[k] = Subtlext::Color.new(v)
    end

    # Just sort once
    s.color_keys = s.colors.keys.sort.reverse
  end

  # Find battery slot and capacity
  begin
    path = s.config[:path] || Dir["/sys/class/power_supply/B*"].first
    now  = ""
    full = ""

    if(File.exist?(File.join(path, "charge_full")))
      full = "charge_full"
      now  = "charge_now"
    elsif(File.exist?(File.join(path, "energy_full")))
      full = "energy_full"
      now  = "energy_now"
    end

    # Assemble paths
    s.now    = File.join(path, now)
    s.status = File.join(path, "status")

    # Get full capacity
    s.full = IO.readlines(File.join(path, full)).first.to_i

  rescue => err
    puts err, err.backtrace
    raise "Could't find any battery"
  end

  rules_path = s.rules_path || "~/.config/subtle/battery_rules.rb"
  rules_path = File.expand_path(rules_path)

  Battery::BatteryRule.load_rules rules_path

end # }}}

on :run do |s| # {{{
  begin
    now     = IO.readlines(s.now).first.to_i
    state   = IO.readlines(s.status).first.chop
    percent = (now * 100 / s.full).to_i

    # Select color
    unless(s.colors.nil?)
      # Find start color from top
      s.color_keys.each do |k|
        break if(k < percent)
        s.color = s.colors[k] if(k >= percent)
      end
    end

    # Select icon for state
    icon = case state
      when "Charging"  then :ac
      when "Discharging"
        case percent
          when 67..100 then :full
          when 34..66  then :low
          when 0..33   then :empty
        end
      when "Full"      then :ac
      else                  :unknown
    end

    Battery::BatteryRule.trigger_all state.downcase.to_sym, percent

    s.data = "%s%s%s%d%%" % [
      s.color_icon ? s.color : s.color_def, s.icons[icon],
      s.color_text ? s.color : s.color_def, percent
    ]
  rescue => err # Sanitize to prevent unloading
    s.data = "subtle"
    p err
  end
end # }}}
