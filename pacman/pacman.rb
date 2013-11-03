# Pacman sublet file
# Created with sur-0.2
configure :pacman do |s|
  s.icon = Subtlext::Icon.new( "pacman.xbm" )
  s.dot = Subtlext::Icon.new( "dot.xbm" )
  s.bigdot = Subtlext::Icon.new( "bigdot.xbm" )
  s.fleeing_ghost = Subtlext::Icon.new( "fleeing_ghost.xbm" )
  s.interval =   s.config[:interval]   || 3600
  s.serious = true unless s.config[:serious] == false
  if s.serious
    s.separator =  s.config[:separator]  || " / "
  else
    s.separator = s.config[:separator] || :ghost
  end
  s.updatefile = s.config[:updatefile] || "#{ENV['HOME']}/.pacmanupdates"
  s.repositories = s.config[:repositories] || {"core" => nil, "extra" => nil, "community" => nil}
  s.color_def = Subtlext::Subtle.colors[:sublets_fg]
  s.sep_color_def = Subtlext::Subtle.colors[:separator_fg]
  s.zeroes = true unless s.config[:zeroes] == false
  s.colors = {}
  if(s.config[:colors].is_a?(Hash))
    s.config[:colors].each do |k, v|
      if v.is_a? Array
        s.colors[k] = v.map {|c| Subtlext::Color.new(c)}
      else
        s.colors[k] = Subtlext::Color.new(v)
      end
    end
  end
  if s.separator == :ghost
    s.separator = Subtlext::Icon.new( "ghost.xbm" )
  end
end

helper do |s|
  def updates
    # Open file
    f = File.open( self.updatefile, "r" )
    h = Hash.new

    # Fill hash, just in case there are no updates
    self.repositories.each do |name,abbr|
      h[name] = 0
    end

    kernel_update = false
    # Count occurences of "core", "extra" and "community" in details
    packages = []
    f.each_line do |line|
      words = line.split("/")
      if words.any? && h.has_key?(words.first)
        unless packages.include? words[1]
          h[words[0]] += 1
          packages << words[1]
          kernel_update = true if words[1].match(/^linux\s+/)
        end
      end
    end

    f.close

    color = self.colors["separator"] || self.sep_color_def
    sep = []
    if color.is_a? Array
      color.each {|c| sep << (c + self.separator)}
    else
      sep << (color + self.separator)
    end
    counts = []
    if serious
      self.repositories.each do |name, abbr|
        if (h[name] != 0 || self.zeroes)
          label = abbr || ""
          counts << (label + h[name].to_s)
        end
      end
    else
      self.repositories.each do |name, abbr|
        if h[name] > 0
          count = ""
          color = self.colors[name] || self.color_def
          if name == 'core' && kernel_update
            count << Subtlext::Color.new("#00F") << self.fleeing_ghost
            ((h[name] - 1)/10).times { count << color << self.bigdot }
            ((h[name] - 1)%10).times { count << color << self.dot }
          else
            (h[name]/10).times { count << color << self.bigdot }
            (h[name]%10).times { count << color << self.dot }
          end
          counts << count
        end
      end
    end
    icon_color = self.colors["pacman"] || ""
    format_data = icon_color + self.icon
    counts.each_with_index do |count, index|
      format_data += count
      if (index + 1) < counts.size
        format_data += sep[index%sep.size]
      end
    end
    self.data = format_data
  end
end

on :run do |s|
  updates
end
#  vim: set ts=2 sw=2 tw=0 :
