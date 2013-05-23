# Pacman sublet file
# Created with sur-0.2
configure :pacman do |s|
  s.icon = Subtlext::Icon.new( "pacman.xbm" )
  s.interval =   s.config[:interval]   || 3600
  s.separator =  s.config[:separator]  || " // "
  s.updatefile = s.config[:updatefile] || "#{ENV['HOME']}/.pacmanupdates"
  s.repositories = s.config[:repositories] || {"core" => "!:", "extra" => "e:", "community" => "c:"}
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
    f.each_line do |line|
      words = line.split("/")
      if words.any? && h.has_key?(words.first)
        h[words.first] += 1
      end
    end

    f.close

    counts = []
    self.repositories.each do |name, abbr|
      label = abbr || ""
      counts << (label + h[name].to_s)
    end
    self.data = self.icon + ' ' + counts.join(self.separator)
  end
end

on :run do |s|
  updates
end
#  vim: set ts=2 sw=2 tw=0 :
