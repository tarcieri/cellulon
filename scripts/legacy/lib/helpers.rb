require 'open3'
require 'uri'
require 'fileutils'
require 'sdbm'

module Strobot
  module HookerHelpers
    # Display the following string when "Strobot: help hookname" is called
    def usage(string)
      if ARGV[0] == 'help'
        puts string
        exit 1
      end
    end
    
    # Obtain all args as a single string
    def input_string
      ARGV[0..-1].join(' ') if ARGV[0]
    end
    
    # Who invoked the hook
    def called_by
      ENV['CALLED_BY']
    end
    alias_method :who, :called_by

    # Play a sound
    def play(sound)
      case sound
      when 'live', 'tmyk', 'rimshot'
        puts "strobot_play: #{sound}"
      else
        sounds_dir = File.expand_path('../../sounds', __FILE__)
        mp3 = File.expand_path("#{sound}.mp3", sounds_dir)
        system "afplay #{mp3}" if File.exists?(mp3) and mp3["hooks/sounds"]
      end
    end

    # Paste a string to the channel
    def paste(string)
      # Strip color codes
      string.gsub!(/\033\[.*?m/, '')
    
      puts "strobot_paste: #{string.dump}"
    end

    def lock(name)
      dir = File.expand_path('../../tmp', __FILE__)
      FileUtils.mkdir_p(dir)

      File.open(File.join(dir, name.to_s), "w") do |file|
        file.flock(File::LOCK_EX)
        yield
      end
    end

    def db
      lock(:db) do
        dbm = SDBM.new('./tmp/local.db')
        yield dbm
        dbm.close
      end
    end

    # Execute a command and dump its results to the channel
    def sh(command, strip=true)
      result, _ = Open3.capture2e(command)
      result.strip! if strip
      paste result
    end
    
    # Say something on the teeve
    def say(*text)
      opts = text[-1].is_a?(Hash) ? text.pop : {}

      cmd = "say"
      if opts[:voice]
        if opts[:voice] =~ /[^\w ]/
          puts "Screw you hacker!"
          exit
        end
        cmd << " -v \"#{opts[:voice]}\""
      end

      lock(:say) do
        safe_pipe(cmd, text.join(' '))
      end
    end

    # Execute a given Strobot CLI command
    def strobot_cli(command, *args)
      Dir.chdir File.expand_path("../../..", __FILE__) do
        sh "bundle exec strobot #{command} #{args.join(' ')}"
      end
    end

    # Evaluate the given AppleScript string
    def run_applescript(script)
      lock(:applescript) do
        Open3.popen3("osascript") do |stdin, _|
          stdin << script
        end
      end
      nil
    end

    # 'ascript' is shorthand for AppleScript eval
    alias_method :ascript, :run_applescript

    # Open the given URL with Chrome on the TV
    def open_with_chrome(url)
      uri = URI.parse(url)
  
      unless uri.is_a? URI::HTTP
        puts "What kind of a fucking URL is this crap? #{url}"
        exit 1
      end

      ascript <<-EOD
        tell application "Google Chrome"
          open location "#{url}"
        end tell
      EOD
    end

    def control_characters(arr)
      output_head = []
      output = []
      output_tail = []

      arr.each do |char|
        if char == "{return}"
          output.push %{keystroke return}
        elsif char =~ /{\w+}/
          output_head.push "key down #{char}"
          output_tail.unshift "key up #{char}"
        else
          output.push %{keystroke #{char.inspect}}
        end
      end

      output_head + output + output_tail
    end

    def type(chars)
      sleep 1

      output = []

      chars.each do |char|
        if char == "{return}"
          output.push %{keystroke return}
        elsif char =~ /(-|{\w+})/
          output.concat control_characters(char.split("-"))
        else
          output.push %{keystroke #{char.inspect}}
        end

        output.push %{delay 0.5}
      end

      ascript <<-EOD
        tell application "Google Chrome"
          activate
            tell application "System Events"
              #{output.join("\n")}
            end tell
        end tell
      EOD
    end


    # Put Chrome in fullscreen mode
    def chrome_fullscreen
      ascript <<-EOD
          tell application "Google Chrome"
            activate
              tell application "System Events"
                  key down {command}
                  key down {shift}
                  keystroke "f"
                  key up {shift}
                  key up {command}
              end tell
          end tell
      EOD
    end

    def safe
      t = Thread.new do
        $SAFE = 4
        yield
      end
      t.join.value
    rescue Exception => e
      paste <<-ERROR
        #{e.class}: #{e.message}
        #{e.backtrace.join("\n")}
      ERROR
      exit
    end

    def safe_pipe(cmd, input)
      Open3.popen2(cmd) do |stdin, stdout|
        stdin << input
        stdin.close
        stdout.read
      end
    end

  end
end

include Strobot::HookerHelpers
