# Pacman sublet file
# Created with sur-0.2
configure :pacman do |s|
  s.icon = Subtlext::Icon.new( "pacman.xbm" )
  s.dot = Subtlext::Icon.new( "dot.xbm" )
  s.bigdot = Subtlext::Icon.new( "bigdot.xbm" )
  s.interval =   s.config[:interval]   || 3600
  s.separator =  s.config[:separator]  || " "
  s.updatefile = s.config[:updatefile] || "#{ENV['HOME']}/.pacmanupdates"
  s.repositories = s.config[:repositories] || {"core" => nil, "extra" => nil, "community" => nil}
  s.serious = true unless s.config[:serious] == false
  s.color_def = Subtlext::Subtle.colors[:sublets_fg]
  s.sep_color_def = Subtlext::Subtle.colors[:separator_fg]
  s.zeroes = true unless s.config[:zeroes] == false
  s.colors = {}
  if(s.config[:colors].is_a?(Hash))
    s.config[:colors].each do |k, v|
      s.colors[k] = Subtlext::Color.new(v)
    end
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

    # Count occurences of "core", "extra" and "community" in details
    packages = []
    f.each_line do |line|
      words = line.split("/")
      if words.any? && h.has_key?(words.first)
        unless packages.include? words[1]
          h[words[0]] += 1
          packages << words[1]
        end
      end
    end

    f.close

    color = self.colors["separator"] || self.sep_color_def
    sep = color + self.separator
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
          (h[name]/10).times { count << color << self.bigdot }
          (h[name]%10).times { count << color << self.dot }
          counts << count
        end
      end
    end
    self.data = self.icon + ' ' + counts.join(sep)
  end
end

on :run do |s|
  updates
end
#  vim: set ts=2 sw=2 tw=0 :
