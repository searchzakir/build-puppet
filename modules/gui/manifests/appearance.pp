# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class gui::appearance {
    include dirs::usr::local::bin
    include users::root

    case $::operatingsystem {
        Darwin: {
            if (!$puppetizing) {
                exec {
                    "set-background-image" :
                        command => "/bin/bash /usr/local/bin/changebackground.sh",
                        unless => "/usr/bin/defaults read com.apple.desktop Background | egrep 'Solid Aqua Blue.png'",
                        notify => Exec["restart-Dock"] ;
                    "restart-Dock" :
                        command => "/usr/bin/killall Dock",
                        refreshonly => true;
                }
                file {
                    "/usr/local/bin/changebackground.sh" :
                        source => "puppet:///modules/gui/changebackground.sh",
                        owner => "$users::root::username",
                        group => "$users::root::group",
                        mode => 0755,
                        notify => Exec["set-background-image"] ;
                }
                if ($::macosx_productversion_major == "10.10") {
                    osxutils::defaults {
                        "${username}-enable-showscrollbars":
                            domain => "-g",
                            key => "AppleShowScrollBars",
                            value => "Always";
                    }
                }
            }
        }
        Ubuntu: {
            include packages::libglib20_bin

            file {
                "/usr/share/glib-2.0/schemas/99_gsettings.gschema.override":
                    notify => Exec['update-gsettings'],
                    source => "puppet:///modules/gui/gsettings.gschema.override";
            }
            exec {
                "update-gsettings":
                    command => "/usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas",
                    require => Class['packages::libglib20_bin'],
                    refreshonly => true;
            }
        }
        default: {
            fail("Don't know how to set up GUI appearance on $::operatingsystem")
        }
    }
}
