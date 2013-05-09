# Brightness sublet file
# Created with sur-0.2
configure :brightness do |s|
  s.interval = s.config[:interval] || 60
  s.path = s.config[:path] || "/sys/class/backlight/acpi_video0/"
  s.icon = Subtlext::Icon.new("light1.xbm")
end

helper do
    def update
        brightness = File.open(File.expand_path("brightness", self.path)).first.to_f
        max_brightness = File.open(File.expand_path("max_brightness", self.path)).first.to_f
        percent = brightness/max_brightness * 100
        percent = (percent.round 0).to_i
        percent_str = "#{percent}%"
        if percent < 10
            percent_str = "  #{percent}%"
        elsif percent < 100
            percent_str = " #{percent}%"
        end
        self.data = self.icon + percent_str
    end
end
on :run do |s|
    s.update
end

grab :BrightCtrl do |s, c|
    s.update
    s.render
end
