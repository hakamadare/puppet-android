# == Class: android::params
#
# Defines some sensible default parameters.
#
# === Authors
#
# Etienne Pelletier <epelletier@maestrodev.com>
#
# === Copyright
#
# Copyright 2012 MaestroDev, unless otherwise noted.
#
class android::params {

  $version    = '22.3'
  $proxy_host = undef
  $proxy_port = undef
  $installdir = '/usr/local/android'
  
  case $::kernel {
    'Linux': {
      $user       = 'root'
      $group      = 'root'


      # make sure we have $::lsbmajdistrelease
      validate_re($::lsbmajdistrelease, '^\d+$', 'The $lsbmajdistrelease fact value is not an integer.')

      case $::osfamily {
        'Debian': {
          $base_libs = ['libstdc++6', 'libgcc1', 'zlib1g', 'libncurses5']
          $32bit_libs = suffix($base_libs, ':i386')
          $arch_libs = suffix($base_libs, $::architecture)
          case $::operatingsystem {
            'Ubuntu': {
              if ($::lsbmajdistrelease < 11) {
                # multiarch requires natty or better
                $sdk_32bit_libs = []
              }
              elsif ($::lsbmajdistrelease < 14) {
                # natty through trusty
                $sdk_32bit_libs = $32bit_libs
              }
              else {
                # trusty and up
                $sdk_32bit_libs = ['libc6-i386', 'lib32stdc++6', 'lib32gcc1', 'lib32ncurses5', 'lib32z1']
              }
            }
            'Debian': {
              if ($::lsbmajdistrelease < 7) {
                # multiarch requires wheezy or better
                $sdk_32bit_libs = []
              }
              else {
                # wheezy and up
                $sdk_32bit_libs = $32bit_libs
              }
            }
            default: {
              fail("Only Debian and Ubuntu are supported, not '$::operatingsystem'.")
            }
          }
        }
        'RedHat','Amazon': {
          # http://fedoraproject.org/wiki/HOWTO_Setup_Android_Development#32_bit_packages
          $base_libs = ['glibc', 'glibc-devel', 'libstdc++', 'zlib-devel', 'ncurses-devel']
          $32bit_libs = suffix(['glibc', 'glibc-devel', 'libstdc++', 'zlib-devel', 'ncurses-devel'], '.i386')
          $arch_libs = suffix(['glibc', 'glibc-devel', 'libstdc++', 'zlib-devel', 'ncurses-devel'], $::architecture)
          $sdk_32bit_libs = $32bit_libs
        }
        default: {
          fail("Unsupported Linux distribution: ${::osfamily}")
        }
      }
    }
    'Darwin': {
      $user       = 'root'
      $group      = 'admin'
    }
    default: {
      fail("Unsupported Kernel: ${::kernel} operatingsystem: ${::operatingsystem}")
    }
  }
}
