# Call Status Labels in the CallStatus model
# dial
# answer
# callout
# connected
# hungup


events.asterisk.manager_interface.each do |event|
  begin

    if event.name =~ /UserEvent/
      if event.headers["UserEvent"] == "NEWCALL"
        @call = Call.first(:unique_id.eql => event.headers["callid"])
        puts "-----NEWCALL-----"
        puts "Call ID: #{@call.id}"
        @call.asterisk_unique_id_1 = event.headers["uniqueid1"]
        @call.status = "answer"
        @call.save
      elsif event.headers["UserEvent"] == "CALLOUT"
        puts "-----CALLING OUT-----"
        puts "Call ID: #{@call.id}"
        @call.status = "callout"
        @call.save
      end
      puts event.name
      puts event.headers.inspect
    elsif event.name =~ /^Link/
        puts "-----LINKING CALLS-----"
        puts event.name
        puts event.headers.inspect        
        @call = Call.first(:asterisk_unique_id_1.eql => event.headers["Uniqueid1"])
        puts "Call ID: #{@call.id}"
        @call.status = "connected"
        @call.cancelled = false
        @call.save      
    elsif event.name =~ /Hangup/
      puts "-----HUNG UP-----"
      @call = Call.first(:asterisk_unique_id_1.eql => event.headers["Uniqueid"])
      if @call
        puts "Call ID: #{@call.id}"
        @call.status = "hungup"
        @call.completed = true
        @call.save
        puts "-----Processing audio-----"
        fork do
          system "lame #{SiteConfig.audio_dir}#{@call.unique_id}.wav #{SiteConfig.media_dir}audio/#{@call.unique_id}.mp3"
        end

      end
      puts event.name
      puts event.headers.inspect
    end
  rescue => err
    ahn_log.event_logger.info err
  end
end