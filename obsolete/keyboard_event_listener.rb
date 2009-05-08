class KeyboardEventListener
  def initialize(mappings = {})
    @quit = false
    @mappings = mappings
  end

  def loop
    while !@quit
      # http://www.ruby-forum.com/topic/123327
      key = (Win32API.new("crtdll", "_getch", [], "L").Call).chr

      if @mappings[key]
        @mappings[key].call(nil)
      else
        puts "Warning: no listener defined for key #{key}"
      end
    end
  end

  def quit
    @quit = true
  end
end