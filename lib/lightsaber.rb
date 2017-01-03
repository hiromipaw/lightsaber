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

    base_uri 'https://trac.torproject.org/projects/tor'

    def self.login
      page = self.get("/login")
      @@token = page.xpath("//input[@name='__FORM_TOKEN']")[0]['value']
      response = self.post("/login", self.login_options)
      if response.code == 303
        self.login_redirect(response)
      else
        return [response.code, response.message]
      end
    end

    def self.ticket(ticket)
      self.login if @@cookies.nil?

      response = self.get("/ticket/#{ticket}", self.request_options)
      if response.code == 200
        parsed_res = Nokogiri::HTML(response.body)
        t = {
          ticket: {
            ticket_id: self.parse_id(parsed_res.xpath("//a[@class='trac-id']")),
            date: self.parse_date(parsed_res.xpath("//div[@class='date']//p")),
            summary: parsed_res.xpath("//span[@class='summary']").text,
            properties: self.parse_properties(parsed_res.xpath("//table[@class='properties']//tr")),
            description: self.parse_description(parsed_res.xpath("//div[@class='description']")),
            changelog: self.parse_log(parsed_res.xpath("//div[@class='change']"))
          }
        }
      else
        return [response.code, response.message]
      end
    end

    private

    def self.parse_id(container)
      {
        id: container[0].text,
        href: base_uri + container[0].values[0]
      }
    end

    def self.parse_date(container)
      {
        created_at: container[0].text,
        updated_at: container[1].text
      }
    end

    def self.parse_properties(container)
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

    def self.parse_description(container)
      description = []
      container.children.each do |child|
        c = child.text.strip
        description << c unless c.empty?
      end
      return description.join
    end

    def self.parse_log(container)
      logs = []
      container.children.each do |child|
        c = child.text.strip
        logs << c unless c.empty?
      end
      return logs
    end

    def self.login_options
      {
        body: {
          user: @@config['USERNAME'],
          password: @@config['PASSWORD'],
          __FORM_TOKEN: @@token,
          referer: base_uri
        },
        headers: {
          Cookie: "trac_form_token=#{@@token}"
        },
        follow_redirects: false
      }
    end

    def self.request_options
      { body: {
          user: @@config['USERNAME'],
          password: @@config['PASSWORD'],
          __FORM_TOKEN: @@token,
          referer: base_uri
        },
        headers: {
          Cookie: "trac_form_token=#{@@token};#{@@cookies.split(';')[0]}",
          contentType: "application/json",
        }
      }
    end

    def self.login_redirect(response)
      @@cookies = response.headers['set-cookie']
      response = self.get(response.headers['location'])
      if response.code == 200
        puts Nokogiri::HTML(response.body).xpath("//h1[@style='color: green']").text()
      else
        return [response.code, response.message]
      end
    end
  end
end
