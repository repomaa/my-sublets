# Volume_perc specification file
# Created with sur-0.2.143
Sur::Specification.new do |s|
  # Sublet information
  s.name        = "Volume_perc"
  s.version     = "0.1"
  s.tags        = [ "Icon", "Ioctl", "Linux", "Config", "Grab" ]
  s.files       = [ "volume_perc.rb" ]
  s.icons       = [
    "icons/spkr_01.xbm",
    "icons/spkr_02.xbm"
  ]

  # Sublet authors
  s.authors     = [ "unexist", "jokke" ]
  s.contact     = "mail@jreinert.com"
  s.date        = "Thu Jan 01 16:22 CEST 2013"

  # Sublet description
  s.description = "Display and control the volume"
  s.notes       = <<NOTES
This sublet shows the volume of the default mixer device, this works
with ALSA and OSS sound systems.

Left click toggles mute, mouse wheel up and down changes the volume.

This version adds an option to show the volume in percent (see config)
NOTES

  # Sublet config
  s.config = [
    {
      :name        => "step",
      :type        => "integer",
      :description => "Volume increase/decrease steps",
      :def_value   => "5"
    },
    {
        :name           => "percent",
        :type           => "boolean",
        :description    => "Show volume in percent instead of the bar",
        :def_value      => true
    }
  ]

  # Sublet grabs
  s.grabs = {
    :VolumeRaise  => "Increase volume",
    :VolumeLower  => "Decrease volume",
    :VolumeToggle => "Toggle mute"
  }

  # Sublet requirements
  s.required_version = "0.9.2620"
end
