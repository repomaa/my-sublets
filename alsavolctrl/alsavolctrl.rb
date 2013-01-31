# Alsavol sublet file
# Created with sur-0.2
configure :alsavol do |s|
  s.interval = s.config[:interval] || 60
  s.device = s.config[:device] || "'Master',0"
  s.steps = s.config[:steps] || 4
  s.auto_unmute = s.config[:auto_unmute] || true
  if s.auto_unmute
      s.on = " on "
  else
      s.on = " "
  end
  s.icon_on = Subtlext::Icon.new("volume_on.xbm")
  s.icon_off = Subtlext::Icon.new("volume_off.xbm")
end

helper do
    def update command = "amixer sget #{self.device}"
        alsa = `#{command}`
        perc = (alsa[/\[(\d{1,3})%\]/, 1]).to_i
        mute = alsa[/\[(on|off)\]/, 1]
        if mute == "on"
            data = self.icon_on
        else
            data = self.icon_off
        end
        if perc < 10
            data += " "
        end
        if perc < 100
            data += " "
        end
        data += "#{perc}%"
        self.data = data
    end
end

on :run do |s|
  s.update 
end

grab :VolCtrl do |s, c|
    s.update
    s.render
end
grab :VolUp do |s, c|
    s.update "amixer sset #{s.device} #{s.steps}+"
    s.render
end
grab :VolDown do |s, c|
    s.update "amixer sset #{s.device} #{s.steps}-"
    s.render
end
grab :ToggleMute do |s, c|
    s.update "amixer sset #{s.device} toggle"
    s.render
end
