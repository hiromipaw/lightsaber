require "highline/import"
require "httparty"
require "json"
require "lightsaber/version"
require "lightsaber/cli"
require "nokogiri"
require "pp"
require "yaml"

module Lightsaber
  class HtmlParserIncluded < HTTParty::Parser
    def html
      Nokogiri::HTML(body)
    end
    def headers
      headers.to_json
    end
  end

  class Trac
    include HTTParty
    parser HtmlParserIncluded

    @@cookies = nil
    @@config = YAML.load_file('config/.cli.yml')

    self.base_uri 'https://trac.torproject.org/projects/tor'

    def login
      page = self.class.get("/login")
      @@token = page.xpath("//input[@name='__FORM_TOKEN']")[0]['value']
      response = self.class.post("/login", login_options)
      if response.code == 303
        login_redirect(response)
      else
        return [response.code, response.message]
      end
    end

    def ticket(ticket)
      login if @@cookies.nil?

      response = self.class.get("/ticket/#{ticket}", request_options)
      if response.code == 200
        parsed_res = Nokogiri::HTML(response.body)
        t = {
          ticket: {
            ticket_id: parse_id(parsed_res.xpath("//a[@class='trac-id']")),
            date: parse_date(parsed_res.xpath("//div[@class='date']//p")),
            summary: parsed_res.xpath("//span[@class='summary']").text,
            properties: parse_properties(parsed_res.xpath("//table[@class='properties']//tr")),
            description: parse_description(parsed_res.xpath("//div[@class='description']")),
            changelog: parse_log(parsed_res.xpath("//div[@class='change']"))
          }
        }
      else
        return [response.code, response.message]
      end
    end

    def tickets(options)
      login if @@cookies.nil?

      if options[:query]
        @response = self.class.get("/query?#{options[:query]}")
      else
        filter = options[:filter] || 1
        page = options[:page] || 1
        asc = options[:asc] || 1
        sort = options[:sort] || 'component'
        @response = self.class.get("/report/#{filter}?page=#{page}&asc=#{asc}&sort=#{sort}", request_options)
      end

      if @response.code == 200
        parsed_res = Nokogiri::HTML(@response.body)
        pp parse_filtered(parsed_res.xpath("//tr"))
      end
    end

    def reply_ticket(ticket)
      login if @@cookies.nil?

      page = self.class.get("/ticket/#{ticket}", request_options)
      @@token = page.xpath("//input[@name='__FORM_TOKEN']")[0]['value']

      summary = page.xpath("//span[@class='summary']").text
      description = page.xpath("//div[@class='searchable']//p").text
      type = page.xpath("//span[@class='trac-type']//a").text
      priority = page.xpath("//td[@headers='h_priority']//a").text
      component = page.xpath("//td[@headers='h_component']//a").text
      severity = page.xpath("//td[@headers='h_severity']//a").text
      milestone = page.xpath("//td[@headers='h_milestone']//a").text
      start_time = page.xpath("//input[@name='start_time']")[0]['value']
      view_time = page.xpath("//input[@name='view_time']")[0]['value']
      comment = ask "Type your comment:"
      replyto = ask "Type a reply-to user if any:"

      options = {
        body: {
          __FORM_TOKEN: @@token,
          field_reporter: @@config['USERNAME'],
          field_summary: summary,
          field_description: description,
          field_type: type,
          field_priority: priority,
          field_severity: severity,
          field_component: component,
          field_milestone: milestone,
          comment: comment,
          __EDITOR__1: "textarea",
          __EDITOR__2: "textarea",
          action: "leave",
          field_actualpoints: "",
          field_parent: "",
          field_points: "",
          field_reviewer: "",
          field_sponsor: "",
          field_owner: "<+default+>",
          spf_email: "",
          spfh_mail: "",
          replyto: replyto,
          start_time: start_time,
          view_time: view_time,
          submit: "Submit+changes"
        },
        headers: {
          Cookie: "trac_form_token=#{@@token};#{@@cookies.split(';')[0]}",
          contentType: "application/x-www-form-urlencoded",
        },
        follow_redirects: false
      }

      pp options

      response = self.class.post("/ticket/#{ticket}#trac-add-comment", options)
      if response.code == 303
        url = response.headers['location']
        response = self.class.get(url)
        if response.code == 200
          puts "Ticket updated: #{url}"
        else
          return [response.code, response.message]
        end
      else
        error = response.xpath("//div[@class='system-message']").text
        return [response.code, response.message, error]
      end
    end

    def create_ticket
      login if @@cookies.nil?

      page = self.class.get("/newticket", request_options)
      @@token = page.xpath("//input[@name='__FORM_TOKEN']")[0]['value']

      summary = ask "Input Summary:"
      reporter = @@config['USERNAME']
      description = ask "Input Description:"
      type = ask "Choose ticket Type between: defect, enhancement, task, project"
      priority = ask "Choose ticket Priority: Immediate, Very High, High, Medium, Low, Very Low"
      milestone = ask "Input Milestone:"
      component = ask "Input Component:"
      version = ask "Input Version:"
      severity = ask "Chose ticket Severity between: Normal, Blocker, Critical, Major, Minor, Trivial"
      keywords = ask "Input Keywords:"
      cc = ask "Input Cc list:"

      component = "- Select a component" if component.empty?

      options = {
        body: {
          __FORM_TOKEN: @@token,
          field_summary: summary,
          field_reporter: reporter,
          __EDITOR__1: "textarea",
          field_description: description,
          field_type: type,
          field_priority: priority,
          field_milestone: milestone,
          field_component: component,
          field_version: version,
          field_cc: cc,
          field_actualpoints: "",
          field_parent: "",
          field_points: "",
          field_reviewer: "",
          field_sponsor: "",
          field_owner: "<+default+>",
          spf_email: "",
          spfh_mail: "",
          submit: "Create+ticket"
        },
        headers: {
          Cookie: "trac_form_token=#{@@token};#{@@cookies.split(';')[0]}",
          contentType: "application/json",
        },
        follow_redirects: false
      }

      response = self.class.post("/newticket", options)
      if response.code == 303
        url = response.headers['location']
        response = self.class.get(url)
        if response.code == 200
          puts "Ticket created: #{url}"
        else
          return [response.code, response.message]
        end
      else
        error = response.xpath("//div[@class='system-message']").text
        return [response.code, response.message, error]
      end

    end

    private

    def parse_id(container)
      {
        id: container[0].text,
        href: self.class.base_uri + container[0].values[0]
      }
    end

    def parse_date(container)
      {
        created_at: container[0].text,
        updated_at: container[1].text
      }
    end

    def parse_properties(container)
      properties = []
      container.each do |elem|
        elem.children.each do |child|
          c = child.text.strip
          properties <<  c unless c.empty?
        end
      end

      properties = properties.chunk{|n| n}.map(&:first)
      properties.each_with_index do |property, index|
        if index+1 < properties.length
          if property.include? ':' and properties[index+1].include? ':'
            properties.insert(index+1," ")
          end
        elsif property.include? ':' and index+1 == properties.length
          properties << " "
        end
      end
      return Hash[*properties]
    end

    def parse_description(container)
      description = []
      container.children.each do |child|
        c = child.text.strip
        description << c.gsub(/\s+/, " ") unless c.empty?
      end
      return description.join
    end

    def parse_log(container)
      logs = []
      container.children.each do |child|
        c = child.text.strip
        logs << c.gsub(/\s+/, " ") unless c.empty?
      end
      return logs
    end

    def parse_filtered(container)
      tickets = []
      container.each do |child|
        tickets << {ticket: parse_row(child)}
      end
      return tickets
    end

    def parse_row(container)
      fields = {}
      container.children.each do |c|
        value = c.values.join.strip.gsub(/\s+/, " ")
        text = c.text.strip.gsub(/\s+/, " ")
        unless value.empty? and text.empty?
          fields["#{value}"] = text
        end
      end
      return fields
    end

    def login_options
      {
        body: {
          user: @@config['USERNAME'],
          password: @@config['PASSWORD'],
          __FORM_TOKEN: @@token,
          referer: self.class.base_uri
        },
        headers: {
          Cookie: "trac_form_token=#{@@token}"
        },
        follow_redirects: false
      }
    end

    def request_options
      { body: {
          user: @@config['USERNAME'],
          password: @@config['PASSWORD'],
          __FORM_TOKEN: @@token,
          referer: self.class.base_uri
        },
        headers: {
          Cookie: "trac_form_token=#{@@token};#{@@cookies.split(';')[0]}",
          contentType: "application/json",
        }
      }
    end

    def login_redirect(response)
      @@cookies = response.headers['set-cookie']
      response = self.class.get(response.headers['location'])
      if response.code == 200
        puts Nokogiri::HTML(response.body).xpath("//h1[@style='color: green']").text()
      else
        return [response.code, response.message]
      end
    end
  end
end
