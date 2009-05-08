require "iTunes.rb"
require "iTunes_debug_event_handler.rb"

it = ITunes.new
it.register(ITunesDebugEventHandler.new)

it.start_message_loop
