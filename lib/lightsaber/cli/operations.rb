module Lightsaber
  module CLI
    class Operations < Thor
      desc "get_ticket --ticket <ticket number>", "This will get you the ticket you want"
      option :ticket
      def get_ticket
        puts "Fetching ticket: #{options[:ticket]}"
        trac = Trac.new
        response = trac.ticket(options[:ticket])
        puts response
      end

      desc "filter_tickets --filter <filter> [OPTIONS]",
           "This will fetch tickets and summary based on a filter."

      long_desc <<-FILTER_TICKETS
          Available filters are:

          {1} Active Tickets

          {2} Active Tickets by Version

          {3} Active Tickets by Milestone

          {4} Accepted, Active Tickets by Owner

          {5} Accepted, Active Tickets by Owner (Full Description)

          {6} All Tickets By Milestone (Including closed)

          {7} My Tickets (all)

          {8} Active Tickets, Mine first

          {10} Tor Bundles and Installation

          {12} Tor: Active Tickets by Milestone

          {14} Active Torbutton Tickets

          {15} My Reported Tickets (based on current user)

          {16} New Tickets

          {17} Open Defect Tickets

          {18} My Open Tickets (all open)

          {19} HTTPS Everywhere Tickets

          {20} Tor Company: Active Tickets

          {22} Newest 500 tickets

          {23} Tor tickets needing review

          {24} Archived Mixminion-* Tasks

          {27} Open TorBirdy Tickets

          {28} Open Nyx Tickets

          {29} TorFlow Tickets

          {30} Easy Tickets

          {31} Iteration Report: Closed Tickets

          {32} Iteration Report: Recently Opened Tickets

          {33} Iteration Report: Backlog

          {34} BridgeDB Tickets

          {35} GetTor Tickets

          {36} Weather Tickets

          {37} Torperf product backlog

          {38} Tor Browser

          {40} Tor tickets by milestone

          {42} My Active Tickets (owned by me or me on the Cc list)

          {43} Open Stem Tickets

          {44} Tickets for Tor Sysadmin Team

          {45} Tickets for the Website

          {46} Tor: Active Tickets

          {47} Tor: Tickets needing keywords

          {48} HTTPS-Everywhere Ruleset Bugs

          {49} HTTPS Everywhere: next stable FF release

          {50} HTTPS Everywhere: next Chromium release

          {52} Tickets for *.torproject.org services

          {54} Meek open tickets

          {55} BridgeDB tickets

          {56} 0.2.9 - release

          {57} Active Tickets by Components

          {58} Ooni: All non-closed tickets

          {59} OPERATION ALL TICKETS

          {61} Tor Core Team 2015 07 backlog

          {62} TorTeam 07 2015

          {63} SponsorU deliverables Y2 (029 release)

          {64} SponsorS deiverables Y2 (029 release)

          {65} Tickets Needing Triage: Core Tor

          {66} Tickets Needing Triage: Unspecified Component

          You can sort by:

          Ticket 	Summary 	Component 	Status 	Type 	Priority 	Milestone 	Version 	Keywords

          Results can be displayed in asc {1} or desc {0} order

          You can also pass your own query as per:
          "status=accepted&status=assigned&status=closed&status=needs_information"
      FILTER_TICKETS

      option :filter
      option :page
      option :sort
      option :asc
      option :query

      def filter_tickets
        puts "I can get you all the tickets. I will log you in first."
        trac = Trac.new
        response = trac.tickets(options)
        puts response
      end

      desc "create_ticket",
           "This will create a ticket."
      def create_ticket
        puts "So you want to create a ticket? I will log you in first."
        trac = Trac.new
        ticket = trac.create_ticket
        puts ticket
      end

      desc "create_ticket",
           "This will create a ticket."
      option :ticket
      def reply_ticket
        puts "So you want to reply to ticket #{options[:ticket]}? I will log you in first."
        trac = Trac.new
        ticket = trac.reply_ticket(options[:ticket])
        puts ticket
      end
    end
  end
end
