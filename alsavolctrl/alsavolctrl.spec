# -*- encoding: utf-8 -*-
# Alsavolctrl specification file
# Created with sur-0.2
Sur::Specification.new do |s|
  # Sublet information
  s.name        = "Alsavolctrl"
  s.version     = "0.1"
  s.tags        = [ "icon", "volume", "alsa" ]
  s.files       = [ "alsavolctrl.rb" ]
  s.icons       = [ "volume_on.xbm", "volume_off.xbm" ]

  # Sublet description
  s.description = "Displays alsa volume"
  s.notes       = <<NOTES
LONG DESCRIPTION
This sublet displays and optionally controls the volume of a given alsa device.
Depending on the mute state, alsavolctrl sets the icon accordingly.
Please set the desired device. (see config)
NOTES

  # Sublet authors
  s.authors     = [ "jokke" ]
  s.contact     = "mail@jreinert.com"
  s.date        = "Thu Jan 31 02:07 CET 2013"

  # Sublet config
  s.config = [
    {
      :name        => "device",
      :type        => "string",
      :description => "The alsa device which will be used",
      :def_value   => "'Master',0"
    },
    {
        :name           => "steps",
        :type           => "integer",
        :description    => "Amount of volume being in-/decreased on :VolUp and :VolDown",
        :def_value      => 4
    },
    {
        :name           => "auto_unmute",
        :type           => "boolean",
        :description    => "If true alsavolctrl automatically unmutes the device when either :VolUp or :VolDown is called",
        :def_value      => true
    }
  ]

  # Sublet grabs
  s.grabs = {
    :VolCtrl => "Updates the sublet (use this, if you want alsavolctrl only to display the volume",
    :VolUp => "Increases volume by amount specified in config and updates the sublet",
    :VolDown => "Decreases volume by amount specified in config and updates the sublet",
    :ToggleMute => "Mutes the device and updates the sublet"
  }

  # Sublet requirements
  # s.required_version = "0.9.2127"
  # s.add_dependency("subtle", "~> 0.1.2")
  s.add_dependency("alsa-utils", "any" )
end
