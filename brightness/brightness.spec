# -*- encoding: utf-8 -*-
# Brightness specification file
# Created with sur-0.2
Sur::Specification.new do |s|
  # Sublet information
  s.name        = "Brightness"
  s.version     = "0.1"
  s.tags        = [ ]
  s.files       = [ "brightness.rb" ]
  s.icons       = [ "light1.xbm" ]

  # Sublet description
  s.description = "Displays current screen brightness"
  s.notes       = <<NOTES
LONG DESCRIPTION
This sublet displays the current screen brightness setting in percent.
Please set the path to the directory containing the brightness and
max_brightness files accordingly. (see config)
You can add a grab to your subtle.rb to update this sublet on keypress.
XF86MonBrightnessUp and XF86MonBrightnessDown for example. (see grabs)
NOTES

  # Sublet authors
  s.authors     = [ "jokke" ]
  s.contact     = "mail@jreinert.com"
  s.date        = "Wed Jan 30 15:29 CET 2013"

  # Sublet config
  s.config = [
    {
      :name        => "interval",
      :type        => "integer",
      :description => "Update interval in seconds",
      :def_value   => "60"
    },
    {
        :name           =>  "path",
        :type           =>  "string",
        :description    =>  "Path to directory containing brightness and max_brightness",
        :def_value      =>  "/sys/class/backlight/acpi_video0"
    }
  ]

  # Sublet grabs
  s.grabs = {
    :BrightCtrl => "Updates the brightness sublet"
  }

  # Sublet requirements
  # s.required_version = "0.9.2127"
  # s.add_dependency("subtle", "~> 0.1.2")
end
