
import escape from assert require 'Dager.cmd.init'
import execute from assert require 'Dager.utils.execute'
import popen from io
import gmatch, match, sub from string

-- Test if <ls> is availble
error "commands ls and stat aren't available" unless execute("which ls >/dev/null 2>&1") and execute("which stat >/dev/null 2>&1")

{
  dir: (path) ->
    [file for file in popen("ls -1 #{escape path}")\lines!]

  mkdir: (path) ->
    error "Mkdir #{path} failed" unless execute "mkdir #{escape path}"

  attributes: (path) ->
    fd = popen "stat -c '%d %i %A %h %u %g %s %b %t %T %X %Y %Z' #{escape path}"
    stat = [part for part in gmatch (fd\read '*a'), "%S+"]
    fd\close!

    fd = popen "stat -f -c '%S' #{escape path}"
    blksize = match (fd\read '*a'), '%S+'
    fd\close!

    {
      dev:          tonumber stat[1]
      ino:          tonumber stat[2]
      nlink:        tonumber stat[4]
      uid:          tonumber stat[5]
      gid:          tonumber stat[6]
      size:         tonumber stat[7]
      blocks:       tonumber stat[8]
      blksize:      tonumber blksize
      access:       tonumber stat[11]
      modification: tonumber stat[12]
      change:       tonumber stat[13]


      permissions: do
        sub stat[3], 2

      mode: do
        switch sub stat[3], 1, 1
          when '-' then 'file'
          when 'd' then 'directory'
          when 'l' then 'link'
          when 's' then 'socket'
          when 'p' then 'named pipe'
          when 'c' then 'char device'
          when 'b' then 'block device'
          else          'other'

      rdev: do
        (tonumber stat[9]) * 256 + (tonumber stat[10])

    }

}
