module Lightsaber
  module CLI
    class Operations < Thor
      desc "get_ticket <ticket number>", "This will get you the ticket you want"
      option :ticket
      def get_ticket
        puts "I can get you a ticket. I will log you in first."
        response = Trac.ticket(options[:ticket])
        pp response
      end
    end
  end
end
