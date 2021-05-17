require "seastyle_crawler/version"
require "seastyle_crawler/manager"
require "seastyle_crawler/command/ssreserve"
require "yaml"
require "optparse"

module SeastyleCrawler
  class Error < StandardError; end
  class Main
    def run()

      opts = OptionParser.new
      config_file = "./seastyle_crawler.yaml"
      opts.on("-c", "--config path") {|v| config_file = v }
      opts.parse!(ARGV)

      if config_file
        configdata = File::open(config_file).read
      else
        configdata = <<~YAML_EOT
        ---
        date_strategy: weekend
        boat_type: 1
        marina_cd: ""
        target_boats:
        - "SR-X"
        site: ''
        print_reserve_status: 2
        debug: true
YAML_EOT
      end

      config = YAML.load(configdata)
      if config["debug"]
        print "Debugging...\n"
      end

      ssr = SeastyleCrawler::Ssreserve.new(config["date_strategy"], config["boat_type"], config["marina_cd"], 
        config["target_boats"], config["site"], config["reserve_status"], config["debug"])
      ssr.run

      if config["debug"]
        print "End.\n"
      end
    end
  end
end
