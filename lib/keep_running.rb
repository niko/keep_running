require 'fileutils'
require 'pony'

class KeepRunning
  class << self
    attr_accessor :runner_location
    
    def load_runner(runner)
      load @runner_location = runner
    end
    
    def run(&block)
      runner = new
      runner.instance_eval &block
      runner.run
    end
  end
  
  def pidfile(p)            ; @pidfile = p            ; end
  def email(e)              ; @email_opts = e         ; end
  def restart_threshold(t)  ; @restart_threshold = t  ; end
  def restart_delay(d)      ; @restart_delay = d      ; end
  def process(p)
    @process = File.expand_path(File.join(File.dirname(self.class.runner_location), p))
  end
  
  def run
    write_pidfile
    ARGV.shift
    
    output = nil
    loop do
      output = spawn { start_process }              # load the given script
      send_mail subject(@process), output           # send the email
      throttle_restart                              # don't restart too fast
    end
  end
  
  private
    
    def start_process
      if File.extname(@process) == '.rb'
        load @process
      else
        puts 'only spawning of ruby processes supported'
      end
    end
    
    def add_exit_hook(pid)
      at_exit do
        Process.kill 'QUIT', pid rescue nil         # ensure the child exits
        sleep 1                                     # give it some time
        Process.kill 'KILL', pid rescue nil         # really ensure the child exits
      end
    end
    
    def send_mail(subject, body)
      Pony.mail @email_opts.update(:subject => subject(@process), :body => body)
    end
    
    def write_pidfile
      File.open(@pidfile, 'w'){|file| file << Process.pid }
      at_exit{ FileUtils.rm @pidfile rescue nil }
    end
    
    def spawn
      readme, writeme = IO.pipe                     # open an pipe for the child to write in, the parent to read
      pid = fork{ |variable|                        # fork the process
        $stdout.reopen writeme                      # reopen the child end of the pipe
        $stderr.reopen writeme                      # reopen the child end of the pipe
        readme.close                                # close the parent end of the pipe in the child
        yield                                       # YIELD the given block
      }
      writeme.close                                 # close the child end of the pipe in the parent
      puts "forked as PID #{pid}"
      
      add_exit_hook pid
      
      output = ''
      readme.each{ |line| puts line ; output << line }  # collect the childs stdout
      
      Process.waitpid pid, 0                        # wait for the child to exit
      return output
    end
    
    def throttle_restart
      if @last_exit && Time.now - @last_exit < @restart_threshold
        puts "Last restart was less than #{@restart_threshold} seconds ago: #{@last_exit}."
        puts "Sleeping some #{@restart_delay} seconds..."
        sleep @restart_delay
        puts "Let's try again."
      end
      @last_exit = Time.now
    end
    
    def subject(script)
      "#{script} ended (PID #{Process.pid} on #{`hostname`.strip})"
    end
  
end
